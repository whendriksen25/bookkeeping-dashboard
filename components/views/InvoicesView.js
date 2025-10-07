import styles from "./InvoicesView.module.css";

function getStatusClass(status) {
  switch (status) {
    case "Pending Review":
      return styles.statusPending;
    case "Paid":
      return styles.statusPaid;
    case "Missing Data":
      return styles.statusMissing;
    case "Needs Split":
      return styles.statusReady;
    default:
      return styles.statusBadge;
  }
}

export default function InvoicesView({ invoices = [] }) {
  return (
    <div className={styles.root}>
      <section className={styles.mainCard}>
        <div className={styles.filtersRow}>
          <input className={styles.filterInput} placeholder="Search by vendor, number…" />
          <input className={styles.filterInput} placeholder="Vendor: All" />
          <input className={styles.filterInput} placeholder="Status: Any" />
          <input className={styles.filterInput} placeholder="Date: This month" />
        </div>
        <div className={styles.actionsRow}>
          <button type="button">Import</button>
          <button type="button">Export</button>
        </div>
        <div className={styles.tableWrapper}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>Vendor</th>
                <th>Invoice #</th>
                <th>Date</th>
                <th>Total</th>
                <th>Status</th>
                <th>Assigned To</th>
              </tr>
            </thead>
            <tbody>
              {invoices.length === 0 && (
                <tr>
                  <td colSpan={6}>No invoices yet.</td>
                </tr>
              )}
              {invoices.map((invoice) => (
                <tr key={invoice.id}>
                  <td className={styles.vendorCell}>{invoice.vendor}</td>
                  <td>{invoice.invoiceNumber}</td>
                  <td>{invoice.invoiceDate || "—"}</td>
                  <td>
                    {invoice.totalIncl != null
                      ? new Intl.NumberFormat("en-US", {
                          style: "currency",
                          currency: invoice.currency || "USD",
                        }).format(Number(invoice.totalIncl))
                      : "—"}
                  </td>
                  <td>
                    <span className={`${styles.statusBadge} ${getStatusClass(invoice.status)}`}>
                      {invoice.status}
                    </span>
                  </td>
                  <td>{invoice.assignee || "Unassigned"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className={styles.actionsRow}>
          <button type="button">Mark Paid</button>
          <button type="button">Assign</button>
          <button type="button">Delete</button>
        </div>
      </section>

      <aside className={styles.sidebarCard}>
        <div>
          <h3>Filters</h3>
          <div className={styles.filterList}>
            <div className={styles.filterRow}>
              <span>Status</span>
              <span>Any</span>
            </div>
            <div className={styles.filterRow}>
              <span>Vendor</span>
              <span>All</span>
            </div>
            <div className={styles.filterRow}>
              <span>Assigned</span>
              <span>Anyone</span>
            </div>
            <div className={styles.filterRow}>
              <button type="button" className={styles.secondaryButton}>
                Clear
              </button>
              <button type="button" className={styles.applyButton}>
                Apply
              </button>
            </div>
          </div>
        </div>

        <div>
          <h3>Summary</h3>
          <div className={styles.summaryList}>
            <div>Total invoices: {invoices.length}</div>
            <div>
              Pending: {invoices.filter((inv) => inv.status === "Pending Review").length}
            </div>
            <div>Needs Split: {invoices.filter((inv) => inv.status === "Needs Split").length}</div>
            <div>Paid: {invoices.filter((inv) => inv.status === "Paid").length}</div>
          </div>
        </div>

        <div>
          <h3>Saved Views</h3>
          <div className={styles.savedViews}>
            <button type="button">This month</button>
            <button type="button">Pending review</button>
            <button type="button">Needs split</button>
            <button type="button">Paid</button>
          </div>
        </div>
      </aside>
    </div>
  );
}
