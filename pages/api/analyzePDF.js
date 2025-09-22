// pages/api/analyze.js
import fs from "fs";
import path from "path";
import OpenAI from "openai";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const { fileName } = req.body;
    const filePath = path.join(process.cwd(), "public", "uploads", fileName);

    console.log("📥 Incoming analyze request body:", req.body);
    console.log("📂 Full path to file:", filePath);

    // check file exists
    if (!fs.existsSync(filePath)) {
      return res.status(400).json({ error: "File not found" });
    }

    const ext = path.extname(fileName).toLowerCase();
    const isPdf = ext === ".pdf";
    const isImage = [".jpg", ".jpeg", ".png"].includes(ext);

    let response;

    if (isPdf) {
      console.log("📑 Detected PDF → uploading as input_file...");

      // Upload PDF to OpenAI first
      const uploadedFile = await openai.files.create({
        file: fs.createReadStream(filePath),
        purpose: "assistants",
      });

      console.log("✅ File uploaded to OpenAI:", uploadedFile);

      // Request analysis
      response = await openai.responses.create({
        model: "gpt-4o",
        instructions:
          "Extract structured invoice data: sender, receiver, invoice number, date, totals, line items, and any other relevant details.",
        input: [
          {
            role: "user",
            content: [
              {
                type: "input_file",
                file_id: uploadedFile.id,
              },
              {
                type: "input_text",
                text: "Please extract structured invoice data from this PDF.",
              },
            ],
          },
        ],
      });
    } else if (isImage) {
      console.log("🖼️ Detected image → encoding as base64 input_image...");

      const imageBuffer = fs.readFileSync(filePath);
      const base64Data = imageBuffer.toString("base64");
      const mimeType =
        ext === ".png" ? "image/png" : "image/jpeg"; // default to jpeg if not png

      // Request analysis
      response = await openai.responses.create({
        model: "gpt-4o",
        instructions:
          "Extract structured invoice data: sender, receiver, invoice number, date, totals, line items, and any other relevant details.",
        input: [
          {
            role: "user",
            content: [
              {
                type: "input_image",
                filename: fileName,
                image_data: `data:${mimeType};base64,${base64Data}`,
              },
              {
                type: "input_text",
                text: "Please extract structured invoice data from this image.",
              },
            ],
          },
        ],
      });
    } else {
      return res
        .status(400)
        .json({ error: "Unsupported file type. Only PDF, JPG, PNG allowed." });
    }

    console.log("✅ Got response from OpenAI");

    const analysis = response.output_text || "No analysis available";
    return res.status(200).json({ analysis });
  } catch (err) {
    console.error("❌ ANALYZE error:", err);
    return res.status(500).json({ error: err.message });
  }
}
