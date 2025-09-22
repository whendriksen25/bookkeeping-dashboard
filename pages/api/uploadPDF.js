// pages/api/upload.js
import formidable from "formidable";
import fs from "fs";
import path from "path";

export const config = { api: { bodyParser: false } };

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const form = formidable({ multiples: false });
  form.parse(req, async (err, fields, files) => {
    if (err) {
      console.error("❌ Upload parse error:", err);
      return res.status(500).json({ error: "File upload failed" });
    }

    try {
      const file = files.file?.[0] || files.file;
      if (!file) return res.status(400).json({ error: "No file uploaded" });

      const uploadsDir = path.join(process.cwd(), "public", "uploads");
      if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });

      // Keep original extension
      const ext = path.extname(file.originalFilename);
      const newFileName = file.newFilename + ext;
      const newPath = path.join(uploadsDir, newFileName);

      console.log(`➡️ Moving file from ${file.filepath} -> ${newPath}`);
      fs.renameSync(file.filepath, newPath);

      return res.status(200).json({
        success: true,
        fileName: newFileName,
        url: `/uploads/${newFileName}`,
      });
    } catch (e) {
      console.error("❌ Upload save error:", e);
      return res.status(500).json({ error: "Could not save file" });
    }
  });
}
