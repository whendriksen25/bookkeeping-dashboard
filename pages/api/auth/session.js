// pages/api/auth/session.js
import { getSession } from "../../../lib/auth.js";

export default async function handler(req, res) {
  if (req.method !== "GET") {
    res.setHeader("Allow", "GET");
    return res.status(405).json({ error: "Method not allowed" });
  }

  const session = getSession(req);
  if (!session?.userId) {
    return res.status(401).json({ error: "Niet ingelogd" });
  }

  res.status(200).json({ user: { id: session.userId, email: session.email } });
}
