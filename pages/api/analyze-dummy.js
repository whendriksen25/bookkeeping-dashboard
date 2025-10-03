// pages/api/analyze-dummy.js
import dummyInvoice from "../../data/dummy-invoice.json";

export default async function handler(req, res) {
  if (req.method !== "GET") {
    res.setHeader("Allow", "GET");
    return res.status(405).json({ error: "Method not allowed" });
  }

  res.status(200).json(dummyInvoice);
}
