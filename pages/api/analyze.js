// pages/api/analyze.js
import fs from "fs";
import path from "path";
import os from "os";
import OpenAI from "openai";
import { Pool } from "pg";

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
Je bent een Nederlandse boekhoudassistent. Lees de aangeleverde factuur of kassabon en geef ALLE onderstaande velden exact in JSON terug (en niets anders):

{
  "factuurdetails": {
    "afzender": {"naam":"","adres":"","kvk_nummer":"","btw_nummer":"","email":"","telefoon":""},
    "ontvanger": {"naam":"","adres":"","kvk_nummer":"","btw_nummer":"","email":"","telefoon":""},
    "factuurnummer":"",
    "factuurdatum":"",
    "vervaldatum":"",
    "betaalstatus":"betaald|onbetaald|onbekend",
    "totaal":{"valuta":"","totaal_excl_btw":"","btw":"","totaal_incl_btw":""},
    "regels":[
      {"omschrijving":"","aantal":"","eenheid":"","bedrag_excl":"","btw_perc":"","bedrag_incl":""}
    ],
    "opmerkingen":""
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

Regels:
- Vul velden zo compleet mogelijk.
- "ruwe_tekst" bevat de volledige relevante tekst uit de factuur/bon (zoveel mogelijk).
- "boekhoudcategorie_suggesties": noem concrete Nederlandse grootboekcategorie-benamingen (zoals "Telefoonkosten", "Internetkosten", "Abonnementsgelden", "Kantoorkosten"), met korte uitleg en kans 0..1.
- Antwoord ALLEEN met JSON (geen uitleg, geen markdown, geen backticks).
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
        .map((r) => `${r.omschrijving ?? ""} x${r.aantal ?? ""} = ${r.bedrag ?? ""}`)
        .join("; ")
    : "";
  return [
    `Afzender: ${a.naam ?? ""} (KvK: ${a.kvk_nummer ?? ""}, BTW: ${a.btw_nummer ?? ""}, Email: ${
      a.email ?? ""
    }, Tel: ${a.telefoon ?? ""})`,
    `Ontvanger: ${b.naam ?? ""} (KvK: ${b.kvk_nummer ?? ""}, BTW: ${b.btw_nummer ?? ""}, Email: ${
      b.email ?? ""
    }, Tel: ${b.telefoon ?? ""})`,
    `Factuur: #${f.factuurnummer ?? ""} d.d. ${f.factuurdatum ?? ""} vervaldatum ${f.vervaldatum ?? ""}`,
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

    const useFileUpload = isPdf(filename) || storage !== "blob";

    let extraction;
    if (useFileUpload) {
      extraction = await extractWithFile(localPath);
    } else if (fileUrl) {
      extraction = await extractWithImageUrl(fileUrl);
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
