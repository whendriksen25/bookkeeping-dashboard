// pages/api/analyze.js
import OpenAI from "openai";
import path from "path";
import fs from "fs";
import { Pool } from "pg";

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

// ---- DB pool (DATABASE_URL or discrete PG* env vars) ----
let pool;
function getPool() {
  if (pool) return pool;
  if (process.env.DATABASE_URL) {
    pool = new Pool({ connectionString: process.env.DATABASE_URL, ssl: getSSL() });
  } else {
    pool = new Pool({
      host: process.env.PGHOST || "localhost",
      port: Number(process.env.PGPORT || 5432),
      user: process.env.PGUSER,
      password: process.env.PGPASSWORD,
      database: process.env.PGDATABASE || "bookkeeping",
      ssl: getSSL(),
    });
  }
  return pool;
}
function getSSL() {
  // Allow local dev (no SSL) and hosted DBs that require SSL
  if (process.env.PGSSL === "require") return { rejectUnauthorized: false };
  return false;
}

// ---- Helpers ----
function stripCodeFenceToJSON(text) {
  if (!text || typeof text !== "string") return null;
  // remove ```json ... ``` or ``` ... ```
  const cleaned = text
    .trim()
    .replace(/^```(?:json)?/i, "")
    .replace(/```$/i, "")
    .trim();
  try {
    return JSON.parse(cleaned);
  } catch {
    return null;
  }
}

function safeNum(v) {
  if (v == null) return v;
  if (typeof v === "number") return v;
  if (typeof v === "string") {
    // normalize Dutch/European decimals like "36,42"
    const s = v.replace(/\./g, "").replace(",", ".");
    const n = Number(s.replace(/[^\d.-]/g, ""));
    return Number.isFinite(n) ? n : v;
  }
  return v;
}

function cleanAnalysisShape(obj) {
  if (!obj || typeof obj !== "object") return { factuurdetails: {}, boekhoudcategorie_suggesties: [] };

  const factuurdetails = obj.factuurdetails || {};
  const totaal = factuurdetails.totaal || {};

  const cleaned = {
    factuurdetails: {
      afzender: {
        naam: factuurdetails.afzender?.naam || "",
        adres: factuurdetails.afzender?.adres || "",
        kvk_nummer: factuurdetails.afzender?.kvk_nummer || "",
        btw_nummer: factuurdetails.afzender?.btw_nummer || "",
        email: factuurdetails.afzender?.email || "",
        telefoon: factuurdetails.afzender?.telefoon || "",
      },
      ontvanger: {
        naam: factuurdetails.ontvanger?.naam || "",
        adres: factuurdetails.ontvanger?.adres || "",
        klantnummer: factuurdetails.ontvanger?.klantnummer || "",
        debiteurnummer: factuurdetails.ontvanger?.debiteurnummer || "",
        email: factuurdetails.ontvanger?.email || "",
        telefoon: factuurdetails.ontvanger?.telefoon || "",
      },
      factuurnummer: factuurdetails.factuurnummer || "",
      factuurdatum: factuurdetails.factuurdatum || "",
      totaal: {
        totaal_excl_btw: safeNum(totaal.totaal_excl_btw),
        btw: safeNum(totaal.btw),
        totaal_incl_btw: safeNum(totaal.totaal_incl_btw),
        valuta: totaal.valuta || "",
      },
      regels: Array.isArray(factuurdetails.regels)
        ? factuurdetails.regels.map((r) => ({
            omschrijving: r.omschrijving || "",
            aantal: safeNum(r.aantal ?? 1),
            bedrag: safeNum(r.bedrag ?? 0),
            btw_tarief: r.btw_tarief ?? null,
          }))
        : [],
      omschrijving: factuurdetails.omschrijving || "",
    },
    boekhoudcategorie_suggesties: Array.isArray(obj.boekhoudcategorie_suggesties)
      ? obj.boekhoudcategorie_suggesties
          .map((c) => ({
            categorie: c.categorie || c.category || "",
            uitleg: c.uitleg || c.explanation || "",
            kans: typeof c.kans === "number" ? c.kans : (typeof c.probability === "number" ? Math.round(c.probability * 100) : null),
          }))
          .filter((c) => c.categorie)
      : [],
  };

  return cleaned;
}

