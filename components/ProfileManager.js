// components/ProfileManager.js
import { useEffect, useState } from "react";
import styles from "./ProfileManager.module.css";

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
  const [refreshing, setRefreshing] = useState(false);
  const [importing, setImporting] = useState(false);
  const [defaultProfileId, setDefaultProfileId] = useState(null);

  useEffect(() => {
    if (!profiles.length) {
      setDefaultProfileId(null);
      return;
    }
    if (!profiles.some((profile) => profile.id === defaultProfileId)) {
      setDefaultProfileId(profiles[0].id);
    }
  }, [profiles, defaultProfileId]);

  async function refreshProfiles() {
    const resp = await fetch("/api/profiles");
    if (!resp.ok) throw new Error("Kon profielen niet ophalen");
    const data = await resp.json();
    if (typeof onProfilesChange === "function") {
      onProfilesChange(data.profiles || []);
    }
  }

  async function handleRefresh() {
    try {
      setRefreshing(true);
      setError("");
      await refreshProfiles();
    } catch (err) {
      console.error("[profiles] refresh failed", err);
      setError(err.message || "Kon profielen niet verversen");
    } finally {
      setRefreshing(false);
    }
  }

  function handleNewProfile() {
    setEditingId(null);
    setForm({ name: "", type: "company", website: "", description: "", aiSummary: "" });
    setError("");
  }

  async function handleImportPlaceholder() {
    setImporting(true);
    setTimeout(() => {
      setImporting(false);
      setError("Importeren is binnenkort beschikbaar.");
    }, 400);
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

  function handleSetDefault(id) {
    setDefaultProfileId(id);
  }

  const defaultProfileName = profiles.find((profile) => profile.id === defaultProfileId)?.name || "Select a profile";

  return (
    <section className={styles.wrapper}>
      <div className={styles.headlineRow}>
        <div>
          <h2>Company Profiles</h2>
          <p className={styles.headlineText}>
            Provide website and locale so AI can enrich vendor matching, chart-of-accounts suggestions, and compliance
            defaults for each company profile.
          </p>
        </div>
        <button
          type="button"
          onClick={handleRefresh}
          disabled={refreshing}
          className={styles.refreshButton}
        >
          {refreshing ? "Refreshing…" : "Refresh list"}
        </button>
      </div>

      <div className={styles.layout}>
        <div className={styles.listCard}>
          <div className={styles.listHeader}>
            <h3>Saved profiles</h3>
            <div className={styles.actionGroup}>
              <button type="button" className={styles.primaryPill} onClick={handleNewProfile}>
                + New profile
              </button>
              <button
                type="button"
                className={styles.outlinePill}
                onClick={handleImportPlaceholder}
                disabled={importing}
              >
                {importing ? "Importing…" : "Import"}
              </button>
            </div>
          </div>

          {profiles.length === 0 ? (
            <div className={styles.emptyState}>No profiles yet. Add your first company on the right.</div>
          ) : (
            <div className={styles.profileList}>
              {profiles.map((profile) => (
                <div
                  key={profile.id}
                  className={`${styles.profileCard} ${profile.id === defaultProfileId ? styles.profileCardActive : ""}`}
                >
                  <div className={styles.profileMeta}>
                    <div className={styles.profileNameRow}>
                      <strong>{profile.name}</strong>
                      {profile.id === defaultProfileId && <span className={styles.defaultBadge}>Default</span>}
                    </div>
                    {profile.website && <div className={styles.profileSubtle}>{profile.website}</div>}
                    <div className={styles.profileSubtle}>
                      {profile.type === "personal" ? "Personal profile" : "Company profile"}
                    </div>
                    {profile.aiSummary && <p className={styles.profileSummary}>{profile.aiSummary}</p>}
                  </div>
                  <div className={styles.profileActions}>
                    <button type="button" onClick={() => handleEdit(profile)} className={styles.linkButton}>
                      Edit
                    </button>
                    <button type="button" onClick={() => handleDelete(profile.id)} className={styles.linkButton}>
                      Delete
                    </button>
                    <button
                      type="button"
                      onClick={() => handleSetDefault(profile.id)}
                      className={styles.linkButton}
                      disabled={profile.id === defaultProfileId}
                    >
                      {profile.id === defaultProfileId ? "Default" : "Set Default"}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className={styles.choiceCard}>
            <div className={styles.choiceContent}>
              <p className={styles.choiceLabel}>Choose profile for next upload</p>
              <span className={styles.choiceName}>{defaultProfileName}</span>
            </div>
            <button type="button" className={styles.primaryPill} disabled={profiles.length === 0}>
              Select
            </button>
          </div>

          <div className={styles.infoFooter}>
            Protect your account with SSO and 2FA in Settings after signup.
          </div>
        </div>

        <form className={styles.formPanel} onSubmit={handleSubmit}>
          <h3>{editingId ? "Update company" : "Add company"}</h3>
          <div className={styles.formGrid}>
            <div className={styles.field}>
              <label htmlFor="profile-name">Company name</label>
              <input
                id="profile-name"
                type="text"
                value={form.name}
                onChange={(e) => setForm((prev) => ({ ...prev, name: e.target.value }))}
                placeholder="Your Company Ltd"
                required
              />
            </div>
            <div className={styles.field}>
              <label htmlFor="profile-type">Profile type</label>
              <select
                id="profile-type"
                value={form.type}
                onChange={(e) => setForm((prev) => ({ ...prev, type: e.target.value }))}
              >
                <option value="company">Company</option>
                <option value="personal">Personal</option>
              </select>
            </div>
            <div className={styles.field}>
              <label htmlFor="profile-website">Website</label>
              <input
                id="profile-website"
                type="url"
                value={form.website}
                onChange={(e) => setForm((prev) => ({ ...prev, website: e.target.value }))}
                placeholder="https://www.yourcompany.com"
              />
            </div>
            <div className={styles.field}>
              <label htmlFor="profile-description">Description</label>
              <textarea
                id="profile-description"
                value={form.description}
                onChange={(e) => setForm((prev) => ({ ...prev, description: e.target.value }))}
                placeholder="Summarize services, locations, or compliance notes"
              />
            </div>
            <div className={`${styles.field} ${styles.fullWidth}`}>
              <label htmlFor="profile-ai-summary">AI summary</label>
              <textarea
                id="profile-ai-summary"
                value={form.aiSummary}
                onChange={(e) => setForm((prev) => ({ ...prev, aiSummary: e.target.value }))}
                placeholder="Optional AI-generated summary for colleagues"
              />
              <div className={styles.inlineActions}>
                <button
                  type="button"
                  onClick={handleSuggest}
                  disabled={suggesting || !form.name.trim()}
                  className={styles.outlinePill}
                >
                  {suggesting ? "Generating…" : "Generate AI summary"}
                </button>
              </div>
            </div>
          </div>

          {error && <div className={styles.errorText}>{error}</div>}

          <div className={styles.buttonRow}>
            <button type="submit" disabled={saving} className={styles.submitButton}>
              {saving ? "Saving…" : editingId ? "Save changes" : "Save profile"}
            </button>
            {editingId && (
              <button type="button" onClick={handleCancelEdit} className={styles.cancelButton}>
                Cancel
              </button>
            )}
          </div>
        </form>
      </div>
    </section>
  );
}
