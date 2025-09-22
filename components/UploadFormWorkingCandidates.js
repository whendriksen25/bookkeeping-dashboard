// components/UploadForm.js
import { useState } from "react";

export default function UploadForm() {
  const [file, setFile] = useState(null);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleUploadAndAnalyze = async () => {
    if (!file) return;
    setLoading(true);

    try {
      // 1. Upload file
      const formData = new FormData();
      formData.append("file", file);

      const uploadRes = await fetch("/api/upload", {
        method: "POST",
        body: formData,
      });
      const uploadData = await uploadRes.json();
      console.log("✅ Uploaded:", uploadData);

      // 2. Analyze file (dummy analyze currently)
      const analyzeRes = await fetch("/api/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ filename: uploadData.filename }),
      });
      const analyzeData = await analyzeRes.json();
      console.log("📊 Analysis result:", analyzeData);

      setResult(analyzeData);
    } catch (err) {
      console.error("❌ Upload/Analyze failed:", err);
      setResult({ error: err.message });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 border rounded-md shadow-md bg-white">
      <h1 className="text-2xl font-bold mb-4">🚀 Bookkeeping Dashboard</h1>

      <h2 className="text-lg font-semibold mb-2">📤 Upload and Analyze Invoice</h2>
      <input
        type="file"
        onChange={(e) => setFile(e.target.files[0])}
        className="mb-4"
      />
      <button
        onClick={handleUploadAndAnalyze}
        disabled={!file || loading}
        className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:bg-gray-400"
      >
        {loading ? "Bezig..." : "Upload & Analyze"}
      </button>

      {result && (
        <div className="mt-6">
          {result.error && (
            <div className="text-red-600 font-semibold">
              ⚠️ Error: {result.error}
            </div>
          )}

          {result.analysis && (
            <div className="space-y-4">
              {/* Factuurdetails */}
              <div>
                <h3 className="text-lg font-semibold">📑 Factuurdetails</h3>
                <p><strong>Afzender:</strong> {result.analysis.factuurdetails?.afzender?.naam}</p>
                <p>KvK: {result.analysis.factuurdetails?.afzender?.kvk_nummer}</p>
                <p>BTW: {result.analysis.factuurdetails?.afzender?.btw_nummer}</p>

                <p className="mt-2"><strong>Ontvanger:</strong> {result.analysis.factuurdetails?.ontvanger?.naam}</p>
                <p>Klantnummer: {result.analysis.factuurdetails?.ontvanger?.klantnummer}</p>
                <p>Debiteurnummer: {result.analysis.factuurdetails?.ontvanger?.debiteurnummer}</p>

                <p className="mt-2"><strong>Factuur:</strong> #{result.analysis.factuurdetails?.factuurnummer}</p>
                <p>Datum: {result.analysis.factuurdetails?.factuurdatum}</p>
                <p>Totaal excl. BTW: {result.analysis.factuurdetails?.totaal?.totaal_excl_btw}</p>
                <p>BTW: {result.analysis.factuurdetails?.totaal?.btw}</p>
                <p>Totaal incl. BTW: {result.analysis.factuurdetails?.totaal?.totaal_incl_btw}</p>

                {result.analysis.factuurdetails?.regels && (
                  <div className="mt-2">
                    <strong>Regels:</strong>
                    <ul className="list-disc ml-6">
                      {result.analysis.factuurdetails.regels.map((r, i) => (
                        <li key={i}>
                          {r.omschrijving} — {r.aantal} × {r.bedrag}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>

              {/* Boekhoudcategorie suggesties */}
              <div>
                <h3 className="text-lg font-semibold">📂 Boekhoudcategorie Suggesties</h3>
                {result.analysis.boekhoudcategorie_suggesties?.length > 0 ? (
                  <ul className="list-disc ml-6">
                    {result.analysis.boekhoudcategorie_suggesties.map((s, i) => (
                      <li key={i}>
                        {s.categorie} ({Math.round(s.kans * 100)}%) — {s.uitleg}
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p>Geen suggesties gevonden.</p>
                )}
              </div>

              {/* COA Kandidaten */}
              <div>
                <h3 className="text-lg font-semibold">📊 COA Kandidaten (Database)</h3>
                {result.candidates?.length > 0 ? (
                  <ul className="list-disc ml-6">
                    {result.candidates.map((c, i) => (
                      <li key={i}>
                        {c.number} — {c.description}
                        {c.parent_code && (
                          <span className="text-gray-500"> (Parent: {c.parent_code})</span>
                        )}
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p>Geen kandidaten gevonden.</p>
                )}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}