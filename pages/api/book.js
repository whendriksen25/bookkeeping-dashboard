// pages/api/book.js
import pool from "../../lib/db.js";
import { saveInvoiceWithItems } from "../../lib/invoices.js";
import { requireAuth } from "../../lib/auth.js";

async function ensureBookingTableShape() {
  await pool.query(
    `ALTER TABLE bookings
      ADD COLUMN IF NOT EXISTS invoice_id UUID,
      ADD COLUMN IF NOT EXISTS invoice_number TEXT,
      ADD COLUMN IF NOT EXISTS profile_reference TEXT,
      ADD COLUMN IF NOT EXISTS account_code TEXT,
      ADD COLUMN IF NOT EXISTS counter_account_code TEXT,
      ADD COLUMN IF NOT EXISTS debit_account TEXT,
      ADD COLUMN IF NOT EXISTS credit_account TEXT,
      ADD COLUMN IF NOT EXISTS amount NUMERIC,
      ADD COLUMN IF NOT EXISTS description TEXT,
      ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`
  );

  await pool.query(`ALTER TABLE bookings ALTER COLUMN account_code DROP NOT NULL`);
  await pool.query(`ALTER TABLE bookings ALTER COLUMN counter_account_code DROP NOT NULL`);
  await pool.query(`UPDATE bookings SET account_code = COALESCE(account_code, debit_account)`);
  await pool.query(`UPDATE bookings SET counter_account_code = COALESCE(counter_account_code, credit_account)`);
  await pool.query(`ALTER TABLE bookings ALTER COLUMN account_code SET NOT NULL`);
  await pool.query(`ALTER TABLE bookings ALTER COLUMN counter_account_code SET NOT NULL`);

  await pool.query(`UPDATE bookings SET profile_reference = COALESCE(profile_reference, 'default')`);
  await pool.query(`ALTER TABLE bookings ALTER COLUMN profile_reference SET DEFAULT 'default'`);
  await pool.query(`ALTER TABLE bookings ALTER COLUMN profile_reference SET NOT NULL`);

  await pool.query(`
    DO $$
    DECLARE
      fk_name text;
    BEGIN
      SELECT conname INTO fk_name
      FROM pg_constraint
      WHERE conrelid = 'bookings'::regclass
        AND conname IN (
          'bookings_account_number_fkey',
          'bookings_account_code_fkey',
          'bookings_account_number_fk'
        )
      LIMIT 1;

      IF fk_name IS NOT NULL THEN
        EXECUTE format('ALTER TABLE bookings DROP CONSTRAINT %I', fk_name);
      END IF;
    END
    $$;
  `);

  await pool.query(`
    WITH ranked AS (
      SELECT
        ctid,
        ROW_NUMBER() OVER (
          PARTITION BY invoice_id, account_code, counter_account_code, profile_reference
          ORDER BY created_at DESC
        ) AS rn
      FROM bookings
    )
    DELETE FROM bookings b
    USING ranked r
    WHERE b.ctid = r.ctid AND r.rn > 1;
  `);

  await pool.query(`
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'bookings'::regclass
          AND conname = 'bookings_unique_entry'
      ) THEN
        ALTER TABLE bookings
          ADD CONSTRAINT bookings_unique_entry
          UNIQUE (invoice_id, account_code, counter_account_code, profile_reference);
      END IF;
    END
    $$;
  `);
}

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const session = await requireAuth(req, res);
    if (!session) return;

    const {
      factuurdetails,
      structured,
      invoiceText,
      selectedAccount,
      splitMode,
      selectedProfileId,
      lineItems,
      file,
    } = req.body || {};

    if (!factuurdetails || !selectedAccount) {
      return res.status(400).json({ error: "Missing invoice details or selected account" });
    }

    const amountIncl = Number(
      factuurdetails?.totaal?.totaal_incl_btw || factuurdetails?.totaal?.totaal_incl || 0
    );
    if (!Number.isFinite(amountIncl) || amountIncl === 0) {
      return res.status(400).json({ error: "Invalid invoice amount" });
    }

    console.log("🧾 Booking invoice:", factuurdetails.factuurnummer);

    const invoiceId = await saveInvoiceWithItems({
      factuurdetails,
      structured,
      invoiceText,
      file,
      selectedAccount,
      splitMode,
      selectedProfileId,
      lineItems,
      userId: session.userId,
    });

    await ensureBookingTableShape();

    const expenseAccount = selectedAccount; // chosen COA account for this booking
    const creditorsAccount = "160000"; // Creditors
    const bankAccount = "100000"; // Bank
    const paid = (factuurdetails?.betaalstatus || "").toLowerCase() === "betaald";

    const totalsByProfile = new Map();
    if (Array.isArray(lineItems) && lineItems.length > 0) {
      for (const item of lineItems) {
        const amount = Number(item.totalIncl ?? item.total_price ?? item.totalExcl ?? 0) || 0;
        if (amount === 0) continue;
        const profileKey = item.profileId
          ? String(item.profileId)
          : selectedProfileId
          ? String(selectedProfileId)
          : "default";
        totalsByProfile.set(profileKey, (totalsByProfile.get(profileKey) || 0) + amount);
      }
    } else {
      const key = selectedProfileId ? String(selectedProfileId) : "default";
      totalsByProfile.set(key, amountIncl);
    }

    const client = await pool.connect();
    try {
      await client.query("BEGIN");

      for (const [profileKey, total] of totalsByProfile.entries()) {
        const amount = Number(total || 0);
        if (!Number.isFinite(amount) || amount === 0) continue;

        const profileRef = profileKey || "default";
        await client.query(
          `INSERT INTO bookings (
             invoice_number,
             invoice_id,
             user_id,
             account_code,
             counter_account_code,
             debit_account,
             credit_account,
             amount,
             description,
             profile_reference
           )
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
           ON CONFLICT (invoice_id, account_code, counter_account_code, profile_reference)
           DO UPDATE SET
             amount = EXCLUDED.amount,
             description = EXCLUDED.description,
             debit_account = EXCLUDED.debit_account,
             credit_account = EXCLUDED.credit_account,
             updated_at = NOW()`,
          [
            factuurdetails.factuurnummer,
            invoiceId,
            session.userId,
            expenseAccount,
            creditorsAccount,
            expenseAccount,
            creditorsAccount,
            amount,
            `Factuur ${factuurdetails.factuurnummer || ""} – ${
              factuurdetails?.afzender?.naam || ""
            }`,
            profileRef,
          ]
        );
      }

      console.log("💾 Booking inserted: Expense ↔ Creditors");

      if (paid) {
        await client.query(
          `INSERT INTO bookings (
             invoice_number,
             invoice_id,
             user_id,
             account_code,
             counter_account_code,
             debit_account,
             credit_account,
             amount,
             description,
             profile_reference
           )
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
           ON CONFLICT (invoice_id, account_code, counter_account_code, profile_reference)
           DO UPDATE SET
             amount = EXCLUDED.amount,
             description = EXCLUDED.description,
             debit_account = EXCLUDED.debit_account,
             credit_account = EXCLUDED.credit_account,
             updated_at = NOW()`,
          [
            factuurdetails.factuurnummer,
            invoiceId,
            session.userId,
            creditorsAccount,
            bankAccount,
            creditorsAccount,
            bankAccount,
            amountIncl,
            `Betaling factuur ${factuurdetails.factuurnummer}`,
            "payment",
          ]
        );
        console.log("💾 Payment booking inserted: Creditors ↔ Bank");
      }

      await client.query("COMMIT");
      res.status(200).json({ success: true, message: "Boeking opgeslagen", invoiceId });
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("❌ BOOKING error:", error);
    res.status(500).json({ error: error.message });
  }
}
