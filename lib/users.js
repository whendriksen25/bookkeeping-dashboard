// lib/users.js
import pool from "./db.js";
import bcrypt from "bcryptjs";

const SALT_ROUNDS = 10;

async function ensureUsersTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
}

async function createUser(email, password) {
  await ensureUsersTable();
  const hashed = await bcrypt.hash(password, SALT_ROUNDS);
  const { rows } = await pool.query(
    `INSERT INTO users (email, password_hash)
     VALUES ($1, $2)
     RETURNING id, email, created_at`,
    [email.toLowerCase(), hashed]
  );
  return rows[0];
}

async function findUserByEmail(email) {
  await ensureUsersTable();
  const { rows } = await pool.query(
    `SELECT id, email, password_hash, created_at
     FROM users
     WHERE email = $1`,
    [email.toLowerCase()]
  );
  return rows[0] || null;
}

async function updateUserPassword(email, password) {
  await ensureUsersTable();
  const hashed = await bcrypt.hash(password, SALT_ROUNDS);
  const { rows } = await pool.query(
    `UPDATE users
     SET password_hash = $2,
         created_at = created_at
     WHERE email = $1
     RETURNING id, email, created_at`,
    [email.toLowerCase(), hashed]
  );
  return rows[0] || null;
}

export { ensureUsersTable, createUser, findUserByEmail, updateUserPassword };