function buildKeywordList(analysis) {
  // Use the categories from OpenAI; fall back to a conservative set
  const cats =
    analysis?.boekhoudcategorie_suggesties?.map((c) => String(c.categorie || "").trim()).filter(Boolean) || [];
  const fallback = ["Telecommunicatie", "Abonnementskosten", "Kantoorbenodigdheden", "Algemene bedrijfskosten"];
  // de-dup, keep order
  const seen = new Set();
  const list = [...cats, ...fallback].filter((w) => {
    const key = w.toLowerCase();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
  return list;
}

// ---- COA candidate query (top 20 leaf accounts with full path) ----
const COA_SQL = `
WITH RECURSIVE
kw AS ( SELECT unnest($1::text[]) AS kw ),
scored AS (
  SELECT
    c.code, c.number, c.description, c.parent_code, c.level,
    k.kw AS keyword,
    similarity(c.description, k.kw) AS score
  FROM coa c
  JOIN kw k ON c.description % k.kw
  WHERE c.is_active
    AND c.number IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM coa ch WHERE ch.parent_code = c.code) -- only leaves
),
ranked AS (
  SELECT code, number, description, parent_code, level, keyword, score,
         ROW_NUMBER() OVER (
           PARTITION BY code, number, description, parent_code, level
           ORDER BY score DESC
         ) AS rn
  FROM scored
),
best AS (
  SELECT code, number, description, parent_code, level,
         score AS best_score,
         keyword AS best_keyword
  FROM ranked
  WHERE rn = 1
),
chain AS (
  SELECT
    b.code AS anchor_code,
    b.number AS anchor_number,
    b.description AS anchor_description,
    b.best_score, b.best_keyword,
    b.code, b.parent_code, b.level,
    ARRAY[b.description]::text[] AS path_arr
  FROM best b
  UNION ALL
  SELECT
    ch.anchor_code,
    ch.anchor_number,
    ch.anchor_description,
    ch.best_score, ch.best_keyword,
    p.code, p.parent_code, p.level,
    ARRAY_PREPEND(p.description, ch.path_arr)
  FROM coa p
  JOIN chain ch ON ch.parent_code = p.code
),
to_root AS (
  SELECT DISTINCT ON (anchor_code)
    anchor_code, anchor_number, anchor_description,
    best_score, best_keyword, path_arr
  FROM chain
  WHERE parent_code IS NULL
  ORDER BY anchor_code, level DESC
),
paths AS (
  SELECT
    anchor_code AS code,
    anchor_number AS number,
    anchor_description AS description,
    best_score, best_keyword,
    string_agg(elem, ' → ' ORDER BY ord) AS full_path
  FROM to_root,
       LATERAL (
         SELECT elem, ord,
                lag(elem) OVER (ORDER BY ord) AS prev_elem
         FROM unnest(path_arr) WITH ORDINALITY AS t(elem, ord)
       ) u
  WHERE prev_elem IS NULL OR elem <> prev_elem
  GROUP BY anchor_code, anchor_number, anchor_description, best_score, best_keyword
)
SELECT
  number,
  description,
  ROUND(best_score::numeric, 5) AS best_score,
  best_keyword,
  full_path
FROM paths
ORDER BY best_score DESC, number
LIMIT 20;
`;

// ---- Final re-rank with OpenAI given the 20 DB candidates ----
async function rerankWithOpenAI({ invoiceSummary, candidates }) {
  if (!candidates?.length) return null;

  const list = candidates
    .map((c, i) => `${i + 1}. ${c.number} — ${c.description} (pad: ${c.full_path || c.description})`)
    .join("\n");

  const prompt = `
Je bent een Nederlandse boekhoud-assistent. Je krijgt een factuursamenvatting en 20 candidate grootboekrekeningen uit de RGS/COA (leaf-accounts).
Kies de beste en geef voor alle opties een kans (0..1) die samen ongeveer 1 vormen. 
Format: strikt JSON met alleen:
{
  "best": {"number": "xxxx", "name": "Omschrijving", "probability": 0.00},
  "distribution": {
    "<nummer>": {"name": "Omschrijving", "probability": 0.00},
    ...
  }
}

FACTUUR:
${invoiceSummary}

CANDIDATES:
${list}
`;

  const resp = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    temperature: 0,
    messages: [
      { role: "system", content: "Je bent een precieze Nederlandse boekhoud-assistent. Geef alleen geldig JSON terug." },
      { role: "user", content: prompt },
    ],
  });

  const raw = resp.choices?.[0]?.message?.content || "";
  console.log("🧠 OpenAI re-rank raw:", raw);
  const parsed = stripCodeFenceToJSON(raw) || (() => { try { return JSON.parse(raw); } catch { return null; } })();

  if (!parsed || typeof parsed !== "object") {
    console.warn("⚠️ Re-rank JSON parse failed. Returning null.");
    return null;
  }
  return parsed;
}

