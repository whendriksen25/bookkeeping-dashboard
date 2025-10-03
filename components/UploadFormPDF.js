import { useState } from "react";
import ReactMarkdown from "react-markdown";

export default function UploadForm() {
  const [file, setFile] = useState(null);
  const [analysis, setAnalysis] = useState("");
  const [expanded, setExpanded] = useState(true);
  const [loading, setLoading] = useState(false);

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    console.log("📂 File selected:", selectedFile);
    setFile(selectedFile);
  };

  const handleUploadAndAnalyze = async () => {
    if (!file) {
      alert("Please select a file first.");
      return;
    }

    setLoading(true);
    try {
      console.log("⬆️ Starting upload for:", file.name);

      const formData = new FormData();
      formData.append("file", file);

      const uploadRes = await fetch("/api/upload", {
        method: "POST",
        body: formData,
      });

      const uploadData = await uploadRes.json();
      console.log("📦 Upload response:", uploadData);

      if (!uploadData.success) throw new Error(uploadData.error || "Upload failed");

      console.log("🤖 Sending file to analyze:", uploadData.fileName);

      const analyzeRes = await fetch("/api/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ fileName: uploadData.fileName }),
      });

      const analyzeData = await analyzeRes.json();
      console.log("📝 Analyze response:", analyzeData);

      if (analyzeData.error) throw new Error(analyzeData.error);

      setAnalysis(analyzeData.analysis);
      setExpanded(true); // show expanded by default
    } catch (err) {
      console.error("❌ Upload/Analyze failed:", err);
      alert(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ margin: "20px" }}>
      <h2>📤 Upload and Analyze Document</h2>
      <input type="file" onChange={handleFileChange} />
      <button onClick={handleUploadAndAnalyze} disabled={loading}>
        {loading ? "⏳ Processing..." : "Upload & Analyze"}
      </button>

      {analysis && (
        <div style={{ marginTop: "20px" }}>
          <h3>
            <button
              type="button"
              onClick={() => setExpanded((prev) => !prev)}
              style={{ cursor: "pointer", color: "blue", background: "none", border: "none", padding: 0 }}
            >
              📊 Analysis Result {expanded ? "▼" : "▶"}
            </button>
          </h3>
          {expanded && (
            <div style={{ padding: "10px", border: "1px solid #ddd", borderRadius: "5px" }}>
              <ReactMarkdown>{analysis}</ReactMarkdown>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
