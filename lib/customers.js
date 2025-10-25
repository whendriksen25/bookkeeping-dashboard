import pool from "./db.js";

async function ensureCustomersTables() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS customers (
      id SERIAL PRIMARY KEY,
      user_id UUID REFERENCES users(id) ON DELETE CASCADE,
      customer_key TEXT,
      display_name TEXT,
      legal_name TEXT,
      trade_name TEXT,
      kvk_number TEXT,
      vat_number TEXT,
      tax_id TEXT,
      email TEXT,
      phone TEXT,
      website TEXT,
      billing_iban TEXT,
      billing_bank_name TEXT,
      opening_hours TEXT,
      contacts JSONB,
      default_payment_terms_days INTEGER,
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

  await pool.query(`ALTER TABLE customers ALTER COLUMN user_id SET NOT NULL`);

  await pool.query(`ALTER TABLE customers ADD COLUMN IF NOT EXISTS opening_hours TEXT`);
  await pool.query(`ALTER TABLE customers ADD COLUMN IF NOT EXISTS contacts JSONB`);
  await pool.query(`ALTER TABLE customers ADD COLUMN IF NOT EXISTS source_snapshot JSONB`);

  await pool.query(`
    CREATE INDEX IF NOT EXISTS customers_user_id_idx
    ON customers(user_id);
  `);

  await pool.query(`
    CREATE UNIQUE INDEX IF NOT EXISTS customers_user_key_unique
    ON customers(user_id, COALESCE(customer_key, display_name))
    WHERE user_id IS NOT NULL;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS customer_payment_stats (
      customer_id INTEGER PRIMARY KEY REFERENCES customers(id) ON DELETE CASCADE,
      invoices_total INTEGER NOT NULL DEFAULT 0,
      total_invoiced_amount NUMERIC NOT NULL DEFAULT 0,
      total_paid_amount NUMERIC NOT NULL DEFAULT 0,
      outstanding_amount NUMERIC NOT NULL DEFAULT 0,
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
        WHERE conrelid = 'customers'::regclass
          AND conname = 'customers_default_profile_id_fkey'
      ) THEN
        ALTER TABLE customers
          ADD CONSTRAINT customers_default_profile_id_fkey
          FOREIGN KEY (default_profile_id) REFERENCES profiles(id) ON DELETE SET NULL;
      END IF;
    END
    $$;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS customer_locations (
      id SERIAL PRIMARY KEY,
      customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
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
    CREATE TABLE IF NOT EXISTS customer_tax_ids (
      id SERIAL PRIMARY KEY,
      customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
      type TEXT,
      value TEXT,
      country TEXT,
      is_primary BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);
}

function buildCustomerKey({ vatNumber, kvkNumber, trimmedName }) {
  if (vatNumber) return `vat:${vatNumber.toUpperCase()}`;
  if (kvkNumber) return `kvk:${kvkNumber}`;
  if (trimmedName) return `name:${trimmedName.toLowerCase()}`;
  return null;
}

function extractCustomerDetails(factuurdetails = {}) {
  const entity = factuurdetails.ontvanger || {};
  const address = {
    street: entity.straat || entity.adres_straat || null,
    houseNumber: entity.huisnummer || null,
    postalCode: entity.postcode || null,
    city: entity.plaats || entity.stad || null,
    region: entity.provincie_of_staat || entity.regio || null,
    country: entity.land || null,
    full: entity.adres_volledig || entity.adres || null,
  };

  return {
    displayName: entity.naam || null,
    tradeName: entity.handelsnaam || null,
    kvkNumber: entity.kvk_nummer || null,
    vatNumber: entity.btw_nummer || null,
    taxId: entity.fiscaal_nummer || entity.tax_id || null,
    email: entity.email || null,
    phone: entity.telefoon || entity.telefoonnummer || null,
    website: entity.website || null,
    address,
    iban: entity.iban || entity.bankrekening || entity.bank_account || null,
    bankName: entity.bank_naam || entity.bank_name || null,
    openingHours: entity.openingstijden || entity.opening_hours || null,
    contacts: entity.contacten || entity.contacts || null,
  };
}

async function upsertCustomerFromInvoice({ userId, factuurdetails, invoiceTotalIncl, invoiceCurrency }) {
  if (!userId || !factuurdetails) return null;
  await ensureCustomersTables();

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
  } = extractCustomerDetails(factuurdetails);

  if (!displayName && !vatNumber && !kvkNumber) {
    return null;
  }

  const trimmedName = displayName ? displayName.trim() : null;
  const customerKey = buildCustomerKey({ vatNumber, kvkNumber, trimmedName });

  const existing = await pool.query(
    `SELECT id, display_name FROM customers WHERE user_id = $1 AND (
        ($2 IS NOT NULL AND customer_key = $2)
        OR (customer_key IS NULL AND display_name = $3)
      )
      ORDER BY customer_key IS NULL, id
      LIMIT 1`,
    [userId, customerKey, trimmedName]
  );

  const fields = {
    customer_key: customerKey,
    display_name: trimmedName,
    legal_name: factuurdetails?.ontvanger?.rechtspersoon || null,
    trade_name: tradeName,
    kvk_number: kvkNumber,
    vat_number: vatNumber,
    tax_id: taxId,
    email,
    phone,
    website,
    billing_iban: iban,
    billing_bank_name: bankName,
    opening_hours: openingHours || factuurdetails?.openingstijden || null,
    contacts: contacts || factuurdetails?.contacten || null,
    metadata: {
      address,
    },
    source_snapshot: factuurdetails || null,
  };

  let customerId;

  if (existing.rowCount > 0) {
    customerId = existing.rows[0].id;
    const assignments = Object.keys(fields)
      .filter((key) => fields[key] !== undefined)
      .map((key, idx) => `${key} = $${idx + 4}`);

    await pool.query(
      `UPDATE customers
       SET ${assignments.join(", ")}, updated_at = NOW()
       WHERE id = $1 AND user_id = $2`,
      [customerId, userId, ...Object.values(fields)]
    );
  } else {
    const columnNames = ["user_id"].concat(Object.keys(fields));
    const placeholders = columnNames.map((_, idx) => `$${idx + 1}`);

    const result = await pool.query(
      `INSERT INTO customers (${columnNames.join(", ")})
       VALUES (${placeholders.join(", ")})
       RETURNING id`,
      [userId, ...Object.values(fields)]
    );
    customerId = result.rows[0].id;
  }

  if (!customerId) return null;

  const amount = Number(invoiceTotalIncl || 0) || 0;
  const currency = invoiceCurrency || factuurdetails?.totaal?.valuta || null;
  const paymentTermsDays = factuurdetails?.betalingstermijn_dagen || factuurdetails?.betalingstermijn || null;

  await pool.query(
    `INSERT INTO customer_payment_stats (
        customer_id, invoices_total, total_invoiced_amount, total_paid_amount,
        outstanding_amount, average_days_to_pay, on_time_ratio,
        last_invoice_amount, last_invoice_currency, last_invoice_at,
        credit_state, credit_notes, credit_limit, updated_at
      ) VALUES (
        $1, 1, $2, 0, $2, NULL, NULL, $2, $3, NOW(), 'unknown', NULL, NULL, NOW()
      )
      ON CONFLICT (customer_id) DO UPDATE SET
        invoices_total = customer_payment_stats.invoices_total + 1,
        total_invoiced_amount = customer_payment_stats.total_invoiced_amount + EXCLUDED.total_invoiced_amount,
        outstanding_amount = customer_payment_stats.outstanding_amount + EXCLUDED.outstanding_amount,
        last_invoice_amount = EXCLUDED.last_invoice_amount,
        last_invoice_currency = EXCLUDED.last_invoice_currency,
        last_invoice_at = NOW(),
        updated_at = NOW();`,
    [customerId, amount, currency]
  );

  if (paymentTermsDays != null) {
    await pool.query(
      `UPDATE customers
       SET default_payment_terms_days = COALESCE($3, default_payment_terms_days), updated_at = NOW()
       WHERE id = $1 AND user_id = $2`,
      [customerId, userId, Number(paymentTermsDays) || null]
    );
  }

  await upsertCustomerLocations({ customerId, address, email, phone });
  await upsertCustomerTaxIds({ customerId, vatNumber, kvkNumber, taxId });

  return customerId;
}

async function upsertCustomerLocations({ customerId, address, email, phone }) {
  if (!customerId) return;
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
    `SELECT id FROM customer_locations
     WHERE customer_id = $1 AND (full_address = $2 OR ($2 IS NULL AND is_primary = TRUE))
     ORDER BY is_primary DESC, id
     LIMIT 1`,
    [customerId, normalized.full_address]
  );

  if (existing.rowCount > 0) {
    const locationId = existing.rows[0].id;
    const assignments = Object.keys(normalized)
      .map((key, idx) => `${key} = $${idx + 2}`)
      .join(", ");
    await pool.query(
      `UPDATE customer_locations
       SET ${assignments}, updated_at = NOW(), is_primary = TRUE
       WHERE id = $1`,
      [locationId, ...Object.values(normalized)]
    );
  } else {
    await pool.query(
      `INSERT INTO customer_locations (
        customer_id, street, house_number, postal_code, city, region, country,
        full_address, phone, email, is_primary
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7,
        $8, $9, $10, TRUE
      )`,
      [customerId, ...Object.values(normalized)]
    );
  }
}

async function upsertCustomerTaxIds({ customerId, vatNumber, kvkNumber, taxId }) {
  if (!customerId) return;
  const entries = [];
  if (vatNumber) entries.push({ type: "vat", value: vatNumber });
  if (kvkNumber) entries.push({ type: "kvk", value: kvkNumber });
  if (taxId) entries.push({ type: "tax", value: taxId });
  if (!entries.length) return;

  for (const entry of entries) {
    const existing = await pool.query(
      `SELECT id FROM customer_tax_ids
       WHERE customer_id = $1 AND type = $2 AND value = $3
       LIMIT 1`,
      [customerId, entry.type, entry.value]
    );
    if (existing.rowCount > 0) {
      await pool.query(
        `UPDATE customer_tax_ids
         SET updated_at = NOW(), is_primary = TRUE
         WHERE id = $1`,
        [existing.rows[0].id]
      );
    } else {
      await pool.query(
        `INSERT INTO customer_tax_ids (customer_id, type, value, country, is_primary)
         VALUES ($1, $2, $3, NULL, TRUE)`,
        [customerId, entry.type, entry.value]
      );
    }
  }

  await pool.query(
    `UPDATE customer_tax_ids
     SET is_primary = (id = (
       SELECT id FROM customer_tax_ids
       WHERE customer_id = $1
       ORDER BY is_primary DESC, updated_at DESC
       LIMIT 1
     ))
     WHERE customer_id = $1`,
    [customerId]
  );
}

async function findCustomerWithDetails({ userId, factuurdetails }) {
  if (!userId || !factuurdetails) return null;
  await ensureCustomersTables();

  const { displayName, kvkNumber, vatNumber } = extractCustomerDetails(factuurdetails);
  const trimmedName = displayName ? displayName.trim() : null;
  const customerKey = buildCustomerKey({ vatNumber, kvkNumber, trimmedName });

  const result = await pool.query(
    `SELECT * FROM customers
     WHERE user_id = $1 AND (
        ($2 IS NOT NULL AND customer_key = $2)
        OR (customer_key IS NULL AND display_name = $3)
      )
     ORDER BY customer_key IS NULL, id
     LIMIT 1`,
    [userId, customerKey, trimmedName]
  );

  if (result.rowCount === 0) return null;

  const customer = result.rows[0];

  const [locationsRes, taxRes, statsRes] = await Promise.all([
    pool.query(`SELECT * FROM customer_locations WHERE customer_id = $1 ORDER BY is_primary DESC, updated_at DESC`, [customer.id]),
    pool.query(`SELECT * FROM customer_tax_ids WHERE customer_id = $1 ORDER BY is_primary DESC, updated_at DESC`, [customer.id]),
    pool.query(`SELECT * FROM customer_payment_stats WHERE customer_id = $1`, [customer.id]),
  ]);

  return {
    customer,
    locations: locationsRes.rows,
    taxIds: taxRes.rows,
    stats: statsRes.rows[0] || null,
  };
}

export {
  ensureCustomersTables,
  upsertCustomerFromInvoice,
  findCustomerWithDetails,
};
