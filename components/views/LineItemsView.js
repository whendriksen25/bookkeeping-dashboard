import { useEffect, useMemo, useState } from "react";
import styles from "./LineItemsView.module.css";

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

function normalizeDate(value) {
  if (!value) return null;
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return null;
  return d;
}

const DEFAULT_FILTERS = {
  search: "",
  category: "all",
  subcategory: "all",
  vendor: "all",
  startDate: "",
  endDate: "",
  minAmount: "",
  maxAmount: "",
};

export default function LineItemsView() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [filters, setFilters] = useState(DEFAULT_FILTERS);
  const [draftFilters, setDraftFilters] = useState(DEFAULT_FILTERS);
  const [view, setView] = useState("items");

  useEffect(() => {
    let ignore = false;
    const load = async () => {
      setLoading(true);
      setError("");
      try {
        const resp = await fetch("/api/line-items?limit=800");
        if (!resp.ok) {
          const text = await resp.text();
          throw new Error(text || "Failed to load line items");
        }
        const data = await resp.json();
        if (!ignore) setItems(Array.isArray(data.items) ? data.items : []);
      } catch (err) {
        console.error("[line-items] fetch failed", err);
        if (!ignore) setError(err.message || "Could not load line items");
      } finally {
        if (!ignore) setLoading(false);
      }
    };
    load();
    return () => {
      ignore = true;
    };
  }, []);

  const categories = useMemo(() => {
    const set = new Set();
    items.forEach((item) => {
      if (item.category) set.add(item.category);
    });
    return Array.from(set).sort();
  }, [items]);

  const vendors = useMemo(() => {
    const set = new Set();
    items.forEach((item) => {
      if (item.vendorName) set.add(item.vendorName);
    });
    return Array.from(set).sort();
  }, [items]);

  const subcategories = useMemo(() => {
    const set = new Set();
    items.forEach((item) => {
      if (draftFilters.category !== "all" && item.category !== draftFilters.category) return;
      if (item.subcategory) set.add(item.subcategory);
    });
    return Array.from(set).sort();
  }, [items, draftFilters.category]);

  const filteredItems = useMemo(() => {
    const searchLower = filters.search.trim().toLowerCase();
    const start = filters.startDate ? new Date(filters.startDate) : null;
    const end = filters.endDate ? new Date(filters.endDate) : null;
    const min = filters.minAmount !== "" ? Number(filters.minAmount) : null;
    const max = filters.maxAmount !== "" ? Number(filters.maxAmount) : null;

    return items.filter((item) => {
      const matchesSearch = searchLower
        ? [
            item.description,
            item.vendorName,
            item.invoiceNumber,
            item.category,
            item.subcategory,
          ]
            .filter(Boolean)
            .some((value) => String(value).toLowerCase().includes(searchLower))
        : true;

      const matchesCategory = filters.category === "all" || item.category === filters.category;
      const matchesSubcategory = filters.subcategory === "all" || item.subcategory === filters.subcategory;
      const matchesVendor = filters.vendor === "all" || item.vendorName === filters.vendor;

      const itemDate = normalizeDate(item.invoiceDate);
      const matchesStart = !start || (itemDate && itemDate >= start);
      const matchesEnd = !end || (itemDate && itemDate <= end);

      const amount = Number(item.totalPrice);
      const matchesMin = min === null || (Number.isFinite(amount) && amount >= min);
      const matchesMax = max === null || (Number.isFinite(amount) && amount <= max);

      return (
        matchesSearch &&
        matchesCategory &&
        matchesSubcategory &&
        matchesVendor &&
        matchesStart &&
        matchesEnd &&
        matchesMin &&
        matchesMax
      );
    });
  }, [items, filters]);

  const summary = useMemo(() => {
    const totalAmount = filteredItems.reduce((acc, item) => acc + (Number(item.totalPrice) || 0), 0);
    const uniqueVendors = new Set(filteredItems.map((item) => item.vendorName)).size;
    const uniqueInvoices = new Set(filteredItems.map((item) => item.invoiceNumber)).size;
    const avgCost = filteredItems.length ? totalAmount / filteredItems.length : 0;
    return { totalAmount, uniqueVendors, uniqueInvoices, avgCost };
  }, [filteredItems]);

  const totalsByCategory = useMemo(() => {
    const map = new Map();
    filteredItems.forEach((item) => {
      if (!item.category) return;
      map.set(item.category, (map.get(item.category) || 0) + (Number(item.totalPrice) || 0));
    });
    return Array.from(map.entries())
      .map(([name, total]) => ({ name, total }))
      .sort((a, b) => b.total - a.total);
  }, [filteredItems]);

  const totalsBySubcategory = useMemo(() => {
    const map = new Map();
    filteredItems.forEach((item) => {
      if (!item.subcategory) return;
      const key = `${item.category || ""}::${item.subcategory}`;
      map.set(key, (map.get(key) || 0) + (Number(item.totalPrice) || 0));
    });
    return Array.from(map.entries())
      .map(([key, total]) => {
        const [cat, sub] = key.split("::");
        return { category: cat, subcategory: sub, total };
      })
      .sort((a, b) => b.total - a.total);
  }, [filteredItems]);

  const totalsByVendor = useMemo(() => {
    const map = new Map();
    filteredItems.forEach((item) => {
      const key = item.vendorName || "(unknown vendor)";
      map.set(key, (map.get(key) || 0) + (Number(item.totalPrice) || 0));
    });
    return Array.from(map.entries())
      .map(([name, total]) => ({ name, total }))
      .sort((a, b) => b.total - a.total);
  }, [filteredItems]);

  const invoiceTotals = useMemo(() => {
    const map = new Map();
    filteredItems.forEach((item) => {
      const key = item.invoiceId || item.invoiceNumber;
      if (!key) return;
      const entry = map.get(key) || { lineTotal: 0, invoiceTotal: Number(item.invoiceTotal) || 0 };
      entry.lineTotal += Number(item.totalPrice) || 0;
      if (!entry.invoiceTotal && Number(item.invoiceTotal)) {
        entry.invoiceTotal = Number(item.invoiceTotal);
      }
      map.set(key, entry);
    });
    let taxTotal = 0;
    map.forEach((entry) => {
      const diff = entry.invoiceTotal - entry.lineTotal;
      if (Number.isFinite(diff) && diff > 0) taxTotal += diff;
    });
    const subtotal = filteredItems.reduce((acc, item) => acc + (Number(item.totalPrice) || 0), 0);
    const total = subtotal + taxTotal;
    return { subtotal, taxTotal, total };
  }, [filteredItems]);

  const currency = filteredItems[0]?.currency || "EUR";

  const summaryCards = [
    {
      label: "Total spend",
      value: formatCurrency(summary.totalAmount, currency),
      helper: "Across selected period",
    },
    {
      label: "Items purchased",
      value: String(filteredItems.length),
      helper: "Unique line items",
    },
    {
      label: "Avg. cost / item",
      value: formatCurrency(summary.avgCost, currency),
      helper: "Mean of line items",
    },
    {
      label: "Vendors",
      value: String(summary.uniqueVendors),
      helper: "Active this period",
    },
  ];

  const draftChange = (field) => (event) => {
    const value = event.target.value;
    setDraftFilters((prev) => ({ ...prev, [field]: value }));
  };

  const applyFilters = () => {
    setFilters(draftFilters);
  };

  const clearFilters = () => {
    setDraftFilters(DEFAULT_FILTERS);
    setFilters(DEFAULT_FILTERS);
  };

  const renderTableView = () => {
    if (loading) return <div className={styles.loadingState}>Loading line items…</div>;
    if (error) return <div className={styles.errorState}>{error}</div>;
    if (filteredItems.length === 0) return <div className={styles.emptyState}>No line items match your filters.</div>;

    return (
      <div className={styles.tableWrapper}>
        <table className={styles.table}>
          <thead>
            <tr>
              <th>Invoice</th>
              <th>Date</th>
              <th>Vendor</th>
              <th>Description</th>
              <th>Category</th>
              <th>Subcategory</th>
              <th className={styles.amount}>Quantity</th>
              <th className={styles.amount}>Unit cost</th>
              <th className={styles.amount}>Total</th>
            </tr>
          </thead>
          <tbody>
            {filteredItems.map((item) => (
              <tr key={item.id}>
                <td>{item.invoiceNumber}</td>
                <td>{item.invoiceDate || "—"}</td>
                <td>{item.vendorName}</td>
                <td>{item.description}</td>
                <td>{item.category || "—"}</td>
                <td>{item.subcategory || "—"}</td>
                <td className={styles.amount}>{item.quantity ?? "—"}</td>
                <td className={styles.amount}>{formatCurrency(item.unitPrice, item.currency)}</td>
                <td className={styles.amount}>{formatCurrency(item.totalPrice, item.currency)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };

  const renderGroupTable = (rows, columns) => {
    if (loading) return <div className={styles.loadingState}>Loading line items…</div>;
    if (error) return <div className={styles.errorState}>{error}</div>;
    if (rows.length === 0) return <div className={styles.emptyState}>No data for the current selection.</div>;

    return (
      <div className={styles.tableWrapper}>
        <table className={styles.table}>
          <thead>
            <tr>
              {columns.map((column) => (
                <th key={column.key} className={column.align === "right" ? styles.amount : undefined}>
                  {column.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={`${row.name || row.category || row.vendor}-${index}`}>
                {columns.map((column) => {
                  const value = row[column.key];
                  const content = column.format ? column.format(value) : value;
                  return (
                    <td key={column.key} className={column.align === "right" ? styles.amount : undefined}>
                      {content}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };

  let tableContent;
  if (view === "category") {
    tableContent = renderGroupTable(totalsByCategory, [
      { key: "name", label: "Category" },
      { key: "total", label: "Total", align: "right", format: (v) => formatCurrency(v, currency) },
    ]);
  } else if (view === "subcategory") {
    tableContent = renderGroupTable(totalsBySubcategory, [
      { key: "category", label: "Category" },
      { key: "subcategory", label: "Subcategory" },
      { key: "total", label: "Total", align: "right", format: (v) => formatCurrency(v, currency) },
    ]);
  } else if (view === "vendor") {
    tableContent = renderGroupTable(totalsByVendor, [
      { key: "name", label: "Vendor" },
      { key: "total", label: "Total", align: "right", format: (v) => formatCurrency(v, currency) },
    ]);
  } else {
    tableContent = renderTableView();
  }

  return (
    <div className={styles.root}>
      <aside className={styles.sidebarCard}>
        <div className={styles.sidebarHeader}>
          <h2>Filters</h2>
          <div className={styles.filterActions}>
            <button type="button" className={styles.clearButton} onClick={clearFilters}>
              Clear
            </button>
            <button type="button" className={styles.applyButton} onClick={applyFilters}>
              Apply
            </button>
          </div>
        </div>

        <div className={styles.filterGrid}>
          <label className={styles.filterLabel}>
            Search items, vendors, invoices
            <input
              className={styles.filterInput}
              value={draftFilters.search}
              onChange={draftChange("search")}
              placeholder="Search…"
            />
          </label>
          <label className={styles.filterLabel}>
            Date (from)
            <input
              type="date"
              className={styles.filterInput}
              value={draftFilters.startDate}
              onChange={draftChange("startDate")}
            />
          </label>
          <label className={styles.filterLabel}>
            Date (to)
            <input
              type="date"
              className={styles.filterInput}
              value={draftFilters.endDate}
              onChange={draftChange("endDate")}
            />
          </label>
          <label className={styles.filterLabel}>
            Vendor
            <select
              className={styles.filterSelect}
              value={draftFilters.vendor}
              onChange={draftChange("vendor")}
            >
              <option value="all">All vendors</option>
              {vendors.map((name) => (
                <option key={name} value={name}>
                  {name}
                </option>
              ))}
            </select>
          </label>
          <label className={styles.filterLabel}>
            Category
            <select
              className={styles.filterSelect}
              value={draftFilters.category}
              onChange={(event) => {
                const value = event.target.value;
                setDraftFilters((prev) => ({ ...prev, category: value, subcategory: "all" }));
              }}
            >
              <option value="all">All categories</option>
              {categories.map((name) => (
                <option key={name} value={name}>
                  {name}
                </option>
              ))}
            </select>
          </label>
          <label className={styles.filterLabel}>
            Subcategory
            <select
              className={styles.filterSelect}
              value={draftFilters.subcategory}
              onChange={draftChange("subcategory")}
            >
              <option value="all">All subcategories</option>
              {subcategories.map((name) => (
                <option key={name} value={name}>
                  {name}
                </option>
              ))}
            </select>
          </label>
          <label className={styles.filterLabel}>
            Min amount
            <input
              type="number"
              min="0"
              className={styles.filterInput}
              value={draftFilters.minAmount}
              onChange={draftChange("minAmount")}
            />
          </label>
          <label className={styles.filterLabel}>
            Max amount
            <input
              type="number"
              min="0"
              className={styles.filterInput}
              value={draftFilters.maxAmount}
              onChange={draftChange("maxAmount")}
            />
          </label>
        </div>
      </aside>

      <div className={styles.main}>
        <section className={styles.summaryRow}>
          {summaryCards.map((card) => (
            <div key={card.label} className={styles.summaryCard}>
              <span className={styles.summaryLabel}>{card.label}</span>
              <span className={styles.summaryValue}>{card.value}</span>
              <span className={styles.summaryHelper}>{card.helper}</span>
            </div>
          ))}
        </section>

        <section className={styles.tableCard}>
          <div className={styles.tableHeader}>
            <h3>Overview</h3>
            <div className={styles.tabBar}>
              {[
                { id: "items", label: "All items" },
                { id: "category", label: "By category" },
                { id: "subcategory", label: "By subcategory" },
                { id: "vendor", label: "By vendor" },
              ].map((tab) => (
                <button
                  key={tab.id}
                  type="button"
                  className={`${styles.tabButton} ${view === tab.id ? styles.tabButtonActive : ""}`}
                  onClick={() => setView(tab.id)}
                >
                  {tab.label}
                </button>
              ))}
            </div>
            <button type="button" className={styles.exportButton}>
              Export
            </button>
          </div>

          {tableContent}

          <div className={styles.bottomTotals}>
            <div>
              <span>Subtotal</span>
              <strong>{formatCurrency(invoiceTotals.subtotal, currency)}</strong>
            </div>
            <div>
              <span>Tax</span>
              <strong>{formatCurrency(invoiceTotals.taxTotal, currency)}</strong>
            </div>
            <div>
              <span>Total</span>
              <strong>{formatCurrency(invoiceTotals.total, currency)}</strong>
            </div>
          </div>
        </section>

        <section className={styles.summaryCardAlt}>
          <h3>By category</h3>
          {totalsByCategory.length === 0 ? (
            <div className={styles.emptyState}>No category totals for the current selection.</div>
          ) : (
            <div className={styles.summaryGrid}>
              {totalsByCategory.map((entry) => (
                <div key={entry.name} className={styles.summaryItem}>
                  <span>{entry.name || "(uncategorised)"}</span>
                  <span className={styles.summaryValue}>
                    {formatCurrency(entry.total, currency)}
                  </span>
                </div>
              ))}
            </div>
          )}
        </section>

        <section className={styles.summaryCardAlt}>
          <h3>By subcategory</h3>
          {totalsBySubcategory.length === 0 ? (
            <div className={styles.emptyState}>No subcategory totals for the current selection.</div>
          ) : (
            <div className={styles.summaryGrid}>
              {totalsBySubcategory.map((entry) => (
                <div key={`${entry.category}-${entry.subcategory}`} className={styles.summaryItem}>
                  <span>
                    {entry.category || "(uncategorised)"} · {entry.subcategory || "(none)"}
                  </span>
                  <span className={styles.summaryValue}>
                    {formatCurrency(entry.total, currency)}
                  </span>
                </div>
              ))}
            </div>
          )}
        </section>

        <section className={styles.summaryCardAlt}>
          <h3>By vendor</h3>
          {totalsByVendor.length === 0 ? (
            <div className={styles.emptyState}>No vendor totals for the current selection.</div>
          ) : (
            <div className={styles.summaryGrid}>
              {totalsByVendor.map((entry) => (
                <div key={entry.name} className={styles.summaryItem}>
                  <span>{entry.name}</span>
                  <span className={styles.summaryValue}>{formatCurrency(entry.total, currency)}</span>
                </div>
              ))}
            </div>
          )}
        </section>
      </div>
    </div>
  );
}
