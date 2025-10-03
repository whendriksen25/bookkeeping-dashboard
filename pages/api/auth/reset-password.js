// pages/api/auth/reset-password.js
import { findUserByEmail, updateUserPassword } from "../../../lib/users.js";
import { signToken, setAuthCookie } from "../../../lib/auth.js";

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const { email, password } = req.body || {};
    if (!email || !password) {
      return res.status(400).json({ error: "Email en nieuw wachtwoord zijn verplicht" });
    }

    const existing = await findUserByEmail(email);
    if (!existing) {
      return res.status(404).json({ error: "Geen gebruiker gevonden" });
    }

    const updated = await updateUserPassword(email, password);
    if (!updated) {
      return res.status(500).json({ error: "Wachtwoord kon niet worden bijgewerkt" });
    }

    const token = signToken({ userId: updated.id, email: updated.email });
    setAuthCookie(res, token);

    res.status(200).json({ user: { id: updated.id, email: updated.email } });
  } catch (err) {
    console.error("[auth/reset-password] failed", err);
    res.status(500).json({ error: "Wachtwoord reset mislukt" });
  }
}
