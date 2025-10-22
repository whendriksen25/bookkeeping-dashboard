import { useCallback, useEffect, useMemo, useState } from "react";
import styles from "./SimpleView.module.css";

export default function ReportsView() {
  const [summary, setSummary] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [profileNames, setProfileNames] = useState({ default: "Default" });

  useEffect(() => {
    let ignore = false;
    const loadSummary = async () => {
      setLoading(true);
      setError("");
      try {
        const resp = await fetch("/api/reports/financial?includeProfiles=true");
        if (!resp.ok) {
          const text = await resp.text();
          throw new Error(text || "Failed to load financial summary");
        }
        const data = await resp.json();
        if (!ignore) setSummary(data.summary || null);
      } catch (err) {
        if (!ignore) {
          console.error("[reports] load financial summary failed", err);
          setError(err.message || "Could not load summary");
          setSummary(null);
        }
      } finally {
        if (!ignore) setLoading(false);
      }
    };

    loadSummary();
    return () => {
      ignore = true;
    };
  }, []);

  useEffect(() => {
    let ignore = false;
    const loadProfiles = async () => {
      try {
        const resp = await fetch("/api/profiles");
        if (!resp.ok) return;
        const data = await resp.json();
        if (!ignore && Array.isArray(data.profiles)) {
          const map = { default: "Default" };
          data.profiles.forEach((profile) => {
            if (!profile || profile.id == null) return;
            map[String(profile.id)] = profile.name || `Profile ${profile.id}`;
          });
          setProfileNames(map);
        }
      } catch (err) {
        console.warn("[reports] load profiles failed", err);
      }
    };

    loadProfiles();
    return () => {
      ignore = true;
    };
  }, []);

  const profileRows = useMemo(() => {
    if (!summary?.profiles) return [];
    return summary.profiles
      .map((entry) => {
        const aggregate = entry.aggregate || {};
        const pl = aggregate.profitLoss || {};
        const bs = aggregate.balanceSheet || {};
        const revenue = (pl.revenue ?? 0) + (pl.otherIncome ?? 0);
        const expenses = (pl.cogs ?? 0) + (pl.expenses ?? 0) + (pl.otherExpense ?? 0);
        const net = pl.net ?? revenue - expenses;
        return {
          profile: entry.profile,
          label:
            profileNames[String(entry.profile)] ||
            (String(entry.profile) === "default" ? "Default" : `Profile ${entry.profile}`),
          revenue,
          expenses,
          net,
          assets: bs.assets ?? 0,
          liabilities: bs.liabilities ?? 0,
        };
      })
      .sort((a, b) => b.net - a.net);
  }, [summary?.profiles, profileNames]);

  const handleDownloadManagementReport = useCallback(async (profileKey) => {
    try {
      const params = new URLSearchParams();
      if (summary?.filters?.startDate) params.set("startDate", summary.filters.startDate);
      if (summary?.filters?.endDate) params.set("endDate", summary.filters.endDate);
      params.set("profile", profileKey);
      const resp = await fetch(`/api/reports/management?${params.toString()}`);
      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Unable to generate management report");
      }
      const buffer = await resp.arrayBuffer();
      const blob = new Blob([buffer], { type: "application/pdf" });
      const url = URL.createObjectURL(blob);
      const win = window.open(url, "_blank");
      if (!win) {
        const link = document.createElement("a");
        link.href = url;
        link.download = `management-report-${profileKey || "summary"}.pdf`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }
      setTimeout(() => URL.revokeObjectURL(url), 60_000);
    } catch (err) {
      console.error("[reports] management report", err);
      alert(err.message || "Could not generate management report");
    }
  }, [summary]);

  const buildParamsFromFilters = useCallback(() => {
    const params = new URLSearchParams();
    if (summary?.filters?.startDate) params.set("startDate", summary.filters.startDate);
    if (summary?.filters?.endDate) params.set("endDate", summary.filters.endDate);
    return params;
  }, [summary]);

  const handleDownloadCashflowReport = useCallback(async () => {
    try {
      const params = buildParamsFromFilters();
      const resp = await fetch(`/api/reports/cashflow?${params.toString()}`);
      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Unable to generate cash flow report");
      }
      const buffer = await resp.arrayBuffer();
      const blob = new Blob([buffer], { type: "application/pdf" });
      const url = URL.createObjectURL(blob);
      const win = window.open(url, "_blank");
      if (!win) {
        const link = document.createElement("a");
        link.href = url;
        link.download = `liquiditeitsprognose.pdf`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }
      setTimeout(() => URL.revokeObjectURL(url), 60_000);
    } catch (err) {
      console.error("[reports] cashflow report", err);
      alert(err.message || "Could not generate liquidity forecast report");
    }
  }, [buildParamsFromFilters]);

  const handleDownloadPnL = useCallback(async () => {
    try {
      const params = buildParamsFromFilters();
      const resp = await fetch(`/api/reports/pnl?${params.toString()}`);
      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Unable to generate profit & loss report");
      }
      const blob = await resp.blob();
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `profit-and-loss-${Date.now()}.csv`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      setTimeout(() => URL.revokeObjectURL(url), 60_000);
    } catch (err) {
      console.error("[reports] pnl report", err);
      alert(err.message || "Could not generate profit & loss report");
    }
  }, [buildParamsFromFilters]);

  const handleDownloadBalanceSheet = useCallback(async () => {
    try {
      const params = buildParamsFromFilters();
      const resp = await fetch(`/api/reports/balance-sheet?${params.toString()}`);
      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Unable to generate balance sheet report");
      }
      const blob = await resp.blob();
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `balance-sheet-${Date.now()}.csv`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      setTimeout(() => URL.revokeObjectURL(url), 60_000);
    } catch (err) {
      console.error("[reports] balance sheet report", err);
      alert(err.message || "Could not generate balance sheet report");
    }
  }, [buildParamsFromFilters]);

  return (
    <div className={styles.root}>
      <section className={styles.card}>
        <h2>Reports</h2>
        <p className={styles.subtext}>
          Generate period-based financial reports, export CSVs, and share tailored summaries with accountants.
        </p>
        <div className={styles.sectionList}>
          <div>
            <strong>Profit &amp; Loss</strong>
            <div>Compare revenue and expenses across custom periods.</div>
          </div>
          <div>
            <strong>Balance Sheet</strong>
            <div>Track assets, liabilities, and equity for your entities.</div>
          </div>
          <div>
            <strong>Tasks &amp; Approvals</strong>
            <div>Monitor approval workload across accounting teams.</div>
          </div>
        </div>
      </section>

      <section className={styles.section}>
        <h3>Management Reports</h3>
        {loading && <div className={styles.statusNote}>Loading financial summary…</div>}
        {!loading && error && <div className={styles.errorNote}>{error}</div>}
        {!loading && !error && profileRows.length === 0 && (
          <div className={styles.statusNote}>No profiles available yet. Upload and book invoices to generate insights.</div>
        )}
        <div className={styles.reportList}>
          <div className={styles.reportItem}>
            <div>
              <strong>Profit &amp; Loss Statement</strong>
              <div className={styles.reportDescription}>
                Export revenue, COGS, operating expenses, and net profit for the selected period.
              </div>
            </div>
            <button
              type="button"
              className={styles.reportButton}
              onClick={handleDownloadPnL}
              disabled={!summary}
            >
              Create
            </button>
          </div>
          <div className={styles.reportItem}>
            <div>
              <strong>Balance Sheet</strong>
              <div className={styles.reportDescription}>
                Snapshot of assets, liabilities, and equity to share with stakeholders.
              </div>
            </div>
            <button
              type="button"
              className={styles.reportButton}
              onClick={handleDownloadBalanceSheet}
              disabled={!summary}
            >
              Create
            </button>
          </div>
          <div className={styles.reportItem}>
            <div>
              <strong>Liquidity Forecast</strong>
              <div className={styles.reportDescription}>
                30/90/180-day cash flow outlook with operating, investing, and financing projections.
              </div>
            </div>
            <button
              type="button"
              className={styles.reportButton}
              onClick={handleDownloadCashflowReport}
              disabled={!summary}
            >
              Download
            </button>
          </div>
          {profileRows.map((profile) => (
            <div key={profile.profile} className={styles.reportItem}>
              <div>
                <strong>Management Report – {profile.label}</strong>
                <div className={styles.reportDescription}>
                  Net {formatAmount(profile.net)} (Revenue {formatAmount(profile.revenue)}, Expenses {formatAmount(Math.abs(profile.expenses))})
                </div>
              </div>
              <button
                type="button"
                className={styles.reportButton}
                onClick={() => handleDownloadManagementReport(profile.profile)}
              >
                Download
              </button>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}

function formatAmount(value, currency = "EUR") {
  const numeric = Number(value);
  if (!Number.isFinite(numeric)) return "—";
  try {
    return new Intl.NumberFormat("nl-NL", { style: "currency", currency }).format(numeric);
  } catch {
    return `${numeric.toFixed(2)} ${currency}`;
  }
}
