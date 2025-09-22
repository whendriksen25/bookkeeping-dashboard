// components/UploadForm.js
import { useState } from "react";

export default function UploadForm() {
  const [file, setFile] = useState(null);
  const [analysis, setAnalysis] = useState(null);

  const handleFileChange = (e) => {
    setFile(e.target.files[0]);
  };

  const handleUploadAndAnalyze = async () => {
    if (!file) return;

    const formData = new FormData();
    formData.append("file", file);

    try {
      // Upload PDF to /api/upload
      const uploadRes = await fetch("/api/upload", {
        method: "POST",
        body: formData,
      });
      const uploadData = await uploadRes.json();
      console.log("✅ Uploaded:", uploadData);

      if (!uploadData.filename) throw new Error("Upload failed");

      // Call /api/analyze
      const analyzeRes = await fetch("/api/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ filename: uploadData.filename }),
      });
      const analyzeData = await analyzeRes.json();
      console.log("📊 Analysis result:", analyzeData);

      if (analyzeData.error) throw new Error(analyzeData.error);

      setAnalysis(analyzeData.analysis);
    } catch (err) {
      console.error("❌ Upload/Analyze failed:", err);
      alert("Error: " + err.message);
    }
  };

  return (
    <div className="p-6 border rounded-lg shadow">
      <h2 className="text-xl font-bold mb-4">📤 Upload and Analyze Invoice</h2>

      <input
        type="file"
        accept="application/pdf"
        onChange={handleFileChange}
        className="mb-4"
      />

      <button
        onClick={handleUploadAndAnalyze}
        className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
      >
        Upload & Analyze
      </button>

      {analysis && (
        <div className="mt-6">
          <h3 className="text-lg font-semibold">✅ Full Response</h3>
          <pre className="bg-gray-100 p-4 rounded mt-2 text-sm overflow-x-auto">
            {JSON.stringify(analysis, null, 2)}
          </pre>
        </div>
      )}
    </div>
  );
}
