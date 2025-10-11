/* eslint-disable @next/next/no-img-element */
import UploadForm from "../UploadForm";
import styles from "./CaptureInvoiceView.module.css";
import usePreviewAsset from "../hooks/usePreviewAsset.js";
import formatInvoiceName from "../utils/formatInvoiceName.js";

function buildPreviewData(analysis, fallbackInvoice) {
  const sourceUrl = analysis?.file?.url || fallbackInvoice?.sourceUrl || null;
  const sourceFilename = analysis?.file?.filename || fallbackInvoice?.sourceFilename || null;
  const factuur = analysis?.factuurdetails || fallbackInvoice?.factuurdetails || fallbackInvoice || {};
  const totals = factuur?.totaal || {};
  const total = totals?.totaal_incl_btw ?? factuur?.totaal_incl ?? fallbackInvoice?.totalIncl ?? null;
  const subtotal = totals?.totaal_excl_btw ?? fallbackInvoice?.totalExcl ?? null;
  const tax = totals?.btw ?? fallbackInvoice?.totalVat ?? null;
  const currency = totals?.valuta || factuur?.valuta || fallbackInvoice?.currency || "EUR";
  const vendor = factuur?.afzender?.naam || fallbackInvoice?.vendor || "—";
  const vendorAddress =
    factuur?.afzender?.adres_volledig || fallbackInvoice?.senderAddress || "—";
  const customer = factuur?.ontvanger?.naam || fallbackInvoice?.receiver || "—";
  const invoiceNumber =
    factuur?.factuurnummer || factuur?.referentie || fallbackInvoice?.invoiceNumber || "—";
  const invoiceDate = factuur?.factuurdatum || fallbackInvoice?.invoiceDate || "—";
  const status = factuur?.betaalstatus || fallbackInvoice?.status || "Pending";
  const displayName = formatInvoiceName({
    vendor,
    invoiceDate,
    invoiceNumber,
    fallback: sourceFilename || sourceUrl || "Invoice",
  });

  const rawLineItems = Array.isArray(factuur?.regels)
    ? factuur.regels
    : Array.isArray(fallbackInvoice?.lineItems)
    ? fallbackInvoice.lineItems
    : [];

  const lineItems = rawLineItems.slice(0, 5).map((item, index) => ({
    description:
      item.omschrijving || item.description || item.omschrijving_lang || `Line ${index + 1}`,
    quantity: item.aantal ?? item.quantity ?? "—",
    unitPrice: item.prijs_per_eenheid_excl ?? item.prijs ?? item.unit_price_excl ?? item.unitPrice,
    total: item.totaal_incl ?? item.totaal ?? item.totalPrice ?? item.totalIncl ?? null,
  }));

  return {
    sourceUrl,
    sourceFilename,
    vendor,
    vendorAddress,
    customer,
    invoiceNumber,
    invoiceDate,
    status,
    total,
    subtotal,
    tax,
    currency,
    lineItems,
    displayName,
  };
}

function getUploadStatusClass(status) {
  switch (status) {
    case "Processing":
      return styles.statusProcessing;
    case "Booked":
      return styles.statusBooked;
    case "Pending Review":
      return styles.statusPending;
    default:
      return styles.statusReady;
  }
}

