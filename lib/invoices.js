// lib/invoices.js
import crypto from "crypto";
import pool from "./db.js";
import { ensureProfilesTable } from "./profiles.js";
import { ensureVendorsTables, upsertVendorFromInvoice } from "./vendors.js";
import { ensureCustomersTables, upsertCustomerFromInvoice } from "./customers.js";

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

function formatInvoiceDisplayName({ vendor, invoiceDate, invoiceNumber, fallback = "Invoice" }) {
  const parts = [];
  const vendorName = vendor ? String(vendor).trim() : "";
  if (vendorName) parts.push(vendorName);

  let normalizedDate = "";
  if (invoiceDate) {
    const parsed = new Date(invoiceDate);
    if (!Number.isNaN(parsed.getTime())) {
      normalizedDate = parsed.toISOString().slice(0, 10);
    } else if (typeof invoiceDate === "string" && invoiceDate.trim()) {
      normalizedDate = invoiceDate.trim();
    }
  }
  if (normalizedDate) parts.push(normalizedDate);

  const numberLabel = invoiceNumber ? String(invoiceNumber).trim() : "";
  if (numberLabel) parts.push(`#${numberLabel}`);

  if (!parts.length) return fallback;
  return parts.join(" · ");
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

  await pool.query(`ALTER TABLE invoices ADD COLUMN IF NOT EXISTS booking_status TEXT DEFAULT 'pending_review'`);
  await pool.query(`ALTER TABLE invoices ADD COLUMN IF NOT EXISTS booked_at TIMESTAMPTZ`);
  await pool.query(`ALTER TABLE invoices ADD COLUMN IF NOT EXISTS booking_summary JSONB DEFAULT '[]'::jsonb`);
  await pool.query(`UPDATE invoices SET booking_status = 'pending_review' WHERE booking_status IS NULL`);
  await pool.query(`UPDATE invoices SET booking_summary = '[]'::jsonb WHERE booking_summary IS NULL`);

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
  await ensureVendorsTables();
  await ensureCustomersTables();

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

    try {
      await upsertVendorFromInvoice({
        userId,
        factuurdetails,
        invoiceId: effectiveInvoiceId,
        invoiceTotalIncl: totalIncl,
        invoiceCurrency: currency,
      });
    } catch (err) {
      console.warn("[invoices] vendor upsert failed", err);
    }

    try {
      await upsertCustomerFromInvoice({
        userId,
        factuurdetails,
        invoiceTotalIncl: totalIncl,
        invoiceCurrency: currency,
      });
    } catch (err) {
      console.warn("[invoices] customer upsert failed", err);
    }

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

function normalizeJsonArray(value) {
  if (!value) return [];
  if (Array.isArray(value)) return value;
  if (typeof value === "string") {
    try {
      const parsed = JSON.parse(value);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }
  if (typeof value === "object") {
    return Array.isArray(value) ? value : [];
  }
  return [];
}

function deriveInvoiceStatus(row) {
  if (!row.invoice_number) return "Missing Data";
  if (row.split_mode) return "Needs Split";

  const stored = typeof row.booking_status === "string" ? row.booking_status.toLowerCase() : "";
  const bookingCount = Number(row.booking_profile_count || 0);

  if (stored === "booked" || stored === "paid" || bookingCount > 0 || row.booked_at) {
    return "Booked";
  }

  return "Pending Review";
}

function mapInvoiceRow(row) {
  const rawJson = row.raw_json || {};
  const factuur = rawJson?.factuurdetails || {};
  const afzender = factuur?.afzender || {};
  const ontvanger = factuur?.ontvanger || {};
  const vendorName = row.vendor_name || afzender?.naam || "—";
  const invoiceNumber = row.invoice_number || factuur?.factuurnummer || factuur?.referentie || null;
  const invoiceDate = row.invoice_date || factuur?.factuurdatum || null;
  const displayName = formatInvoiceDisplayName({
    vendor: vendorName,
    invoiceDate,
    invoiceNumber,
    fallback: row.source_filename || invoiceNumber || vendorName || "Invoice",
  });

  const bookingTargets = normalizeJsonArray(row.booking_targets ?? row.booking_summary);
  const bookingSummary = bookingTargets
    .filter((entry) => entry && entry.profile !== "payment")
    .map((entry) => ({
      profile: entry.profile ?? "default",
      profileName: entry.profileName || null,
      account: entry.account || null,
      amount: toNumber(entry.amount),
    }));

  const assignedTo = bookingSummary.length
    ? bookingSummary
        .map((entry) => {
          const profileLabel = entry.profileName
            ? entry.profileName
            : entry.profile === "default"
            ? "Default"
            : `Profile ${entry.profile}`;
          const accountLabel = entry.account || "—";
          return `${profileLabel} -> ${accountLabel}`;
        })
        .join("; ")
    : row.assignee || null;

  const status = deriveInvoiceStatus(row);

  return {
    id: row.id,
    invoiceNumber: row.invoice_number || "",
    invoiceDate: row.invoice_date || null,
    vendor: vendorName,
    totalIncl: toNumber(row.total_incl),
    currency: row.currency || factuur?.valuta || "USD",
    status,
    bookingStatus: row.booking_status || status,
    bookedAt: row.booked_at,
    bookingSummary,
    splitMode: row.split_mode,
    sourceFilename: row.source_filename || displayName,
    displayName,
    primaryProfileId: row.primary_profile_id != null ? String(row.primary_profile_id) : null,
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
    assignee: assignedTo || undefined,
  };
}

async function listInvoicesForUser(userId, { limit = 50 } = {}) {
  await ensureInvoiceTables();
  if (!userId) return [];
  const { rows } = await pool.query(
    `SELECT
        i.*,
        COALESCE(
          json_agg(
            jsonb_build_object(
              'profile', b.profile_reference,
              'profileName', p.name,
              'account', b.account_code,
              'amount', b.amount
            )
          ) FILTER (WHERE b.invoice_id IS NOT NULL),
          '[]'
        ) AS booking_targets,
        COUNT(*) FILTER (
          WHERE b.invoice_id IS NOT NULL
            AND COALESCE(b.profile_reference, '') <> 'payment'
        ) AS booking_profile_count
     FROM invoices i
     LEFT JOIN bookings b
       ON NULLIF(b.invoice_id::text, '')::uuid = i.id
     AND (
        (b.user_id IS NOT NULL AND NULLIF(b.user_id::text, '')::uuid = i.user_id)
        OR (b.user_id IS NULL AND i.user_id IS NULL)
      )
     LEFT JOIN profiles p
       ON b.profile_reference ~ '^[0-9]+$'
      AND p.id::text = b.profile_reference
     WHERE i.user_id = $1::uuid
     GROUP BY i.id
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
        i.*,
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
      GROUP BY i.id
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

async function listLineItemsForUser(userId, { limit = 500, profile = null } = {}) {
  await ensureInvoiceTables();
  if (!userId) return [];

  const values = [userId, limit];
  let profileCondition = "";
  if (profile && profile !== "all") {
    values.push(String(profile));
    profileCondition = `WHERE items.profile_key = $${values.length}`;
  }

  const sql = `
    WITH booking_profiles AS (
      SELECT
        b.invoice_id,
        b.profile_reference,
        array_remove(array_agg(DISTINCT b.account_code), NULL) AS debit_accounts,
        array_remove(array_agg(DISTINCT b.counter_account_code), NULL) AS credit_accounts,
        SUM(b.amount) AS booking_total
      FROM bookings b
      WHERE b.profile_reference IS NOT NULL
        AND b.profile_reference <> 'payment'
        AND (b.user_id = $1::uuid OR $1 IS NULL)
      GROUP BY b.invoice_id, b.profile_reference
    ),
    items AS (
      SELECT
        ii.id,
        ii.invoice_id,
        ii.line_index,
        ii.description,
        ii.quantity,
        ii.unit_price,
        ii.total_price,
        ii.category,
        ii.subcategory,
        ii.raw_json,
        ii.profile_id,
        i.invoice_number,
        i.invoice_date,
        i.created_at AS invoice_created_at,
        i.vendor_name,
        i.currency,
        i.total_incl,
        COALESCE(
          NULLIF(bp.profile_reference, ''),
          CASE
            WHEN ii.profile_id IS NOT NULL THEN ii.profile_id::text
            WHEN i.primary_profile_id IS NOT NULL THEN i.primary_profile_id::text
            ELSE 'default'
          END
        ) AS profile_key,
        bp.debit_accounts,
        bp.credit_accounts,
        bp.booking_total
      FROM invoice_items ii
      JOIN invoices i ON i.id = ii.invoice_id
      LEFT JOIN booking_profiles bp
        ON bp.invoice_id = ii.invoice_id
       AND (
          (ii.profile_id IS NOT NULL AND bp.profile_reference = ii.profile_id::text)
          OR (ii.profile_id IS NULL AND bp.profile_reference = COALESCE(i.primary_profile_id::text, 'default'))
        )
      WHERE i.user_id = $1::uuid
    )
    SELECT
      items.*,
      pr.name AS profile_name
    FROM items
    LEFT JOIN profiles pr
      ON items.profile_key ~ '^[0-9]+$' AND pr.id::text = items.profile_key
    ${profileCondition}
    ORDER BY items.invoice_date DESC NULLS LAST, items.invoice_created_at DESC, items.line_index ASC
    LIMIT $2`;

  const { rows } = await pool.query(sql, values);

  return rows.map((row) => {
    const totalPrice = toNumber(row.total_price);
    const unitPrice = toNumber(row.unit_price);
    const quantity = toNumber(row.quantity);
    const fallbackTotal = quantity != null && unitPrice != null ? quantity * unitPrice : null;
    const parsedRaw = (() => {
      if (!row.raw_json) return null;
      if (typeof row.raw_json === "object") return row.raw_json;
      try {
        return JSON.parse(row.raw_json);
      } catch {
        return row.raw_json;
      }
    })();

    const profileKey =
      row.profile_key ||
      (row.profile_id != null ? String(row.profile_id) : null) ||
      "default";

    const debitAccounts = Array.isArray(row.debit_accounts)
      ? row.debit_accounts.filter(Boolean).map(String)
      : [];
    const creditAccounts = Array.isArray(row.credit_accounts)
      ? row.credit_accounts.filter(Boolean).map(String)
      : [];

    return {
      id: row.id,
      invoiceId: row.invoice_id,
      lineIndex: row.line_index,
      description: row.description || parsedRaw?.omschrijving || "—",
      quantity,
      unitPrice,
      totalPrice: totalPrice ?? fallbackTotal,
      category: row.category || parsedRaw?.categorie || "",
      subcategory: row.subcategory || parsedRaw?.subcategorie || "",
      raw: parsedRaw,
      profileId: profileKey,
      profileName:
        row.profile_name || (profileKey === "default" ? "Default" : `Profile ${profileKey}`),
      invoiceNumber: row.invoice_number || "—",
      invoiceDate: row.invoice_date,
      vendorName: row.vendor_name || "—",
      currency: row.currency || "EUR",
      invoiceTotal: toNumber(row.total_incl),
      bookingAccounts: {
        debit: debitAccounts,
        credit: creditAccounts,
      },
      bookingAmount: toNumber(row.booking_total),
    };
  });
}

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function normalizeUuidList(values) {
  if (!Array.isArray(values)) return [];
  const unique = new Set();
  for (const value of values) {
    if (typeof value !== "string") continue;
    const trimmed = value.trim();
    if (UUID_REGEX.test(trimmed)) {
      unique.add(trimmed.toLowerCase());
    }
  }
  return Array.from(unique);
}

async function deleteInvoicesForUser(userId, invoiceIds) {
  const normalizedUserId = typeof userId === "string" && UUID_REGEX.test(userId) ? userId : null;
  const normalizedIds = normalizeUuidList(invoiceIds);
  if (!normalizedUserId || normalizedIds.length === 0) {
    return { deleted: 0 };
  }

  await ensureInvoiceTables();

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    await client.query(`DELETE FROM bookings WHERE invoice_id::text = ANY($1::text[])`, [normalizedIds]);

    const { rowCount } = await client.query(
      `DELETE FROM invoices WHERE id = ANY($1::uuid[]) AND user_id = $2::uuid`,
      [normalizedIds, normalizedUserId]
    );

    await client.query("COMMIT");
    return { deleted: rowCount };
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}

export {
  ensureInvoiceTables,
  saveInvoiceWithItems,
  listInvoicesForUser,
  listInboxEntriesForUser,
  listLineItemsForUser,
  deleteInvoicesForUser,
};
