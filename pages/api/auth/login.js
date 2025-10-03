// pages/api/auth/login.js
import bcrypt from "bcryptjs";
import { findUserByEmail } from "../../../lib/users.js";
import { signToken, setAuthCookie } from "../../../lib/auth.js";

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const { email, password } = req.body || {};
    if (!email || !password) {
      return res.status(400).json({ error: "Email en wachtwoord zijn verplicht" });
    }

    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(401).json({ error: "Onjuiste inloggegevens" });
    }

    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) {
      return res.status(401).json({ error: "Onjuiste inloggegevens" });
    }

    const token = signToken({ userId: user.id, email: user.email });
    setAuthCookie(res, token);

    res.status(200).json({ user: { id: user.id, email: user.email } });
  } catch (err) {
    console.error("[auth/login] failed", err);
    res.status(500).json({ error: "Inloggen mislukt" });
  }
}
