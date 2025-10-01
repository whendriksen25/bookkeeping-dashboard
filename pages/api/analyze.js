// pages/api/analyze.js
import fs from "fs";
import path from "path";
import os from "os";
import OpenAI from "openai";
import { Pool } from "pg";
import crypto from "crypto";

const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const pool =
  process.env.DATABASE_URL
    ? new Pool({ connectionString: process.env.DATABASE_URL })
    : new Pool({
        host: process.env.PGHOST || "localhost",
        port: Number(process.env.PGPORT || 5432),
        user: process.env.PGUSER || "jean",
        password: process.env.PGPASSWORD || "",
        database: process.env.PGDATABASE || "bookkeeping",
      });

const INVOICE_PROMPT = `
Je bent een Nederlandse boekhoudassistent. Analyseer de factuur of kassabon en retourneer ALLEEN JSON in exact onderstaand formaat.

{
  "factuurdetails": {
    "afzender": {
      "naam":"",
      "adres_volledig":"",
      "straat":"",
      "huisnummer":"",
      "postcode":"",
      "plaats":"",
      "regio":"",
      "provincie_of_staat":"",
      "land":"",
      "kvk_nummer":"",
      "btw_nummer":"",
      "email":"",
      "telefoon":""
    },
    "ontvanger": {
      "naam":"",
      "adres_volledig":"",
      "straat":"",
      "huisnummer":"",
      "postcode":"",
      "plaats":"",
      "regio":"",
      "provincie_of_staat":"",
      "land":"",
      "kvk_nummer":"",
      "btw_nummer":"",
      "email":"",
      "telefoon":""
    },
    "factuurnummer":"",
    "factuurdatum":"",
    "vervaldatum":"",
    "betaalstatus":"betaald|onbetaald|onbekend",
    "betaling_methode":"",
    "kassier":"",
    "kassa_terminal":"",
    "aankoop_tijd":"",
    "betaal_tijd":"",
    "openingstijden":"",
    "totaal":{
      "valuta":"",
      "totaal_excl_btw":"",
      "btw":"",
      "totaal_incl_btw":""
    },
    "regels":[
      {
        "omschrijving":"",
        "productcode":"",
        "aantal":"",
        "eenheid":"",
        "prijs_per_eenheid_excl":"",
        "totaal_excl":"",
        "btw_percentage":"",
        "btw_bedrag":"",
        "totaal_incl":""
      }
    ],
    "opmerkingen":""
  },
  "herberekende_totalen": {
    "totaal_excl":"",
    "totaal_btw":"",
    "totaal_incl":"",
    "komt_overeen_met_ticket": true,
    "verschil": ""
  },
  "boekhoudcategorie_suggesties":[
    {"naam":"","uitleg":"","kans":0.0},
    {"naam":"","uitleg":"","kans":0.0},
    {"naam":"","uitleg":"","kans":0.0},
    {"naam":"","uitleg":"","kans":0.0},
    {"naam":"","uitleg":"","kans":0.0}
  ],
  "alternatieve_zoekwoorden":["",""],
  "ruwe_tekst":""
}

Belangrijk:
- Vul alle waarden zo volledig mogelijk in; gebruik numerieke waardes zonder valuta-teken maar behoud decimalen met punt (bijv. 12.34).
- Bepaal "productcode" vanuit barcode, artikelnummer of SKU indien zichtbaar; anders laat leeg.
- Noteer "kassier" en "kassa_terminal" indien vermeld.
- Geef "openingstijden" als tekst indien ze op de bon staan.
- Splits adressen in straat, huisnummer, postcode, plaats, regio/provincie/staat en land waar mogelijk; laat onbekende velden leeg. Vul daarnaast "adres_volledig" met de tekst exact zoals deze op de bon staat.
- Leg vast wanneer mogelijk: "aankoop_tijd" (bon tijdstip) en "betaal_tijd" (indien afzonderlijk vermeld). Laat leeg als onbekend.
- "herberekende_totalen" moeten worden afgeleid uit de regels. Zet "komt_overeen_met_ticket" op false en vul "verschil" in wanneer de herberekende totalen afwijken of de ticket-bedragen niet leesbaar zijn.
- "btw_bedrag" per regel is de totale btw voor die regel.
- Retourneer alleen JSON, geen extra tekst of markdown.
`;

