import pool from "./db.js";
import { ensureInvoiceTables } from "./invoices.js";

const ACCOUNT_OVERRIDES = {
  "100000": { type: "balance", category: "assets", normal: "debit" },
  "101000": { type: "balance", category: "assets", normal: "debit" },
  "110000": { type: "balance", category: "assets", normal: "debit" },
  "130000": { type: "balance", category: "assets", normal: "debit" },
  "140000": { type: "balance", category: "assets", normal: "debit" },
  "160000": { type: "balance", category: "liabilities", normal: "credit" },
};

function extractDigits(account) {
  if (!account) return "";
  const digits = String(account).replace(/[^0-9]/g, "");
  return digits;
}

function classifyAccount(accountCode) {
  if (!accountCode) return null;
  const override = ACCOUNT_OVERRIDES[accountCode];
  if (override) return override;

  const digits = extractDigits(accountCode);
  if (!digits) return null;
  const first = digits.charAt(0);
  const firstTwo = Number(digits.slice(0, 2));

  switch (first) {
    case "0":
      return { type: "balance", category: "assets", normal: "debit" };
    case "1": {
      if (!Number.isNaN(firstTwo) && firstTwo >= 15) {
        return { type: "balance", category: "liabilities", normal: "credit" };
      }
      return { type: "balance", category: "assets", normal: "debit" };
    }
    case "2":
      return { type: "balance", category: "liabilities", normal: "credit" };
    case "3":
      return { type: "balance", category: "equity", normal: "credit" };
    case "4":
      return { type: "pl", category: "revenue", normal: "credit" };
    case "5":
      return { type: "pl", category: "cogs", normal: "debit" };
    case "6":
    case "7":
      return { type: "pl", category: "expenses", normal: "debit" };
    case "8":
      return { type: "pl", category: "otherIncome", normal: "credit" };
    case "9":
      return { type: "pl", category: "otherExpense", normal: "debit" };
    default:
      return null;
  }
}

function createEmptyAggregate() {
  return {
    profitLoss: {
      revenue: 0,
      cogs: 0,
      expenses: 0,
      otherIncome: 0,
      otherExpense: 0,
      net: 0,
    },
    balanceSheet: {
      assets: 0,
      liabilities: 0,
      equity: 0,
      net: 0,
    },
    accounts: {},
    postings: 0,
  };
}

function applyAccountAggregate(target, accountCode, amount, classification) {
  if (amount === 0 || !classification) return;
  const { type, category, normal } = classification;

  if (!target.accounts[accountCode]) {
    target.accounts[accountCode] = { debit: 0, credit: 0, net: 0, category: classification };
  }
  const accountBucket = target.accounts[accountCode];
  if (amount >= 0) {
    accountBucket.debit += amount;
  } else {
    accountBucket.credit += -amount;
  }
  accountBucket.net += amount;

  if (type === "pl") {
    if (category === "revenue") {
      target.profitLoss.revenue += normal === "credit" ? -amount : amount;
    } else if (category === "cogs") {
      target.profitLoss.cogs += normal === "credit" ? -amount : amount;
    } else if (category === "expenses") {
      target.profitLoss.expenses += normal === "credit" ? -amount : amount;
    } else if (category === "otherIncome") {
      target.profitLoss.otherIncome += normal === "credit" ? -amount : amount;
    } else if (category === "otherExpense") {
      target.profitLoss.otherExpense += normal === "credit" ? -amount : amount;
    }
  } else if (type === "balance") {
    if (category === "assets") {
      target.balanceSheet.assets += amount;
    } else if (category === "liabilities") {
      target.balanceSheet.liabilities += amount;
    } else if (category === "equity") {
      target.balanceSheet.equity += amount;
    }
  }
}

function finalizeAggregate(aggregate) {
  const pl = aggregate.profitLoss;
  pl.net = (pl.revenue + pl.otherIncome) - (pl.cogs + pl.expenses + pl.otherExpense);
  const bs = aggregate.balanceSheet;
  bs.net = bs.assets - (bs.liabilities + bs.equity);
}

function registerPosting(store, key, accountCode, amount, classification) {
  if (!accountCode || !Number.isFinite(amount) || amount === 0) return;
  const target = store.get(key) || createEmptyAggregate();
  applyAccountAggregate(target, accountCode, amount, classification);
  target.postings += 1;
  store.set(key, target);
}

async function getFinancialSummary({ userId, startDate = null, endDate = null, includeProfiles = true }) {
  if (!userId) {
    return { overall: createEmptyAggregate(), profiles: [] };
  }

  await ensureInvoiceTables();

  const conditions = ["(user_id = $1)"];
  const values = [userId];

  if (startDate) {
    conditions.push("created_at >= $" + (values.length + 1));
    values.push(new Date(startDate));
  }
  if (endDate) {
    conditions.push("created_at <= $" + (values.length + 1));
    values.push(new Date(endDate));
  }

  const sql = `
    SELECT
      profile_reference,
      account_code,
      counter_account_code,
      debit_account,
      credit_account,
      amount,
      created_at
    FROM bookings
    WHERE ${conditions.join(" AND ")}
  `;

  const { rows } = await pool.query(sql, values);

  const aggregates = new Map();
  const overallKey = "__overall__";

  for (const row of rows) {
    const amount = Number(row.amount);
    if (!Number.isFinite(amount) || amount === 0) continue;

    const profileKey = row.profile_reference || "default";
    const debitAccount = row.debit_account || row.account_code;
    const creditAccount = row.credit_account || row.counter_account_code;

    const debitClassification = classifyAccount(debitAccount);
    const creditClassification = classifyAccount(creditAccount);

    // Register for overall scope
    if (debitAccount) {
      registerPosting(aggregates, overallKey, debitAccount, amount, debitClassification);
    }
    if (creditAccount) {
      registerPosting(aggregates, overallKey, creditAccount, -amount, creditClassification);
    }

    if (includeProfiles && profileKey !== "payment") {
      if (debitAccount) {
        registerPosting(aggregates, profileKey, debitAccount, amount, debitClassification);
      }
      if (creditAccount) {
        registerPosting(aggregates, profileKey, creditAccount, -amount, creditClassification);
      }
    }
  }

  const overall = aggregates.get(overallKey) || createEmptyAggregate();
  finalizeAggregate(overall);

  const profiles = [];
  if (includeProfiles) {
    for (const [key, aggregate] of aggregates.entries()) {
      if (key === overallKey) continue;
      finalizeAggregate(aggregate);
      profiles.push({ profile: key, aggregate });
    }
    profiles.sort((a, b) => a.profile.localeCompare(b.profile));
  }

  return {
    generatedAt: new Date().toISOString(),
    filters: { startDate, endDate },
    overall,
    profiles,
  };
}

export { getFinancialSummary };