// ---- Main handler ----
export default async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });

  const pool = getPool();

  try {
    const { filename } = req.body;
    console.log("📥 Analyze request:", filename);

    // --- 1) Upload file -> extract structured analysis
    const filePath = path.join(process.cwd(), "public", "uploads", filename);
    const file = await openai.files.create({
      file: fs.createReadStream(filePath),
      purpose: "assistants",
    });
    console.log("✅ File uploaded to OpenAI:", file.id);

    const oa = await openai.responses.create({
      model: "gpt-4o-mini",
      input: [
        {
          role: "system",
          content:
            `Je bent een Nederlandse boekhoud-assistent.\n` +
            `Lees de factuur en geef STRIKT geldige JSON terug met:\n` +
            `{\n` +
            `  "factuurdetails": {\n` +
            `    "afzender": { "naam":"", "adres":"", "kvk_nummer":"", "btw_nummer":"", "email":"", "telefoon":"" },\n` +
            `    "ontvanger": { "naam":"", "adres":"", "klantnummer":"", "debiteurnummer":"", "email":"", "telefoon":"" },\n` +
            `    "factuurnummer":"", "factuurdatum":"",\n` +
            `    "totaal": { "totaal_excl_btw":0, "btw":0, "totaal_incl_btw":0, "valuta":"" },\n` +
            `    "regels": [ { "omschrijving":"", "aantal":1, "bedrag":0, "btw_tarief":null } ]\n` +
            `  },\n` +
            `  "boekhoudcategorie_suggesties": [\n` +
            `    { "categorie":"", "uitleg":"", "kans": 0 }\n` +
            `  ]\n` +
            `}\n` +
            `Geen tekst buiten het JSON!`
        },
        {
          role: "user",
          content: [{ type: "input_file", file_id: file.id }],
        },
      ],
      temperature: 0,
    });

    // OpenAI Responses format: prefer response.output_text if present, else drill fields
    let rawText = oa.output_text || "";
    if (!rawText && oa.output?.[0]?.content?.[0]?.text) {
      rawText = oa.output[0].content[0].text;
    }
    if (!rawText) {
      // fallback to any string content found
      const blob = JSON.stringify(oa);
      console.warn("⚠️ No output_text, dumping first 500 chars of response JSON");
      rawText = blob.slice(0, 500);
    }
    console.log("🔎 Raw OpenAI text (first 500):", rawText.slice(0, 500));

    const parsedFromFence = stripCodeFenceToJSON(rawText);
    const analysis = cleanAnalysisShape(parsedFromFence || {});
    console.log("📊 Parsed analysis:", analysis);

    // Build a human-ish invoice summary for re-rank later
    const fd = analysis.factuurdetails || {};
    const vend = fd.afzender?.naam || "";
    const rec = fd.ontvanger?.naam || "";
    const lines = (fd.regels || [])
      .slice(0, 6)
      .map((r) => `- ${r.omschrijving} (${r.aantal} × ${r.bedrag})`)
      .join("\n");
    const invoiceSummary =
      `Afzender: ${vend}\nOntvanger: ${rec}\nNummer: ${fd.factuurnummer || ""}\n` +
      `Datum: ${fd.factuurdatum || ""}\nTotaal: ${fd.totaal?.totaal_incl_btw ?? ""}\n` +
      `Regels:\n${lines}`;

    // --- 2) COA lookup (top 20 leafs, with full path)
    const keywords = buildKeywordList(analysis);
    console.log("🔍 Keywords for COA lookup:", keywords);

    // Ensure pg_trgm exists (for % / similarity)
    try {
      await pool.query("CREATE EXTENSION IF NOT EXISTS pg_trgm;");
    } catch (e) {
      console.warn("⚠️ Could not ensure pg_trgm extension (may already exist).", e?.message);
    }

    let candidates = [];
    try {
      const { rows } = await pool.query(COA_SQL, [keywords]);
      candidates = rows.map((r) => ({
        number: r.number,
        description: r.description,
        best_score: Number(r.best_score),
        best_keyword: r.best_keyword,
        full_path: r.full_path,
      }));
      console.log("📑 COA candidates:", candidates);
    } catch (dbErr) {
      console.error("❌ COA query error:", dbErr);
    }

    // --- 3) Re-rank with OpenAI (probabilities)
    let reranked = null;
    try {
      reranked = await rerankWithOpenAI({ invoiceSummary, candidates });
      console.log("🏆 Re-ranked result:", reranked);
    } catch (rankErr) {
      console.warn("⚠️ Rerank failed, continuing with DB scores only.", rankErr?.message);
    }

    return res.status(200).json({
      analysis,
      candidates,          // from DB (best_score ~ similarity to keyword)
      reranked,            // from OpenAI (probabilities)
      invoice_summary: invoiceSummary,
    });
  } catch (error) {
    console.error("❌ ANALYZE error:", error);
    return res.status(500).json({ error: error.message });
  }
}