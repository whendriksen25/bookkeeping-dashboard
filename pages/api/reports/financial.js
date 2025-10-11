import { getFinancialSummary } from "../../../lib/reports.js";
import { requireAuth } from "../../../lib/auth.js";

export default async function handler(req, res) {
  if (req.method !== "GET") {
    res.setHeader("Allow", "GET");
    return res.status(405).json({ error: "Method not allowed" });
  }

  const session = await requireAuth(req, res);
  if (!session) return;

  try {
    const { startDate, endDate, includeProfiles } = req.query;
    const summary = await getFinancialSummary({
      userId: session.userId,
      startDate: startDate ? new Date(startDate) : null,
      endDate: endDate ? new Date(endDate) : null,
      includeProfiles: includeProfiles !== "false",
    });
    res.status(200).json({ summary });
  } catch (err) {
    console.error("[reports] financial summary failed", err);
    res.status(500).json({ error: "Failed to build financial summary" });
  }
}
