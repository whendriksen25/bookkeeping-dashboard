/* eslint-disable @next/next/no-img-element */
import styles from "./BookingsView.module.css";

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

export default function BookingsView({ entries = [], selectedId, onSelectEntry }) {
  const selected = entries.find((entry) => entry.id === selectedId) || entries[0] || null;
  return (
    <div className={styles.root}>
      <section className={styles.listCard}>
        <div className={styles.listFilters}>
          <span className={styles.filterPill}>Search files, senders…</span>
          <span className={styles.filterPill}>Type: All</span>
          <span className={styles.filterPill}>Status: Unreviewed</span>
        </div>
        <div className={styles.entryList}>
          {entries.map((entry) => (
            <button
              key={entry.id}
              type="button"
              className={styles.entryButton}
              onClick={() => onSelectEntry?.(entry.id)}
              style={{ borderColor: entry.id === selected?.id ? "#0d9488" : "#e2e8f0" }}
            >
              <div>
                <strong>{entry.vendor}</strong>
                <div>{entry.invoiceNumber || entry.sourceFilename}</div>
                <div className={styles.entryMeta}>
                  {entry.invoiceDate || "—"} · {entry.status}
                </div>
              </div>
              <div className={styles.entryMeta}>{entry.currency}</div>
            </button>
          ))}
          {entries.length === 0 && <div>No items awaiting booking.</div>}
        </div>
      </section>

      <section className={styles.detailCard}>
        {selected ? (
          <>
            <div className={styles.sectionColumn}>
              <div className={styles.panelHeader}>
                <div>
                  <h3>Book to Accounting</h3>
                  <div className={styles.entryMeta}>
                    Destination: QuickBooks Online · Company: Northshore LLC
                  </div>
                </div>
                <span className={styles.badge}>Requires review</span>
              </div>
              <div className={styles.actionsRow}>
                <button type="button">Upload</button>
                <button type="button">Import Email</button>
              </div>
              <div className={styles.previewBox}>
                {selected.sourceUrl ? (
                  selected.sourceUrl.match(/\.(png|jpe?g|gif|webp)$/i) ? (
                    <img
                      src={selected.sourceUrl}
                      alt={selected.sourceFilename || "Invoice preview"}
                      style={{ maxWidth: "100%", maxHeight: "100%", borderRadius: 16 }}
                    />
                  ) : (
                    <iframe
                      src={selected.sourceUrl}
                      title={selected.sourceFilename || "Invoice preview"}
                      style={{ width: "100%", height: "100%", border: "none", borderRadius: 16 }}
                    />
                  )
                ) : (
                  "Invoice preview (image/PDF)"
                )}
              </div>
              <div className={styles.detailSpace}>
                <section>
                  <h4>Header</h4>
                  <dl className={styles.detailGrid}>
                    <div>
                      <dt>Vendor</dt>
                      <dd>{selected.vendor}</dd>
                    </div>
                    <div>
                      <dt>Invoice #</dt>
                      <dd>{selected.invoiceNumber || "—"}</dd>
                    </div>
                    <div>
                      <dt>Issue Date</dt>
                      <dd>{selected.invoiceDate || "—"}</dd>
                    </div>
                    <div>
                      <dt>Total</dt>
                      <dd>{formatCurrency(selected.totalIncl, selected.currency)}</dd>
                    </div>
                  </dl>
                </section>

                <section>
                  <h4>Booking Accounts</h4>
                  <div className={styles.chipRow}>
                    <span className={styles.chip}>Default Expense · Office Supplies (6200)</span>
                    <span className={styles.chip}>Tax Account · Sales Tax Payable (2200)</span>
                    <span className={styles.chip}>AP Account · Accounts Payable (2000)</span>
                  </div>
                </section>

                <section>
                  <h4>Line Items & Splits</h4>
                  <div className={styles.lineItems}>
                    <div className={styles.lineItemsHeader}>
                      <span>Description</span>
                      <span>Qty</span>
                      <span>Unit price</span>
                    </div>
                    {(selected.lineItems || []).map((item, index) => (
                      <div key={`${item.description || index}`} className={styles.lineItemRow}>
                        <span>{item.description || `Line ${index + 1}`}</span>
                        <span>{item.quantity ?? "—"}</span>
                        <span>{formatCurrency(item.unitPrice, selected.currency)}</span>
                      </div>
                    ))}
                    {(!selected.lineItems || selected.lineItems.length === 0) && (
                      <div className={styles.lineItemRow}>No line items captured.</div>
                    )}
                  </div>
                </section>

                <section>
                  <h4>Notes</h4>
                  <div className={styles.notesArea}>Approval notes, exceptions, or policy references…</div>
                </section>

                <div className={styles.bottomActions}>
                  <button type="button" className={styles.secondaryButton}>
                    Request Changes
                  </button>
                  <button type="button" className={styles.warningButton}>
                    Reject
                  </button>
                  <button type="button" className={styles.primaryButton}>
                    Approve &amp; Book
                  </button>
                </div>
              </div>
            </div>

            <aside className={styles.sectionColumn}>
              <div>
                <h4>Actions</h4>
                <div className={styles.actionsRow}>
                  <button type="button">Change Connection</button>
                  <button type="button">Sync Vendors</button>
                  <button type="button">Re-run OCR</button>
                </div>
              </div>
            </aside>
          </>
        ) : (
          <div>No booking selected.</div>
        )}
      </section>
    </div>
  );
}
