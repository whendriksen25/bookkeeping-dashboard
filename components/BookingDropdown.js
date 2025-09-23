import { useState, useMemo } from "react";

export default function BookingDropdown({ analysis }) {
  const candidates = analysis?.db_candidates ?? [];
  const scores = analysis?.ai_ranking?.scores ?? {};
  const [selected, setSelected] = useState(() => analysis?.ai_ranking?.keuze_nummer || "");

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

  if (options.length === 0) {
    return <p className="text-sm text-gray-600">Geen kandidaten gevonden.</p>;
  }

  return (
    <div>
      <label className="block font-medium mb-1">Kies grootboekrekening:</label>
      <select
        value={selected}
        onChange={(e) => setSelected(e.target.value)}
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
