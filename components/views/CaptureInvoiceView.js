/* eslint-disable @next/next/no-img-element */
import BookingDropdown from "../BookingDropdown";
import UploadForm from "../UploadForm";
import styles from "./CaptureInvoiceView.module.css";

const captureTips = [
  "Good light, flat surface, include full document.",
  "Avoid shadows and folds.",
  "Take multiple pages if needed.",
];

const inboxRules = [
  { rule: "Subject contains \"Invoice\"", folder: "Finance/Invoices", action: "Move" },
  { rule: "From: vendors@acme.com", folder: "Vendors", action: "Flag" },
];

function formatCurrency(value, currency = "USD") {
  if (value === null || value === undefined) return "—";
  try {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency,
    }).format(Number(value));
  } catch {
    return `$${Number(value).toFixed(2)}`;
  }
}

function extractFromAnalysis(analysis) {
  if (!analysis) return null;
  const factuur = analysis?.factuurdetails || {};
  const lineItems = Array.isArray(factuur?.regels) ? factuur.regels : [];
  const vendor = factuur?.afzender?.naam || "—";
  const invoiceNumber = factuur?.factuurnummer || factuur?.referentie || "—";
  const currency = factuur?.valuta || factuur?.valuta_code || "USD";
  const total = factuur?.totaal_incl || analysis?.herberekende_totalen?.totaal || null;
  const receivedDate = factuur?.factuurdatum || "—";
  const addressFrom =
    [factuur?.afzender?.naam, factuur?.afzender?.adres?.straat, factuur?.afzender?.adres?.stad]
      .filter(Boolean)
      .join(", ") || "—";
  const addressTo =
    [factuur?.ontvanger?.naam, factuur?.ontvanger?.adres?.straat, factuur?.ontvanger?.adres?.stad]
      .filter(Boolean)
      .join(", ") || "—";
  const contactPhone = factuur?.afzender?.telefoon || factuur?.ontvanger?.telefoon || "—";
  const contactEmail = factuur?.afzender?.email || factuur?.ontvanger?.email || "—";

  return {
    vendor,
    invoiceNumber,
    currency,
    total,
    receivedDate,
    addressFrom,
    addressTo,
    contactPhone,
    contactEmail,
    lineItems: lineItems.map((item, index) => ({
      description: item.omschrijving || item.omschrijving_lang || `Line ${index + 1}`,
      quantity: item.aantal ?? null,
      unitPrice: item.prijs_per_stuk || item.prijs || null,
      totalPrice: item.totaal_incl || item.totaal || null,
    })),
  };
}