// ---------- Helpers ----------
function stripCodeFence(s) {
  if (!s || typeof s !== "string") return s;
  const fence = s.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fence) return fence[1].trim();
  return s.trim();
}

function safeParseJSON(s) {
  if (!s) return null;
  try {
    return JSON.parse(s);
  } catch {
    try {
      const inner = stripCodeFence(s);
      return JSON.parse(inner);
    } catch {
      return null;
    }
  }
}

function summarizeForAI(structured) {
  if (!structured || !structured.factuurdetails) return "";
  const f = structured.factuurdetails;
  const a = f.afzender || {};
  const b = f.ontvanger || {};
  const t = f.totaal || {};
  const regels = Array.isArray(f.regels)
    ? f.regels
        .map((r) => `${r.omschrijving ?? ""} x${r.aantal ?? ""} = ${r.totaal_incl ?? r.totaal_excl ?? r.bedrag ?? ""}`)
        .join("; ")
    : "";

  const formatAddress = (entity) => {
    if (!entity) return "";
    if (entity.adres_volledig) return entity.adres_volledig;
    const parts = [
      entity.straat,
      entity.huisnummer,
      entity.postcode,
      entity.plaats,
      entity.provincie_of_staat || entity.regio,
      entity.land,
    ].filter(Boolean);
    return parts.join(" ");
  };

  return [
    `Afzender: ${a.naam ?? ""} ${formatAddress(a)} (KvK: ${a.kvk_nummer ?? ""}, BTW: ${a.btw_nummer ?? ""}, Email: ${a.email ?? ""}, Tel: ${a.telefoon ?? ""})`,
    `Ontvanger: ${b.naam ?? ""} ${formatAddress(b)} (KvK: ${b.kvk_nummer ?? ""}, BTW: ${b.btw_nummer ?? ""}, Email: ${b.email ?? ""}, Tel: ${b.telefoon ?? ""})`,
    `Factuur: #${f.factuurnummer ?? ""} d.d. ${f.factuurdatum ?? ""} vervaldatum ${f.vervaldatum ?? ""} aankoop_tijd ${f.aankoop_tijd ?? ""} betaal_tijd ${f.betaal_tijd ?? ""}`,
    `Totaal excl: ${t.totaal_excl_btw ?? ""}, BTW: ${t.btw ?? ""}, Totaal incl: ${t.totaal_incl_btw ?? ""}`,
    `Regels: ${regels}`,
  ].join("\n");
}

function pickKeywordsFromAI(structured) {
  const list = [];
  if (structured?.boekhoudcategorie_suggesties?.length) {
    for (const s of structured.boekhoudcategorie_suggesties) {
      if (s?.naam) list.push(s.naam);
    }
  }
  if (list.length === 0 && structured?.alternatieve_zoekwoorden?.length) {
    for (const k of structured.alternatieve_zoekwoorden) {
      if (k) list.push(k);
    }
  }
  return [...new Set(list.map((x) => String(x).toLowerCase()))].slice(0, 8);
}

async function convertHeicViaCloudinary(sourceUrl) {
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
  const apiKey = process.env.CLOUDINARY_API_KEY;
  const apiSecret = process.env.CLOUDINARY_API_SECRET;
  if (!cloudName || !apiKey || !apiSecret) {
    throw new Error("Cloudinary credentials missing (CLOUDINARY_CLOUD_NAME/KEY/SECRET)");
  }

  const endpoint = `https://api.cloudinary.com/v1_1/${cloudName}/image/upload`;
  const timestamp = Math.floor(Date.now() / 1000);
  const publicId = `heic_${Date.now()}`;
  const folder = process.env.CLOUDINARY_FOLDER;

  const signatureParams = [];
  if (folder) signatureParams.push(`folder=${folder}`);
  signatureParams.push(`format=jpg`);
  signatureParams.push(`public_id=${publicId}`);
  signatureParams.push(`timestamp=${timestamp}`);
  const signatureBase = signatureParams.sort().join("&") + apiSecret;

  const signature = crypto
    .createHash("sha1")
    .update(signatureBase)
    .digest("hex");

  const params = new URLSearchParams({
    file: sourceUrl,
    format: "jpg",
    resource_type: "image",
    public_id: publicId,
    timestamp: String(timestamp),
    signature,
    api_key: apiKey,
  });
  if (folder) params.append("folder", folder);

  const resp = await fetch(endpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: params.toString(),
  });

  const payload = await resp.json();
  if (!resp.ok) {
    const message = payload?.error?.message || `Cloudinary conversion failed (${resp.status})`;
    throw new Error(message);
  }

  if (!payload?.secure_url) {
    throw new Error("Cloudinary response missing secure_url");
  }
  return payload.secure_url;
}

