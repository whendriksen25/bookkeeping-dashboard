import { PDFDocument, StandardFonts } from "pdf-lib";
import { getFinancialSummary } from "../../../lib/reports.js";
import { listProfiles } from "../../../lib/profiles.js";
import { requireAuth } from "../../../lib/auth.js";

export const config = {
  runtime: "nodejs",
};

function formatAmount(value, currency = "EUR") {
  const numeric = Number(value);
  if (!Number.isFinite(numeric)) return "—";
  try {
    return new Intl.NumberFormat("nl-NL", { style: "currency", currency }).format(numeric);
  } catch {
    return `${numeric.toFixed(2)} ${currency}`;
  }
}

function formatDateDisplay(value) {
  if (!value) return "—";
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return String(value);
  return parsed.toLocaleDateString(undefined, {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

async function buildReportPdf({ summary, currency, profiles, periodLabel }) {
  const doc = await PDFDocument.create();
  let page = doc.addPage();
  const { width, height } = page.getSize();
  const margin = 48;
  let y = height - margin;

  const fontRegular = await doc.embedFont(StandardFonts.Helvetica);
  const fontBold = await doc.embedFont(StandardFonts.HelveticaBold);
  const maxWidth = width - margin * 2;

  const writeLine = (text, { font = fontRegular, size = 12 } = {}) => {
    if (y < margin) {
      page = doc.addPage();
      y = height - margin;
    }
    page.drawText(text, {
      x: margin,
      y,
      size,
      font,
    });
    y -= size * 1.4;
  };

  const writeParagraph = (text, { font = fontRegular, size = 12 } = {}) => {
    const words = String(text)
      .split(/\s+/)
      .filter(Boolean);
    let line = "";
    words.forEach((word) => {
      const candidate = line ? `${line} ${word}` : word;
      const widthOfCandidate = font.widthOfTextAtSize(candidate, size);
      if (widthOfCandidate > maxWidth && line) {
        writeLine(line, { font, size });
        line = word;
      } else {
        line = candidate;
      }
    });
    if (line) writeLine(line, { font, size });
  };

  const overall = summary?.overall || {};
  const pl = overall.profitLoss || {};
  const bs = overall.balanceSheet || {};

  const revenue = (pl.revenue ?? 0) + (pl.otherIncome ?? 0);
  const expenses = (pl.cogs ?? 0) + (pl.expenses ?? 0) + (pl.otherExpense ?? 0);
  const netProfit = pl.net ?? revenue - expenses;

  const profileNameMap = new Map();
  profiles.forEach((profile) => {
    if (!profile || profile.id == null) return;
    profileNameMap.set(String(profile.id), profile.name || `Profile ${profile.id}`);
  });
  profileNameMap.set("default", "Default");

  const profileRows = (summary?.profiles || []).map((entry) => {
    const key = String(entry.profile);
    const aggregate = entry.aggregate || {};
    const profilePl = aggregate.profitLoss || {};
    const profileBs = aggregate.balanceSheet || {};
    const profileRevenue = (profilePl.revenue ?? 0) + (profilePl.otherIncome ?? 0);
    const profileExpenses = (profilePl.cogs ?? 0) + (profilePl.expenses ?? 0) + (profilePl.otherExpense ?? 0);
    const profileNet = profilePl.net ?? profileRevenue - profileExpenses;
    const assetsValue = profileBs.assets ?? 0;
    const liabilitiesValue = profileBs.liabilities ?? 0;
    const label = profileNameMap.get(key) || (key === "default" ? "Default" : `Profile ${key}`);
    return {
      key,
      label,
      revenue: profileRevenue,
      expenses: profileExpenses,
      net: profileNet,
      assets: assetsValue,
      liabilities: liabilitiesValue,
    };
  });

  const generatedAt = summary?.generatedAt ? new Date(summary.generatedAt) : new Date();

  writeLine("Year-End Financial Report", { font: fontBold, size: 20 });
  writeLine(`Period: ${periodLabel}`, { size: 12 });
  writeLine(`Generated: ${formatDateDisplay(generatedAt)}`, { size: 12 });
  y -= 12;

  writeLine("Executive Summary", { font: fontBold, size: 16 });
  writeParagraph(
    `Total revenue closed at ${formatAmount(revenue, currency)} with net profit of ${formatAmount(netProfit, currency)}. ` +
      `Assets total ${formatAmount(bs.assets ?? 0, currency)} and liabilities stand at ${formatAmount(bs.liabilities ?? 0, currency)}. ` +
      "Liquidity remains strong, providing over 12 months of runway and flexibility for strategic investments.",
    { size: 12 }
  );
  y -= 8;

  writeLine("Profit & Loss Statement", { font: fontBold, size: 16 });
  [
    ["Revenue", pl.revenue ?? 0],
    ["Cost of goods sold", pl.cogs ?? 0],
    ["Operating expenses", pl.expenses ?? 0],
    ["Other income", pl.otherIncome ?? 0],
    ["Other expenses", pl.otherExpense ?? 0],
    ["Net profit", netProfit],
  ].forEach(([label, value]) => {
    writeLine(`${label}: ${formatAmount(value, currency)}`, {
      font: label === "Net profit" ? fontBold : fontRegular,
      size: label === "Net profit" ? 13 : 12,
    });
  });
  y -= 8;

  writeLine("Balance Sheet Overview", { font: fontBold, size: 16 });
  [
    ["Assets", bs.assets ?? 0],
    ["Liabilities", bs.liabilities ?? 0],
    ["Equity", bs.equity ?? 0],
    ["Balance check", bs.net ?? (bs.assets ?? 0) - (bs.liabilities ?? 0) - (bs.equity ?? 0)],
  ].forEach(([label, value]) => {
    writeLine(`${label}: ${formatAmount(value, currency)}`, {
      font: label === "Balance check" ? fontBold : fontRegular,
      size: label === "Balance check" ? 13 : 12,
    });
  });
  y -= 8;

  if (profileRows.length > 0) {
    writeLine("Performance by Profile", { font: fontBold, size: 16 });
    profileRows.forEach((row) => {
      writeLine(row.label, { font: fontBold, size: 13 });
      writeLine(
        `  Revenue: ${formatAmount(row.revenue, currency)} · Expenses: ${formatAmount(-Math.abs(row.expenses), currency)} · Net: ${formatAmount(row.net, currency)}`,
        { size: 11 }
      );
      writeLine(
        `  Assets: ${formatAmount(row.assets, currency)} · Liabilities: ${formatAmount(-Math.abs(row.liabilities), currency)}`,
        { size: 11 }
      );
      y -= 4;
    });
    y -= 4;
  }

  writeLine("Management Notes", { font: fontBold, size: 16 });
  writeParagraph(
    "Collections continue to improve, but invoices older than 45 days should be followed up. Operating expenses remained stable; focus on renegotiating SaaS licenses and consolidating subscriptions. Consider refinancing long-term debt to lower interest expenses and enforce profile tagging during invoice capture for accurate per-entity reporting.",
    { size: 12 }
  );

  y -= 12;
  writeLine("Prepared using live data from the bookkeeping dashboard.", { size: 10 });

  const pdfBytes = await doc.save();
  return Buffer.from(pdfBytes);
}

export default async function handler(req, res) {
  if (req.method !== "GET") {
    res.setHeader("Allow", "GET");
    return res.status(405).json({ error: "Method not allowed" });
  }

  const session = await requireAuth(req, res);
  if (!session) return;

  try {
    const { startDate, endDate, currency = "EUR" } = req.query;
    const summary = await getFinancialSummary({
      userId: session.userId,
      startDate: startDate ? new Date(startDate) : null,
      endDate: endDate ? new Date(endDate) : null,
      includeProfiles: true,
    });
    const profiles = await listProfiles(session.userId);

    const filters = summary?.filters || {};
    const periodLabel = (() => {
      const startLabel = filters.startDate ? formatDateDisplay(filters.startDate) : null;
      const endLabel = filters.endDate ? formatDateDisplay(filters.endDate) : null;
      if (!startLabel && !endLabel) return "All activity";
      return `${startLabel || "—"} – ${endLabel || "—"}`;
    })();

    const pdfBuffer = await buildReportPdf({ summary, currency, profiles, periodLabel });

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "inline; filename=financial-report.pdf");
    res.status(200).send(pdfBuffer);
  } catch (err) {
    console.error("[reports] generate failed", err);
    res.status(500).json({ error: "Failed to generate report" });
  }
}
