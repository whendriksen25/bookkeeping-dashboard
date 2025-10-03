// pages/api/auth/logout.js
import { clearAuthCookie } from "../../../lib/auth.js";

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).json({ error: "Method not allowed" });
  }

  clearAuthCookie(res);
  res.status(200).json({ success: true });
}