async function fetchCoaLeafCandidates(keywords) {
  if (!keywords?.length) return [];

  const sql = `
    WITH kw AS (
      SELECT unnest($1::text[]) AS kw
    ),
    scored AS (
      SELECT
        c.code, c.number, c.description, c.parent_code, c.level,
        MAX(similarity(c.description, k.kw)) AS best_score
      FROM coa c
      JOIN kw k ON c.description % k.kw
      WHERE c.is_active
        AND c.number IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM coa ch WHERE ch.parent_code = c.code)
      GROUP BY c.code, c.number, c.description, c.parent_code, c.level
    )
    SELECT number, description, level, best_score
    FROM scored
    ORDER BY best_score DESC, number
    LIMIT 20;
  `;

  const { rows } = await pool.query(sql, [keywords]);
  return rows.map((r) => ({
    number: r.number,
    description: r.description,
    level: r.level,
    score: Number(r.best_score ?? 0),
  }));
}

async function rankDbCandidatesWithAI(structured, candidates) {
  if (!candidates?.length) return {};

  const invoiceSummary = summarizeForAI(structured);

  const instructions = `
Je krijgt een factuursamenvatting en een lijst met COA (RGS 3.7) grootboekrekeningen (nummer + omschrijving).
Kies de beste rekening voor het boeken van deze factuur, en geef ook kansen voor de overige opties.
Antwoord ALLEEN met JSON in dit formaat (geen markdown):

{
  "keuze_nummer": "<beste_nummer>",
  "toelichting": "<korte motivatie>",
  "scores": {
    "<nummer>": { "account_name": "<omschrijving>", "probability": 0.0 },
    ...
  }
}

- "probability" ∈ [0,1] en de som ≈ 1.0
- Gebruik ALLE kandidaten in "scores".
`;

  const list = candidates.map((c) => `- ${c.number}: ${c.description}`).join("\n");

  const message = `
Factuur (samenvatting):
${invoiceSummary}

Kandidaten (DB):
${list}

JSON:
`;

  const resp = await client.chat.completions.create({
    model: "gpt-4o-mini",
    temperature: 0,
    messages: [
      { role: "system", content: "Je bent een nauwkeurige Nederlandse boekhoudassistent." },
      { role: "user", content: instructions + "\n" + message },
    ],
  });

  const content = resp.choices?.[0]?.message?.content || "";
  const parsed = safeParseJSON(content);
  if (!parsed?.scores) {
    const top = candidates[0];
    const rest = candidates.slice(1);
    const scores = {};
    let remainder = 1.0;
    scores[top.number] = { account_name: top.description, probability: 0.6 };
    remainder -= 0.6;
    const p = remainder / Math.max(1, rest.length);
    for (const c of rest) scores[c.number] = { account_name: c.description, probability: p };
    return {
      keuze_nummer: top.number,
      toelichting: "Fallback ranking (AI parse failed).",
      scores,
    };
  }
  return parsed;
}

function isPdf(filename) {
  return /.pdf$/i.test(filename || "");
}

