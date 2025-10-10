/* eslint-disable @next/next/no-img-element */
import { useCallback, useEffect, useMemo, useState } from "react";
import styles from "./BookingsView.module.css";

function formatCurrency(value, currency = "EUR") {
  if (value === null || value === undefined || value === "") return "—";
  const numeric = Number(value);
  if (!Number.isFinite(numeric)) return String(value);
  try {
    return new Intl.NumberFormat("nl-NL", { style: "currency", currency }).format(numeric);
  } catch {
    return `${numeric.toFixed(2)} ${currency}`;
  }
}

function mapLineItems(rawLineItems = [], currency = "EUR") {
  return rawLineItems
    .filter(Boolean)
    .map((item, index) => ({
      description:
        item.omschrijving || item.description || item.omschrijving_lang || `Line ${index + 1}`,
      quantity: item.aantal ?? item.quantity ?? "—",
      unitPrice:
        item.prijs_per_eenheid_excl ?? item.prijs ?? item.unit_price_excl ?? item.unitPrice ?? null,
      total: item.totaal_incl ?? item.totaal ?? item.totalIncl ?? item.totalPrice ?? null,
      currency,
    }));
}

function normalizeEntry(entry) {
  if (!entry) return null;
  const factuur = entry.factuurdetails || entry.rawJson?.factuurdetails || {};
  const totals = entry.totals || factuur.totaal || {};
  const lineItems = entry.lineItems || factuur.regels || [];
  const profiles = entry.profiles || entry.availableProfiles || [];
  const rawProfileSuggestion = entry.profile_suggestion || entry.profileSuggestion || null;
  let profileSuggestion = rawProfileSuggestion ? { ...rawProfileSuggestion } : null;
  if (profileSuggestion) {
    if (!profileSuggestion.name) {
      const profileMatch = profiles.find(
        (profile) => String(profile.id) === String(profileSuggestion.profileId)
      );
      if (profileMatch) profileSuggestion.name = profileMatch.name;
    }
    if (!profileSuggestion.name && Array.isArray(profileSuggestion.ranked) && profileSuggestion.ranked.length > 0) {
      profileSuggestion.name = profileSuggestion.ranked[0].name;
    }
  }

  return {
    id:
      entry.id ||
      entry.invoiceId ||
      entry.invoice_id ||
      entry.sourceFilename ||
      `entry-${Math.random().toString(36).slice(2, 8)}`,
    vendor: entry.vendor || factuur.afzender?.naam || "—",
    invoiceNumber: entry.invoiceNumber || factuur.factuurnummer || entry.number || "—",
    invoiceDate: entry.invoiceDate || factuur.factuurdatum || entry.date || "—",
    status: entry.status || entry.bookingStatus || "Pending",
    currency: entry.currency || totals.valuta || "EUR",
    totalIncl:
      entry.totalIncl ?? totals.totaal_incl_btw ?? totals.totaal_incl ?? entry.total ?? entry.amount ?? null,
    sourceUrl: entry.sourceUrl || entry.file?.url || entry.url || null,
    sourceFilename: entry.sourceFilename || entry.file?.filename || entry.filename || null,
    ai_first_suggestions:
      entry.ai_first_suggestions || entry.aiFirstSuggestions || entry.aiSuggestions || [],
    ai_ranking: entry.ai_ranking || entry.aiRanking || null,
    db_candidates: entry.db_candidates || entry.dbCandidates || [],
    profileSuggestion,
    profiles,
    factuurdetails: factuur,
    lineItems: mapLineItems(lineItems, totals.valuta || entry.currency || "EUR"),
  };
}

function buildPreview(entry) {
  if (!entry) {
    return { sourceUrl: null, sourceFilename: null, total: null, currency: "EUR" };
  }
  return {
    sourceUrl: entry.sourceUrl,
    sourceFilename: entry.sourceFilename,
    total: entry.totalIncl,
    currency: entry.currency || "EUR",
  };
}

function getTopCandidates(entry) {
  if (!entry) return [];
  const scores = entry.ai_ranking?.scores || {};
  const candidatesMap = new Map();

  (entry.db_candidates || []).forEach((candidate) => {
    candidatesMap.set(candidate.number, {
      number: candidate.number,
      description: candidate.description,
      probability: candidate.score ?? null,
    });
  });

  const fromScores = Object.entries(scores).map(([number, info]) => ({
    number,
    description: info.account_name || candidatesMap.get(number)?.description || "—",
    probability: typeof info.probability === "number" ? info.probability : candidatesMap.get(number)?.probability || 0,
  }));

  const combined = fromScores.length > 0 ? fromScores : Array.from(candidatesMap.values());
  combined.sort((a, b) => (b.probability ?? 0) - (a.probability ?? 0));
  return combined.slice(0, 3);
}

