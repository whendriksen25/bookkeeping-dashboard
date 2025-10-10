import { listInvoicesForUser, deleteInvoicesForUser } from "../../../lib/invoices.js";
import { requireAuth } from "../../../lib/auth.js";

export default async function handler(req, res) {
  if (!["GET", "DELETE"].includes(req.method)) {
    res.setHeader("Allow", "GET, DELETE");
    return res.status(405).json({ error: "Method not allowed" });
  }

  const session = await requireAuth(req, res);
  if (!session) return;

  try {
    if (req.method === "GET") {
      const limit = req.query.limit ? Number(req.query.limit) : 50;
      const invoices = await listInvoicesForUser(session.userId, { limit });
      return res.status(200).json({ invoices });
    }

    const ids = Array.isArray(req.body?.ids)
      ? req.body.ids
      : typeof req.body?.id === "string"
      ? [req.body.id]
      : [];

    if (ids.length === 0) {
      return res.status(400).json({ error: "No invoice IDs provided" });
    }

    const result = await deleteInvoicesForUser(session.userId, ids);
    return res.status(200).json({ success: true, deleted: result.deleted });
  } catch (err) {
    console.error("[invoices] handler failed", err);
    res.status(500).json({ error: "Failed to process invoices" });
  }
}
