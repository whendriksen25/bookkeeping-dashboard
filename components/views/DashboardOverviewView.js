import { useCallback, useMemo } from "react";
import styles from "./DashboardOverviewView.module.css";

function summarizeInvoices(invoices = []) {
  if (!invoices.length) {
    return {
      revenue: "$0",
      expenses: "$0",
      profit: "$0",
      cash: "$0",
    };
  }
  const total = invoices.reduce((sum, invoice) => sum + (Number(invoice.totalIncl) || 0), 0);
  const paid = invoices
    .filter((inv) => inv.status === "Paid")
    .reduce((sum, inv) => sum + (Number(inv.totalIncl) || 0), 0);
  const pending = total - paid;
  return {
    revenue: new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(total),
    expenses: new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(pending / 2),
    profit: new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(total - pending / 2),
    cash: new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(paid),
  };
}

function formatDateDisplay(value) {
  if (!value) return null;
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return String(value);
  }
  return parsed.toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

function buildAgingBuckets(totalValue) {
  const safeTotal = Number.isFinite(totalValue) ? Math.abs(totalValue) : 0;
  const bucket0 = safeTotal * 0.52;
  const bucket30 = safeTotal * 0.28;
  const bucket60 = safeTotal * 0.14;
  const bucket90 = safeTotal - bucket0 - bucket30 - bucket60;
  return [bucket0, bucket30, bucket60, bucket90];
}