async function extractWithFile(localPath) {
  const upload = await client.files.create({
    file: fs.createReadStream(localPath),
    purpose: "assistants",
  });

  const resp = await client.responses.create({
    model: "gpt-4o-mini",
    input: [
      {
        role: "user",
        content: [
          { type: "input_text", text: INVOICE_PROMPT },
          { type: "input_file", file_id: upload.id },
        ],
      },
    ],
    temperature: 0,
  });

  const blocks = resp.output?.[0]?.content || [];
  const text = blocks
    .filter((b) => b.type === "output_text")
    .map((b) => b.text)
    .join("\n")
    .trim();
  return { rawText: text, structured: safeParseJSON(text) };
}

async function extractWithImageUrl(imageUrl) {
  const resp = await client.responses.create({
    model: "gpt-4o",
    input: [
      {
        role: "user",
        content: [
          { type: "input_text", text: INVOICE_PROMPT },
          { type: "input_image", image_url: imageUrl },
        ],
      },
    ],
    temperature: 0,
  });

  const blocks = resp.output?.[0]?.content || [];
  const text = blocks
    .filter((b) => b.type === "output_text")
    .map((b) => b.text)
    .join("\n")
    .trim();
  return { rawText: text, structured: safeParseJSON(text) };
}

// ---------- API handler ----------
export default async function handler(req, res) {
  let cleanupTmpDir = null;

  try {
    if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });

    const { file } = req.body || {};
    const storage = file?.storage || "local";
    const filename = file?.filename;
    const fileUrl = file?.url;

    if (!filename) return res.status(400).json({ error: "filename missing" });

    let localPath = "";
    if (storage === "blob" && fileUrl) {
      const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "invoice-"));
      const ext = path.extname(filename || "") || path.extname(new URL(fileUrl).pathname || "");
      const tmpPath = path.join(tmpDir, `${Date.now()}${ext || ""}`);
      const resp = await fetch(fileUrl);
      if (!resp.ok) throw new Error(`Failed to download blob (${resp.status})`);
      const arrayBuffer = await resp.arrayBuffer();
      await fs.promises.writeFile(tmpPath, Buffer.from(arrayBuffer));
      localPath = tmpPath;
      cleanupTmpDir = async () => {
        try {
          await fs.promises.rm(tmpDir, { recursive: true, force: true });
        } catch (cleanupErr) {
          console.warn("[analyze] Failed to cleanup tmp dir", cleanupErr);
        }
      };
    } else {
      localPath = path.join(process.cwd(), "public", "uploads", filename);
      if (!fs.existsSync(localPath)) {
        return res.status(404).json({ error: "file not found" });
      }
    }

    const ext = path.extname(filename || "").toLowerCase();
    const useFileUpload = isPdf(filename) || storage !== "blob";
    let imageUrlForAI = fileUrl;

    if (!useFileUpload && imageUrlForAI) {
      const isHeic = [".heic", ".heif", ".heics"].includes(ext);
      if (isHeic) {
        imageUrlForAI = await convertHeicViaCloudinary(imageUrlForAI);
      }
    }

    let extraction;
    if (useFileUpload) {
      extraction = await extractWithFile(localPath);
    } else if (imageUrlForAI) {
      extraction = await extractWithImageUrl(imageUrlForAI);
    } else {
      throw new Error("No accessible URL for image analysis");
    }

    const { rawText, structured } = extraction;

    const aiKeywords = pickKeywordsFromAI(structured);
    const fallbackKw = ["telecommunicatie", "internet", "abonnement", "hosting", "kantoorkosten"];
    const keywords = (aiKeywords.length ? aiKeywords : fallbackKw).map((s) => s.toLowerCase());

    const candidates = await fetchCoaLeafCandidates(keywords);
    const aiRanking = await rankDbCandidatesWithAI(structured, candidates);

    res.status(200).json({
      invoice_text: structured?.ruwe_tekst || rawText || "",
      factuurdetails: structured?.factuurdetails || {},
      ai_first_suggestions: structured?.boekhoudcategorie_suggesties || [],
      ai_keywords_used: keywords,
      db_candidates: candidates,
      ai_ranking: aiRanking,
      structured,
    });
  } catch (err) {
    console.error("❌ Error in analyze:", err);
    res.status(500).json({ error: err.message });
  } finally {
    if (cleanupTmpDir) {
      await cleanupTmpDir();
    }
  }
}
