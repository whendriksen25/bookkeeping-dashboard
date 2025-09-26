// pages/api/analyze.js
import fs from "fs";
import path from "path";
import os from "os";
import OpenAI from "openai";
import { Pool } from "pg";
import { PDFDocument } from "pdf-lib";
import sharp from "sharp";
import { Image } from "@napi-rs/image";

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

async function convertHeicToJpeg(filePath) {
  const fileBuffer = await fs.promises.readFile(filePath);
  const image = await Image.decode(fileBuffer);
  try {
    const jpegData = await image.encode({ format: "jpeg", quality: 90 });
    return Buffer.isBuffer(jpegData) ? jpegData : Buffer.from(jpegData);
  } finally {
    if (typeof image.free === "function") image.free();
  }
}

async function ensurePdf(filePath) {
  const ext = path.extname(filePath || "").toLowerCase();
  if (ext === ".pdf") {
    return { pdfPath: filePath, cleanup: null };
  }

  let buffer;
  let format;

  if (ext === ".png") {
    buffer = await sharp(filePath).withMetadata().png().toBuffer();
    format = "png";
  } else if (ext === ".jpg" || ext === ".jpeg") {
    buffer = await sharp(filePath).withMetadata().jpeg().toBuffer();
    format = "jpg";
  } else if (ext === ".heic" || ext === ".heif" || ext === ".heics") {
    buffer = await convertHeicToJpeg(filePath);
    format = "jpg";
  } else {
    throw new Error(`Unsupported file type: ${ext || "unknown"}`);
  }

  const pdfDoc = await PDFDocument.create();
  const embedded =
    format === "png" ? await pdfDoc.embedPng(buffer) : await pdfDoc.embedJpg(buffer);

  const page = pdfDoc.addPage([embedded.width, embedded.height]);
  page.drawImage(embedded, {
    x: 0,
    y: 0,
    width: embedded.width,
    height: embedded.height,
  });

  const pdfBytes = await pdfDoc.save();
  const tmpPdfPath = path.join(os.tmpdir(), `invoice-${Date.now()}.pdf`);
  await fs.promises.writeFile(tmpPdfPath, pdfBytes);

  return {
    pdfPath: tmpPdfPath,
    cleanup: async () => {
      try {
        await fs.promises.unlink(tmpPdfPath);
      } catch (err) {
        console.warn("[analyze] Failed to cleanup temp pdf", err?.message);
      }
    },
  };
}

async function extractInvoiceWithAI(localPath) {
  const { pdfPath, cleanup } = await ensurePdf(localPath);
  try {
    const file = await client.files.create({
      file: fs.createReadStream(pdfPath),
      purpose: "assistants",
    });

    const prompt = `
Je bent een Nederlandse boekhoudassistent. Lees de bijgevoegde factuur (PDF/beeld) en geef ALLE onderstaande velden exact in JSON terug (en niets anders):

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
- "ruwe_tekst" bevat de volledige relevante tekst uit de factuur (zoveel mogelijk).
- "boekhoudcategorie_suggesties": noem concrete Nederlandse grootboekcategorie-benamingen (bijv. "Telefoonkosten", "Internetkosten", "Abonnementsgelden", "Kantoorkosten"), met korte uitleg en kans 0..1.
- Antwoord met ALLEEN JSON (geen uitleg, geen markdown, geen backticks).
`;

    const resp = await client.responses.create({
      model: "gpt-4o-mini",
      input: [
        {
          role: "user",
          content: [
            { type: "input_text", text: prompt },
            { type: "input_file", file_id: file.id },
          ],
        },
      ],
      temperature: 0,
    });

    let text = "";
    try {
      const blocks = resp.output?.[0]?.content || [];
      const textBlocks = blocks.filter((b) => b.type === "output_text");
      text = textBlocks.map((b) => b.text).join("\n").trim();
    } catch {
      text = resp.choices?.[0]?.message?.content || "";
    }

    const parsed = safeParseJSON(text);
    return { rawText: text, structured: parsed };
  } finally {
    await cleanup?.();
  }
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

// ---------- API handler ----------
export default async function handler(req, res) {
  let cleanupTmpFile = null;

  try {
    console.log("[analyze] Incoming request", {
      method: req.method,
      headers: req.headers["content-type"],
    });
    if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });

    const { file } = req.body || {};
    const storage = file?.storage || "local";
    const filename = file?.filename;
    const fileUrl = file?.url;

    if (!filename && !fileUrl) {
      return res.status(400).json({ error: "filename or url missing" });
    }

    let localPath = "";

    if (storage === "blob") {
      if (!fileUrl) return res.status(400).json({ error: "blob url missing" });
      const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "invoice-"));
      const ext =
        path.extname(filename || "") || path.extname(new URL(fileUrl).pathname || "");
      const tmpPath = path.join(tmpDir, `${Date.now()}${ext || ""}`);
      console.log("[analyze] Downloading blob to temp file", { fileUrl, tmpPath });
      const resp = await fetch(fileUrl);
      if (!resp.ok) {
        throw new Error(`Failed to download blob (${resp.status})`);
      }
      const arrayBuffer = await resp.arrayBuffer();
      await fs.promises.writeFile(tmpPath, Buffer.from(arrayBuffer));
      localPath = tmpPath;
      cleanupTmpFile = async () => {
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

    console.log("📥 Analyze triggered for file:", { filename, storage });

    const { rawText, structured } = await extractInvoiceWithAI(localPath);
    console.log("[analyze] Extraction finished", {
      hasStructured: Boolean(structured),
      hasRawText: Boolean(rawText),
      suggestions: structured?.boekhoudcategorie_suggesties?.length || 0,
    });

    const aiKeywords = pickKeywordsFromAI(structured);
    const fallbackKw = ["telecommunicatie", "internet", "abonnement", "hosting", "kantoorkosten"];
    const keywords = (aiKeywords.length ? aiKeywords : fallbackKw).map((s) => s.toLowerCase());
    console.log("[analyze] Keywords chosen", {
      aiSuggested: aiKeywords,
      usingFallback: aiKeywords.length === 0,
      final: keywords,
    });

    const candidates = await fetchCoaLeafCandidates(keywords);
    console.log("[analyze] DB candidates fetched", {
      keywordCount: keywords.length,
      candidateCount: candidates.length,
    });

    const aiRanking = await rankDbCandidatesWithAI(structured, candidates);
    console.log("[analyze] AI ranking ready", {
      keuze: aiRanking?.keuze_nummer,
      scoreKeys: aiRanking?.scores ? Object.keys(aiRanking.scores).length : 0,
    });

    res.status(200).json({
      invoice_text: structured?.ruwe_tekst || rawText || "",
      factuurdetails: structured?.factuurdetails || {},
      ai_first_suggestions: structured?.boekhoudcategorie_suggesties || [],
      ai_keywords_used: keywords,
      db_candidates: candidates,
      ai_ranking: aiRanking,
    });
  } catch (err) {
    console.error("❌ Error in analyze:", err);
    res.status(500).json({ error: err.message });
  } finally {
    if (cleanupTmpFile) {
      await cleanupTmpFile();
    }
  }
}
