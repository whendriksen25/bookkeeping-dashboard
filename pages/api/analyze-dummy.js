// pages/api/analyze-dummy.js
import dummyInvoice from "../../data/dummy-invoice.json";
import { requireAuth } from "../../lib/auth.js";

export default async function handler(req, res) {
  if (req.method !== "GET") {
    res.setHeader("Allow", "GET");
    return res.status(405).json({ error: "Method not allowed" });
  }

  const session = await requireAuth(req, res);
  if (!session) {
    if (process.env.NODE_ENV !== "production") {
      return res.status(200).json(dummyInvoice);
    }
    return;
  }

  res.status(200).json(dummyInvoice);
}