function extractFromFallback(fallback) {
  if (!fallback) return null;
  return {
    vendor: fallback.vendor || "—",
    invoiceNumber: fallback.invoiceNumber || "—",
    currency: fallback.currency || "USD",
    total: fallback.totalIncl || null,
    receivedDate: fallback.invoiceDate || "—",
    addressFrom: fallback.senderAddress || "—",
    addressTo: fallback.receiverAddress || "—",
    contactPhone: fallback.contactPhone || "—",
    contactEmail: fallback.contactEmail || "—",
    lineItems: Array.isArray(fallback.lineItems)
      ? fallback.lineItems.map((item, index) => ({
          description: item.description || `Line ${index + 1}`,
          quantity: item.quantity ?? null,
          unitPrice: item.unitPrice ?? null,
          totalPrice: item.totalPrice ?? null,
        }))
      : [],
    sourceUrl: fallback.sourceUrl || null,
    sourceFilename: fallback.sourceFilename || null,
  };
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
}) {
  const preview = extractFromAnalysis(analysis) || extractFromFallback(fallbackInvoice) || {
    vendor: "—",
    invoiceNumber: "—",
    currency: "USD",
    total: null,
    receivedDate: "—",
    addressFrom: "—",
    addressTo: "—",
    contactPhone: "—",
    contactEmail: "—",
    lineItems: [],
    sourceUrl: null,
    sourceFilename: null,
  };

  const previewSource = analysis?.file?.url || preview.sourceUrl;

  return (
    <div className={styles.root}>
      <section className={styles.card}>
        <div className={styles.cardHeader}>
          <h2>Upload or Capture</h2>
          <button type="button" className={styles.helpButton}>
            Help
          </button>
        </div>
        <UploadForm
          onAnalyze={onAnalyze}
          profiles={profiles}
          profilesLoaded={profilesLoaded}
          onProfilesChange={onProfilesChange}
          selectedAccount={selectedAccount}
          onSelectAccount={onSelectAccount}
          onUploadComplete={onUploadComplete}
        />
        {profileError && <p className="text-sm text-red-500 mt-4">{profileError}</p>}
      </section>

      <aside className={styles.previewStack}>
        <div className={styles.card}>
          <div className={styles.cardHeader}>
            <h3>Preview</h3>
            <div className={styles.previewActions}>
              <button type="button">Rotate</button>
              <button type="button">Enhance</button>
              <button type="button">Download</button>
            </div>
          </div>
          <div className={styles.previewBox}>
            {previewSource ? (
              previewSource.match(/\.(png|jpe?g|gif|webp)$/i) ? (
                <img
                  src={previewSource}
                  alt={preview.sourceFilename || "Invoice preview"}
                  style={{ maxWidth: "100%", maxHeight: "100%", borderRadius: 12 }}
                />
              ) : (
                <iframe
                  src={previewSource}
                  title={preview.sourceFilename || "Invoice preview"}
                  style={{ width: "100%", height: "100%", border: "none", borderRadius: 12 }}
                />
              )
            ) : (
              "Invoice image or PDF preview"
            )}
          </div>

          <section className={styles.accountSection}>
            <div className={styles.accountPrimary}>
              <span>{preview.vendor}</span>
              <span className={styles.accountBadge}>{analysis ? "AI suggested" : "From invoice"}</span>
            </div>
            <div className={styles.accountOptions}>
              <button type="button">Acme Holdings</button>
              <button type="button">Bluewave Retail</button>
              <button type="button">New company…</button>
            </div>
          </section>

          {analysis && (
            <BookingDropdown
              analysis={analysis}
              selectedAccount={selectedAccount}
              onAccountChange={onSelectAccount}
            />
          )}

          <section className={styles.panelSection}>
            <h4>Invoice details</h4>
            <dl className={styles.detailGrid}>
              <div>
                <dt>Vendor</dt>
                <dd>{preview.vendor}</dd>
              </div>
              <div>
                <dt>Invoice Date</dt>
                <dd>{preview.receivedDate}</dd>
              </div>
              <div>
                <dt>Total</dt>
                <dd>{formatCurrency(preview.total, preview.currency)}</dd>
              </div>
              <div>
                <dt>Currency</dt>
                <dd>{preview.currency}</dd>
              </div>
              <div>
                <dt>Invoice #</dt>
                <dd>{preview.invoiceNumber}</dd>
              </div>
              <div>
                <dt>Status</dt>
                <dd>{analysis ? "Pending review" : "Awaiting upload"}</dd>
              </div>
            </dl>
          </section>

          <section className={styles.panelSection}>
            <h4>Line items</h4>
            <div className={styles.lineItems}>
              <div className={styles.lineItemsHeader}>
                <span>Description</span>
                <span>Qty</span>
                <span>Unit price</span>
              </div>
              {preview.lineItems.length === 0 && (
                <div className={styles.lineItemRow}>No line items captured.</div>
              )}
              {preview.lineItems.map((item, index) => (
                <div key={`${item.description || index}`} className={styles.lineItemRow}>
                  <span>{item.description || `Line ${index + 1}`}</span>
                  <span>{item.quantity ?? "—"}</span>
                  <span>{formatCurrency(item.unitPrice, preview.currency)}</span>
                </div>
              ))}
            </div>
          </section>

          <section className={styles.panelSection}>
            <h4>Sender (From)</h4>
            <div className={styles.addressBlock}>{preview.addressFrom}</div>
            <h4>Receiver (To)</h4>
            <div className={styles.addressBlock}>{preview.addressTo}</div>
          </section>

          <section className={styles.panelSection}>
            <h4>Contacts</h4>
            <div className={styles.contactGrid}>
              <div>
                <dt>Phone</dt>
                <dd>{preview.contactPhone}</dd>
              </div>
              <div>
                <dt>Email</dt>
                <dd>{preview.contactEmail}</dd>
              </div>
            </div>
          </section>

          <div className={styles.previewActionsFooter}>
            <button type="button" className={styles.secondaryButton}>
              Discard
            </button>
            <button type="button" className={styles.primaryButton}>
              Confirm
            </button>
          </div>
        </div>

        <div className={styles.card}>
          <div className={styles.cardHeader}>
            <h3>Capture Tips</h3>
          </div>
          <div className={styles.tipList}>
            {captureTips.map((tip) => (
              <div key={tip} className={styles.tipItem}>
                {tip}
              </div>
            ))}
          </div>
        </div>

        <div className={styles.card}>
          <div className={styles.cardHeader}>
            <h3>Inbox Rules</h3>
          </div>
          <div className={styles.ruleList}>
            {inboxRules.map((rule) => (
              <div key={rule.rule} className={styles.ruleItem}>
                <strong>{rule.rule}</strong>
                <div>Folder: {rule.folder}</div>
                <div>Action: {rule.action}</div>
              </div>
            ))}
          </div>
        </div>
      </aside>

      <section className={styles.card}>
        <div className={styles.cardHeader}>
          <h3>Recently Added</h3>
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
                  <td>{upload.filename}</td>
                  <td>
                    <span
                      className={`${styles.statusBadge} ${
                        upload.status === "Processing" ? styles.statusProcessing : styles.statusReady
                      }`}
                    >
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
  );
}
