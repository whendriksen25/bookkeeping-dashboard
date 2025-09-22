// pages/api/book.js
import pool from "../../lib/db.js";

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const { invoice, bestCandidate, paid } = req.body;

    if (!invoice || !bestCandidate) {
      return res.status(400).json({ error: "Missing invoice data or account candidate" });
    }

    console.log("🧾 Booking invoice:", invoice.factuurnummer);

    // Extract invoice details
    const amountIncl = parseFloat(invoice.totaal?.totaal_incl_btw || invoice.totaal_bedrag || 0);
    if (isNaN(amountIncl) || amountIncl === 0) {
      return res.status(400).json({ error: "Invalid invoice amount" });
    }

    // Lookup accounts
    const expenseAccount = bestCandidate.nummer; // chosen COA account
    const creditorsAccount = "160000"; // Creditors
    const bankAccount = "100000"; // Bank

    const client = await pool.connect();
    try {
      await client.query("BEGIN");

      // 1. Record invoice: Expense ↔ Creditors
      await client.query(
        `INSERT INTO bookings (invoice_number, debit_account, credit_account, amount, description)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          invoice.factuurnummer,
          expenseAccount,
          creditorsAccount,
          amountIncl,
          `Factuur ${invoice.factuurnummer} - ${invoice.afzender?.naam || ""}`,
        ]
      );

      console.log("💾 Booking inserted: Expense ↔ Creditors");

      // 2. If paid, add settlement: Creditors ↔ Bank
      if (paid) {
        await client.query(
          `INSERT INTO bookings (invoice_number, debit_account, credit_account, amount, description)
           VALUES ($1, $2, $3, $4, $5)`,
          [
            invoice.factuurnummer,
            creditorsAccount,
            bankAccount,
            amountIncl,
            `Betaling factuur ${invoice.factuurnummer}`,
          ]
        );
        console.log("💾 Payment booking inserted: Creditors ↔ Bank");
      }

      await client.query("COMMIT");
      res.status(200).json({ success: true, message: "Booking(s) saved" });
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
