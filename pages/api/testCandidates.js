// pages/api/testCandidates.js
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY, // Loaded from .env.local
});

// ✅ Default candidates (used if no POST body provided)
const defaultCandidates = [
  { number: "4206010", description: "Kantoorbenodigdheden kantoorkosten" },
  { number: "4206160", description: "Communicatie" },
  { number: "8090100", description: "Algemene beheerskosten" },
  { number: "4206115", description: "Kosten software abonnementen" },
  { number: "4215010", description: "Algemene kosten andere kosten" },
  { number: "4206070", description: "Contributies en abonnementen kantoorkosten" },
];

export default async function handler(req, res) {
  try {
    // Accept POST with invoice text + candidates
    const { invoiceText, candidates } = req.body || {};

    const text = invoiceText || "KPN factuur: internet en telefonie voor kantoor";
    const list = candidates?.length ? candidates : defaultCandidates;

    // Ask OpenAI to pick probabilities
    const response = await client.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: "Je bent een boekhoudassistent. Kies de meest geschikte grootboekrekening en geef waarschijnlijkheden.",
        },
        {
          role: "user",
          content: `
Factuur: "${text}"

Beschikbare grootboekrekeningen:
${list.map((c) => `- ${c.number}: ${c.description}`).join("\n")}

Geef een JSON-object terug met de accountnummers als keys.
Voor elke entry geef:
- "account_name": de omschrijving
- "probability": een waarde tussen 0 en 1 (de kans dat dit de juiste rekening is).
          `,
        },
      ],
      temperature: 0,
    });

    // Safe parsing in case model wraps JSON
    let raw = response.choices[0].message.content.trim();
    if (raw.startsWith("```")) {
      raw = raw.replace(/```json\n?/, "").replace(/```$/, "").trim();
    }
    const parsed = JSON.parse(raw);

    // Return debug + result
    res.status(200).json({
      invoice: text,
      candidates: list,
      result: parsed,
    });
  } catch (err) {
    console.error("Error in /api/testCandidates:", err);
    res.status(500).json({ error: err.message });
  }
}