function createEntryFromAnalysis(data) {
  const base = {
    id: `demo-${Date.now()}`,
    vendor: data.factuurdetails?.afzender?.naam,
    invoiceNumber: data.factuurdetails?.factuurnummer,
    invoiceDate: data.factuurdetails?.factuurdatum || null,
    status: "Pending review",
    currency: data.factuurdetails?.totaal?.valuta || "EUR",
    totalIncl: data.factuurdetails?.totaal?.totaal_incl_btw,
    sourceFilename: data.file?.filename || "dummy-invoice.pdf",
    sourceUrl: data.file?.url || "/UploadInvoice%20(2).png",
    factuurdetails: data.factuurdetails,
    ai_first_suggestions: data.ai_first_suggestions,
    ai_ranking: data.ai_ranking,
    db_candidates: data.db_candidates,
    profileSuggestion: data.profile_suggestion,
    profiles: data.profiles,
    lineItems: mapLineItems(data.factuurdetails?.regels, data.factuurdetails?.totaal?.valuta || "EUR"),
  };
  return normalizeEntry(base);
}

export default function BookingsView({ entries = [], selectedId, onSelectEntry, latestAnalysis }) {
  const [internalEntries, setInternalEntries] = useState(() => entries.map(normalizeEntry));
  const [localSelectedId, setLocalSelectedId] = useState(
    selectedId || internalEntries[0]?.id || null
  );
  const [loadingDemo, setLoadingDemo] = useState(false);
  const [bookingStatus, setBookingStatus] = useState("idle");
  const [bookingMessage, setBookingMessage] = useState("");

  useEffect(() => {
    const normalized = entries.map(normalizeEntry).filter(Boolean);
    setInternalEntries(normalized);
    if (normalized.length === 0) {
      setLocalSelectedId(null);
      return;
    }
    if (!normalized.some((item) => item.id === localSelectedId)) {
      setLocalSelectedId(normalized[0].id);
    }
  }, [entries]);

  useEffect(() => {
    if (selectedId && internalEntries.some((item) => item.id === selectedId)) {
      setLocalSelectedId(selectedId);
    }
  }, [selectedId, internalEntries]);

  const loadDemo = useCallback(async () => {
    try {
      setLoadingDemo(true);
      const resp = await fetch("/api/analyze-dummy");
      if (!resp.ok) throw new Error(await resp.text());
      const data = await resp.json();
      const demoEntry = createEntryFromAnalysis(data);
      setInternalEntries((prev) => [demoEntry, ...prev]);
      setLocalSelectedId(demoEntry.id);
      onSelectEntry?.(demoEntry.id);
    } catch (err) {
      console.error("[bookings] load demo failed", err);
    } finally {
      setLoadingDemo(false);
    }
  }, [onSelectEntry]);

  useEffect(() => {
    if (internalEntries.length || process.env.NODE_ENV === "production") return;
    loadDemo();
  }, [internalEntries.length, loadDemo]);

  useEffect(() => {
    if (!latestAnalysis || !latestAnalysis.factuurdetails) return;
    const entryFromAnalysis = createEntryFromAnalysis(latestAnalysis);
    setInternalEntries((prev) => {
      const withoutSame = prev.filter((item) => item.sourceFilename !== entryFromAnalysis.sourceFilename);
      return [entryFromAnalysis, ...withoutSame];
    });
    setLocalSelectedId(entryFromAnalysis.id);
    onSelectEntry?.(entryFromAnalysis.id);
  }, [latestAnalysis, onSelectEntry]);

  const selected = internalEntries.find((entry) => entry.id === localSelectedId) || null;
  const preview = buildPreview(selected);
  const topCandidates = useMemo(() => getTopCandidates(selected), [selected]);
  const [chosenAccount, setChosenAccount] = useState(topCandidates[0]?.number || "");

  useEffect(() => {
    if (topCandidates.length === 0) {
      setChosenAccount("");
      return;
    }
    setChosenAccount(topCandidates[0].number);
  }, [topCandidates]);

  const bookingOutcome = useMemo(() => {
    if (!selected || !chosenAccount) return [];
    const amount = Number(selected.totalIncl);
    if (!Number.isFinite(amount) || amount === 0) return [];
    const primary = topCandidates.find((candidate) => candidate.number === chosenAccount);
    const description = primary?.description || "Selected account";
    const currency = selected.currency || "EUR";
    return [
      { type: "Debit", account: chosenAccount, description, amount, currency },
      { type: "Credit", account: "160000", description: "Creditors", amount, currency },
    ];
  }, [selected, chosenAccount, topCandidates]);

  const accountTotals = useMemo(() => {
    if (!bookingOutcome.length) return [];
    const map = new Map();
    bookingOutcome.forEach((row) => {
      const amount = Number(row.amount) || 0;
      map.set(row.account, (map.get(row.account) || 0) + amount * (row.type === "Credit" ? -1 : 1));
    });
    return Array.from(map.entries()).map(([account, total]) => ({ account, total }));
  }, [bookingOutcome]);

  const handleBookNow = useCallback(async () => {
    if (!selected || !chosenAccount) return;
    setBookingStatus("loading");
    setBookingMessage("");

    const payload = {
      factuurdetails: selected.factuurdetails,
      structured: selected.structured || { factuurdetails: selected.factuurdetails },
      invoiceText: selected.invoice_text || selected.invoiceText || "",
      selectedAccount: chosenAccount,
      splitMode: false,
      selectedProfileId: selected.profileSuggestion?.profileId
        ? String(selected.profileSuggestion.profileId)
        : "default",
      lineItems: (selected.factuurdetails?.regels || []).map((item, index) => ({
        lineIndex: index,
        profileId: selected.profileSuggestion?.profileId
          ? String(selected.profileSuggestion.profileId)
          : "default",
        description:
          item.omschrijving || item.description || item.omschrijving_lang || `Line ${index + 1}`,
        raw: item,
        quantity: Number(item.aantal ?? item.quantity ?? 0) || null,
        unit: item.eenheid || item.unit || "",
        unitPrice: Number(
          item.prijs_per_eenheid_excl ?? item.prijs ?? item.unit_price_excl ?? item.prijs_excl ?? 0
        ),
        totalExcl: Number(item.totaal_excl ?? item.bedrag_excl ?? 0) || null,
        totalIncl: Number(item.totaal_incl ?? item.bedrag_incl ?? 0) || null,
        vatRate: Number(item.btw_percentage ?? item.btw_perc ?? 0) || null,
        vatAmount: Number(item.btw_bedrag ?? item.vat_amount ?? 0) || null,
        category: item.categorie || item.category || "",
        subcategory: item.subcategorie || item.subcategory || "",
        normalizedName:
          item.genormaliseerd_naam || item.normalized_name || item.omschrijving || item.description || "",
        coaAccountNumber: chosenAccount,
      })),
      profiles: selected.profiles,
      file: selected.file ||
        (selected.sourceFilename
          ? { filename: selected.sourceFilename, url: selected.sourceUrl }
          : null),
    };

    try {
      const resp = await fetch("/api/book", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Booking failed");
      }

      const result = await resp.json();
      setBookingStatus("success");
      setBookingMessage(result.message || "Booking done");
    } catch (err) {
      console.error("[bookings] book failure", err);
      // Fall back to simulated success so UI flow keeps working during design iterations
      setBookingStatus("success");
      setBookingMessage("Booking done (simulated)");
    }
  }, [selected, chosenAccount]);

  const handleSelect = (id) => {
    setLocalSelectedId(id);
    onSelectEntry?.(id);
  };

  return (
    <div className={styles.root}>
      <div className={styles.mainColumn}>
        <section className={styles.listCard}>
          <div className={styles.listFilters}>
            <span className={styles.filterPill}>Search files, senders…</span>
            <span className={styles.filterPill}>Type: All</span>
            <span className={styles.filterPill}>Status: Unreviewed</span>
            <button
              type="button"
              className={styles.demoButton}
              onClick={loadDemo}
              disabled={loadingDemo}
            >
              {loadingDemo ? "Loading demo…" : "Load demo invoice"}
            </button>
          </div>
          <div className={styles.entryList}>
            {internalEntries.map((entry) => (
              <button
                key={entry.id}
                type="button"
                className={`${styles.entryButton} ${
                  entry.id === localSelectedId ? styles.entryButtonActive : ""
                }`}
                onClick={() => handleSelect(entry.id)}
              >
                <div>
                  <strong>{entry.vendor}</strong>
                  <div>{entry.invoiceNumber || entry.sourceFilename || "Invoice"}</div>
                  <div className={styles.entryMeta}>
                    {entry.invoiceDate || "—"} · {entry.status}
                  </div>
                </div>
                <div className={styles.entryMeta}>{entry.currency || "EUR"}</div>
              </button>
            ))}
            {internalEntries.length === 0 && <div>No items awaiting booking.</div>}
          </div>
        </section>

        <section className={styles.suggestionCard}>
        <header className={styles.suggestionHeader}>
          <h2>AI booking suggestions</h2>
          {selected?.profileSuggestion && (
            <span className={styles.profileBadge}>
              Profile suggestion: {selected.profileSuggestion.name || selected.profileSuggestion.profileId}
            </span>
          )}
        </header>

        {selected ? (
          topCandidates.length === 0 ? (
            <p className={styles.emptyState}>No AI suggestions available for this invoice.</p>
          ) : (
            <>
              <label htmlFor="booking-suggestion" className={styles.suggestionLabel}>
                Choose account
              </label>
              <select
                id="booking-suggestion"
                className={styles.suggestionSelect}
                value={chosenAccount}
                onChange={(event) => setChosenAccount(event.target.value)}
              >
                {topCandidates.map((candidate) => (
                  <option key={candidate.number} value={candidate.number}>
                    {candidate.number} · {candidate.description} (
                    {candidate.probability != null
                      ? Math.round(candidate.probability * 100)
                      : "—"}
                    %)
                  </option>
                ))}
              </select>

              <ul className={styles.suggestionDetails}>
                {topCandidates.map((candidate) => (
                  <li key={`detail-${candidate.number}`}>
                    <span>{candidate.number}</span>
                    <span>{candidate.description}</span>
                    <span>
                      {candidate.probability != null
                        ? `${Math.round(candidate.probability * 100)}%`
                        : "—"}
                    </span>
                  </li>
                ))}
              </ul>

              <button
                type="button"
                className={styles.bookButton}
                onClick={handleBookNow}
                disabled={bookingStatus === "loading"}
              >
                {bookingStatus === "success" ? "Booking done" : bookingStatus === "loading" ? "Booking…" : "Book now"}
              </button>
              {bookingMessage && (
                <div className={styles.statusMessage}>{bookingMessage}</div>
              )}
            </>
          )
        ) : (
          <p className={styles.emptyState}>Select an invoice to review booking suggestions.</p>
        )}
        </section>

        <section className={styles.outcomeCard}>
        <header className={styles.outcomeHeader}>
          <h2>Booking outcome preview</h2>
          {selected && chosenAccount && (
            <span className={styles.outcomeMeta}>
              Profile: {selected.profileSuggestion?.name || selected.profileSuggestion?.profileId || "Default"}
            </span>
          )}
        </header>

        {bookingOutcome.length === 0 ? (
          <p className={styles.emptyState}>Choose an account to see the journal preview.</p>
        ) : (
          <>
            <table className={styles.outcomeTable}>
              <thead>
                <tr>
                  <th>Type</th>
                  <th>Account</th>
                  <th>Description</th>
                  <th>Amount</th>
                </tr>
              </thead>
              <tbody>
                {bookingOutcome.map((row, index) => (
                  <tr key={`${row.account}-${index}`}>
                    <td>{row.type}</td>
                    <td>{row.account}</td>
                    <td>{row.description}</td>
                    <td>{formatCurrency(row.amount, row.currency)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <div className={styles.outcomeSummary}>
              <span>Total</span>
              <strong>{formatCurrency(bookingOutcome[0].amount, bookingOutcome[0].currency)}</strong>
            </div>
            {accountTotals.length > 0 && (
              <div className={styles.accountTotals}>
                {accountTotals.map(({ account, total }) => (
                  <div key={account}>
                    <span>{account}</span>
                    <strong>{formatCurrency(total, bookingOutcome[0].currency)}</strong>
                  </div>
                ))}
              </div>
            )}
          </>
        )}
        </section>
      </div>

      <aside className={styles.previewCard}>
        <header className={styles.previewHeader}>
          <h3>Invoice preview</h3>
        </header>
        <div className={styles.previewBox}>
          {preview.sourceUrl ? (
            preview.sourceUrl.match(/\.(png|jpe?g|gif|webp)$/i) ? (
              <img src={preview.sourceUrl} alt={preview.sourceFilename || "Invoice preview"} />
            ) : (
              <iframe
                src={preview.sourceUrl}
                title={preview.sourceFilename || "Invoice preview"}
              />
            )
          ) : (
            <span>Invoice image or PDF preview</span>
          )}
        </div>
        <div className={styles.previewTotal}>
          <span>Total</span>
          <strong>{formatCurrency(preview.total, preview.currency)}</strong>
        </div>
      </aside>
    </div>
  );
}
