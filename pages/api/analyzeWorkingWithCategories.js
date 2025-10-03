// pages/api/analyze.js
import OpenAI from "openai";
import path from "path";
import fs from "fs";

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const { filename } = req.body;
    console.log("📥 Analyze request:", filename);

    const filePath = path.join(process.cwd(), "public", "uploads", filename);

    // Upload the file to OpenAI
    const file = await openai.files.create({
      file: fs.createReadStream(filePath),
      purpose: "assistants",
    });

    console.log("✅ File uploaded to OpenAI:", file.id);

    // Ask OpenAI to extract invoice details, category & keywords
    const response = await openai.responses.create({
      model: "gpt-4o-mini",
      input: [
        {
          role: "system",
          content: `Je bent een Nederlandse boekhoud-assistent. 
Lees de factuur zorgvuldig en geef een JSON terug met:
1. Alle factuurdetails (afzender, ontvanger, factuurnummer, datum, regels, totalen, etc.).
2. Een boekhoudcategorie (bijvoorbeeld "Autokosten", "Kantoorartikelen", "Telecommunicatie", "Verzekeringen").
3. Een lijst van minimaal 5 alternatieve zoekwoorden of benamingen in het Nederlands die in de praktijk voorkomen voor deze categorie, zodat een COA-query kan werken.
⚠️ Geef géén grootboeknummers terug. Alleen categorie en zoekwoorden.`
        },
        {
          role: "user",
          content: [
            {
              type: "input_file",   // ✅ Corrected back to working type
              file_id: file.id,
            },
          ],
        },
      ],
      temperature: 0.2,
    });

    console.log("✅ OpenAI responded");

    let analysis;
    try {
      analysis = JSON.parse(response.output[0].content[0].text);
    } catch (err) {
      console.warn("⚠️ Could not parse JSON, returning raw text", err);
      analysis = { raw: response.output_text };
    }

    return res.status(200).json({ analysis });
  } catch (error) {
    console.error("❌ ANALYZE error:", error);
    return res.status(500).json({ error: error.message });
  }
}
