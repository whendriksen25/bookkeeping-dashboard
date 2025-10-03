import { useMemo, useEffect } from "react";

export default function BookingDropdown({ analysis, selectedAccount, onAccountChange }) {
  const candidates = analysis?.db_candidates ?? [];
  const scores = analysis?.ai_ranking?.scores ?? {};

  const options = useMemo(() => {
    return candidates.map((c) => {
      const prob = scores[c.number]?.probability ?? 0;
      return {
        value: c.number,
        label: `${c.number} – ${c.description} (${(prob * 100).toFixed(1)}%)`,
        probability: prob,
      };
    });
  }, [candidates, scores]);

  useEffect(() => {
    if (!analysis) return;
    if (selectedAccount) return;
    const suggested = analysis?.ai_ranking?.keuze_nummer || options[0]?.value || "";
    if (suggested && typeof onAccountChange === "function") {
      onAccountChange(suggested);
    }
  }, [analysis, selectedAccount, options, onAccountChange]);

  if (options.length === 0) {
    return <p className="text-sm text-gray-600">Geen kandidaten gevonden.</p>;
  }

  return (
    <div>
      <label className="block font-medium mb-1">Kies grootboekrekening:</label>
      <select
        value={selectedAccount || ""}
        onChange={(e) => onAccountChange?.(e.target.value)}
        className="border rounded p-2 w-full"
      >
        {options
          .slice()
          .sort((a, b) => b.probability - a.probability)
          .map((o) => (
            <option key={o.value} value={o.value}>
              {o.label}
            </option>
          ))}
      </select>
    </div>
  );
}
