import { useEffect, useMemo, useState } from "react";
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
  const [search, setSearch] = useState("");
  const [profileFilter, setProfileFilter] = useState("all");

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

  const profiles = useMemo(() => {
    const map = new Map();
    invoices.forEach((invoice) => {
      const summary = Array.isArray(invoice.bookingSummary) ? invoice.bookingSummary : [];
      if (summary.length === 0) {
        map.set("default", { id: "default", name: "Default" });
      }
      summary.forEach((entry) => {
        const id = entry.profile || "default";
        const name = entry.profileName
          ? entry.profileName
          : id === "default"
          ? "Default"
          : `Profile ${id}`;
        if (!map.has(id)) {
          map.set(id, { id, name });
        }
      });
    });
    return Array.from(map.values()).sort((a, b) => a.name.localeCompare(b.name));
  }, [invoices]);

  const filteredInvoices = useMemo(() => {
    const searchLower = search.trim().toLowerCase();
    return invoices.filter((invoice) => {
      const matchesSearch = searchLower
        ? [invoice.vendor, invoice.invoiceNumber, invoice.status]
            .filter(Boolean)
            .some((value) => String(value).toLowerCase().includes(searchLower))
        : true;

      const matchesProfile = (() => {
        if (profileFilter === "all") return true;
        const summary = Array.isArray(invoice.bookingSummary) ? invoice.bookingSummary : [];
        if (profileFilter === "default") {
          return summary.length === 0 || summary.some((entry) => (entry.profile || "default") === "default");
        }
        return summary.some((entry) => String(entry.profile) === String(profileFilter));
      })();

      return matchesSearch && matchesProfile;
    });
  }, [invoices, search, profileFilter]);

  const summaryStats = useMemo(() => {
    const counts = {
      total: filteredInvoices.length,
      pending: 0,
      booked: 0,
      split: 0,
      paid: 0,
      totalAmount: 0,
    };
    filteredInvoices.forEach((invoice) => {
      const status = (invoice.status || "").toLowerCase();
      if (status === "pending review") counts.pending += 1;
      if (status === "booked") counts.booked += 1;
      if (status === "needs split") counts.split += 1;
      if (status === "paid") counts.paid += 1;
      const amount = Number(invoice.totalIncl);
      if (Number.isFinite(amount)) counts.totalAmount += amount;
    });
    return counts;
  }, [filteredInvoices]);

  return (
    <div className={styles.root}>
      <section className={styles.mainCard}>
        <div className={styles.filtersRow}>
          <input
            className={styles.filterInput}
            placeholder="Search by vendor, number…"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
          />
          <select
            className={styles.filterInput}
            value={profileFilter}
            onChange={(event) => setProfileFilter(event.target.value)}
          >
            <option value="all">All profiles</option>
            {profiles.map((profile) => (
              <option key={profile.id} value={profile.id}>
                {profile.name}
              </option>
            ))}
          </select>
          <input className={styles.filterInput} placeholder="Status: Any" disabled />
          <input className={styles.filterInput} placeholder="Date: This month" disabled />
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
                <th>Invoice</th>
                <th>Date</th>
                <th>Total</th>
                <th>Status</th>
                <th>Booked To</th>
              </tr>
            </thead>
            <tbody>
              {filteredInvoices.length === 0 && (
                <tr>
                  <td colSpan={selectionMode ? 7 : 6}>No invoices yet.</td>
                </tr>
              )}
              {filteredInvoices.map((invoice) => (
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
                  <td>{invoice.displayName || invoice.invoiceNumber || "—"}</td>
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
              <button type="button" className={styles.secondaryButton} onClick={() => setProfileFilter("all")}>
                Reset profile
              </button>
            </div>
          </div>
        </div>

        <div>
          <h3>Summary</h3>
          <div className={styles.summaryList}>
            <div>Total invoices: {summaryStats.total}</div>
            <div>
              Pending: {summaryStats.pending}
            </div>
            <div>Booked: {summaryStats.booked}</div>
            <div>Needs Split: {summaryStats.split}</div>
            <div>Paid: {summaryStats.paid}</div>
            <div>Total amount: {formatAmount(summaryStats.totalAmount, "EUR") || "—"}</div>
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
