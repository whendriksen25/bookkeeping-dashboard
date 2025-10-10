// components/UploadForm.js
import { useState, useMemo, useEffect, useRef } from "react";
import styles from "./UploadForm.module.css";

const formatCurrency = (value, currency = "EUR") => {
  if (value === null || value === undefined || value === "") return "—";
  const amount = Number(value);
  if (!Number.isFinite(amount)) return String(value);
  try {
    return new Intl.NumberFormat("en-IE", {
      style: "currency",
      currency,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(amount);
  } catch {
    return `${amount.toFixed(2)} ${currency}`;
  }
};

const prettyPrint = (value) => {
  if (value === null || value === undefined) return "—";
  try {
    return JSON.stringify(value, null, 2);
  } catch (err) {
    return String(value);
  }
};

function formatAddress(entity) {
  if (!entity) return "";
  if (entity.adres_volledig) return entity.adres_volledig;
  const parts = [
    entity.straat,
    entity.huisnummer,
    entity.postcode,
    entity.plaats,
    entity.provincie_of_staat || entity.regio,
    entity.land,
  ].filter(Boolean);
  return parts.join(" ") || entity.adres || "";
}

export default function UploadForm({
  onAnalyze,
  profiles = [],
  profilesLoaded = false,
  onProfilesChange,
  selectedAccount,
  onSelectAccount,
  onUploadComplete,
  analysis,
}) {
  const [file, setFile] = useState(null);
  const [uploadedFileMeta, setUploadedFileMeta] = useState(null);
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState(null);
  const [selectedProfileId, setSelectedProfileId] = useState("");
  const [splitMode, setSplitMode] = useState(false);
  const [lineAssignments, setLineAssignments] = useState([]);
  const [bookingState, setBookingState] = useState("idle");
  const [bookingMessage, setBookingMessage] = useState("");
  const [dragActive, setDragActive] = useState(false);
  const [emailCopied, setEmailCopied] = useState(false);
  const demoLoadedRef = useRef(false);

  const fileInputRef = useRef(null);
  const cameraInputRef = useRef(null);

  useEffect(() => {
    if (!emailCopied) return undefined;
    const timer = setTimeout(() => setEmailCopied(false), 2000);
    return () => clearTimeout(timer);
  }, [emailCopied]);

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

  const applyAnalysisResult = (azData, fileMeta = null) => {
    if (!azData) return;

    const enrichedData = fileMeta
      ? { ...(data || {}), ...azData, file: fileMeta }
      : { ...(data || {}), ...azData };

    setData(enrichedData);
    setBookingState("idle");
    setBookingMessage("");

    if (fileMeta) {
      setUploadedFileMeta(fileMeta);
    }

    if (Array.isArray(enrichedData.profiles) && typeof onProfilesChange === "function") {
      onProfilesChange(enrichedData.profiles);
    }

    const suggestedProfile = enrichedData?.profile_suggestion?.profileId
      ? String(enrichedData.profile_suggestion.profileId)
      : "";
    setSelectedProfileId(suggestedProfile);

    const defaultAssignments = Array.isArray(enrichedData?.factuurdetails?.regels)
      ? enrichedData.factuurdetails.regels.map(() => suggestedProfile)
      : [];
    setLineAssignments(defaultAssignments);
    setSplitMode(false);

    if (typeof onSelectAccount === "function") {
      const suggestedAccount =
        enrichedData?.ai_ranking?.keuze_nummer || enrichedData?.db_candidates?.[0]?.number || "";
      onSelectAccount(suggestedAccount || "");
    }

    if (typeof onAnalyze === "function") {
      try {
        onAnalyze(enrichedData);
      } catch (callbackErr) {
        console.warn("onAnalyze callback threw", callbackErr);
      }
    }

    if (typeof onUploadComplete === "function" && fileMeta) {
      try {
        onUploadComplete(fileMeta, enrichedData);
      } catch (callbackErr) {
        console.warn("onUploadComplete callback threw", callbackErr);
      }
    }
  };

  async function handleLoadDummy() {
    try {
      setLoading(true);
      const resp = await fetch("/api/analyze-dummy");
      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Dummy analyse mislukt");
      }
      const dummyData = await resp.json();
      const dummyFileMeta = {
        storage: "dummy",
        filename: "dummy-invoice.pdf",
        url: null,
      };
      setFile(null);
      applyAnalysisResult(dummyData, dummyFileMeta);
    } catch (err) {
      console.error("[dummy] failed", err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (process.env.NODE_ENV === "production") return;
    if (demoLoadedRef.current) return;
    if (data || analysis) return;
    demoLoadedRef.current = true;
    handleLoadDummy();
  }, [data, analysis]);

  useEffect(() => {
    if (!analysis) return;
    setData((prev) => ({ ...(prev || {}), ...analysis }));
  }, [analysis]);

  const inboxAddress = "inbox@aiutofin.app";

  const handleFileSelection = (selectedFile) => {
    if (selectedFile) {
      setFile(selectedFile);
    } else {
      setFile(null);
    }
  };

  const handleFileInputChange = (event) => {
    const selected = event.target.files?.[0];
    handleFileSelection(selected || null);
  };

  const handleCameraInputChange = (event) => {
    const selected = event.target.files?.[0];
    handleFileSelection(selected || null);
  };

  const openFilePicker = (event) => {
    if (event?.stopPropagation) event.stopPropagation();
    fileInputRef.current?.click();
  };

  const openCameraPicker = (event) => {
    if (event?.stopPropagation) event.stopPropagation();
    cameraInputRef.current?.click();
  };

  const handleDragOver = (event) => {
    event.preventDefault();
    event.stopPropagation();
    if (!dragActive) setDragActive(true);
  };

  const handleDragLeave = (event) => {
    event.preventDefault();
    event.stopPropagation();
    setDragActive(false);
  };

  const handleDrop = (event) => {
    event.preventDefault();
    event.stopPropagation();
    setDragActive(false);
    const dropped = event.dataTransfer?.files?.[0];
    if (dropped) {
      handleFileSelection(dropped);
    }
  };

  const clearSelectedFile = () => {
    handleFileSelection(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
    if (cameraInputRef.current) {
      cameraInputRef.current.value = "";
    }
  };

  const formatFileSize = (size) => {
    if (!size && size !== 0) return "";
    if (size < 1024) return `${size} B`;
    if (size < 1024 * 1024) return `${(size / 1024).toFixed(1)} KB`;
    return `${(size / (1024 * 1024)).toFixed(1)} MB`;
  };

  const handleCopyInbox = async () => {
    try {
      await navigator.clipboard.writeText(inboxAddress);
      setEmailCopied(true);
    } catch (err) {
      console.error("[clipboard] failed", err);
    }
  };

  async function handleSubmit(e) {
    e.preventDefault();
    if (!file) return;
    setLoading(true);

    try {
      const formData = new FormData();
      formData.append("file", file);
      const up = await fetch("/api/upload", { method: "POST", body: formData });
      if (!up.ok) {
        const errorText = await up.text();
        console.error("Upload failed", errorText);
        return;
      }
      const upData = await up.json();

      const az = await fetch("/api/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ file: upData }),
      });
      if (!az.ok) {
        const errorText = await az.text();
        console.error("Analyze failed", errorText);
        return;
      }
      const azData = await az.json();
      applyAnalysisResult(azData, upData);
    } finally {
      setLoading(false);
    }
  }

  const lineItems = useMemo(() => {
    return Array.isArray(data?.factuurdetails?.regels) ? data.factuurdetails.regels : [];
  }, [data]);

  const invoiceDetails = data?.factuurdetails || {};
  const totals = invoiceDetails?.totaal || {};
  const summaryCards = [
    { label: "Vendor", value: invoiceDetails?.afzender?.naam || "—" },
    {
      label: "Invoice total",
      value:
        totals?.totaal_incl_btw != null
          ? formatCurrency(totals.totaal_incl_btw, totals?.valuta || "EUR")
          : "—",
    },
    { label: "Status", value: invoiceDetails?.betaalstatus || data?.status || "—" },
    {
      label: "Paid amount",
      value:
        invoiceDetails?.betaald_bedrag != null
          ? formatCurrency(invoiceDetails.betaald_bedrag, totals?.valuta || "EUR")
          : totals?.totaal_incl_btw != null
          ? formatCurrency(totals.totaal_incl_btw, totals?.valuta || "EUR")
          : "—",
    },
  ];

  const paymentInfo = [
    { label: "Invoice #", value: invoiceDetails.factuurnummer || "—" },
    { label: "Invoice date", value: invoiceDetails.factuurdatum || "—" },
    { label: "Due date", value: invoiceDetails.vervaldatum || "—" },
    { label: "Payment method", value: invoiceDetails.betaling_methode || "—" },
    { label: "Reference", value: invoiceDetails.betaal_referentie || "—" },
    { label: "Cashier", value: invoiceDetails.kassier || "—" },
    { label: "Point of sale", value: invoiceDetails.kassa_terminal || "—" },
  ];

  const transactionInfo = [
    { label: "Merchant ID", value: invoiceDetails.merchant_id || "—" },
    { label: "Transaction ID", value: invoiceDetails.transactie_id || "—" },
    { label: "Purchase time", value: invoiceDetails.aankoop_tijd || "—" },
    { label: "Payment time", value: invoiceDetails.betaal_tijd || invoiceDetails.aankoop_tijd || "—" },
  ];

  const miscInfo = [
    { label: "Notes", value: invoiceDetails.opmerkingen || "—" },
    { label: "Opening hours", value: invoiceDetails.openingstijden || "—" },
    { label: "Payment reference", value: invoiceDetails.betaal_referentie || "—" },
    { label: "POS terminal", value: invoiceDetails.kassa_terminal || "—" },
  ];

  const recalculated = data?.herberekende_totalen || {};
  const sender = data?.factuurdetails?.afzender || {};
  const receiver = data?.factuurdetails?.ontvanger || {};
  const loyalty = data?.factuurdetails?.loyalty || {};
  const spaaracties = Array.isArray(loyalty.spaaracties)
    ? loyalty.spaaracties.filter(Boolean)
    : [];
  const profileSuggestion = data?.profile_suggestion || null;
  const rankedProfiles = Array.isArray(profileSuggestion?.ranked)
    ? profileSuggestion.ranked
    : [];
  const selectedProfile = profiles.find((p) => String(p.id) === selectedProfileId);
  const totalsCurrency = totals?.valuta || "EUR";
  const totalsInfo = [
    {
      label: "Subtotal",
      value:
        totals?.totaal_excl_btw != null
          ? formatCurrency(totals.totaal_excl_btw, totalsCurrency)
          : "—",
    },
    {
      label: "Tax",
      value:
        totals?.btw != null ? formatCurrency(totals.btw, totalsCurrency) : "—",
    },
    {
      label: "Total",
      value:
        totals?.totaal_incl_btw != null
          ? formatCurrency(totals.totaal_incl_btw, totalsCurrency)
          : "—",
    },
    { label: "Currency", value: totalsCurrency || "—" },
  ];

  const infoClusters = [
    { title: "Payment", items: paymentInfo },
    { title: "Transaction", items: transactionInfo },
    { title: "Totals", items: totalsInfo },
    { title: "Other Captured Info", items: miscInfo },
  ];

  const senderInfo = [
    { label: "Name", value: sender.naam || "—" },
    { label: "Address", value: formatAddress(sender) || "—" },
    { label: "KvK", value: sender.kvk_nummer || "—" },
    { label: "VAT", value: sender.btw_nummer || "—" },
    { label: "Email", value: sender.email || "—" },
    { label: "Phone", value: sender.telefoon || "—" },
  ];

  const receiverInfo = [
    { label: "Name", value: receiver.naam || "—" },
    { label: "Address", value: formatAddress(receiver) || "—" },
    { label: "KvK", value: receiver.kvk_nummer || "—" },
    { label: "VAT", value: receiver.btw_nummer || "—" },
    {
      label: "Account #",
      value: receiver.klantnummer || receiver.debiteurnummer || "—",
    },
    { label: "Contact", value: receiver.email || receiver.telefoon || "—" },
  ];

  useEffect(() => {
    const suggestedRaw = data?.profile_suggestion?.profileId;
    if (suggestedRaw == null) return;
    const suggestedId = String(suggestedRaw);
    if (!profiles.some((p) => String(p.id) === suggestedId)) return;
    setSelectedProfileId((prev) => (prev ? prev : suggestedId));
  }, [data?.profile_suggestion?.profileId, profiles]);
  useEffect(() => {
    if (splitMode) return;
    if (!lineItems.length) {
      setLineAssignments((prev) => (prev.length ? [] : prev));
      return;
    }
    const fallback = selectedProfileId || "";
    setLineAssignments((prev) => {
      if (prev.length === lineItems.length && prev.every((value) => value === fallback)) {
        return prev;
      }
      return Array.from({ length: lineItems.length }, () => fallback);
    });
  }, [selectedProfileId, splitMode, lineItems]);

  const handleToggleSplit = () => {
    if (!profiles.length) return;
    setSplitMode((prev) => !prev);
    if (!splitMode && lineAssignments.length !== lineItems.length) {
      setLineAssignments(lineItems.map(() => selectedProfileId || ""));
    }
  };

  const handleLineAssignmentChange = (index, value) => {
    setLineAssignments((prev) => {
      const next = [...prev];
      next[index] = value;
      return next;
    });
  };

  const handleApplyProfileToAll = () => {
    setLineAssignments(lineItems.map(() => selectedProfileId || ""));
  };

  const parseAmount = (input) => {
    if (input === null || input === undefined) return 0;
    const normalized = String(input).replace(/[^0-9,.-]/g, "").replace(",", ".");
    const num = Number(normalized);
    return Number.isFinite(num) ? num : 0;
  };

  const splitSummaryEntries = splitMode
    ? Object.values(
        lineAssignments.reduce((acc, rawProfileId, idx) => {
          const key = rawProfileId ? String(rawProfileId) : "default";
          if (!acc[key]) {
            const profileInfo = profiles.find((p) => String(p.id) === key);
            acc[key] = {
              profileId: key,
              name: profileInfo?.name || (key === "default" ? "Geen profiel" : `Profiel ${key}`),
              total: 0,
              lines: 0,
            };
          }
          acc[key].lines += 1;
          acc[key].total += parseAmount(lineItems[idx]?.totaal_incl ?? lineItems[idx]?.totaal_excl ?? 0);
          return acc;
        }, {})
      )
    : [];

  const toNumeric = (value) => {
    if (value === null || value === undefined || value === "") return null;
    const normalized = String(value).replace(/[^0-9,.-]/g, "").replace(",", ".");
    const num = Number(normalized);
    return Number.isFinite(num) ? num : null;
  };

  const buildLineItemsPayload = () => {
    return lineItems.map((item, idx) => {
      const assignedProfileRaw = lineAssignments[idx] || (splitMode ? "" : selectedProfileId || "");
      const resolvedProfile = assignedProfileRaw ? String(assignedProfileRaw) : "default";
      return {
        lineIndex: idx,
        profileId: resolvedProfile,
        description: item.omschrijving ?? item.description ?? "",
        raw: item,
        quantity: toNumeric(item.aantal ?? item.quantity),
        unit: item.eenheid ?? item.unit ?? "",
        unitPrice: toNumeric(
          item.prijs_per_eenheid_excl ?? item.prijs ?? item.unit_price_excl ?? item.prijs_excl
        ),
        totalExcl: toNumeric(item.totaal_excl ?? item.bedrag_excl),
        totalIncl: toNumeric(item.totaal_incl ?? item.bedrag_incl),
        vatRate: toNumeric(item.btw_percentage ?? item.btw_perc),
        vatAmount: toNumeric(item.btw_bedrag ?? item.vat_amount),
        category: item.categorie ?? item.category ?? "",
        subcategory: item.subcategorie ?? item.subcategory ?? "",
        normalizedName: item.genormaliseerd_naam ?? item.normalized_name ?? item.omschrijving ?? item.description ?? "",
        coaAccountNumber: item.coa_account_number || selectedAccount || null,
      };
    });
  };

  const handleBookInvoice = async () => {
    if (!data) return;
    if (!selectedAccount) {
      setBookingState("error");
      setBookingMessage("Kies eerst een grootboekrekening.");
      return;
    }

    if (profiles.length > 0 && !splitMode && !selectedProfileId) {
      setBookingState("error");
      setBookingMessage("Selecteer een profiel voor deze bon of schakel splisten in.");
      return;
    }

    if (splitMode) {
      const missing = lineAssignments.some((value) => !value);
      if (missing) {
        setBookingState("error");
        setBookingMessage("Niet alle regels zijn gekoppeld aan een profiel.");
        return;
      }
    }

    setBookingState("processing");
    setBookingMessage("");

    try {
    const payload = {
      factuurdetails: data.factuurdetails,
      structured: data.structured,
      invoiceText: data.invoice_text,
      selectedAccount,
      splitMode,
      selectedProfileId: selectedProfileId ? String(selectedProfileId) : "default",
      lineItems: buildLineItemsPayload(),
        profiles,
        file: uploadedFileMeta,
      };

      const resp = await fetch("/api/book", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Boeking mislukt");
      }

      const result = await resp.json();
      setBookingState("success");
      setBookingMessage(result.message || "Boeking opgeslagen.");
    } catch (err) {
      console.error("[book] failed", err);
      setBookingState("error");
      setBookingMessage(err.message || "Kon de boeking niet opslaan.");
    }
  };

  return (
    <div className={`${styles.wrapper}`}>
      <form
        onSubmit={handleSubmit}
        className={styles.form}
        onDragOver={handleDragOver}
        onDragEnter={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
      >
        <input
          ref={fileInputRef}
          type="file"
          accept=".pdf,.png,.jpg,.jpeg,.heic,.heif,.heics,image/*"
          onChange={handleFileInputChange}
          className={styles.hiddenInput}
        />
        <input
          ref={cameraInputRef}
          type="file"
          accept="image/*"
          capture="environment"
          onChange={handleCameraInputChange}
          className={styles.hiddenInput}
        />

        <div
          className={`${styles.dropzone} ${dragActive ? styles.dropzoneActive : ""}`}
          onClick={openFilePicker}
          onDragOver={handleDragOver}
          onDragEnter={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
        >
          <svg
            viewBox="0 0 24 24"
            aria-hidden="true"
            focusable="false"
            className={styles.dropzoneIcon}
          >
            <path
              fill="currentColor"
              d="M12 3a1 1 0 0 1 .78.375l4.5 5.5a1 1 0 1 1-1.56 1.25L13 7.74V16a1 1 0 1 1-2 0V7.74L8.28 10.13a1 1 0 0 1-1.56-1.25l4.5-5.5A1 1 0 0 1 12 3Zm-7 12a1 1 0 0 1 2 0v3h10v-3a1 1 0 1 1 2 0v3a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3v-3Z"
            />
          </svg>
          <div className={styles.dropzoneTitle}>Drag &amp; drop invoice files</div>
          <div className={styles.dropzoneHint}>PDF, PNG, JPG up to 25MB</div>
          <button type="button" className={styles.browseButton} onClick={openFilePicker}>
            Browse files
          </button>
        </div>

        <div className={styles.quickActions}>
          <div className={styles.quickCard}>
            <div className={styles.quickCardTitle}>Use Camera</div>
            <div className={styles.quickCardSubtitle}>Snap a photo of your receipt or invoice.</div>
            <div className={styles.quickCardActions}>
              <button type="button" className={styles.quickButton} onClick={openCameraPicker}>
                Open
              </button>
            </div>
          </div>
          <div className={styles.quickCard}>
            <div className={styles.quickCardTitle}>Email In</div>
            <div className={styles.quickCardSubtitle}>
              <span className={styles.inlineHelperText}>Forward invoices directly to Aiutofin.</span>
              <span className={styles.emailBadge}>{inboxAddress}</span>
            </div>
            <div className={styles.quickCardActions}>
              <button type="button" className={styles.quickButton} onClick={handleCopyInbox}>
                Copy
              </button>
              {emailCopied && <span className={styles.copyBadge}>Copied!</span>}
            </div>
          </div>
          <div className={styles.quickCard}>
            <div className={styles.quickCardTitle}>Import from Mailbox</div>
            <div className={styles.quickCardSubtitle}>Fetch invoices from a specific folder.</div>
            <div className={styles.quickCardActions}>
              <button
                type="button"
                className={styles.quickButton}
                onClick={() => console.info("Mailbox import coming soon")}
              >
                Connect
              </button>
            </div>
          </div>
        </div>

        {file && (
          <div className={styles.fileInfo}>
            <div className={styles.fileName}>
              <strong>{file.name}</strong>
              <span>{formatFileSize(file.size)}</span>
            </div>
            <button type="button" className={styles.clearButton} onClick={clearSelectedFile}>
              Remove
            </button>
          </div>
        )}

        <div className={styles.actionRow}>
          <button type="submit" disabled={loading || !file} className={styles.primaryAction}>
            {loading ? "Analyzing…" : "Upload & Analyze"}
          </button>
          <button
            type="button"
            onClick={handleLoadDummy}
            disabled={loading}
            className={styles.secondaryAction}
          >
            Load demo invoice
          </button>
        </div>
      </form>

      {data && (
        <div className={styles.extractedSection}>
          <section className={`${styles.preselectCard} border rounded p-4 bg-gray-50 space-y-3`}>
            <div className={styles.sectionHeading}>
              <h2>Preselect Company & Details</h2>
              {profileSuggestion && (
                <span className={styles.matchBadge}>
                  {Math.round((profileSuggestion.confidence ?? 0) * 100)}% match
                </span>
              )}
            </div>
            <p className={styles.sectionSubheading}>
              Suggested profile: {selectedProfile?.name || "(none selected)"}
            </p>
            {profileSuggestion?.reason && (
              <p className={styles.sectionNote}>{profileSuggestion.reason}</p>
            )}
            {!profilesLoaded ? (
              <p className="text-sm text-gray-600">Loading profiles…</p>
            ) : profiles.length === 0 ? (
              <p className="text-sm text-gray-600">
                No profiles yet. Add a business or personal profile to route invoices automatically.
              </p>
            ) : (
              <div className="space-y-3">
                <div>
                  <label className={styles.fieldLabel} htmlFor="upload-profile-select">
                    Company / Profile
                  </label>
                  <select
                    id="upload-profile-select"
                    className={styles.fieldControl}
                    value={selectedProfileId}
                    onChange={(e) => setSelectedProfileId(e.target.value)}
                  >
                    <option value="">— Select profile —</option>
                    {profiles.map((p) => (
                      <option key={p.id} value={String(p.id)}>
                        {p.name} ({p.type})
                      </option>
                    ))}
                  </select>
                </div>

                {profiles.length > 1 && (
                  <div className={styles.splitRow}>
                    <span>Split invoice over multiple profiles?</span>
                    <div className={styles.splitActions}>
                      <button
                        type="button"
                        onClick={handleToggleSplit}
                        disabled={!lineItems.length}
                        className={styles.splitButton}
                      >
                        {splitMode ? "Cancel split" : "Start split"}
                      </button>
                      {splitMode && (
                        <button
                          type="button"
                          onClick={handleApplyProfileToAll}
                          className={styles.secondarySplitButton}
                        >
                          Apply selected profile to all lines
                        </button>
                      )}
                    </div>
                  </div>
                )}

                {rankedProfiles.length > 0 && (
                  <div className={styles.rankList}>
                    <div className={styles.rankListTitle}>AI profile ranking</div>
                    <ul>
                      {rankedProfiles.map((r) => (
                        <li key={r.profileId}>
                          {r.name || `Profile ${r.profileId}`} – {Math.round((r.probability ?? 0) * 100)}%
                          {r.reason ? ` • ${r.reason}` : ""}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            )}
          </section>

          {/* FACTUURDETAILS */}
          <details className={styles.dropdownCard}>
            <summary className={styles.dropdownSummary}>
              <span>Invoice Overview</span>
              <span className={styles.dropdownChevron}>▾</span>
            </summary>
            <div className={styles.dropdownBody}>
              <div className={styles.summaryGrid}>
                {summaryCards.map((card) => (
                  <div key={card.label} className={styles.summaryCard}>
                    <span className={styles.summaryLabel}>{card.label}</span>
                    <span className={styles.summaryValue}>{card.value}</span>
                  </div>
                ))}
              </div>
            </div>
          </details>

          <section className={styles.dropdownGrid}>
            <details className={styles.dropdownCard}>
              <summary className={styles.dropdownSummary}>
                <span>Sender (Vendor)</span>
                <span className={styles.dropdownChevron}>▾</span>
              </summary>
              <div className={styles.dropdownBody}>
                <div className={styles.infoList}>
                  {senderInfo.map((item) => (
                    <div key={`sender-${item.label}`} className={styles.infoItem}>
                      <span className={styles.infoLabel}>{item.label}</span>
                      <span className={styles.infoValue}>{item.value || "—"}</span>
                    </div>
                  ))}
                </div>
              </div>
            </details>

            <details className={styles.dropdownCard}>
              <summary className={styles.dropdownSummary}>
                <span>Receiver (Your company)</span>
                <span className={styles.dropdownChevron}>▾</span>
              </summary>
              <div className={styles.dropdownBody}>
                <div className={styles.infoList}>
                  {receiverInfo.map((item) => (
                    <div key={`receiver-${item.label}`} className={styles.infoItem}>
                      <span className={styles.infoLabel}>{item.label}</span>
                      <span className={styles.infoValue}>{item.value || "—"}</span>
                    </div>
                  ))}
                </div>
              </div>
            </details>
          </section>

          {(loyalty.bonuskaart_nummer || spaaracties.length > 0 || loyalty.bonus_box || loyalty.bonus_voordeel) && (
            <details className={styles.dropdownCard}>
              <summary className={styles.dropdownSummary}>
                <span>Loyalty &amp; Discounts</span>
                <span className={styles.dropdownChevron}>▾</span>
              </summary>
              <div className={styles.dropdownBody}>
                <div className={styles.infoGrid}>
                  <div className={styles.infoItem}>
                    <span className={styles.infoLabel}>Bonus card</span>
                    <span className={styles.infoValue}>{loyalty.bonuskaart_nummer || "—"}</span>
                  </div>
                  <div className={styles.infoItem}>
                    <span className={styles.infoLabel}>Bonus savings</span>
                    <span className={styles.infoValue}>{loyalty.bonus_voordeel || "—"}</span>
                  </div>
                  <div className={styles.infoItem}>
                    <span className={styles.infoLabel}>Bonus Box</span>
                    <span className={styles.infoValue}>{loyalty.bonus_box || "—"}</span>
                  </div>
                </div>
                {spaaracties.length > 0 && (
                  <ul className={styles.loyaltyList}>
                    {spaaracties.map((actie, idx) => (
                      <li key={idx}>
                        {(actie.type || "Action") + ": " + (actie.aantal || actie.waarde || "—")}
                      </li>
                    ))}
                  </ul>
                )}
              </div>
            </details>
          )}

          {/* LINE ITEMS */}
          <section className={styles.sectionBlock}>
            <div className={styles.sectionHeaderRow}>
              <h2>Line Items</h2>
              {lineItems.length > 0 && (
                <span className={styles.sectionHint}>
                  {lineItems.length} item{lineItems.length === 1 ? "" : "s"}
                  {splitMode ? " • split mode" : ""}
                </span>
              )}
            </div>

          {lineItems.length === 0 ? (
            <div className={styles.emptyState}>No line items captured.</div>
          ) : (
              <div className={styles.lineItemSection}>
                <div className={styles.lineItemTableWrapper}>
                  <table className={styles.lineItemTable}>
                    <thead>
                      <tr>
                        <th><span className={styles.labelWrap}>Code</span></th>
                        <th><span className={styles.labelWrap}>Description</span></th>
                        <th className={styles.numeric}><span className={styles.labelWrap}>Qty</span></th>
                        <th><span className={styles.labelWrap}>Unit</span></th>
                        <th className={styles.numeric}><span className={styles.labelWrap}>Unit Price</span></th>
                        <th className={styles.numeric}><span className={styles.labelWrap}>VAT %</span></th>
                        <th className={styles.numeric}><span className={styles.labelWrap}>VAT Amount</span></th>
                        <th className={styles.numeric}><span className={styles.labelWrap}>Subtotal</span></th>
                        <th className={styles.numeric}><span className={styles.labelWrap}>Total</span></th>
                        <th><span className={styles.labelWrap}>Category</span></th>
                        <th><span className={styles.labelWrap}>Sub<br />category</span></th>
                        <th className={styles.profileHead}><span className={styles.labelWrap}>Profile</span></th>
                      </tr>
                    </thead>
                    <tbody>
                      {lineItems.map((item, idx) => {
                        const assignedProfile = splitMode ? lineAssignments[idx] || "" : selectedProfileId || "";
                        const profileLabel = splitMode
                          ? profiles.find((p) => String(p.id) === String(assignedProfile))?.name ||
                            (assignedProfile ? `Profile ${assignedProfile}` : "No profile")
                          : profiles.find((p) => String(p.id) === String(assignedProfile))?.name || selectedProfile?.name || "No profile";
                        const quantity = toNumeric(item.aantal ?? item.quantity);
                        const unitLabel = item.eenheid ?? item.unit ?? "";
                        const unitPrice = toNumeric(
                          item.prijs_per_eenheid_excl ?? item.prijs ?? item.unit_price_excl ?? item.prijs_excl
                        );
                        const totalExcl = toNumeric(item.totaal_excl ?? item.bedrag_excl);
                        const totalIncl = toNumeric(item.totaal_incl ?? item.bedrag_incl);
                        const vatRate = toNumeric(item.btw_percentage ?? item.btw_perc);
                        const vatAmount = toNumeric(item.btw_bedrag ?? item.vat_amount);
                        const category = item.categorie || item.category || "—";
                        const subcategory = item.subcategorie || item.subcategory || "—";

                        return (
                          <tr key={`summary-${idx}`}>
                            <td>{item.productcode || item.barcode || item.artikelnummer || "—"}</td>
                            <td>{item.omschrijving || item.description || `Line ${idx + 1}`}</td>
                            <td className={styles.numeric}>{quantity != null ? quantity : "—"}</td>
                            <td>{unitLabel || "—"}</td>
                            <td className={styles.numeric}>
                              {unitPrice != null ? formatCurrency(unitPrice, totals?.valuta || "EUR") : "—"}
                            </td>
                            <td className={styles.numeric}>{vatRate != null ? `${vatRate}%` : "—"}</td>
                            <td className={styles.numeric}>
                              {vatAmount != null ? formatCurrency(vatAmount, totals?.valuta || "EUR") : "—"}
                            </td>
                            <td className={styles.numeric}>
                              {totalExcl != null ? formatCurrency(totalExcl, totals?.valuta || "EUR") : "—"}
                            </td>
                            <td className={styles.numeric}>
                              {totalIncl != null ? formatCurrency(totalIncl, totals?.valuta || "EUR") : "—"}
                            </td>
                            <td>{category}</td>
                            <td>{subcategory}</td>
                            <td className={styles.profileCell}>
                              {splitMode ? (
                                <select
                                  className={styles.profileSelectInline}
                                  value={lineAssignments[idx] || ""}
                                  onChange={(e) => handleLineAssignmentChange(idx, e.target.value)}
                                >
                                  <option value="">— select profile —</option>
                                  {profiles.map((p) => (
                                    <option key={p.id} value={String(p.id)}>
                                      {p.name}
                                    </option>
                                  ))}
                                </select>
                              ) : (
                                profileLabel
                              )}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>

              </div>
            )}
          </section>

          {infoClusters.map((cluster) => (
            <details key={cluster.title} className={styles.dropdownCard}>
              <summary className={styles.dropdownSummary}>
                <span>{cluster.title}</span>
                <span className={styles.dropdownChevron}>▾</span>
              </summary>
              <div className={styles.dropdownBody}>
                <div className={styles.infoGrid}>
                  {cluster.items.map((item) => (
                    <div key={`${cluster.title}-${item.label}`} className={styles.infoItem}>
                      <span className={styles.infoLabel}>{item.label}</span>
                      <span className={styles.infoValue}>{item.value || "—"}</span>
                    </div>
                  ))}
                </div>
              </div>
            </details>
          ))}

          {/* CAPTURED RAW DATA */}
          <section className="grid gap-4 md:grid-cols-2">
            <details className="border rounded-xl bg-white shadow-sm p-4 text-sm text-gray-700" open>
              <summary className="font-semibold text-gray-900 cursor-pointer">📦 Captured invoice JSON</summary>
              <pre className="mt-3 p-3 bg-gray-100 rounded whitespace-pre-wrap max-h-72 overflow-auto">
                {prettyPrint(invoiceDetails)}
              </pre>
            </details>
            <details className="border rounded-xl bg-white shadow-sm p-4 text-sm text-gray-700">
              <summary className="font-semibold text-gray-900 cursor-pointer">🧾 Gestandaardiseerde output</summary>
              <pre className="mt-3 p-3 bg-gray-100 rounded whitespace-pre-wrap max-h-72 overflow-auto">
                {prettyPrint(data.structured || data.factuurdetails)}
              </pre>
            </details>
            <details className="border rounded-xl bg-white shadow-sm p-4 text-sm text-gray-700">
              <summary className="font-semibold text-gray-900 cursor-pointer">🧠 AI ranking details</summary>
              <pre className="mt-3 p-3 bg-gray-100 rounded whitespace-pre-wrap max-h-72 overflow-auto">
                {prettyPrint(data.ai_ranking)}
              </pre>
            </details>
            <details className="border rounded-xl bg-white shadow-sm p-4 text-sm text-gray-700">
              <summary className="font-semibold text-gray-900 cursor-pointer">📚 DB candidates (raw)</summary>
              <pre className="mt-3 p-3 bg-gray-100 rounded whitespace-pre-wrap max-h-72 overflow-auto">
                {prettyPrint(data.db_candidates)}
              </pre>
            </details>
          </section>

          <section className="grid gap-4 lg:grid-cols-2">
            <div className="border rounded-xl bg-white shadow-sm p-4 space-y-2">
              <h2 className="text-lg font-semibold text-gray-900">🤖 AI Suggesties</h2>
              {Array.isArray(data.ai_first_suggestions) && data.ai_first_suggestions.length > 0 ? (
                <ul className="space-y-2 text-sm text-gray-700">
                  {data.ai_first_suggestions.map((s, i) => (
                    <li key={i} className="border rounded-lg bg-gray-50 p-3">
                      <div className="font-medium">{s.naam || "—"}{" "}
                        <span className="text-gray-500">({Math.round((s.kans ?? 0) * 100)}%)</span>
                      </div>
                      {s.uitleg && <div className="text-xs text-gray-600 mt-1">{s.uitleg}</div>}
                    </li>
                  ))}
                </ul>
              ) : (
                <div className="text-sm text-gray-600">Geen suggesties terug van AI.</div>
              )}
              {Array.isArray(data.ai_keywords_used) && data.ai_keywords_used.length > 0 && (
                <div className="text-xs text-gray-500">Keywords gebruikt voor DB: {data.ai_keywords_used.join(", ")}</div>
              )}
            </div>

            <details className="border rounded-xl bg-white shadow-sm p-4 text-sm text-gray-700">
              <summary className="font-semibold text-gray-900 cursor-pointer">📄 Ruwe tekst (OCR/parse)</summary>
              <pre className="mt-3 p-3 bg-gray-100 rounded whitespace-pre-wrap max-h-64 overflow-auto">
                {data.invoice_text || "—"}
              </pre>
            </details>
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

            <label className="block text-sm font-medium mb-1" htmlFor="upload-booking-select">
              Te boeken op:
            </label>
            <select
              id="upload-booking-select"
              className="border rounded px-3 py-2 w-full md:w-auto"
              value={selectedAccount || ""}
              onChange={(e) => onSelectAccount?.(e.target.value)}
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

          {/* BOOKING ACTION */}
          <section className="border rounded p-4 bg-white space-y-3">
            <h2 className="text-lg font-semibold">📘 Boeking</h2>
            <p className="text-sm text-gray-600">
              Controleer het grootboeknummer en de profielverdeling voordat je de bon in de database boekt.
            </p>
            <div className="flex flex-wrap gap-3 items-center">
              <button
                type="button"
                onClick={handleBookInvoice}
                disabled={bookingState === "processing" || !selectedAccount || !data}
                className="px-4 py-2 bg-green-600 text-white rounded disabled:opacity-50"
              >
                {bookingState === "processing" ? "Bezig met boeken..." : "Boek naar database"}
              </button>
              {!selectedAccount && (
                <span className="text-sm text-red-600">
                  Kies eerst een grootboekrekening.
                </span>
              )}
              {splitMode && splitSummaryEntries.some((entry) => !entry.profileId) && (
                <span className="text-sm text-red-600">
                  Wijs alle regels aan een profiel toe.
                </span>
              )}
            </div>
            {bookingState === "success" && (
              <div className="text-sm text-green-700">{bookingMessage || "Boeking opgeslagen."}</div>
            )}
            {bookingState === "error" && (
              <div className="text-sm text-red-600">{bookingMessage}</div>
            )}
          </section>
        </div>
      )}
    </div>
  );
}
