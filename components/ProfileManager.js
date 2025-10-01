// components/ProfileManager.js
import { useState } from "react";

export default function ProfileManager({ profiles, onProfilesChange }) {
  const [form, setForm] = useState({
    name: "",
    type: "company",
    website: "",
    description: "",
    aiSummary: "",
  });
  const [saving, setSaving] = useState(false);
  const [suggesting, setSuggesting] = useState(false);
  const [error, setError] = useState("");
  const [editingId, setEditingId] = useState(null);

  async function refreshProfiles() {
    const resp = await fetch("/api/profiles");
    if (!resp.ok) throw new Error("Kon profielen niet ophalen");
    const data = await resp.json();
    if (typeof onProfilesChange === "function") {
      onProfilesChange(data.profiles || []);
    }
  }

  async function handleSuggest() {
    try {
      setSuggesting(true);
      setError("");
      const resp = await fetch("/api/profiles/suggest", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: form.name,
          type: form.type,
          website: form.website,
          description: form.description,
        }),
      });
      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Suggestie mislukt");
      }
      const data = await resp.json();
      setForm((prev) => ({ ...prev, aiSummary: data.summary || "" }));
    } catch (err) {
      console.error("[profiles] suggest failed", err);
      setError(err.message || "Kon geen voorstel genereren");
    } finally {
      setSuggesting(false);
    }
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (!form.name.trim()) {
      setError("Naam is verplicht");
      return;
    }
    try {
      setSaving(true);
      setError("");

      const payload = {
        name: form.name,
        type: form.type,
        website: form.website,
        description: form.description,
        aiSummary: form.aiSummary,
      };

      const resp = await fetch(editingId ? `/api/profiles/${editingId}` : "/api/profiles", {
        method: editingId ? "PUT" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Opslaan mislukt");
      }

      setForm({ name: "", type: form.type, website: "", description: "", aiSummary: "" });
      setEditingId(null);
      await refreshProfiles();
    } catch (err) {
      console.error("[profiles] save failed", err);
      setError(err.message || "Kon profiel niet opslaan");
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete(id) {
    if (!window.confirm("Profiel verwijderen?")) return;
    try {
      const resp = await fetch(`/api/profiles/${id}`, { method: "DELETE" });
      if (!resp.ok && resp.status !== 204) {
        const text = await resp.text();
        throw new Error(text || "Verwijderen mislukt");
      }
      await refreshProfiles();
    } catch (err) {
      console.error("[profiles] delete failed", err);
      setError(err.message || "Kon profiel niet verwijderen");
    }
  }

  function handleEdit(profile) {
    setEditingId(profile.id);
    setForm({
      name: profile.name || "",
      type: profile.type || "company",
      website: profile.website || "",
      description: profile.description || "",
      aiSummary: profile.aiSummary || "",
    });
    setError("");
  }

  function handleCancelEdit() {
    setEditingId(null);
    setForm({ name: "", type: "company", website: "", description: "", aiSummary: "" });
    setError("");
  }

  return (
    <section className="bg-white shadow rounded p-6 space-y-4">
      <div>
        <h2 className="text-lg font-semibold">📇 Profielinstellingen</h2>
        <p className="text-sm text-gray-600">
          Voeg een bedrijfs- of persoonlijk profiel toe. Gebruik de AI-knop voor een voorstel op basis van naam en website, en werk de tekst daarna eventueel bij.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-2">
          <label className="block text-sm font-medium">Naam</label>
          <input
            type="text"
            value={form.name}
            onChange={(e) => setForm((prev) => ({ ...prev, name: e.target.value }))}
            className="border rounded p-2 w-full"
            placeholder="Bijv. Example BV"
            required
          />
        </div>

        <div className="space-y-2">
          <label className="block text-sm font-medium">Type</label>
          <select
            value={form.type}
            onChange={(e) => setForm((prev) => ({ ...prev, type: e.target.value }))}
            className="border rounded p-2 w-full"
          >
            <option value="company">Bedrijf</option>
            <option value="personal">Persoonlijk</option>
          </select>
        </div>

        <div className="space-y-2">
          <label className="block text-sm font-medium">Website</label>
          <input
            type="url"
            value={form.website}
            onChange={(e) => setForm((prev) => ({ ...prev, website: e.target.value }))}
            className="border rounded p-2 w-full"
            placeholder="https://..."
          />
        </div>

        <div className="space-y-2">
          <label className="block text-sm font-medium">Beschrijving</label>
          <textarea
            value={form.description}
            onChange={(e) => setForm((prev) => ({ ...prev, description: e.target.value }))}
            className="border rounded p-2 w-full"
            rows={3}
            placeholder="Korte beschrijving van activiteiten"
          />
        </div>

        <div className="md:col-span-2 space-y-2">
          <label className="block text-sm font-medium">AI-samenvatting</label>
          <textarea
            value={form.aiSummary}
            onChange={(e) => setForm((prev) => ({ ...prev, aiSummary: e.target.value }))}
            className="border rounded p-2 w-full"
            rows={4}
            placeholder="Laat leeg of gebruik AI-voorstel"
          />
          <div className="flex gap-2">
            <button
              type="button"
              onClick={handleSuggest}
              disabled={suggesting || !form.name.trim()}
              className="px-3 py-2 text-sm bg-gray-200 rounded disabled:opacity-50"
            >
              {suggesting ? "Bezig..." : "Genereer AI-voorstel"}
            </button>
          </div>
        </div>

        {error && (
          <div className="md:col-span-2 text-sm text-red-600">{error}</div>
        )}

      <div className="md:col-span-2">
        <button
          type="submit"
          disabled={saving}
          className="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50"
        >
          {saving ? "Opslaan..." : editingId ? "Profiel bijwerken" : "Profiel opslaan"}
        </button>
        {editingId && (
          <button
            type="button"
            onClick={handleCancelEdit}
            className="ml-3 px-4 py-2 bg-gray-200 text-gray-700 rounded"
          >
            Annuleren
          </button>
        )}
      </div>
      </form>

      <div className="space-y-2">
        <h3 className="text-md font-semibold">Bestaande profielen</h3>
        {profiles.length === 0 ? (
          <p className="text-sm text-gray-600">Nog geen profielen toegevoegd.</p>
        ) : (
          <ul className="space-y-2">
            {profiles.map((p) => (
              <li key={p.id} className="border rounded p-3 text-sm bg-gray-50">
                <div className="flex justify-between items-start gap-3">
                  <div>
                    <div className="font-medium">
                      {p.name} <span className="text-gray-500">({p.type})</span>
                    </div>
                    {p.website && (
                      <div className="text-gray-600">{p.website}</div>
                    )}
                    {p.aiSummary && (
                      <p className="text-gray-700 mt-1 whitespace-pre-line">{p.aiSummary}</p>
                    )}
                  </div>
                  <div className="flex flex-col items-end gap-2">
                    <button
                      onClick={() => handleEdit(p)}
                      className="text-xs text-blue-600 hover:underline"
                    >
                      Bewerken
                    </button>
                    <button
                      onClick={() => handleDelete(p.id)}
                      className="text-xs text-red-600 hover:underline"
                    >
                      Verwijderen
                    </button>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    </section>
  );
}
