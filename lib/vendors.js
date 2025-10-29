import pool from "./db.js";

const CREDIT_STATES = ["good", "attention", "delinquent", "unknown"];

async function ensureVendorsTables() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS vendors (
      id SERIAL PRIMARY KEY,
      user_id UUID REFERENCES users(id) ON DELETE CASCADE,
      vendor_key TEXT,
      display_name TEXT,
      legal_name TEXT,
      trade_name TEXT,
      kvk_number TEXT,
      vat_number TEXT,
      tax_id TEXT,
      email TEXT,
      phone TEXT,
      website TEXT,
      iban TEXT,
      bank_name TEXT,
      opening_hours TEXT,
      contacts JSONB,
      payment_terms_days INTEGER,
      default_account TEXT,
      default_profile_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL,
      tags TEXT[],
      notes TEXT,
      metadata JSONB,
      source_snapshot JSONB,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await pool.query(`ALTER TABLE vendors ALTER COLUMN user_id SET NOT NULL`);

  await pool.query(`ALTER TABLE vendors ADD COLUMN IF NOT EXISTS opening_hours TEXT`);
  await pool.query(`ALTER TABLE vendors ADD COLUMN IF NOT EXISTS contacts JSONB`);
  await pool.query(`ALTER TABLE vendors ADD COLUMN IF NOT EXISTS source_snapshot JSONB`);

  await pool.query(`
    CREATE INDEX IF NOT EXISTS vendors_user_id_idx
    ON vendors(user_id);
  `);

  await pool.query(`
    CREATE UNIQUE INDEX IF NOT EXISTS vendors_user_key_unique
    ON vendors(user_id, COALESCE(vendor_key, display_name))
    WHERE user_id IS NOT NULL;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS vendor_payment_stats (
      vendor_id INTEGER PRIMARY KEY REFERENCES vendors(id) ON DELETE CASCADE,
      invoices_total INTEGER NOT NULL DEFAULT 0,
      total_invoiced_amount NUMERIC NOT NULL DEFAULT 0,
      total_paid_amount NUMERIC NOT NULL DEFAULT 0,
      average_days_to_pay NUMERIC,
      on_time_ratio NUMERIC,
      last_invoice_amount NUMERIC,
      last_invoice_currency TEXT,
      last_invoice_at TIMESTAMPTZ,
      last_payment_at TIMESTAMPTZ,
      credit_state TEXT DEFAULT 'unknown',
      credit_limit NUMERIC,
      credit_notes TEXT,
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await pool.query(`
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'vendors'::regclass
          AND conname = 'vendors_default_profile_id_fkey'
      ) THEN
        ALTER TABLE vendors
          ADD CONSTRAINT vendors_default_profile_id_fkey
          FOREIGN KEY (default_profile_id) REFERENCES profiles(id) ON DELETE SET NULL;
      END IF;
    END
    $$;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS vendor_locations (
      id SERIAL PRIMARY KEY,
      vendor_id INTEGER REFERENCES vendors(id) ON DELETE CASCADE,
      label TEXT,
      street TEXT,
      house_number TEXT,
      postal_code TEXT,
      city TEXT,
      region TEXT,
      country TEXT,
      full_address TEXT,
      phone TEXT,
      email TEXT,
      is_primary BOOLEAN DEFAULT FALSE,
      metadata JSONB,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS vendor_tax_ids (
      id SERIAL PRIMARY KEY,
      vendor_id INTEGER REFERENCES vendors(id) ON DELETE CASCADE,
      type TEXT,
      value TEXT,
      country TEXT,
      is_primary BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
}

function buildVendorKey({ vatNumber, kvkNumber, trimmedName }) {
  if (vatNumber) return `vat:${vatNumber.toUpperCase()}`;
  if (kvkNumber) return `kvk:${kvkNumber}`;
  if (trimmedName) return `name:${trimmedName.toLowerCase()}`;
  return null;
}

function extractContactDetails(factuurdetails = {}) {
  const vendor = factuurdetails.afzender || {};
  const address = {
    street: vendor.straat || vendor.adres_straat || null,
    houseNumber: vendor.huisnummer || null,
    postalCode: vendor.postcode || null,
    city: vendor.plaats || vendor.stad || null,
    region: vendor.provincie_of_staat || vendor.regio || null,
    country: vendor.land || null,
    full: vendor.adres_volledig || vendor.adres || null,
  };

  return {
    displayName: vendor.naam || null,
    tradeName: vendor.handelsnaam || null,
    kvkNumber: vendor.kvk_nummer || null,
    vatNumber: vendor.btw_nummer || null,
    taxId: vendor.fiscaal_nummer || vendor.tax_id || null,
    email: vendor.email || null,
    phone: vendor.telefoon || vendor.telefoonnummer || null,
    website: vendor.website || null,
    address,
    iban: vendor.iban || vendor.bankrekening || vendor.bank_account || null,
    bankName: vendor.bank_naam || vendor.bank_name || null,
    openingHours: vendor.openingstijden || vendor.opening_hours || null,
    contacts: vendor.contacten || vendor.contacts || null,
  };
}

async function upsertVendorFromInvoice({ userId, factuurdetails, invoiceId, invoiceTotalIncl, invoiceCurrency }) {
  if (!userId || !factuurdetails) return null;
  await ensureVendorsTables();

  const {
    displayName,
    tradeName,
    kvkNumber,
    vatNumber,
    taxId,
    email,
    phone,
    website,
    address,
    iban,
    bankName,
    openingHours,
    contacts,
  } = extractContactDetails(factuurdetails);

  if (!displayName && !vatNumber && !kvkNumber) {
    return null;
  }

  const trimmedName = displayName ? displayName.trim() : null;
  const vendorKey = buildVendorKey({ vatNumber, kvkNumber, trimmedName });

  let existing = { rowCount: 0 };
  if (vendorKey) {
    existing = await pool.query(
      `SELECT id, display_name FROM vendors
       WHERE user_id = $1 AND vendor_key = $2
       ORDER BY id
       LIMIT 1`,
      [userId, vendorKey]
    );
  } else if (trimmedName) {
    existing = await pool.query(
      `SELECT id, display_name FROM vendors
       WHERE user_id = $1 AND vendor_key IS NULL AND display_name = $2
       ORDER BY id
       LIMIT 1`,
      [userId, trimmedName]
    );
  }

  const fields = {
    vendor_key: vendorKey,
    display_name: trimmedName,
    legal_name: factuurdetails?.afzender?.rechtspersoon || null,
    trade_name: tradeName,
    kvk_number: kvkNumber,
    vat_number: vatNumber,
    tax_id: taxId,
    email,
    phone,
    website,
    iban,
    bank_name: bankName,
    opening_hours: openingHours || factuurdetails?.openingstijden || null,
    contacts: contacts || factuurdetails?.contacten || null,
    metadata: {
      address,
    },
    source_snapshot: factuurdetails || null,
  };

  let vendorId;

  if (existing.rowCount > 0) {
    vendorId = existing.rows[0].id;
    const assignments = Object.keys(fields)
      .filter((key) => fields[key] !== undefined)
      .map((key, idx) => `${key} = $${idx + 4}`);

    await pool.query(
      `UPDATE vendors
       SET ${assignments.join(", ")}, updated_at = NOW()
       WHERE id = $1 AND user_id = $2`,
      [vendorId, userId, ...Object.values(fields)]
    );
  } else {
    const columnNames = ["user_id"].concat(Object.keys(fields));
    const placeholders = columnNames.map((_, idx) => `$${idx + 1}`);

    const result = await pool.query(
      `INSERT INTO vendors (${columnNames.join(", ")})
       VALUES (${placeholders.join(", ")})
       RETURNING id`,
      [userId, ...Object.values(fields)]
    );
    vendorId = result.rows[0].id;
  }

  if (!vendorId) return null;

  const amount = Number(invoiceTotalIncl || 0) || 0;
  const currency = invoiceCurrency || factuurdetails?.totaal?.valuta || null;
  const paymentTermsDays = factuurdetails?.betalingstermijn_dagen || factuurdetails?.betalingstermijn || null;

  await pool.query(
    `INSERT INTO vendor_payment_stats (
        vendor_id, invoices_total, total_invoiced_amount, total_paid_amount,
        average_days_to_pay, on_time_ratio, last_invoice_amount, last_invoice_currency,
        last_invoice_at, credit_state, credit_notes, credit_limit, updated_at
      ) VALUES (
        $1, 1, $2, 0, NULL, NULL, $2, $3, NOW(), $4, NULL, NULL, NOW()
      )
      ON CONFLICT (vendor_id) DO UPDATE SET
        invoices_total = vendor_payment_stats.invoices_total + 1,
        total_invoiced_amount = vendor_payment_stats.total_invoiced_amount + EXCLUDED.total_invoiced_amount,
        last_invoice_amount = EXCLUDED.last_invoice_amount,
        last_invoice_currency = EXCLUDED.last_invoice_currency,
        last_invoice_at = NOW(),
        credit_state = CASE
          WHEN vendor_payment_stats.credit_state IS NULL OR vendor_payment_stats.credit_state = 'unknown'
            THEN EXCLUDED.credit_state
          ELSE vendor_payment_stats.credit_state
        END,
        updated_at = NOW();`,
    [vendorId, amount, currency, CREDIT_STATES.includes("good") ? "good" : "unknown"]
  );

  if (paymentTermsDays != null) {
    await pool.query(
      `UPDATE vendors
       SET payment_terms_days = COALESCE($3, payment_terms_days), updated_at = NOW()
       WHERE id = $1 AND user_id = $2`,
      [vendorId, userId, Number(paymentTermsDays) || null]
    );
  }

  if (vendorId) {
    await upsertVendorLocations({ vendorId, address, email, phone });
    await upsertVendorTaxIds({ vendorId, vatNumber, kvkNumber, taxId });
  }

  return vendorId;
}

async function upsertVendorLocations({ vendorId, address, email, phone }) {
  if (!vendorId) return;
  const normalized = {
    street: address?.street || null,
    house_number: address?.houseNumber || null,
    postal_code: address?.postalCode || null,
    city: address?.city || null,
    region: address?.region || null,
    country: address?.country || null,
    full_address: address?.full || null,
    email: email || null,
    phone: phone || null,
  };

  const existing = await pool.query(
    `SELECT id FROM vendor_locations
     WHERE vendor_id = $1 AND (full_address = $2 OR ($2 IS NULL AND is_primary = TRUE))
     ORDER BY is_primary DESC, id
     LIMIT 1`,
    [vendorId, normalized.full_address]
  );

  if (existing.rowCount > 0) {
    const locationId = existing.rows[0].id;
    const assignments = Object.keys(normalized)
      .map((key, idx) => `${key} = $${idx + 2}`)
      .join(", ");
    await pool.query(
      `UPDATE vendor_locations
       SET ${assignments}, updated_at = NOW(), is_primary = TRUE
       WHERE id = $1`,
      [locationId, ...Object.values(normalized)]
    );
  } else {
    await pool.query(
      `INSERT INTO vendor_locations (
        vendor_id, street, house_number, postal_code, city, region, country,
        full_address, phone, email, is_primary
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7,
        $8, $9, $10, TRUE
      )`,
      [vendorId, ...Object.values(normalized)]
    );
  }
}

async function upsertVendorTaxIds({ vendorId, vatNumber, kvkNumber, taxId }) {
  if (!vendorId) return;
  const entries = [];
  if (vatNumber) entries.push({ type: "vat", value: vatNumber });
  if (kvkNumber) entries.push({ type: "kvk", value: kvkNumber });
  if (taxId) entries.push({ type: "tax", value: taxId });
  if (!entries.length) return;

  for (const entry of entries) {
    const existing = await pool.query(
      `SELECT id FROM vendor_tax_ids
       WHERE vendor_id = $1 AND type = $2 AND value = $3
       LIMIT 1`,
      [vendorId, entry.type, entry.value]
    );
    if (existing.rowCount > 0) {
      await pool.query(
        `UPDATE vendor_tax_ids
         SET updated_at = NOW(), is_primary = TRUE
         WHERE id = $1`,
        [existing.rows[0].id]
      );
    } else {
      await pool.query(
        `INSERT INTO vendor_tax_ids (vendor_id, type, value, country, is_primary)
         VALUES ($1, $2, $3, NULL, TRUE)`,
        [vendorId, entry.type, entry.value]
      );
    }
  }

  await pool.query(
    `UPDATE vendor_tax_ids
     SET is_primary = (id = (
       SELECT id FROM vendor_tax_ids
       WHERE vendor_id = $1
       ORDER BY is_primary DESC, updated_at DESC
       LIMIT 1
     ))
     WHERE vendor_id = $1`,
    [vendorId]
  );
}

async function findVendorWithDetails({ userId, factuurdetails }) {
  if (!userId || !factuurdetails) return null;
  await ensureVendorsTables();

  const { displayName, kvkNumber, vatNumber } = extractContactDetails(factuurdetails);
  const trimmedName = displayName ? displayName.trim() : null;
  const vendorKey = buildVendorKey({ vatNumber, kvkNumber, trimmedName });

  let result = { rowCount: 0 };
  if (vendorKey) {
    result = await pool.query(
      `SELECT * FROM vendors
       WHERE user_id = $1 AND vendor_key = $2
       ORDER BY id
       LIMIT 1`,
      [userId, vendorKey]
    );
  } else if (trimmedName) {
    result = await pool.query(
      `SELECT * FROM vendors
       WHERE user_id = $1 AND vendor_key IS NULL AND display_name = $2
       ORDER BY id
       LIMIT 1`,
      [userId, trimmedName]
    );
  }

  if (result.rowCount === 0) return null;

  const vendor = result.rows[0];

  const [locationsRes, taxRes, statsRes] = await Promise.all([
    pool.query(`SELECT * FROM vendor_locations WHERE vendor_id = $1 ORDER BY is_primary DESC, updated_at DESC`, [vendor.id]),
    pool.query(`SELECT * FROM vendor_tax_ids WHERE vendor_id = $1 ORDER BY is_primary DESC, updated_at DESC`, [vendor.id]),
    pool.query(`SELECT * FROM vendor_payment_stats WHERE vendor_id = $1`, [vendor.id]),
  ]);

  return {
    vendor,
    locations: locationsRes.rows,
    taxIds: taxRes.rows,
    stats: statsRes.rows[0] || null,
  };
}

export {
  ensureVendorsTables,
  upsertVendorFromInvoice,
  CREDIT_STATES,
  findVendorWithDetails,
};
