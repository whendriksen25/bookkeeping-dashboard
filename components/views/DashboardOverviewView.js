import { useMemo } from "react";
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

  const formatAmount = (value) => {
    const numeric = Number(value);
    const safe = Number.isFinite(numeric) ? numeric : 0;
    return currencyFormatter.format(safe);
  };

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

      {summaryAvailable && (
        <section className={styles.gridTwo}>
          <div className={styles.card}>
            <h3>Profit &amp; Loss</h3>
            <div className={styles.detailList}>
              {plBreakdown.map((row) => {
                const toneClass =
                  row.value > 0
                    ? styles.amountPositive
                    : row.value < 0
                    ? styles.amountNegative
                    : "";
                return (
                  <div
                    key={row.label}
                    className={`${styles.detailRow} ${row.emphasis ? styles.detailRowEmphasis : ""}`}
                  >
                    <span>{row.label}</span>
                    <strong className={toneClass}>{formatAmount(row.value)}</strong>
                  </div>
                );
              })}
            </div>
          </div>
          <div className={styles.card}>
            <h3>Balance Sheet</h3>
            <div className={styles.detailList}>
              {balanceBreakdown.map((row) => {
                const toneClass =
                  row.value > 0
                    ? styles.amountPositive
                    : row.value < 0
                    ? styles.amountNegative
                    : "";
                return (
                  <div
                    key={row.label}
                    className={`${styles.detailRow} ${row.emphasis ? styles.detailRowEmphasis : ""}`}
                  >
                    <span>{row.label}</span>
                    <strong className={toneClass}>{formatAmount(row.value)}</strong>
                  </div>
                );
              })}
            </div>
          </div>
        </section>
      )}

      {summaryAvailable && profileSummaries.length > 0 && (
        <section>
          <h3 className={styles.sectionTitle}>Performance by profile</h3>
          <div className={styles.profileGrid}>
            {profileSummaries.map((profile) => {
              const toneClass =
                profile.net > 0
                  ? styles.profileCardPositive
                  : profile.net < 0
                  ? styles.profileCardNegative
                  : "";
              return (
                <div key={profile.key} className={`${styles.profileCard} ${toneClass}`}>
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
              );
            })}
          </div>
        </section>
      )}

      <section className={styles.gridTwo}>
        <div className={styles.card}>
          <h3>Connections</h3>
          <div className={styles.connectionList}>
            {CONNECTIONS.map((connection) => (
              <div key={connection.name} className={styles.connectionItem}>
                <span>{connection.name}</span>
                <span
                  className={
                    connection.status === "Connected" ? styles.badgeSuccess : styles.badgeWarn
                  }
                >
                  {connection.status}
                </span>
              </div>
            ))}
          </div>
        </div>
        <div className={styles.card}>
          <h3>Tasks &amp; Approvals</h3>
          <div className={styles.tasksList}>
            {TASKS.map((task) => (
              <div key={task} className={styles.connectionItem}>
                {task}
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className={styles.card}>
        <h3>Generate Accountant Report</h3>
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
        <button type="button" className={styles.primaryButton}>
          Generate PDF {generatedLabel ? `(as of ${generatedLabel})` : ""}
        </button>
      </section>
    </div>
  );
}
