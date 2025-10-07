import { listInboxEntriesForUser } from "../../../lib/invoices.js";
import { requireAuth } from "../../../lib/auth.js";

export default async function handler(req, res) {
  if (req.method !== "GET") {
    res.setHeader("Allow", "GET");
    return res.status(405).json({ error: "Method not allowed" });
  }

  const session = await requireAuth(req, res);
  if (!session) return;

  try {
    const limit = req.query.limit ? Number(req.query.limit) : 10;
    const entries = await listInboxEntriesForUser(session.userId, { limit });
    res.status(200).json({ entries });
  } catch (err) {
    console.error("[inbox] list failed", err);
    res.status(500).json({ error: "Failed to load inbox" });
  }
}
