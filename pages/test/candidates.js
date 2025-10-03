// pages/test/candidates.js
import { useState } from "react";

export default function CandidatesTest() {
  const [keywords, setKeywords] = useState("");
  const [results, setResults] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleSearch = async () => {
    setLoading(true);
    setResults(null);

    try {
      const res = await fetch("/api/testCandidates", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ keywords: keywords.split(",") }),
      });

      const data = await res.json();
      setResults(data);
    } catch (err) {
      console.error("❌ Error:", err);
      setResults({ error: err.message });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">🔎 Test COA Candidate Search</h1>

      <input
        type="text"
        value={keywords}
        onChange={(e) => setKeywords(e.target.value)}
        placeholder="Typ zoekwoorden, bv: Telecommunicatie, Internet"
        className="border p-2 w-full mb-4"
      />

      <button
        onClick={handleSearch}
        disabled={loading}
        className="bg-blue-600 text-white px-4 py-2 rounded"
      >
        {loading ? "⏳ Zoeken..." : "Zoek Kandidaten"}
      </button>

      {results && (
        <div className="mt-6">
          <h2 className="text-xl font-semibold mb-2">Resultaten:</h2>
          <pre className="bg-gray-100 p-4 rounded text-sm">
            {JSON.stringify(results, null, 2)}
          </pre>
        </div>
      )}
    </div>
  );
}
