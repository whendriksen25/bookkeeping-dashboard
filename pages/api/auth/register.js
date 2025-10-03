// pages/api/auth/register.js
import { createUser, findUserByEmail } from "../../../lib/users.js";
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

    const existing = await findUserByEmail(email);
    if (existing) {
      return res.status(409).json({ error: "Gebruiker bestaat al" });
    }

    const user = await createUser(email, password);
    const token = signToken({ userId: user.id, email: user.email });
    setAuthCookie(res, token);

    res.status(201).json({ user: { id: user.id, email: user.email } });
  } catch (err) {
    console.error("[auth/register] failed", err);
    res.status(500).json({ error: "Registratie mislukt" });
  }
}
