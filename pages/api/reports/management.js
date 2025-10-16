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

async function buildManagementPdf({ profile, currency, summary, periodLabel }) {
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

  const aggregate = profile.aggregate || {};
  const pl = aggregate.profitLoss || {};
  const bs = aggregate.balanceSheet || {};

  const revenue = (pl.revenue ?? 0) + (pl.otherIncome ?? 0);
  const expenses = (pl.cogs ?? 0) + (pl.expenses ?? 0) + (pl.otherExpense ?? 0);
  const net = pl.net ?? revenue - expenses;
  const grossMargin = revenue !== 0 ? ((revenue - (pl.cogs ?? 0)) / revenue) * 100 : 0;
  const assets = bs.assets ?? 0;
  const liabilities = bs.liabilities ?? 0;

  writeLine("Management Report", { font: fontBold, size: 20 });
  writeLine(profile.label ? String(profile.label) : "", { font: fontBold, size: 16 });
  writeLine(`Period: ${periodLabel}`, { size: 12 });
  const generatedAt = summary?.generatedAt ? new Date(summary.generatedAt) : new Date();
  writeLine(`Generated: ${formatDateDisplay(generatedAt)}`, { size: 12 });
  y -= 12;

  writeLine("Highlights", { font: fontBold, size: 16 });
  writeParagraph(
    `Revenue grew to ${formatAmount(revenue, currency)} with a gross margin of ${grossMargin.toFixed(1)}%. ` +
      `Expenses total ${formatAmount(-Math.abs(expenses), currency)}, resulting in net profit of ${formatAmount(net, currency)}.`,
    { size: 12 }
  );
  y -= 8;

  writeLine("Key Metrics", { font: fontBold, size: 16 });
  [
    ["Revenue", revenue],
    ["Cost of goods sold", pl.cogs ?? 0],
    ["Operating expenses", pl.expenses ?? 0],
    ["Other income", pl.otherIncome ?? 0],
    ["Other expenses", pl.otherExpense ?? 0],
    ["Net profit", net],
    ["Assets", assets],
    ["Liabilities", liabilities],
  ].forEach(([label, value]) => {
    writeLine(`${label}: ${formatAmount(value, currency)}`, {
      font: label === "Net profit" ? fontBold : fontRegular,
      size: label === "Net profit" ? 13 : 12,
    });
  });
  y -= 8;

  writeLine("Performance Commentary", { font: fontBold, size: 16 });
  writeParagraph(
    "Collections and cost discipline remain the focus. Follow up on outstanding receivables older than 45 days, and evaluate subscription spend for potential consolidation. Positive operating cash flow supports the current investment roadmap.",
    { size: 12 }
  );

  y -= 12;
  writeLine("Prepared using live booking data.", { size: 10 });

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
    const { profile: profileParam, startDate, endDate, currency = "EUR" } = req.query;

    const summary = await getFinancialSummary({
      userId: session.userId,
      startDate: startDate ? new Date(startDate) : null,
      endDate: endDate ? new Date(endDate) : null,
      includeProfiles: true,
    });
    const profiles = await listProfiles(session.userId);

    const profileNameMap = new Map();
    profiles.forEach((p) => {
      if (!p || p.id == null) return;
      profileNameMap.set(String(p.id), p.name || `Profile ${p.id}`);
    });
    profileNameMap.set("default", "Default");

    const profileEntries = summary?.profiles || [];
    const targetKey = profileParam ? String(profileParam) : profileEntries[0]?.profile || "default";
    const targetEntry = profileEntries.find((entry) => String(entry.profile) === targetKey);
    if (!targetEntry) {
      return res.status(404).json({ error: "Profile not found" });
    }

    const filters = summary?.filters || {};
    const periodLabel = (() => {
      const startLabel = filters.startDate ? formatDateDisplay(filters.startDate) : null;
      const endLabel = filters.endDate ? formatDateDisplay(filters.endDate) : null;
      if (!startLabel && !endLabel) return "All activity";
      return `${startLabel || "—"} – ${endLabel || "—"}`;
    })();

    const pdfBuffer = await buildManagementPdf({
      profile: {
        ...targetEntry,
        label: profileNameMap.get(targetKey) || (targetKey === "default" ? "Default" : `Profile ${targetKey}`),
      },
      currency,
      summary,
      periodLabel,
    });

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `inline; filename=management-report-${targetKey}.pdf`);
    res.status(200).send(pdfBuffer);
  } catch (err) {
    console.error("[reports] management generate failed", err);
    res.status(500).json({ error: "Failed to generate management report" });
  }
}
