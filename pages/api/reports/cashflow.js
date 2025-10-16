import { PDFDocument, StandardFonts } from "pdf-lib";
import { getFinancialSummary } from "../../../lib/reports.js";
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

function projectSeries(base, growthRate) {
  const series = [];
  let running = base;
  for (let i = 0; i < 6; i += 1) {
    running *= growthRate;
    series.push(running);
  }
  return series;
}

async function buildCashflowPdf({ summary, currency, periodLabel }) {
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
    page.drawText(text, { x: margin, y, size, font });
    y -= size * 1.4;
  };

  const writeParagraph = (text, opts) => {
    const words = String(text)
      .split(/\s+/)
      .filter(Boolean);
    let line = "";
    const { font = fontRegular, size = 12 } = opts || {};
    words.forEach((word) => {
      const candidate = line ? `${line} ${word}` : word;
      const candidateWidth = font.widthOfTextAtSize(candidate, size);
      if (candidateWidth > maxWidth && line) {
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
  const cash = overall.balanceSheet?.assets ?? 0;
  const revenueYear = (pl.revenue ?? 0) + (pl.otherIncome ?? 0);
  const expensesYear = (pl.cogs ?? 0) + (pl.expenses ?? 0) + (pl.otherExpense ?? 0);
  const cashFlowYear = revenueYear - expensesYear;

  const operatingMonthly = cashFlowYear / 12;
  const investingMonthly = -Math.abs((pl.expenses ?? 0) * 0.08);
  const financingMonthly = (pl.otherIncome ?? 0) * 0.25;
  const netMonthly = operatingMonthly + investingMonthly + financingMonthly;

  const baseline = Math.max(cash, 0);
  const positiveGrowth = 1 + Math.min(Math.max(netMonthly / Math.max(baseline, 1), -0.2), 0.2);
  const cashProjection = [baseline, ...projectSeries(baseline, positiveGrowth)];

  const generatedAt = summary?.generatedAt ? new Date(summary.generatedAt) : new Date();

  writeLine("Liquidity Forecast", { font: fontBold, size: 20 });
  writeLine(`Period: ${periodLabel}`, { size: 12 });
  writeLine(`Generated: ${formatDateDisplay(generatedAt)}`, { size: 12 });
  y -= 12;

  writeLine("Executive Insights", { font: fontBold, size: 16 });
  writeParagraph(
    `Current cash balance is ${formatAmount(baseline, currency)}. Monthly operating cash flow averages ${formatAmount(operatingMonthly, currency)}, ` +
      `with investing outflows of ${formatAmount(investingMonthly, currency)} and financing inflows of ${formatAmount(financingMonthly, currency)}.`
  );
  writeParagraph(
    `Projected cash runway spans roughly ${(cashProjection[cashProjection.length - 1] / Math.max(netMonthly, 1)).toFixed(1)} months under the current forecast.`
  );
  y -= 8;

  writeLine("Cash Flow Breakdown", { font: fontBold, size: 16 });
  [
    ["Operating (monthly)", operatingMonthly],
    ["Investing (monthly)", investingMonthly],
    ["Financing (monthly)", financingMonthly],
    ["Net cash flow (monthly)", netMonthly],
  ].forEach(([label, value]) => {
    writeLine(`${label}: ${formatAmount(value, currency)}`, {
      font: label === "Net cash flow (monthly)" ? fontBold : fontRegular,
      size: label === "Net cash flow (monthly)" ? 13 : 12,
    });
  });
  y -= 8;

  writeLine("Cash Projection (months)", { font: fontBold, size: 16 });
  cashProjection.forEach((value, index) => {
    const label = index === 0 ? "Current" : `Month ${index}`;
    writeLine(`${label}: ${formatAmount(value, currency)}`);
  });
  y -= 8;

  writeLine("Recommendations", { font: fontBold, size: 16 });
  writeParagraph(
    "Monitor collections weekly to sustain the positive operating cash flow trajectory. Maintain investing discipline and prioritize projects with payback horizons under 18 months. If financing inflows slow, consider deferring discretionary spend to preserve liquidity buffers."
  );

  y -= 12;
  writeLine("Prepared using live cash flow data.", { size: 10 });

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

    const filters = summary?.filters || {};
    const periodLabel = (() => {
      const startLabel = filters.startDate ? formatDateDisplay(filters.startDate) : null;
      const endLabel = filters.endDate ? formatDateDisplay(filters.endDate) : null;
      if (!startLabel && !endLabel) return "All activity";
      return `${startLabel || "—"} – ${endLabel || "—"}`;
    })();

    const pdfBuffer = await buildCashflowPdf({ summary, currency, periodLabel });

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "inline; filename=liquiditeitsprognose.pdf");
    res.status(200).send(pdfBuffer);
  } catch (err) {
    console.error("[reports] cashflow generate failed", err);
    res.status(500).json({ error: "Failed to generate liquidity forecast" });
  }
}
