import { useEffect, useState } from "react";
import styles from "./InvoicesView.module.css";

function getStatusClass(status) {
  switch (status) {
    case "Pending Review":
      return styles.statusPending;
    case "Booked":
      return styles.statusBooked;
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

function formatAmount(value, currency) {
  if (value == null) return null;
  const amount = Number(value);
  if (!Number.isFinite(amount)) return null;
  try {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: currency || "EUR",
      maximumFractionDigits: 2,
    }).format(amount);
  } catch {
    return amount.toFixed(2);
  }
}

export default function InvoicesView({ invoices = [], onDeleteSelected }) {
  const [selectionMode, setSelectionMode] = useState(false);
  const [selectedIds, setSelectedIds] = useState(new Set());

  useEffect(() => {
    setSelectedIds((prev) => {
      if (prev.size === 0) return prev;
      const next = new Set();
      invoices.forEach((inv) => {
        if (prev.has(inv.id)) next.add(inv.id);
      });
      if (next.size === prev.size) {
        let identical = true;
        prev.forEach((id) => {
          if (!next.has(id)) identical = false;
        });
        if (identical) return prev;
      }
      return next;
    });
  }, [invoices]);

  useEffect(() => {
    if (selectionMode && invoices.length === 0) {
      setSelectionMode(false);
      setSelectedIds(new Set());
    }
  }, [selectionMode, invoices.length]);

  const selectedCount = selectedIds.size;
  const invoicesCount = invoices.length;
  const allSelected = selectionMode && invoicesCount > 0 && selectedCount === invoicesCount;

  const toggleSelectionMode = () => {
    setSelectionMode((prev) => {
      const next = !prev;
      if (!next) {
        setSelectedIds(new Set());
      }
      return next;
    });
  };

  const handleRowToggle = (invoiceId) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(invoiceId)) {
        next.delete(invoiceId);
      } else {
        next.add(invoiceId);
      }
      return next;
    });
  };

  const handleSelectAll = () => {
    if (allSelected) {
      setSelectedIds(new Set());
    } else {
      setSelectedIds(new Set(invoices.map((inv) => inv.id)));
    }
  };

  const handleDeleteClick = async () => {
    if (!selectedCount || typeof onDeleteSelected !== "function") return;
    try {
      await onDeleteSelected(Array.from(selectedIds));
    } finally {
      setSelectedIds(new Set());
      setSelectionMode(false);
    }
  };

  const handleRowClick = (event, invoiceId) => {
    if (!selectionMode) return;
    const target = event.target;
    if (target instanceof HTMLInputElement || target instanceof HTMLButtonElement) {
      return;
    }
    handleRowToggle(invoiceId);
  };

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
          <div className={styles.actionsLeft}>
            <button type="button" className={styles.secondaryButton} onClick={toggleSelectionMode}>
              {selectionMode ? "Done" : "Select"}
            </button>
            {selectionMode && (
              <>
                <button type="button" className={styles.secondaryButton} onClick={handleSelectAll}>
                  {allSelected ? "Clear all" : "Select all"}
                </button>
                <button
                  type="button"
                  className={styles.dangerButton}
                  onClick={handleDeleteClick}
                  disabled={!selectedCount}
                >
                  Delete selected
                </button>
                {selectedCount > 0 && (
                  <span className={styles.selectionCount}>
                    {selectedCount} selected
                  </span>
                )}
              </>
            )}
          </div>
          <div className={styles.actionsRight}>
            <button type="button" className={styles.secondaryButton}>
              Import
            </button>
            <button type="button" className={styles.secondaryButton}>
              Export
            </button>
          </div>
        </div>
        <div className={styles.tableWrapper}>
          <table className={styles.table}>
            <thead>
              <tr>
                {selectionMode && (
                  <th className={styles.selectionHeader}>
                    <input
                      type="checkbox"
                      checked={allSelected}
                      onChange={handleSelectAll}
                      className={styles.selectionCheckbox}
                    />
                  </th>
                )}
                <th>Vendor</th>
                <th>Invoice #</th>
                <th>Date</th>
                <th>Total</th>
                <th>Status</th>
                <th>Booked To</th>
              </tr>
            </thead>
            <tbody>
              {invoices.length === 0 && (
                <tr>
                  <td colSpan={selectionMode ? 7 : 6}>No invoices yet.</td>
                </tr>
              )}
              {invoices.map((invoice) => (
                <tr
                  key={invoice.id}
                  className={selectionMode && selectedIds.has(invoice.id) ? styles.selectedRow : undefined}
                  onClick={(event) => handleRowClick(event, invoice.id)}
                >
                  {selectionMode && (
                    <td className={styles.selectionCell}>
                      <input
                        type="checkbox"
                        className={styles.selectionCheckbox}
                        checked={selectedIds.has(invoice.id)}
                        onChange={() => handleRowToggle(invoice.id)}
                      />
                    </td>
                  )}
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
                  <td>
                    {Array.isArray(invoice.bookingSummary) && invoice.bookingSummary.length > 0 ? (
                      <div className={styles.bookingSummary}>
                        {invoice.bookingSummary.map((entry, index) => {
                          const profileLabel = entry.profileName
                            ? entry.profileName
                            : entry.profile === "default"
                            ? "Default"
                            : `Profile ${entry.profile}`;
                          const amountLabel = formatAmount(entry.amount, invoice.currency);
                          return (
                            <div
                              key={`${invoice.id}-${entry.profile}-${entry.account || "_"}-${index}`}
                              className={styles.bookingSummaryRow}
                            >
                              <span className={styles.bookingSummaryProfile}>{profileLabel}</span>
                              <span className={styles.bookingSummaryAccount}>{entry.account || "—"}</span>
                              {amountLabel && (
                                <span className={styles.bookingSummaryAmount}>{amountLabel}</span>
                              )}
                            </div>
                          );
                        })}
                      </div>
                    ) : (
                      invoice.assignee || "Unassigned"
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {selectionMode && (
          <div className={styles.secondaryActions}>
            <button
              type="button"
              className={styles.dangerButton}
              onClick={handleDeleteClick}
              disabled={!selectedCount}
            >
              Delete selected
            </button>
            <button type="button" className={styles.secondaryButton} onClick={toggleSelectionMode}>
              Cancel
            </button>
          </div>
        )}
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
            <div>Booked: {invoices.filter((inv) => inv.status === "Booked").length}</div>
            <div>Needs Split: {invoices.filter((inv) => inv.status === "Needs Split").length}</div>
            <div>Paid: {invoices.filter((inv) => inv.status === "Paid").length}</div>
          </div>
        </div>

        <div>
          <h3>Saved Views</h3>
          <div className={styles.savedViews}>
            <button type="button">This month</button>
            <button type="button">Pending review</button>
            <button type="button">Booked</button>
            <button type="button">Needs split</button>
            <button type="button">Paid</button>
          </div>
        </div>
      </aside>
    </div>
  );
}
