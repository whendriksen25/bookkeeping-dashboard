// pages/api/profiles/index.js
import { createProfile, listProfiles } from "../../../lib/profiles.js";

export default async function handler(req, res) {
  try {
    if (req.method === "GET") {
      const profiles = await listProfiles();
      return res.status(200).json({ profiles });
    }

    if (req.method === "POST") {
      const { name, type, website, description, aiSummary, notes } = req.body || {};
      if (!name || !type) {
        return res.status(400).json({ error: "name and type are required" });
      }
      if (!["company", "personal"].includes(type)) {
        return res.status(400).json({ error: "type must be 'company' or 'personal'" });
      }
      const profile = await createProfile({ name, type, website, description, aiSummary, notes });
      return res.status(201).json({ profile });
    }

    res.setHeader("Allow", "GET,POST");
    return res.status(405).json({ error: "Method not allowed" });
  } catch (err) {
    console.error("[profiles] handler failed", err);
    res.status(500).json({ error: "Internal server error" });
  }
}
