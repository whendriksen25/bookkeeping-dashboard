// components/BookingDropdown.js
import { useState, useEffect } from "react";

export default function BookingDropdown({ analyzeResult }) {
  const [selected, setSelected] = useState(null);

  // Build options with probabilities
  const options = analyzeResult.candidates.map((c) => {
    const prob = analyzeResult.result[c.number]?.probability ?? 0;
    return {
      value: c.number,
      label: `${c.number} – ${c.description} (${(prob * 100).toFixed(1)}%)`,
      probability: prob,
    };
  });

  // Preselect highest probability
  useEffect(() => {
    if (options.length > 0) {
      const best = [...options].sort((a, b) => b.probability - a.probability)[0];
      setSelected(best.value);
    }
  }, [analyzeResult]);

  return (
    <div>
      <label className="block font-medium mb-1">Kies grootboekrekening:</label>
      <select
        value={selected || ""}
        onChange={(e) => setSelected(e.target.value)}
        className="border rounded p-2 w-full"
      >
        {options
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