function PreviewPanel({ analysis, fallbackInvoice, selectedAccount, onGoToBookings }) {
  const preview = buildPreviewData(analysis, fallbackInvoice);
  const previewAsset = usePreviewAsset(preview.sourceUrl);
  const previewUrl = previewAsset.url;

  const isImagePreview = (() => {
    if (!previewUrl) return false;
    if (previewAsset.mime) return previewAsset.mime.startsWith("image/");
    return /\.(png|jpe?g|gif|bmp|webp|avif)$/i.test(preview.sourceUrl || "");
  })();

  const isPdfPreview = (() => {
    if (!previewUrl) return false;
    if (previewAsset.mime) return previewAsset.mime.includes("pdf");
    return /\.pdf$/i.test(preview.sourceUrl || "");
  })();
  const suggestions = Array.isArray(analysis?.ai_first_suggestions)
    ? analysis.ai_first_suggestions
    : [];
  const ranking = analysis?.ai_ranking || null;
  const candidates = Array.isArray(analysis?.db_candidates) ? analysis.db_candidates : [];
  const topCandidateNumber = ranking?.keuze_nummer || selectedAccount || candidates[0]?.number || null;

  return (
    <div className={styles.previewStack}>
      <section className={styles.previewCard}>
        <div className={styles.previewHeader}>
          <h2>Preview</h2>
          <div className={styles.previewActions}>
            <button type="button">Rotate</button>
            <button type="button">Enhance</button>
            <button type="button">Download</button>
          </div>
        </div>
        <div className={styles.previewBox}>
          {previewUrl ? (
            isImagePreview ? (
              <img
                src={previewUrl}
                alt={preview.displayName || preview.sourceFilename || "Invoice preview"}
                className={styles.previewImage}
              />
            ) : isPdfPreview ? (
              <iframe
                src={`${previewUrl}#view=FitH`}
                title={preview.displayName || preview.sourceFilename || "Invoice preview"}
                className={styles.previewFrame}
              />
            ) : (
              <iframe
                src={previewUrl}
                title={preview.displayName || preview.sourceFilename || "Invoice preview"}
                className={styles.previewFrame}
              />
            )
          ) : (
            <span>Invoice image or PDF preview</span>
          )}
        </div>
      </section>

      <section className={styles.previewCard}>
        <div className={styles.previewHeader}>
          <h3>AI COA suggestions</h3>
        </div>
        {suggestions.length === 0 ? (
          <p className={styles.emptyState}>Upload or load a demo to see AI suggestions.</p>
        ) : (
          <ul className={styles.suggestionList}>
            {suggestions.map((s, idx) => (
              <li key={`${s.naam || idx}-${idx}`}>
                <div>
                  <span className={styles.suggestionName}>{s.naam || "Unnamed"}</span>
                  {typeof s.kans === "number" && (
                    <span className={styles.suggestionScore}>{Math.round(s.kans * 100)}%</span>
                  )}
                </div>
                {s.uitleg && <p>{s.uitleg}</p>}
              </li>
            ))}
          </ul>
        )}
        {candidates.length > 0 && (
          <div className={styles.candidateList}>
            <span className={styles.metaLabel}>Database matches</span>
            <ul>
              {candidates.slice(0, 5).map((candidate) => (
                <li key={candidate.number} className={candidate.number === topCandidateNumber ? styles.activeCandidate : undefined}>
                  <span>{candidate.number}</span>
                  <span>{candidate.description}</span>
                </li>
              ))}
            </ul>
          </div>
        )}
        <button
          type="button"
          className={styles.bookButton}
          onClick={() => onGoToBookings?.()}
        >
          Suggestion for your bookkeeping system?
        </button>
      </section>
    </div>
  );
}

export default function CaptureInvoiceView({
  analysis,
  profiles,
  profilesLoaded,
  profileError,
  onProfilesChange,
  selectedAccount,
  onSelectAccount,
  recentUploads,
  onUploadComplete,
  onAnalyze,
  fallbackInvoice,
  onGoToBookings,
}) {
  return (
    <div className={styles.page}>
      <header className={styles.header}>
        <div>
          <p className={styles.breadcrumb}>Add Invoice</p>
          <h1>Upload or Capture</h1>
          <p className={styles.subtitle}>
            Drag in receipts, email them, or snap a quick photo. We will extract the details and
            keep the raw data at the bottom for review.
          </p>
        </div>
        <button type="button" className={styles.helpButton}>
          Help
        </button>
      </header>
      <div className={styles.content}>
        <div className={styles.mainColumn}>
          <section className={styles.primaryCard}>
            <UploadForm
              onAnalyze={onAnalyze}
              profiles={profiles}
              profilesLoaded={profilesLoaded}
              onProfilesChange={onProfilesChange}
              selectedAccount={selectedAccount}
              onSelectAccount={onSelectAccount}
              onUploadComplete={onUploadComplete}
              analysis={analysis}
              fallbackInvoice={fallbackInvoice}
              profileError={profileError}
            />
            {profileError && <p className={styles.inlineError}>{profileError}</p>}
          </section>

          <section className={styles.secondaryCard}>
            <div className={styles.sectionHeader}>
              <h2>Recently Added</h2>
              <button type="button" className={styles.viewAllButton}>
                View all
              </button>
            </div>
            <table className={styles.recentTable}>
              <thead>
                <tr>
                  <th>File</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {recentUploads.length === 0 ? (
                  <tr>
                    <td colSpan={3}>No uploads yet.</td>
                  </tr>
                ) : (
                  recentUploads.map((upload) => (
                    <tr key={upload.id}>
                      <td>
                        <div className={styles.fileName}>{upload.filename}</div>
                        {upload.details && <div className={styles.fileMeta}>{upload.details}</div>}
                      </td>
                      <td>
                        <span className={`${styles.statusBadge} ${getUploadStatusClass(upload.status)}`}>
                          {upload.status}
                        </span>
                      </td>
                      <td>
                        <button type="button" className={styles.actionButton}>
                          {upload.action || "View"}
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </section>
        </div>

        <aside className={styles.previewColumn}>
          <PreviewPanel
            analysis={analysis}
            fallbackInvoice={fallbackInvoice}
            selectedAccount={selectedAccount}
            onGoToBookings={onGoToBookings}
          />
        </aside>
      </div>
    </div>
  );
}
