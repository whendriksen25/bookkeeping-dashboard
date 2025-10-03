// scripts/syncCOA.js
import fs from "fs";
import path from "path";
import { Pool } from "pg";
import dotenv from "dotenv";

dotenv.config({ path: ".env.local" });

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function main() {
  const coaPath = path.join(process.cwd(), "data", "coa.json");
  const coaList = JSON.parse(fs.readFileSync(coaPath, "utf8"));

  for (const acc of coaList) {
    await pool.query(
      `INSERT INTO accounts (code, description)
       VALUES ($1, $2)
       ON CONFLICT (code) DO UPDATE SET description = EXCLUDED.description`,
      [acc.code, acc.description]
    );
  }

  console.log("✅ COA synced to database.");
  await pool.end();
}

main().catch((err) => {
  console.error("❌ Sync failed:", err);
  process.exit(1);
});
