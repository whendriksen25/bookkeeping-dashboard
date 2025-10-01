// pages/api/profiles/suggest.js
import OpenAI from "openai";

const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const { name, description, website, type = "company" } = req.body || {};
    if (!name) return res.status(400).json({ error: "name is required" });

    const profileType = type === "personal" ? "persoonlijk" : "bedrijf";
    const descText = description?.trim() ? description.trim() : "(geen aanvullende beschrijving)";
    const websiteText = website?.trim() ? website.trim() : "(geen website opgegeven)";

    const prompt = `
Je krijgt basisinformatie over een ${profileType} binnen een boekhoudcontext.
Schrijf een korte samenvatting (3-5 zinnen) waarin je beschrijft:
- Wat de organisatie/persoon doet of aanbiedt.
- Typische klanten / activiteiten / inkomstenstromen (waar mogelijk afleiden uit beschrijving of naam).
- Verwachte kosten- of inkoopcategorieën waarvoor bonnetjes/facturen zullen worden geüpload.
Geef alleen tekst, geen opsommingen of bullets. Gebruik maximum ~120 woorden.

Naam: ${name}
Website: ${websiteText}
Beschrijving: ${descText}
`;

    const resp = await client.chat.completions.create({
      model: "gpt-4o-mini",
      temperature: 0.3,
      messages: [
        { role: "system", content: "Je bent een Nederlandse boekhoudassistent." },
        { role: "user", content: prompt },
      ],
    });

    const summary = resp.choices?.[0]?.message?.content?.trim();
    if (!summary) {
      return res.status(500).json({ error: "Kon geen samenvatting genereren" });
    }

    return res.status(200).json({ summary });
  } catch (err) {
    console.error("[profiles/suggest] failed", err);
    res.status(500).json({ error: err.message || "Internal server error" });
  }
}
