// lib/auth.js
import cookie from "cookie";
import jwt from "jsonwebtoken";

const COOKIE_NAME = "auth_token";
const MAX_AGE_SECONDS = 60 * 60 * 24 * 7; // 7 days

function getSecret() {
  const secret = process.env.AUTH_SECRET || process.env.NEXT_PUBLIC_AUTH_SECRET;
  if (!secret) {
    throw new Error("AUTH_SECRET is not defined. Set it in your environment variables.");
  }
  return secret;
}

function signToken(payload) {
  return jwt.sign(payload, getSecret(), { expiresIn: MAX_AGE_SECONDS });
}

function verifyToken(token) {
  try {
    return jwt.verify(token, getSecret());
  } catch {
    return null;
  }
}

function setAuthCookie(res, token) {
  res.setHeader(
    "Set-Cookie",
    cookie.serialize(COOKIE_NAME, token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      maxAge: MAX_AGE_SECONDS,
      path: "/",
    })
  );
}

function clearAuthCookie(res) {
  res.setHeader(
    "Set-Cookie",
    cookie.serialize(COOKIE_NAME, "", {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      maxAge: 0,
      path: "/",
    })
  );
}

function getTokenFromRequest(req) {
  const cookiesHeader = req.headers.cookie;
  if (!cookiesHeader) return null;
  const parsed = cookie.parse(cookiesHeader);
  return parsed[COOKIE_NAME] || null;
}

function getSession(req) {
  const token = getTokenFromRequest(req);
  if (!token) return null;
  return verifyToken(token);
}

async function requireAuth(req, res) {
  const session = getSession(req);
  if (!session?.userId) {
    res.status(401).json({ error: "Not authenticated" });
    return null;
  }
  return session;
}

export { signToken, setAuthCookie, clearAuthCookie, getSession, requireAuth };
