// pages/api/upload.js
import formidable from "formidable";
import fs from "fs";
import path from "path";
import { put } from "@vercel/blob";

export const config = { api: { bodyParser: false } };

export default async function handler(req, res) {
  console.log("[upload] Incoming request", { method: req.method, headers: req.headers["content-type"] });
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const form = formidable({ multiples: false });
  form.parse(req, async (err, fields, files) => {
    console.log("[upload] Form parsed", {
      err: err ? err.message : null,
      fieldKeys: Object.keys(fields || {}),
      fileKeys: Object.keys(files || {}),
    });
    if (err) {
      console.error("❌ Upload parse error:", err);
      return res.status(500).json({ error: "File upload failed" });
    }

    try {
      const file = files.file?.[0] || files.file;
      if (!file) {
        console.warn("[upload] No file detected in form data");
      } else {
        console.log("[upload] Parsed file", {
          originalFilename: file.originalFilename,
          mimetype: file.mimetype,
          size: file.size,
          filepath: file.filepath,
        });
      }
      if (!file) return res.status(400).json({ error: "No file uploaded" });

      const ext = path.extname(file.originalFilename || "");
      const newFileName = file.newFilename + ext;
      const useBlobStorage = Boolean(process.env.BLOB_READ_WRITE_TOKEN);

      if (useBlobStorage) {
        console.log("[upload] Detected Vercel environment, storing file in Blob", {
          filename: newFileName,
        });
        const buffer = await fs.promises.readFile(file.filepath);
        const blobPath = `uploads/${newFileName}`;
        const blob = await put(blobPath, buffer, {
          access: "private",
          addRandomSuffix: false,
          contentType: file.mimetype || undefined,
        });
        console.log("[upload] Stored in Vercel Blob", { url: blob.url, pathname: blob.pathname });

        return res.status(200).json({
          success: true,
          storage: "blob",
          filename: newFileName,
          blobKey: blob.pathname,
          url: blob.url,
        });
      }

      const uploadsDir = path.join(process.cwd(), "public", "uploads");
      if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });
      const newPath = path.join(uploadsDir, newFileName);

      console.log("[upload] Moving file locally", { from: file.filepath, to: newPath });
      fs.renameSync(file.filepath, newPath);
      console.log("[upload] Local move complete");

      return res.status(200).json({
        success: true,
        storage: "local",
        filename: newFileName,
        url: `/uploads/${newFileName}`,
      });
    } catch (e) {
      console.error("❌ Upload save error:", e);
      return res.status(500).json({ error: "Could not save file" });
    }
  });
}
