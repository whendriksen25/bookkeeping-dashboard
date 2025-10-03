// lib/invoices.js
import crypto from "crypto";
import pool from "./db.js";
import { ensureProfilesTable } from "./profiles.js";

function toNumber(value) {
  if (value === null || value === undefined || value === "") return null;
  const normalized = String(value).replace(/[^0-9,.-]/g, "").replace(",", ".");
  const num = Number(normalized);
  return Number.isFinite(num) ? num : null;
}

function toDate(value) {
  if (!value) return null;
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

async function ensureInvoiceTables() {
  await ensureProfilesTable();

  await pool.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto"`);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS invoices (
      id UUID,
      user_id UUID REFERENCES users(id) ON DELETE CASCADE,
      invoice_number TEXT,
      invoice_date DATE,
      vendor_name TEXT,
      payment_method TEXT,
      total_incl NUMERIC,
      total_excl NUMERIC,
      total_vat NUMERIC,
      currency TEXT,
      vat_breakdown JSONB,
      raw_text TEXT,
      raw_json JSONB,
      source_storage TEXT,
      source_url TEXT,
      source_filename TEXT,
      primary_profile_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL,
      split_mode BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await pool.query(`ALTER TABLE invoices ADD COLUMN IF NOT EXISTS id UUID`);
  await pool.query(`ALTER TABLE invoices ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE`);
  await pool.query(`ALTER TABLE invoices ALTER COLUMN id SET DEFAULT gen_random_uuid()`);
  await pool.query(`UPDATE invoices SET id = gen_random_uuid() WHERE id IS NULL`);
  await pool.query(`ALTER TABLE invoices ALTER COLUMN id SET NOT NULL`);
  await pool.query(`
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'invoices'::regclass
          AND conname = 'invoices_id_unique_constr'
      ) THEN
        ALTER TABLE invoices
          ADD CONSTRAINT invoices_id_unique_constr UNIQUE (id);
      END IF;
    END
    $$;
  `);

  const invoiceColumns = [
    "user_id UUID",
    "invoice_number TEXT",
    "invoice_date DATE",
    "vendor_name TEXT",
    "payment_method TEXT",
    "total_incl NUMERIC",
    "total_excl NUMERIC",
    "total_vat NUMERIC",
    "currency TEXT",
    "vat_breakdown JSONB",
    "raw_text TEXT",
    "raw_json JSONB",
    "source_storage TEXT",
    "source_url TEXT",
    "source_filename TEXT",
    "primary_profile_id INTEGER",
    "split_mode BOOLEAN",
    "created_at TIMESTAMPTZ",
    "updated_at TIMESTAMPTZ",
  ];

  for (const columnDef of invoiceColumns) {
    const [columnName] = columnDef.split(" ");
    await pool.query(`ALTER TABLE invoices ADD COLUMN IF NOT EXISTS ${columnDef}`);
   if (columnName === "primary_profile_id") {
      await pool.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conrelid = 'invoices'::regclass
              AND conname = 'invoices_primary_profile_id_fkey'
          ) THEN
            ALTER TABLE invoices
              ADD CONSTRAINT invoices_primary_profile_id_fkey
              FOREIGN KEY (primary_profile_id) REFERENCES profiles(id) ON DELETE SET NULL;
          END IF;
        END
        $$;
      `);
     }
      if (columnName === "user_id") {
        await pool.query(`
          DO $$
          BEGIN
            IF NOT EXISTS (
              SELECT 1 FROM pg_constraint
              WHERE conrelid = 'invoices'::regclass
                AND conname = 'invoices_user_id_fkey'
            ) THEN
              ALTER TABLE invoices
                ADD CONSTRAINT invoices_user_id_fkey
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
            END IF;
          END
          $$;
        `);
      }
  }

  await pool.query(`
    CREATE UNIQUE INDEX IF NOT EXISTS invoices_user_number_unique
    ON invoices(user_id, invoice_number)
    WHERE user_id IS NOT NULL AND invoice_number IS NOT NULL;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS invoice_items (
      id UUID PRIMARY KEY,
      invoice_id UUID NOT NULL,
      user_id UUID REFERENCES users(id) ON DELETE CASCADE,
      line_index INTEGER,
      description TEXT,
      normalized_name TEXT,
      quantity NUMERIC,
      unit TEXT,
      unit_price NUMERIC,
      total_price NUMERIC,
      vat_rate NUMERIC,
      vat_amount NUMERIC,
      category TEXT,
      subcategory TEXT,
      coa_account_number TEXT,
      profile_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL,
      raw_json JSONB,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await pool.query(`
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'invoice_items'::regclass
          AND conname = 'invoice_items_invoice_id_fkey'
      ) THEN
        ALTER TABLE invoice_items
          ADD CONSTRAINT invoice_items_invoice_id_fkey
          FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE;
      END IF;
    END
    $$;
  `);

  const itemColumns = [
    "user_id UUID",
    "line_index INTEGER",
    "description TEXT",
    "normalized_name TEXT",
    "quantity NUMERIC",
    "unit TEXT",
    "unit_price NUMERIC",
    "total_price NUMERIC",
    "vat_rate NUMERIC",
    "vat_amount NUMERIC",
    "category TEXT",
    "subcategory TEXT",
    "coa_account_number TEXT",
    "profile_id INTEGER",
    "raw_json JSONB",
    "created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()",
  ];

  for (const columnDef of itemColumns) {
    const [columnName] = columnDef.split(" ");
    await pool.query(`ALTER TABLE invoice_items ADD COLUMN IF NOT EXISTS ${columnDef}`);
    if (columnName === "profile_id") {
      await pool.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conrelid = 'invoice_items'::regclass
              AND conname = 'invoice_items_profile_id_fkey'
          ) THEN
            ALTER TABLE invoice_items
              ADD CONSTRAINT invoice_items_profile_id_fkey
              FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE SET NULL;
          END IF;
        END
        $$;
      `);
    }
    if (columnName === "user_id") {
      await pool.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conrelid = 'invoice_items'::regclass
              AND conname = 'invoice_items_user_id_fkey'
          ) THEN
            ALTER TABLE invoice_items
              ADD CONSTRAINT invoice_items_user_id_fkey
              FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
          END IF;
        END
        $$;
      `);
    }
  }
}

async function saveInvoiceWithItems({
  factuurdetails,
  structured,
  invoiceText,
  file,
  selectedAccount,
  splitMode,
  selectedProfileId,
  lineItems,
  userId,
}) {
  await ensureInvoiceTables();

  const invoiceId = crypto.randomUUID();
  const invoiceNumber = factuurdetails?.factuurnummer || null;
  const invoiceDate = toDate(factuurdetails?.factuurdatum);
  const vendorName = factuurdetails?.afzender?.naam || null;
  const paymentMethod = factuurdetails?.betaling_methode || null;
  const totals = factuurdetails?.totaal || {};
  const totalIncl = toNumber(totals?.totaal_incl_btw ?? totals?.totaal_incl);
  const totalExcl = toNumber(totals?.totaal_excl_btw ?? totals?.totaal_excl);
  const totalVat = toNumber(totals?.btw);
  const currency = totals?.valuta || null;
  const vatBreakdown = structured?.factuurdetails?.btw_overzicht || null;
  const primaryProfileId = selectedProfileId ? Number(selectedProfileId) : null;

  const sourceStorage = file?.storage || null;
  const sourceUrl = file?.url || null;
  const sourceFilename = file?.filename || null;

  let effectiveInvoiceId = invoiceId;
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const { rows: upsertRows } = await client.query(
      `INSERT INTO invoices (
        id, user_id, invoice_number, invoice_date, vendor_name, payment_method,
        total_incl, total_excl, total_vat, currency, vat_breakdown,
        raw_text, raw_json, source_storage, source_url, source_filename,
        primary_profile_id, split_mode
      ) VALUES (
        $1, $2, $3, $4, $5, $6,
        $7, $8, $9, $10, $11,
        $12, $13, $14, $15, $16,
        $17, $18
      )
      ON CONFLICT (user_id, invoice_number)
      DO UPDATE SET
        invoice_date = EXCLUDED.invoice_date,
        vendor_name = EXCLUDED.vendor_name,
        payment_method = EXCLUDED.payment_method,
        total_incl = EXCLUDED.total_incl,
        total_excl = EXCLUDED.total_excl,
        total_vat = EXCLUDED.total_vat,
        currency = EXCLUDED.currency,
        vat_breakdown = EXCLUDED.vat_breakdown,
        raw_text = EXCLUDED.raw_text,
        raw_json = EXCLUDED.raw_json,
        source_storage = EXCLUDED.source_storage,
        source_url = EXCLUDED.source_url,
        source_filename = EXCLUDED.source_filename,
        primary_profile_id = EXCLUDED.primary_profile_id,
        split_mode = EXCLUDED.split_mode,
        updated_at = NOW()
      RETURNING id`,
      [
        invoiceId,
        userId || null,
        invoiceNumber,
        invoiceDate,
        vendorName,
        paymentMethod,
        totalIncl,
        totalExcl,
        totalVat,
        currency,
        vatBreakdown,
        invoiceText || null,
        structured || null,
        sourceStorage,
        sourceUrl,
        sourceFilename,
        primaryProfileId,
        Boolean(splitMode),
      ]
    );

    effectiveInvoiceId = upsertRows?.[0]?.id || invoiceId;

    await client.query(
      `DELETE FROM invoice_items WHERE invoice_id = $1 AND (user_id = $2 OR $2 IS NULL)`,
      [effectiveInvoiceId, userId || null]
    );

    if (Array.isArray(lineItems)) {
      for (const item of lineItems) {
        const itemId = crypto.randomUUID();
        const profileId = item.profileId && item.profileId !== "default" ? Number(item.profileId) : null;

        await client.query(
          `INSERT INTO invoice_items (
            id, invoice_id, user_id, line_index, description, normalized_name, quantity, unit,
            unit_price, total_price, vat_rate, vat_amount, category, subcategory,
            coa_account_number, profile_id, raw_json
          ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8,
            $9, $10, $11, $12, $13, $14,
            $15, $16, $17
          )`,
          [
            itemId,
            effectiveInvoiceId,
            userId || null,
            item.lineIndex ?? null,
            item.description || null,
            item.normalizedName || null,
            toNumber(item.quantity),
            item.unit || null,
            toNumber(item.unitPrice),
            toNumber(item.totalIncl ?? item.total_price ?? item.totalExcl),
            toNumber(item.vatRate),
            toNumber(item.vatAmount),
            item.category || null,
            item.subcategory || null,
            item.coaAccountNumber || selectedAccount || null,
            profileId,
            item.raw || null,
          ]
        );
      }
    }

    await client.query("COMMIT");
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }

  return effectiveInvoiceId;
}

export { ensureInvoiceTables, saveInvoiceWithItems };
