// pages/api/profiles/[id].js
import {
  getProfileById,
  updateProfile,
  deleteProfile,
} from "../../../lib/profiles.js";

export default async function handler(req, res) {
  const {
    query: { id },
    method,
  } = req;

  const numericId = Number(id);
  if (!Number.isInteger(numericId) || numericId <= 0) {
    return res.status(400).json({ error: "Invalid profile id" });
  }

  try {
    if (method === "GET") {
      const profile = await getProfileById(numericId);
      if (!profile) return res.status(404).json({ error: "Profile not found" });
      return res.status(200).json({ profile });
    }

    if (method === "PUT") {
      const profile = await updateProfile(numericId, req.body || {});
      if (!profile) return res.status(404).json({ error: "Profile not found" });
      return res.status(200).json({ profile });
    }

    if (method === "DELETE") {
      await deleteProfile(numericId);
      return res.status(204).end();
    }

    res.setHeader("Allow", "GET,PUT,DELETE");
    return res.status(405).json({ error: "Method not allowed" });
  } catch (err) {
    console.error("[profiles:id] handler failed", err);
    res.status(500).json({ error: "Internal server error" });
  }
}
