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

function toInteger(value) {
  if (value === null || value === undefined || value === "") return null;
  const num = Number(value);
  return Number.isFinite(num) ? Math.trunc(num) : null;
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

  await pool.query(`ALTER TABLE IF EXISTS line_items DROP CONSTRAINT IF EXISTS line_items_invoice_number_fkey`);

  await pool.query(`
    DO $$
    DECLARE
      pk_cols text[];
    BEGIN
      SELECT ARRAY_AGG(attname ORDER BY cols.ordinality) INTO pk_cols
      FROM pg_constraint c
      JOIN unnest(c.conkey) WITH ORDINALITY AS cols(attnum, ordinality)
        ON true
      JOIN pg_attribute a
        ON a.attrelid = c.conrelid AND a.attnum = cols.attnum
      WHERE c.conrelid = 'invoices'::regclass
        AND c.contype = 'p';

      IF pk_cols = ARRAY['invoice_number'] THEN
        ALTER TABLE invoices DROP CONSTRAINT invoices_pkey;
      END IF;
    EXCEPTION
      WHEN undefined_column THEN
        NULL;
    END;
    $$;
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
          AND conname = 'invoices_pkey'
      ) THEN
        ALTER TABLE invoices
          ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);
      END IF;
    END
    $$;
  `);
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
    CREATE UNIQUE INDEX IF NOT EXISTS invoices_user_number_unique_all
    ON invoices(user_id, invoice_number);
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
  const invoiceNumber =
    factuurdetails?.factuurnummer ||
    factuurdetails?.referentie ||
    file?.filename ||
    `AUTO-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`;
  const invoiceDate = toDate(factuurdetails?.factuurdatum);
  const vendorName = factuurdetails?.afzender?.naam || null;
  const paymentMethod = factuurdetails?.betaling_methode || null;
  const totals = factuurdetails?.totaal || {};
  const totalIncl = toNumber(totals?.totaal_incl_btw ?? totals?.totaal_incl);
  const totalExcl = toNumber(totals?.totaal_excl_btw ?? totals?.totaal_excl);
  const totalVat = toNumber(totals?.btw);
  const currency = totals?.valuta || null;
  const vatBreakdown = structured?.factuurdetails?.btw_overzicht || null;
  const primaryProfileId = toInteger(selectedProfileId);

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
        const profileId = toInteger(item.profileId && item.profileId !== "default" ? item.profileId : null);

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
            item.coaAccountNumber || (selectedAccount || null),
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

function deriveInvoiceStatus(row) {
  if (!row.invoice_number) return "Missing Data";
  if (row.split_mode) return "Needs Split";
  return "Pending Review";
}

function mapInvoiceRow(row) {
  const rawJson = row.raw_json || {};
  const factuur = rawJson?.factuurdetails || {};
  const afzender = factuur?.afzender || {};
  const ontvanger = factuur?.ontvanger || {};

  return {
    id: row.id,
    invoiceNumber: row.invoice_number || "",
    invoiceDate: row.invoice_date || null,
    vendor: row.vendor_name || afzender?.naam || "—",
    totalIncl: toNumber(row.total_incl),
    currency: row.currency || factuur?.valuta || "USD",
    status: deriveInvoiceStatus(row),
    splitMode: row.split_mode,
    sourceFilename: row.source_filename || null,
    sourceUrl: row.source_url || null,
    createdAt: row.created_at,
    rawJson,
    senderAddress: [
      afzender?.naam,
      afzender?.adres?.straat,
      afzender?.adres?.stad,
      afzender?.adres?.land,
    ]
      .filter(Boolean)
      .join(", ") || "—",
    receiverAddress: [
      ontvanger?.naam,
      ontvanger?.adres?.straat,
      ontvanger?.adres?.stad,
      ontvanger?.adres?.land,
    ]
      .filter(Boolean)
      .join(", ") || "—",
    contactPhone: afzender?.telefoon || ontvanger?.telefoon || "—",
    contactEmail: afzender?.email || ontvanger?.email || "—",
  };
}

async function listInvoicesForUser(userId, { limit = 50 } = {}) {
  await ensureInvoiceTables();
  if (!userId) return [];
  const { rows } = await pool.query(
    `SELECT i.*
     FROM invoices i
     WHERE i.user_id = $1
     ORDER BY i.invoice_date DESC NULLS LAST, i.created_at DESC
     LIMIT $2`,
    [userId, limit]
  );
  return rows.map(mapInvoiceRow);
}

async function listInboxEntriesForUser(userId, { limit = 10 } = {}) {
  await ensureInvoiceTables();
  if (!userId) return [];
  const { rows } = await pool.query(
    `SELECT
        i.id,
        i.user_id,
        i.invoice_number,
        i.invoice_date,
        i.vendor_name,
        i.payment_method,
        i.total_incl,
        i.total_excl,
        i.total_vat,
        i.currency,
        i.vat_breakdown,
        i.raw_text,
        i.raw_json,
        i.source_storage,
        i.source_url,
        i.source_filename,
        i.primary_profile_id,
        i.split_mode,
        i.created_at,
        i.updated_at,
        COALESCE(
          json_agg(
            jsonb_build_object(
              'description', ii.description,
              'quantity', ii.quantity,
              'unitPrice', ii.unit_price,
              'totalPrice', ii.total_price
            ) ORDER BY ii.line_index NULLS LAST
          ) FILTER (WHERE ii.id IS NOT NULL), '[]'
        ) AS items
      FROM invoices i
      LEFT JOIN invoice_items ii ON ii.invoice_id = i.id
      WHERE i.user_id = $1
      GROUP BY
        i.id,
        i.user_id,
        i.invoice_number,
        i.invoice_date,
        i.vendor_name,
        i.payment_method,
        i.total_incl,
        i.total_excl,
        i.total_vat,
        i.currency,
        i.vat_breakdown,
        i.raw_text,
        i.raw_json,
        i.source_storage,
        i.source_url,
        i.source_filename,
        i.primary_profile_id,
        i.split_mode,
        i.created_at,
        i.updated_at
      ORDER BY i.created_at DESC
      LIMIT $2`,
    [userId, limit]
  );

  return rows.map((row) => {
    const base = mapInvoiceRow(row);
    const items = Array.isArray(row.items)
      ? row.items
          .filter(Boolean)
          .map((item) => ({
            description: item.description || "—",
            quantity: toNumber(item.quantity),
            unitPrice: toNumber(item.unitprice ?? item.unitPrice),
            totalPrice: toNumber(item.totalprice ?? item.totalPrice),
          }))
      : [];

    let effectiveItems = items;
    if (!effectiveItems.length) {
      const fallbackLines = base.rawJson?.factuurdetails?.regels;
      if (Array.isArray(fallbackLines)) {
        effectiveItems = fallbackLines.map((line, index) => ({
          description: line.omschrijving || line.omschrijving_lang || `Line ${index + 1}`,
          quantity: toNumber(line.aantal),
          unitPrice: toNumber(line.prijs_per_stuk || line.prijs),
          totalPrice: toNumber(line.totaal_incl || line.totaal || line.totaal_excl),
        }));
      }
    }

    return {
      ...base,
      items: effectiveItems,
      lineItems: effectiveItems,
    };
  });
}

export { ensureInvoiceTables, saveInvoiceWithItems, listInvoicesForUser, listInboxEntriesForUser };