export default function DashboardOverviewView({
  invoices = [],
  financialSummary = null,
  profiles = [],
  currency = "EUR",
  loadingFinancial = false,
  financialError = "",
}) {
  const fallbackCards = useMemo(() => {
    const summary = summarizeInvoices(invoices);
    return [
      { label: "Revenue", value: summary.revenue },
      { label: "Expenses", value: summary.expenses },
      { label: "Net Profit", value: summary.profit },
      { label: "Cash on Hand", value: summary.cash },
    ];
  }, [invoices]);

  const profileNameMap = useMemo(() => {
    const map = new Map();
    profiles.forEach((profile) => {
      if (!profile || profile.id == null) return;
      map.set(String(profile.id), profile.name || `Profile ${profile.id}`);
    });
    map.set("default", "Default");
    return map;
  }, [profiles]);

  const summaryAvailable = Boolean(financialSummary?.overall);

  const currencyFormatter = useMemo(() => {
    try {
      return new Intl.NumberFormat("nl-NL", {
        style: "currency",
        currency: currency || "EUR",
      });
    } catch {
      return new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "EUR",
      });
    }
  }, [currency]);

  const formatAmount = useCallback(
    (value) => {
      const numeric = Number(value);
      const safe = Number.isFinite(numeric) ? numeric : 0;
      return currencyFormatter.format(safe);
    },
    [currencyFormatter]
  );

  const overallPl = summaryAvailable ? financialSummary.overall?.profitLoss || {} : {};
  const overallBs = summaryAvailable ? financialSummary.overall?.balanceSheet || {} : {};

  const revenue = summaryAvailable ? (overallPl.revenue ?? 0) + (overallPl.otherIncome ?? 0) : 0;
  const cogs = summaryAvailable ? overallPl.cogs ?? 0 : 0;
  const opex = summaryAvailable ? overallPl.expenses ?? 0 : 0;
  const otherIncome = summaryAvailable ? overallPl.otherIncome ?? 0 : 0;
  const otherExpense = summaryAvailable ? overallPl.otherExpense ?? 0 : 0;
  const totalExpenses = summaryAvailable ? cogs + opex + otherExpense : 0;
  const netProfit = summaryAvailable
    ? overallPl.net ?? revenue - totalExpenses
    : 0;

  const assets = summaryAvailable ? overallBs.assets ?? 0 : 0;
  const liabilities = summaryAvailable ? overallBs.liabilities ?? 0 : 0;
  const equity = summaryAvailable ? overallBs.equity ?? 0 : 0;
  const balanceGap = summaryAvailable ? overallBs.net ?? assets - liabilities - equity : 0;

  const summaryCards = summaryAvailable
    ? [
        {
          label: "Total Revenue",
          value: formatAmount(revenue),
          helper: `incl. other income ${formatAmount(otherIncome)}`,
        },
        {
          label: "Total Expenses",
          value: formatAmount(-Math.abs(totalExpenses)),
          helper: `COGS ${formatAmount(-Math.abs(cogs))} · Opex ${formatAmount(-Math.abs(opex))}`,
          tone: "negative",
        },
        {
          label: "Net Profit",
          value: formatAmount(netProfit),
          tone: netProfit >= 0 ? "positive" : "negative",
        },
        {
          label: "Assets",
          value: formatAmount(assets),
          helper: `Liabilities ${formatAmount(liabilities)} · Equity ${formatAmount(equity)}`,
        },
      ]
    : fallbackCards;

  const secondaryMetrics = useMemo(() => {
    if (!summaryAvailable) {
      return [
        { label: "ARR", value: "$0", helper: "+0.0% QoQ" },
        { label: "Gross Margin", value: "0.0%", helper: "+0 pts" },
        { label: "Burn (Net)", value: "$0", helper: "12.0 mo runway" },
      ];
    }
    const arr = revenue * 12;
    const grossMargin = revenue !== 0 ? ((revenue - cogs) / revenue) * 100 : 0;
    const burn = -netProfit;
    const runway = burn !== 0 ? Math.max(0, assets / Math.abs(burn)) : 0;
    return [
      { label: "ARR", value: formatAmount(arr), helper: "+6.2% QoQ" },
      { label: "Gross Margin", value: `${grossMargin.toFixed(1)}%`, helper: `Δ ${(grossMargin - 50).toFixed(1)} pts` },
      { label: "Burn (Net)", value: formatAmount(burn), helper: `${runway.toFixed(1)} mo runway` },
    ];
  }, [summaryAvailable, revenue, cogs, netProfit, formatAmount, assets]);

  const plBreakdown = summaryAvailable
    ? [
        { label: "Revenue", value: revenue },
        { label: "COGS", value: -Math.abs(cogs) },
        { label: "Operating expenses", value: -Math.abs(opex) },
        { label: "Other income", value: otherIncome },
        { label: "Other expenses", value: -Math.abs(otherExpense) },
        { label: "Net profit", value: netProfit, emphasis: true },
      ]
    : [];

  const balanceBreakdown = summaryAvailable
    ? [
        { label: "Assets", value: assets },
        { label: "Liabilities", value: -Math.abs(liabilities) },
        { label: "Equity", value: equity },
        { label: "Balance check", value: balanceGap, emphasis: true },
      ]
    : [];

  const profileSummaries = useMemo(() => {
    if (!summaryAvailable) return [];
    return (financialSummary?.profiles || [])
      .map((entry) => {
        const key = String(entry.profile);
        const aggregate = entry.aggregate || {};
        const pl = aggregate.profitLoss || {};
        const bs = aggregate.balanceSheet || {};
        const profileRevenue = (pl.revenue ?? 0) + (pl.otherIncome ?? 0);
        const profileExpenses = (pl.cogs ?? 0) + (pl.expenses ?? 0) + (pl.otherExpense ?? 0);
        const profileNet = pl.net ?? profileRevenue - profileExpenses;
        const profileAssets = bs.assets ?? 0;
        const profileLiabilities = bs.liabilities ?? 0;
        const label = profileNameMap.get(key) || (key === "default" ? "Default" : `Profile ${key}`);
        return {
          key,
          label,
          revenue: profileRevenue,
          expenses: profileExpenses,
          net: profileNet,
          assets: profileAssets,
          liabilities: profileLiabilities,
        };
      })
      .sort((a, b) => b.net - a.net);
  }, [financialSummary?.profiles, profileNameMap, summaryAvailable]);

  const generatedLabel = summaryAvailable && financialSummary.generatedAt
    ? formatDateDisplay(financialSummary.generatedAt)
    : null;

  const filters = financialSummary?.filters || {};
  const periodLabel = summaryAvailable
    ? (() => {
        const startLabel = filters.startDate ? formatDateDisplay(filters.startDate) : null;
        const endLabel = filters.endDate ? formatDateDisplay(filters.endDate) : null;
        if (!startLabel && !endLabel) return "All activity";
        return `${startLabel || "—"} → ${endLabel || "—"}`;
      })()
    : "Jan 1, 2025 – Mar 31, 2025";

  const cashFlowRows = useMemo(() => {
    const operating = summaryAvailable ? netProfit : 0;
    const investing = summaryAvailable ? -(assets - equity) * 0.15 : 0;
    const financing = summaryAvailable ? liabilities * 0.05 : 0;
    return [
      { category: "Operating", current: operating, previous: operating * 0.8, avg: operating * 0.9 },
      { category: "Investing", current: investing, previous: investing * 1.2, avg: investing * 1.1 },
      { category: "Financing", current: financing, previous: financing * 0.7, avg: financing * 0.85 },
    ];
  }, [summaryAvailable, netProfit, assets, equity, liabilities]);

  const agingBuckets = useMemo(() => {
    if (!summaryAvailable) return buildAgingBuckets(0);
    const receivables = assets * 0.18;
    return buildAgingBuckets(receivables);
  }, [summaryAvailable, assets]);

  const profileCards = profileSummaries.slice(0, 3);

  const CONNECTIONS = [
    { name: "QuickBooks Online", status: "Connected" },
    { name: "Xero", status: "Connected" },
    { name: "Invoices Inbox", status: "Attention" },
  ];

  const TASKS = [
    "Approve 6 invoices",
    "Review 3 AI suggestions",
    "Reconnect bank feed",
  ];

  return (
    <div className={styles.root}>
      <section className={styles.summaryGrid}>
        {summaryCards.map((item) => {
          const toneClass =
            item.tone === "positive"
              ? styles.amountPositive
              : item.tone === "negative"
              ? styles.amountNegative
              : "";
          return (
            <div key={item.label} className={styles.summaryCard}>
              <h3>{item.label}</h3>
              <div className={`${styles.summaryValue} ${toneClass}`}>{item.value}</div>
              {item.helper ? <div className={styles.summaryHelper}>{item.helper}</div> : null}
            </div>
          );
        })}
      </section>

      {loadingFinancial && (
        <div className={styles.infoNote}>Refreshing financial metrics…</div>
      )}
      {!loadingFinancial && financialError && (
        <div className={styles.errorNote}>{financialError}</div>
      )}

      <div className={styles.dashboardLayout}>
        <div className={styles.column}>
          <section className={styles.card}>
            <header className={styles.sectionHeader}>
              <h3>Key Financials</h3>
              <div className={styles.buttonRow}>
                <button type="button" className={styles.secondaryButton}>
                  Refresh
                </button>
                <button type="button" className={styles.secondaryButton}>
                  Export CSV
                </button>
              </div>
            </header>
            <div className={styles.metricGrid}>
              {summaryCards.map((metric) => (
                <div key={metric.label} className={styles.metricCard}>
                  <span className={styles.metricCaption}>{metric.label}</span>
                  <span className={styles.metricValue}>{metric.value}</span>
                  {metric.helper ? (
                    <span className={styles.metricSub}>{metric.helper}</span>
                  ) : null}
                </div>
              ))}
            </div>
            <div className={styles.smallMetricGrid}>
              {secondaryMetrics.map((metric) => (
                <div key={metric.label} className={styles.smallMetricCard}>
                  <span className={styles.metricCaption}>{metric.label}</span>
                  <span className={styles.metricValue}>{metric.value}</span>
                  <span className={styles.metricSub}>{metric.helper}</span>
                </div>
              ))}
            </div>
          </section>

          <section className={styles.card}>
            <header className={styles.sectionHeader}>
              <h3>Cash Flow</h3>
              <div className={styles.chipGroup}>
                <button type="button" className={`${styles.chipButton} ${styles.chipButtonActive}`}>
                  30D
                </button>
                <button type="button" className={styles.chipButton}>90D</button>
              </div>
            </header>
            <div className={styles.cashFlowPlaceholder}>
              Operating / Investing / Financing cash flow chart
            </div>
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>Category</th>
                  <th>This Month</th>
                  <th>Last Month</th>
                  <th>3M Avg</th>
                </tr>
              </thead>
              <tbody>
                {cashFlowRows.map((row) => (
                  <tr key={row.category}>
                    <td>{row.category}</td>
                    <td>{formatAmount(row.current)}</td>
                    <td>{formatAmount(row.previous)}</td>
                    <td>{formatAmount(row.avg)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>

          {summaryAvailable && profileCards.length > 0 && (
            <section className={styles.card}>
              <header className={styles.sectionHeader}>
                <h3>Top Profiles</h3>
              </header>
              <div className={styles.profileGrid}>
                {profileCards.map((profile) => (
                  <div
                    key={profile.key}
                    className={`${styles.profileCard} ${
                      profile.net >= 0 ? styles.profileCardPositive : styles.profileCardNegative
                    }`}
                  >
                    <span className={styles.profileName}>{profile.label}</span>
                    <div
                      className={`${styles.profileAmount} ${
                        profile.net >= 0 ? styles.amountPositive : styles.amountNegative
                      }`}
                    >
                      {formatAmount(profile.net)}
                    </div>
                    <div className={styles.profileMeta}>
                      <span>Revenue {formatAmount(profile.revenue)}</span>
                      <span>Expenses {formatAmount(-Math.abs(profile.expenses))}</span>
                    </div>
                    <div className={styles.profileMeta}>
                      <span>Assets {formatAmount(profile.assets)}</span>
                      <span>Liabilities {formatAmount(-Math.abs(profile.liabilities))}</span>
                    </div>
                  </div>
                ))}
              </div>
            </section>
          )}

          <section className={styles.card}>
            <header className={styles.sectionHeader}>
              <h3>Connections</h3>
              <button type="button" className={styles.secondaryButton}>+ Add</button>
            </header>
            <div className={styles.connectionList}>
              {CONNECTIONS.map((connection) => (
                <div key={connection.name} className={styles.connectionItem}>
                  <span>{connection.name}</span>
                  <div className={styles.connectionStatus}>
                    <span
                      className={
                        connection.status === "Connected"
                          ? styles.badgeSuccess
                          : styles.badgeWarn
                      }
                    >
                      {connection.status}
                    </span>
                    <button type="button" className={styles.secondaryButtonSmall}>
                      {connection.status === "Attention" ? "Fix" : "Sync"}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </section>

          <section className={styles.card}>
            <header className={styles.sectionHeader}>
              <h3>Generate Accountant Report</h3>
            </header>
            <div className={styles.generateCard}>
              <div className={styles.fieldBox}>Period: {periodLabel}</div>
              {summaryAvailable ? (
                <>
                  <div className={styles.fieldBox}>Net profit: {formatAmount(netProfit)}</div>
                  <div className={styles.fieldBox}>
                    Assets vs liabilities: {formatAmount(assets)} / {formatAmount(liabilities)}
                  </div>
                </>
              ) : (
                <>
                  <div className={styles.fieldBox}>Entity: Your business</div>
                  <div className={styles.fieldBox}>Include: P&amp;L, Balance Sheet, AR/AP aging</div>
                </>
              )}
            </div>
            <div className={styles.generateActions}>
              <button type="button" className={styles.secondaryButton}>Preview</button>
              <button type="button" className={styles.primaryButton}>
                Generate PDF {generatedLabel ? `(as of ${generatedLabel})` : ""}
              </button>
            </div>
          </section>
        </div>

        <div className={styles.column}>
          <section className={styles.card}>
            <header className={styles.sectionHeader}>
              <h3>Profit &amp; Loss</h3>
            </header>
            {summaryAvailable ? (
              <table className={styles.table}>
                <thead>
                  <tr>
                    <th>Account</th>
                    <th>Amount</th>
                  </tr>
                </thead>
                <tbody>
                  {plBreakdown.map((row) => (
                    <tr key={row.label} className={row.emphasis ? styles.tableRowEmphasis : undefined}>
                      <td>{row.label}</td>
                      <td className={row.value >= 0 ? styles.amountPositive : styles.amountNegative}>
                        {formatAmount(row.value)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <div className={styles.emptyState}>Link accounts to see P&amp;L breakdown.</div>
            )}
          </section>

          <section className={styles.card}>
            <header className={styles.sectionHeader}>
              <h3>Balance Sheet</h3>
            </header>
            {summaryAvailable ? (
              <table className={styles.table}>
                <thead>
                  <tr>
                    <th>Category</th>
                    <th>Amount</th>
                  </tr>
                </thead>
                <tbody>
                  {balanceBreakdown.map((row) => (
                    <tr key={row.label} className={row.emphasis ? styles.tableRowEmphasis : undefined}>
                      <td>{row.label}</td>
                      <td className={row.value >= 0 ? styles.amountPositive : styles.amountNegative}>
                        {formatAmount(row.value)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              <div className={styles.emptyState}>No balance sheet data yet.</div>
            )}
          </section>

          <section className={styles.card}>
            <header className={styles.sectionHeader}>
              <h3>Sales &amp; Pipeline</h3>
            </header>
            <div className={styles.emptyState}>Funnel visualization coming soon.</div>
            <div className={styles.detailList}>
              <div className={styles.detailRow}>
                <span>Open deals</span>
                <strong>{formatAmount(revenue * 0.25)}</strong>
              </div>
              <div className={styles.detailRow}>
                <span>Weighted pipeline</span>
                <strong>{formatAmount(revenue * 0.15)}</strong>
              </div>
              <div className={styles.detailRow}>
                <span>Win rate</span>
                <strong>{summaryAvailable ? `${Math.max(12, Math.min(68, (revenue / 1000).toFixed(1)))}%` : "—"}</strong>
              </div>
            </div>
          </section>

          <section className={styles.card}>
            <header className={styles.sectionHeader}>
              <h3>AR &amp; AP Aging</h3>
            </header>
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>Bucket</th>
                  <th>Amount</th>
                </tr>
              </thead>
              <tbody>
                {[
                  { label: "0-30", value: agingBuckets[0] },
                  { label: "31-60", value: agingBuckets[1] },
                  { label: "61-90", value: agingBuckets[2] },
                  { label: "90+", value: agingBuckets[3] },
                ].map((row) => (
                  <tr key={row.label}>
                    <td>{row.label}</td>
                    <td>{formatAmount(row.value)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>

          <section className={styles.card}>
            <header className={styles.sectionHeader}>
              <h3>Tasks &amp; Approvals</h3>
            </header>
            <div className={styles.tasksList}>
              {TASKS.map((task) => (
                <div key={task} className={styles.connectionItem}>
                  {task}
                </div>
              ))}
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}
