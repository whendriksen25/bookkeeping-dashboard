import { requireAuth } from "../../../lib/auth.js";
import { getFinancialSummary } from "../../../lib/reports.js";
import { listProfiles } from "../../../lib/profiles.js";

function formatAmount(value, currency = "EUR") {
  const numeric = Number(value);
  if (!Number.isFinite(numeric)) return "0";
  try {
    return new Intl.NumberFormat("nl-NL", {
      style: "currency",
      currency,
    }).format(numeric);
  } catch {
    return `${numeric.toFixed(2)} ${currency}`;
  }
}

function toCsv(rows) {
  return rows
    .map((row) =>
      row
        .map((cell) => {
          const value = cell == null ? "" : String(cell);
          const escaped = value.replace(/"/g, '""');
          return `"${escaped}"`;
        })
        .join(",")
    )
    .join("\n");
}

function buildPeriodLabel(filters) {
  if (!filters) return "All activity";
  const { startDate, endDate } = filters;
  const format = (value) => {
    if (!value) return null;
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) return String(value);
    return parsed.toLocaleDateString(undefined, {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  };
  const startLabel = format(startDate);
  const endLabel = format(endDate);
  if (!startLabel && !endLabel) return "All activity";
  return `${startLabel || "—"} → ${endLabel || "—"}`;
}

function resolveAggregate(summary, profileKey) {
  if (!summary) return null;
  if (!profileKey) {
    return summary.overall || null;
  }
  const profileEntry = (summary.profiles || []).find(
    (entry) => String(entry.profile) === String(profileKey)
  );
  return profileEntry?.aggregate || null;
}

export default async function handler(req, res) {
  if (req.method !== "GET") {
    res.setHeader("Allow", "GET");
    return res.status(405).json({ error: "Method not allowed" });
  }

  const session = await requireAuth(req, res);
  if (!session) return;

  try {
    const {
      profile: profileParam,
      startDate,
      endDate,
      currency = "EUR",
    } = req.query;

    const summary = await getFinancialSummary({
      userId: session.userId,
      startDate: startDate ? new Date(startDate) : null,
      endDate: endDate ? new Date(endDate) : null,
      includeProfiles: true,
    });

    const profiles = await listProfiles(session.userId);
    const profileNameMap = new Map();
    profiles.forEach((profile) => {
      if (!profile || profile.id == null) return;
      profileNameMap.set(String(profile.id), profile.name || `Profile ${profile.id}`);
    });
    profileNameMap.set("default", "Default workspace");

    const normalizedProfile = (() => {
      const raw = profileParam != null ? String(profileParam) : "";
      if (!raw || raw === "all" || raw === "overall") return "";
      return raw;
    })();

    const aggregate = resolveAggregate(summary, normalizedProfile);
    if (!aggregate) {
      return res.status(404).json({ error: "No data available for requested scope" });
    }

    const label = normalizedProfile
      ? profileNameMap.get(normalizedProfile) ||
        (normalizedProfile === "default" ? "Default workspace" : `Profile ${normalizedProfile}`)
      : "All workspaces";

    const bs = aggregate.balanceSheet || {};
    const assets = bs.assets ?? 0;
    const liabilities = bs.liabilities ?? 0;
    const equity = bs.equity ?? 0;
    const balanceCheck = bs.net ?? assets - (liabilities + equity);

    const rows = [
      ["Report", "Balance Sheet"],
      ["Profile", label],
      ["Period", buildPeriodLabel(summary?.filters)],
      [],
      ["Metric", "Amount"],
      ["Assets", formatAmount(assets, currency)],
      ["Liabilities", formatAmount(-Math.abs(liabilities), currency)],
      ["Equity", formatAmount(equity, currency)],
      ["Balance check", formatAmount(balanceCheck, currency)],
    ];

    const csv = toCsv(rows);
    const filename = normalizedProfile
      ? `balance-sheet-${normalizedProfile}.csv`
      : "balance-sheet-overall.csv";

    res.setHeader("Content-Type", "text/csv; charset=utf-8");
    res.setHeader("Content-Disposition", `attachment; filename=${filename}`);
    res.status(200).send(csv);
  } catch (err) {
    console.error("[reports] balance sheet export failed", err);
    res.status(500).json({ error: "Failed to generate balance sheet report" });
  }
}
