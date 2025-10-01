// components/UploadForm.js
import { useState, useMemo } from "react";

export default function UploadForm({ onAnalyze }) {
  const [file, setFile] = useState(null);
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState(null);
  const [selectedNumber, setSelectedNumber] = useState("");

  const topChoice = useMemo(() => {
    if (!data?.ai_ranking?.scores) return null;
    let best = null;
    for (const [num, v] of Object.entries(data.ai_ranking.scores)) {
      if (!best || (v.probability ?? 0) > (best.v.probability ?? 0)) {
        best = { num, v };
      }
    }
    return best;
  }, [data]);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!file) return;
    setLoading(true);

    // 1) upload
    const formData = new FormData();
    formData.append("file", file);
    const up = await fetch("/api/upload", { method: "POST", body: formData });
    if (!up.ok) {
      setLoading(false);
      const errorText = await up.text();
      console.error("Upload failed", errorText);
      return;
    }
    const upData = await up.json();

    // 2) analyze
    const az = await fetch("/api/analyze", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ file: upData }),
    });
    if (!az.ok) {
      setLoading(false);
      const errorText = await az.text();
      console.error("Analyze failed", errorText);
      return;
    }
    const azData = await az.json();
    setData(azData);
    if (typeof onAnalyze === "function") {
      try {
        onAnalyze(azData);
      } catch (callbackErr) {
        console.warn("onAnalyze callback threw", callbackErr);
      }
    }

    // preselect best choice
    if (azData?.ai_ranking?.keuze_nummer) {
      setSelectedNumber(azData.ai_ranking.keuze_nummer);
    } else if (azData?.db_candidates?.[0]?.number) {
      setSelectedNumber(azData.db_candidates[0].number);
    }

    setLoading(false);
  }

  const lineItems = Array.isArray(data?.factuurdetails?.regels)
    ? data.factuurdetails.regels
    : [];

  const recalculated = data?.herberekende_totalen || {};

  return (
    <div className="bg-white shadow rounded p-6 space-y-6">
      <form onSubmit={handleSubmit} className="space-y-3">
        <input
          type="file"
          accept=".pdf,.png,.jpg,.jpeg,.heic,.heif,.heics,image/*"
          onChange={(e) => setFile(e.target.files[0] || null)}
          className="block w-full border rounded p-2"
        />
        <button
          type="submit"
          disabled={loading || !file}
          className="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50"
        >
          {loading ? "Analyzing…" : "Upload & Analyze"}
        </button>
      </form>

      {data && (
        <div className="space-y-6">
          {/* FACTUURDETAILS */}
          <section>
            <h2 className="text-lg font-semibold mb-2">📑 Factuurdetails</h2>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              {/* Afzender */}
              <div className="border rounded p-3">
                <h3 className="font-medium mb-1">Afzender</h3>
                <div>Naam: {data.factuurdetails?.afzender?.naam || "-"}</div>
                <div>Adres: {data.factuurdetails?.afzender?.adres || "-"}</div>
                <div>KvK: {data.factuurdetails?.afzender?.kvk_nummer || "-"}</div>
                <div>BTW: {data.factuurdetails?.afzender?.btw_nummer || "-"}</div>
                <div>Email: {data.factuurdetails?.afzender?.email || "-"}</div>
                <div>Telefoon: {data.factuurdetails?.afzender?.telefoon || "-"}</div>
              </div>

              {/* Ontvanger */}
              <div className="border rounded p-3">
                <h3 className="font-medium mb-1">Ontvanger</h3>
                <div>Naam: {data.factuurdetails?.ontvanger?.naam || "-"}</div>
                <div>Adres: {data.factuurdetails?.ontvanger?.adres || "-"}</div>
                <div>KvK: {data.factuurdetails?.ontvanger?.kvk_nummer || "-"}</div>
                <div>BTW: {data.factuurdetails?.ontvanger?.btw_nummer || "-"}</div>
                <div>Klantnummer: {data.factuurdetails?.ontvanger?.klantnummer || "-"}</div>
                <div>Debiteurnummer: {data.factuurdetails?.ontvanger?.debiteurnummer || "-"}</div>
                <div>Email: {data.factuurdetails?.ontvanger?.email || "-"}</div>
                <div>Telefoon: {data.factuurdetails?.ontvanger?.telefoon || "-"}</div>
              </div>
            </div>

            {/* Invoice meta */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm mt-3">
              <div className="border rounded p-3">
                <div>Factuurnummer: {data.factuurdetails?.factuurnummer || "-"}</div>
                <div>Datum: {data.factuurdetails?.factuurdatum || "-"}</div>
                <div>Vervaldatum: {data.factuurdetails?.vervaldatum || "-"}</div>
                <div>Betaalstatus: {data.factuurdetails?.betaalstatus || "-"}</div>
              </div>
              <div className="border rounded p-3">
                <div>Totaal excl. BTW: {data.factuurdetails?.totaal?.totaal_excl_btw ?? "-"}</div>
                <div>BTW: {data.factuurdetails?.totaal?.btw ?? "-"}</div>
                <div>Totaal incl. BTW: {data.factuurdetails?.totaal?.totaal_incl_btw ?? "-"}</div>
                <div>Valuta: {data.factuurdetails?.totaal?.valuta || "-"}</div>
              </div>
              <div className="border rounded p-3">
                <div>Opmerkingen: {data.factuurdetails?.opmerkingen || "-"}</div>
              </div>
            </div>

            {/* Regels */}
            <div className="mt-3">
              <h3 className="font-medium mb-1">Regels</h3>
              <div className="overflow-x-auto">
                <table className="w-full text-sm border rounded">
                  <thead className="bg-gray-100">
                    <tr>
                      <th className="text-left p-2">Productcode</th>
                      <th className="text-left p-2">Omschrijving</th>
                      <th className="text-right p-2">Aantal</th>
                      <th className="text-left p-2">Eenheid</th>
                      <th className="text-right p-2">Prijs excl.</th>
                      <th className="text-right p-2">BTW%</th>
                      <th className="text-right p-2">BTW €</th>
                      <th className="text-right p-2">Totaal excl.</th>
                      <th className="text-right p-2">Totaal incl.</th>
                    </tr>
                  </thead>
                  <tbody>
                    {lineItems.map((r, i) => {
                      const productCode = r.productcode || r.product_code || "";
                      const quantity = r.aantal ?? r.quantity ?? "";
                      const unit = r.eenheid ?? r.unit ?? "";
                      const unitPrice = r.prijs_per_eenheid_excl ?? r.prijs ?? r.unit_price_excl ?? r.prijs_excl ?? "";
                      const vatPerc = r.btw_percentage ?? r.btw_perc ?? "";
                      const vatAmount = r.btw_bedrag ?? r.vat_amount ?? "";
                      const totalExcl = r.totaal_excl ?? r.bedrag_excl ?? "";
                      const totalIncl = r.totaal_incl ?? r.bedrag_incl ?? "";
                      return (
                        <tr key={i} className="border-t">
                          <td className="p-2">{productCode}</td>
                          <td className="p-2">{r.omschrijving ?? r.description ?? ""}</td>
                          <td className="p-2 text-right">{quantity}</td>
                          <td className="p-2">{unit}</td>
                          <td className="p-2 text-right">{unitPrice}</td>
                          <td className="p-2 text-right">{vatPerc}</td>
                          <td className="p-2 text-right">{vatAmount}</td>
                          <td className="p-2 text-right">{totalExcl}</td>
                          <td className="p-2 text-right">{totalIncl}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
            {recalculated && (recalculated.totaal_excl || recalculated.totaal_incl) && (
              <div className="mt-2 text-sm text-gray-700">
                <div className="font-medium">Herberekende totalen</div>
                <div>Totaal excl.: {recalculated.totaal_excl ?? "-"}</div>
                <div>Totaal btw: {recalculated.totaal_btw ?? "-"}</div>
                <div>Totaal incl.: {recalculated.totaal_incl ?? "-"}</div>
                {recalculated.komt_overeen_met_ticket === false && (
                  <div className="text-red-600">Afwijking: {recalculated.verschil || "verschil gedetecteerd"}</div>
                )}
              </div>
            )}
          </section>

          {/* RAW TEXT */}
          <section>
            <h2 className="text-lg font-semibold mb-2">📄 Ruwe tekst (OCR/parse)</h2>
            <pre className="p-3 bg-gray-100 rounded whitespace-pre-wrap max-h-64 overflow-auto">
              {data.invoice_text || "—"}
            </pre>
          </section>

          {/* FIRST AI SUGGESTIONS (used for DB keywords) */}
          <section>
            <h2 className="text-lg font-semibold mb-2">🤖 OpenAI eerste suggesties (ingang fuzzy-zoek)</h2>
            {Array.isArray(data.ai_first_suggestions) && data.ai_first_suggestions.length > 0 ? (
              <ul className="space-y-2">
                {data.ai_first_suggestions.map((s, i) => (
                  <li key={i} className="border rounded p-3 bg-gray-50">
                    <div className="font-medium">{s.naam || "—"}{" "}
                      <span className="text-gray-500">
                        ({Math.round((s.kans ?? 0) * 100)}%)
                      </span>
                    </div>
                    <div className="text-sm text-gray-600">{s.uitleg || ""}</div>
                  </li>
                ))}
              </ul>
            ) : (
              <div className="text-sm text-gray-600">Geen suggesties terug van AI.</div>
            )}
            {Array.isArray(data.ai_keywords_used) && data.ai_keywords_used.length > 0 && (
              <div className="text-xs text-gray-500 mt-2">
                Keywords gebruikt voor DB: {data.ai_keywords_used.join(", ")}
              </div>
            )}
          </section>

          {/* DB CANDIDATES */}
          <section>
            <h2 className="text-lg font-semibold mb-2">📊 COA Kandidaten (DB fuzzy match, leaf-only)</h2>
            {Array.isArray(data.db_candidates) && data.db_candidates.length > 0 ? (
              <ul className="text-sm text-gray-700 space-y-1">
                {data.db_candidates.map((c) => (
                  <li key={c.number}>
                    {c.number} — {c.description} <span className="text-gray-400">(score {c.score?.toFixed(3)})</span>
                  </li>
                ))}
              </ul>
            ) : (
              <div className="text-sm text-gray-600">Geen kandidaten gevonden.</div>
            )}
          </section>

          {/* AI RANKING + DROPDOWN */}
          <section>
            <h2 className="text-lg font-semibold mb-2">🧠 AI-ranking & keuze</h2>
            {topChoice?.num && (
              <div className="mb-3 text-sm">
                Beste keuze (AI): <span className="font-medium">{topChoice.num}</span>{" "}
                — {topChoice.v.account_name}{" "}
                <span className="text-gray-500">
                  ({Math.round((topChoice.v.probability ?? 0) * 100)}%)
                </span>
              </div>
            )}

            <label className="block text-sm font-medium mb-1">Te boeken op:</label>
            <select
              className="border rounded px-3 py-2 w-full md:w-auto"
              value={selectedNumber}
              onChange={(e) => setSelectedNumber(e.target.value)}
            >
              {(data.db_candidates || []).map((c) => (
                <option key={c.number} value={c.number}>
                  {c.number} — {c.description}
                </option>
              ))}
            </select>

            {data.ai_ranking?.toelichting && (
              <p className="text-xs text-gray-500 mt-2">
                Toelichting AI: {data.ai_ranking.toelichting}
              </p>
            )}
          </section>
        </div>
      )}
    </div>
  );
}
