import styles from "./InvoiceBuilderView.module.css";

const QUICK_ACTIONS = [
  { id: "aiLineItems", label: "AI Suggest Line Items" },
  { id: "importQuote", label: "Import From Quote" },
  { id: "duplicateInvoice", label: "Duplicate Last Invoice" },
];

const LINE_ITEMS = [
  {
    id: "brand",
    description: "Brand Design Package",
    quantity: 1,
    unitPrice: "€4,500.00",
    tax: "21% VAT",
    total: "€4,500.00",
  },
  {
    id: "retainer",
    description: "Monthly Retainer",
    quantity: 2,
    unitPrice: "€1,200.00",
    tax: "0% (Reverse)",
    total: "€2,400.00",
  },
];

const RECENT_INVOICES = [
  { id: "INV-1204", customer: "Harbor Retail GmbH", total: "€2,980.00" },
  { id: "INV-1199", customer: "Nimbus Cloud Co.", total: "€1,240.00" },
];

const VALIDATION = [
  { id: 1, label: "Required fields complete", status: "complete" },
  { id: 2, label: "Reverse charge applied", status: "warning" },
];

export default function InvoiceBuilderView() {
  return (
    <div className={styles.page}>
      <header className={styles.headerBar}>
        <div className={styles.headerTitleGroup}>
          <h1>Invoice Builder</h1>
          <select defaultValue="brightwave">
            <option value="brightwave">Company: Brightwave Studios</option>
            <option value="acme">Company: Acme Supplies BV</option>
          </select>
        </div>
        <div className={styles.headerActions}>
          <button type="button" className={styles.ghostButton}>Drafts</button>
          <button type="button" className={styles.ghostButton}>Templates</button>
          <button type="button" className={styles.avatarButton}>AP</button>
        </div>
      </header>

      <div className={styles.layout}>
        <div className={styles.leftColumn}>
          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Quick Actions</h2>
              <button type="button" className={styles.smallButton}>Open</button>
            </header>
            <ul className={styles.quickList}>
              {QUICK_ACTIONS.map((action) => (
                <li key={action.id}>
                  <button type="button">{action.label}</button>
                </li>
              ))}
            </ul>
          </section>

          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Recent Invoices</h2>
              <button type="button" className={styles.smallButton}>View all</button>
            </header>
            <table className={styles.simpleTable}>
              <thead>
                <tr>
                  <th>Customer</th>
                  <th>Number</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                {RECENT_INVOICES.map((row) => (
                  <tr key={row.id}>
                    <td>{row.customer}</td>
                    <td>{row.id}</td>
                    <td>{row.total}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>
        </div>

        <div className={styles.centerColumn}>
          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Invoice Details</h2>
              <div className={styles.segmented}>
                <button type="button" className={styles.segmentedActive}>Invoice Details</button>
                <button type="button">Issue &amp; Due Dates</button>
              </div>
              <button type="button" className={styles.primaryButton}>Save Draft</button>
            </header>
            <div className={styles.detailGrid}>
              <label>
                <span>Customer</span>
                <select>
                  <option>Select customer</option>
                </select>
              </label>
              <label>
                <span>Invoice Number</span>
                <input type="text" value="Auto" readOnly />
              </label>
              <label>
                <span>Currency</span>
                <select defaultValue="EUR">
                  <option value="EUR">EUR (€)</option>
                  <option value="USD">USD ($)</option>
                </select>
              </label>
              <label>
                <span>Issue Date</span>
                <input type="date" defaultValue="2025-04-12" />
              </label>
              <label>
                <span>Due Date</span>
                <select>
                  <option>Net 30</option>
                  <option>Net 15</option>
                  <option>Net 45</option>
                </select>
              </label>
              <label>
                <span>Reference / PO</span>
                <input type="text" placeholder="Optional" />
              </label>
            </div>
          </section>

          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Line Items</h2>
              <div className={styles.headerActions}>
                <button type="button" className={styles.ghostButton}>Split by Account</button>
                <button type="button" className={styles.primaryButton}>+ Add Row</button>
              </div>
            </header>
            <table className={styles.lineItemTable}>
              <thead>
                <tr>
                  <th>Description</th>
                  <th>Qty</th>
                  <th>Unit Price</th>
                  <th>Tax</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                {LINE_ITEMS.map((item) => (
                  <tr key={item.id}>
                    <td>{item.description}</td>
                    <td>{item.quantity}</td>
                    <td>{item.unitPrice}</td>
                    <td>{item.tax}</td>
                    <td>{item.total}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <div className={styles.lineItemMeta}>
              <span>Default Tax Rule: Standard (21%)</span>
              <span>Discount: None</span>
              <span>Shipping: 0.00</span>
            </div>
          </section>

          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Templates &amp; Branding</h2>
              <button type="button" className={styles.ghostButton}>Manage Templates</button>
            </header>
            <div className={styles.detailGrid}>
              <label>
                <span>Template</span>
                <select>
                  <option>Modern Compact</option>
                  <option>Classic</option>
                </select>
              </label>
              <label>
                <span>Accent Color</span>
                <input type="text" value="Company Default" readOnly />
              </label>
              <label>
                <span>Logo</span>
                <input type="text" value="Use company logo" readOnly />
              </label>
            </div>
          </section>

          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Taxes &amp; Compliance</h2>
              <button type="button" className={styles.ghostButton}>Tax Rules</button>
            </header>
            <div className={styles.detailGrid}>
              <label>
                <span>Customer Tax Status</span>
                <select>
                  <option>B2B EU (VAT)</option>
                  <option>B2C</option>
                </select>
              </label>
              <label>
                <span>Reverse Charge</span>
                <select>
                  <option>Auto-detect</option>
                  <option>Always apply</option>
                </select>
              </label>
              <label>
                <span>Invoice Language</span>
                <select>
                  <option>English</option>
                  <option>Dutch</option>
                </select>
              </label>
            </div>
          </section>

          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Payments &amp; Terms</h2>
              <button type="button" className={styles.ghostButton}>Policies</button>
            </header>
            <div className={styles.detailGrid}>
              <label>
                <span>Payment Terms</span>
                <select>
                  <option>Net 30</option>
                  <option>Net 15</option>
                </select>
              </label>
              <label>
                <span>Payment Providers</span>
                <select>
                  <option>Stripe, SEPA</option>
                  <option>Wire Transfer</option>
                </select>
              </label>
              <label>
                <span>Early Payment Discount</span>
                <select>
                  <option>2% if &lt; 10 days</option>
                  <option>None</option>
                </select>
              </label>
              <label>
                <span>Late Fees</span>
                <select>
                  <option>1% / mo</option>
                  <option>None</option>
                </select>
              </label>
              <label>
                <span>Partial Payments</span>
                <select>
                  <option>Allowed</option>
                  <option>Not allowed</option>
                </select>
              </label>
              <label>
                <span>Deposit</span>
                <select>
                  <option>None</option>
                  <option>10%</option>
                </select>
              </label>
            </div>
          </section>

          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Approvals &amp; Sending</h2>
              <div className={styles.headerActions}>
                <button type="button" className={styles.ghostButton}>Preview Email</button>
                <button type="button" className={styles.primaryButton}>Generate PDF</button>
              </div>
            </header>
            <div className={styles.tagGrid}>
              <button type="button" className={styles.tagButton}>Approval Flow</button>
              <button type="button" className={styles.tagButton}>Send Options</button>
              <button type="button" className={styles.tagButton}>Confirmation</button>
            </div>
            <div className={styles.footerActions}>
              <button type="button" className={styles.ghostButton}>Discard</button>
              <button type="button" className={styles.primaryButton}>Send Invoice</button>
            </div>
          </section>
        </div>

        <div className={styles.rightColumn}>
          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Invoice Preview</h2>
              <select defaultValue="modern">
                <option value="modern">Modern • EUR</option>
                <option value="classic">Classic • EUR</option>
              </select>
            </header>
            <div className={styles.previewBox}>
              <p>
                From<br />Brightwave Studios<br />Invoice INV-1205<br />Apr 12, 2025<br />To<br />Select customer
              </p>
            </div>
            <dl className={styles.previewTotals}>
              <div>
                <dt>Subtotal</dt>
                <dd>€6,900.00</dd>
              </div>
              <div>
                <dt>Tax</dt>
                <dd>€945.00</dd>
              </div>
              <div>
                <dt>Total Due</dt>
                <dd>€7,845.00</dd>
              </div>
            </dl>
          </section>

          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Validation</h2>
            </header>
            <ul className={styles.validationList}>
              {VALIDATION.map((item) => (
                <li key={item.id} className={styles[`validation-${item.status}`] || ""}>
                  <span>{item.label}</span>
                </li>
              ))}
            </ul>
          </section>

          <section className={styles.panel}>
            <header className={styles.panelHeader}>
              <h2>Email Preview</h2>
              <span className={styles.muted}>To be sent</span>
            </header>
            <div className={styles.emailPreview}>
              <label>
                <span>Subject</span>
                <input type="text" defaultValue="Invoice INV-1205 from Brightwave Studios" />
              </label>
              <label>
                <span>Message</span>
                <textarea rows={6} defaultValue="Hi, please find your invoice attached. Pay online via Stripe or SEPA." />
              </label>
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}
