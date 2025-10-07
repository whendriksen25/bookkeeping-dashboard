import styles from "./InboxView.module.css";

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

export default function InboxView({ entries = [], selectedId, onSelectEntry }) {
  const selected = entries.find((entry) => entry.id === selectedId) || entries[0] || null;
  return (
    <div className={styles.root}>
      <section className={styles.columnCard}>
        <div className={styles.listFilters}>
          <span className={styles.filterPill}>Search files, senders…</span>
          <span className={styles.filterPill}>Type: All</span>
          <span className={styles.filterPill}>Status: Unreviewed</span>
        </div>
        <div className={styles.queueList}>
          {entries.map((item) => (
            <button
              key={item.id}
              type="button"
              className={styles.queueItem}
              onClick={() => onSelectEntry?.(item.id)}
              style={{ borderColor: item.id === selected?.id ? "#0d9488" : "#e2e8f0" }}
            >
              <div>
                <strong>{item.vendor}</strong>
                <div>{item.invoiceNumber || item.sourceFilename}</div>
                <div style={{ fontSize: "0.75rem", color: "#94a3b8" }}>
                  {item.invoiceDate || "—"} · {item.status}
                </div>
              </div>
              <div>{item.assignee || "Unassigned"}</div>
            </button>
          ))}
          {entries.length === 0 && <div>No invoices in the inbox yet.</div>}
        </div>
      </section>

      <section className={styles.detailCard}>
        {selected ? (
          <>
            <div className={styles.invoiceMeta}>
              <div>
                <h3>Book to Accounting</h3>
                <p style={{ color: "#94a3b8", fontSize: "0.85rem" }}>
                  Destination: QuickBooks Online · Company: Northshore LLC
                </p>
              </div>
              <div className={styles.accountChips}>
                <span className={styles.chip}>Suggested account: Office Supplies</span>
                <span className={styles.chip}>Status: {selected.status}</span>
              </div>
              <div className={styles.lineChips}>
                {(selected.lineItems || []).map((item, index) => (
                  <span key={`${item.description || index}`} className={styles.chip}>
                    {item.description || `Line ${index + 1}`} ·
                    {formatCurrency(item.totalPrice, selected.currency)}
                  </span>
                ))}
              </div>
            </div>

            <aside className={styles.detailPanel}>
              <div>
                <h4>Invoice details</h4>
                <div className={styles.chip}>
                  {selected.vendor} · {selected.invoiceNumber}
                </div>
                <div className={styles.chip}>Issue: {selected.invoiceDate || "—"}</div>
                <div className={styles.chip}>
                  Total: {formatCurrency(selected.totalIncl, selected.currency)}
                </div>
              </div>
              <div>
                <h4>Line items & splits</h4>
                {(selected.lineItems || []).map((item, index) => (
                  <div key={`${item.description || index}`} className={styles.chip}>
                    {item.description || `Line ${index + 1}`} · {item.quantity ?? "—"} × {formatCurrency(item.unitPrice, selected.currency)}
                  </div>
                ))}
              </div>
              <div>
                <h4>Notes</h4>
                <div className={styles.notesArea}>Approval notes, exceptions, or policy references…</div>
              </div>
              <div className={styles.actionRow}>
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
            </aside>
          </>
        ) : (
          <div>No invoice selected.</div>
        )}
      </section>
    </div>
  );
}
