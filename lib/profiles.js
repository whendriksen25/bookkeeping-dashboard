// lib/profiles.js
import pool from "./db.js";

async function ensureProfilesTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS profiles (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL CHECK (type IN ('company', 'personal')),
      website TEXT,
      description TEXT,
      ai_summary TEXT,
      notes TEXT,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
}

async function listProfiles() {
  await ensureProfilesTable();
  const { rows } = await pool.query(
    `SELECT id, name, type, website, description, ai_summary AS "aiSummary", notes, created_at AS "createdAt", updated_at AS "updatedAt"
     FROM profiles
     ORDER BY name ASC`
  );
  return rows;
}

async function getProfileById(id) {
  await ensureProfilesTable();
  const { rows } = await pool.query(
    `SELECT id, name, type, website, description, ai_summary AS "aiSummary", notes, created_at AS "createdAt", updated_at AS "updatedAt"
     FROM profiles
     WHERE id = $1`,
    [id]
  );
  return rows[0] || null;
}

async function createProfile(data) {
  await ensureProfilesTable();
  const { name, type, website, description, aiSummary, notes } = data;
  const { rows } = await pool.query(
    `INSERT INTO profiles (name, type, website, description, ai_summary, notes)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, name, type, website, description, ai_summary AS "aiSummary", notes, created_at AS "createdAt", updated_at AS "updatedAt"`,
    [name, type, website || null, description || null, aiSummary || null, notes || null]
  );
  return rows[0];
}

async function updateProfile(id, data) {
  await ensureProfilesTable();
  const fields = {
    name: data.name,
    type: data.type,
    website: data.website,
    description: data.description,
    ai_summary: data.aiSummary,
    notes: data.notes,
  };

  const assignments = [];
  const values = [];
  let idx = 1;

  for (const [column, value] of Object.entries(fields)) {
    if (value === undefined) continue;
    assignments.push(`${column} = $${idx}`);
    values.push(value ?? null);
    idx += 1;
  }

  if (assignments.length === 0) {
    return getProfileById(id);
  }

  assignments.push(`updated_at = NOW()`);
  values.push(id);

  const { rows } = await pool.query(
    `UPDATE profiles
     SET ${assignments.join(", ")}
     WHERE id = $${idx}
     RETURNING id, name, type, website, description, ai_summary AS "aiSummary", notes, created_at AS "createdAt", updated_at AS "updatedAt"`,
    values
  );

  return rows[0] || null;
}

async function deleteProfile(id) {
  await ensureProfilesTable();
  await pool.query(`DELETE FROM profiles WHERE id = $1`, [id]);
}

export {
  ensureProfilesTable,
  listProfiles,
  getProfileById,
  createProfile,
  updateProfile,
  deleteProfile,
};
