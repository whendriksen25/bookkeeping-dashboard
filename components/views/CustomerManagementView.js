import styles from "./CustomerManagementView.module.css";

const CUSTOMERS = [
  {
    id: "brightwave",
    name: "Brightwave Studios",
    vat: "VAT NL223456789B02",
    coc: "CoC 89234567",
    status: "Active",
  },
  {
    id: "harbor",
    name: "Harbor Retail GmbH",
    vat: "VAT DE256789432",
    coc: "HRB 778899",
    status: "Credit review",
  },
  {
    id: "nimbus",
    name: "Nimbus Cloud Co.",
    vat: "VAT US12-3456789",
    coc: "CoC 00441122",
    status: "Attention",
  },
];

const CUSTOMER_TASKS = [
  {
    id: "credit",
    label: "Resolve Credit Alerts",
    description: "Harbor Retail shows increased risk",
    action: "Start",
    tone: "primary",
  },
  {
    id: "overdue",
    label: "Chase Overdues",
    description: "2 invoices overdue > 15 days",
    action: "Review",
    tone: "ghost",
  },
  {
    id: "details",
    label: "Confirm Customer Details",
    description: "Email change pending for Nimbus Cloud Co.",
    action: "Approve",
    tone: "ghost",
  },
];

const RECENT_SALES = [
  { id: "INV-1204", customer: "Brightwave Studios", date: "Apr 12" },
  { id: "INV-1199", customer: "Harbor Retail GmbH", date: "Apr 08" },
];

const COLLECTION_ACTIONS = [
  { id: 1, label: "Last Reminder", value: "Apr 10, 2025" },
  { id: 2, label: "Promise to Pay", value: "None" },
];

const CUSTOMER_TIMELINE = [
  { id: 1, label: "Payment received INV-1191", actor: "Sara", at: "Apr 11, 12:10", tone: "positive" },
  { id: 2, label: "Reminder sent INV-1188", actor: "System", at: "Apr 09, 09:32", tone: "neutral" },
  { id: 3, label: "Profile updated", actor: "Alex", at: "Apr 08, 16:04", tone: "neutral" },
];

const UNPAID_INVOICES = [
  { id: "INV-1188", date: "Mar 25", amount: "€3,450" },
  { id: "INV-1191", date: "Apr 02", amount: "€1,220" },
];

const PURCHASED_ITEMS = [
  "Brand Design Package",
  "Monthly Retainer",
  "Print Collateral",
];

export default function CustomerManagementView() {
  return (
    <div className={styles.page}>
      <div className={styles.topRow}>
        <section className={styles.card}>
          <header className={styles.cardHeader}>
            <div>
              <h2>Customers</h2>
              <p className={styles.muted}>Search customers, VAT, CoC</p>
            </div>
            <button type="button" className={styles.smallButton}>View all</button>
          </header>
          <div className={styles.searchRow}>
            <input type="search" placeholder="Search customers" />
            <select>
              <option>Status: All</option>
              <option>Active</option>
              <option>Attention</option>
              <option>Dormant</option>
            </select>
          </div>
          <ul className={styles.entityList}>
            {CUSTOMERS.map((customer) => (
              <li key={customer.id}>
                <div>
                  <strong>{customer.name}</strong>
                  <span>{customer.vat}</span>
                  <span>{customer.coc}</span>
                </div>
                <span className={styles.entityBadge}>{customer.status}</span>
              </li>
            ))}
          </ul>
        </section>

        <section className={styles.card}>
          <header className={styles.cardHeader}>
            <div>
              <h2>Task Queue</h2>
              <p className={styles.muted}>3 open</p>
            </div>
          </header>
          <ul className={styles.entityList}>
            {CUSTOMER_TASKS.map((task) => (
              <li key={task.id}>
                <div>
                  <strong>{task.label}</strong>
                  <span>{task.description}</span>
                </div>
                <button type="button" className={task.tone === "primary" ? styles.primaryButton : styles.ghostButton}>
                  {task.action}
                </button>
              </li>
            ))}
          </ul>
        </section>

        <section className={styles.card}>
          <header className={styles.cardHeader}>
            <div>
              <h2>Revenue per Month • Results</h2>
              <p className={styles.muted}>Last 12 months</p>
            </div>
          </header>
          <dl className={styles.metricGrid}>
            <div>
              <dt>Total Revenue</dt>
              <dd>€142,300</dd>
            </div>
            <div>
              <dt>Avg Monthly</dt>
              <dd>€11,860</dd>
            </div>
            <div>
              <dt>Open Balance</dt>
              <dd>€8,120</dd>
            </div>
            <div>
              <dt>Upcoming Due</dt>
              <dd>€1,540</dd>
            </div>
          </dl>
        </section>
      </div>

      <div className={styles.mainGrid}>
        <div className={styles.leftColumn}>
          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Customer Profile</h3>
              <div className={styles.headerActions}>
                <button type="button" className={styles.ghostButton}>Deactivate</button>
                <button type="button" className={styles.primaryButton}>Save Customer</button>
              </div>
            </header>
            <dl className={styles.detailList}>
              <div>
                <dt>Customer Name</dt>
                <dd>Brightwave Studios</dd>
              </div>
              <div>
                <dt>VAT / Tax ID</dt>
                <dd>NL223456789B02</dd>
              </div>
              <div>
                <dt>Chamber of Commerce</dt>
                <dd>89234567</dd>
              </div>
              <div>
                <dt>Primary Email</dt>
                <dd>ap@brightwave.studio</dd>
              </div>
              <div>
                <dt>Phone</dt>
                <dd>+31 20 555 1122</dd>
              </div>
              <div>
                <dt>Website</dt>
                <dd>brightwave.studio</dd>
              </div>
              <div>
                <dt>Billing Address</dt>
                <dd>Herengracht 220, 1016 BT Amsterdam, NL</dd>
              </div>
              <div className={styles.twoColRow}>
                <div>
                  <dt>Default Revenue Account</dt>
                  <dd>Services Revenue</dd>
                </div>
                <div>
                  <dt>Payment Terms</dt>
                  <dd>Net 30</dd>
                </div>
              </div>
            </dl>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Customer Insights</h3>
              <div className={styles.headerActions}>
                <button type="button" className={styles.ghostButton}>Period</button>
                <button type="button" className={styles.ghostButton}>Filters</button>
              </div>
            </header>
            <div className={styles.tagGrid}>
              <button type="button" className={styles.tagButton}>Revenue per Month</button>
              <button type="button" className={styles.tagButton}>Payment Behaviour</button>
              <button type="button" className={styles.tagButton}>Credit Check</button>
              <button type="button" className={styles.tagButton}>Unpaid Invoices</button>
              <button type="button" className={styles.tagButton}>Purchased Items</button>
            </div>
            <div className={styles.filterRow}>
              <div>
                <label>Range</label>
                <select>
                  <option>Last 12 months</option>
                  <option>Last 6 months</option>
                </select>
              </div>
              <div>
                <label>Group by</label>
                <select>
                  <option>Month</option>
                  <option>Quarter</option>
                </select>
              </div>
            </div>
            <div className={styles.filterRow}>
              <div>
                <label>Invoice Status</label>
                <select>
                  <option>All</option>
                  <option>Open</option>
                  <option>Paid</option>
                </select>
              </div>
              <div>
                <label>Min amount</label>
                <input type="number" placeholder="Any" />
              </div>
            </div>
            <div className={styles.footerActions}>
              <button type="button" className={styles.ghostButton}>Reset</button>
              <button type="button" className={styles.primaryButton}>Apply</button>
            </div>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Collections &amp; Actions</h3>
              <div className={styles.headerActions}>
                <button type="button" className={styles.ghostButton}>Send Reminder</button>
                <button type="button" className={styles.ghostButton}>Create Plan</button>
              </div>
            </header>
            <ul className={styles.detailList}>
              {COLLECTION_ACTIONS.map((item) => (
                <li key={item.id} className={styles.listRow}>
                  <span>{item.label}</span>
                  <strong>{item.value}</strong>
                </li>
              ))}
            </ul>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Recent Sales</h3>
            </header>
            <table className={styles.simpleTable}>
              <thead>
                <tr>
                  <th>Customer</th>
                  <th>Invoice #</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                {RECENT_SALES.map((sale) => (
                  <tr key={sale.id}>
                    <td>{sale.customer}</td>
                    <td>{sale.id}</td>
                    <td>{sale.date}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>
        </div>

        <div className={styles.centerColumn}>
          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Collections &amp; Risk</h3>
            </header>
            <div className={styles.metricGrid}>
              <div>
                <dt>Days Beyond Terms</dt>
                <dd>3.4 days</dd>
              </div>
              <div>
                <dt>On-time Payments</dt>
                <dd>91%</dd>
              </div>
              <div>
                <dt>DSO</dt>
                <dd>34 days</dd>
              </div>
              <div>
                <dt>Remark</dt>
                <dd>Stable trend</dd>
              </div>
            </div>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Credit Check • Results</h3>
            </header>
            <dl className={styles.detailList}>
              <div>
                <dt>Overall Risk</dt>
                <dd>Low</dd>
              </div>
              <div>
                <dt>Last Checked</dt>
                <dd>Apr 09, 2025 • 10:04</dd>
              </div>
              <div>
                <dt>Credit Score</dt>
                <dd>795 / 900</dd>
              </div>
              <div>
                <dt>Recommended Limit</dt>
                <dd>€60,000</dd>
              </div>
            </dl>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Unpaid Invoices • Results</h3>
            </header>
            <ul className={styles.listGrid}>
              {UNPAID_INVOICES.map((invoice) => (
                <li key={invoice.id}>
                  <strong>{invoice.id}</strong>
                  <span>{invoice.date}</span>
                  <span>{invoice.amount}</span>
                </li>
              ))}
            </ul>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Purchased Items • Results</h3>
            </header>
            <ul className={styles.tagList}>
              {PURCHASED_ITEMS.map((item) => (
                <li key={item}>
                  <span className={styles.tagDot} /> {item}
                </li>
              ))}
            </ul>
          </section>
        </div>

        <div className={styles.rightColumn}>
          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Document Preview</h3>
            </header>
            <div className={styles.previewBox}>Invoice preview placeholder</div>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Activity Timeline</h3>
            </header>
            <ul className={styles.timeline}>
              {CUSTOMER_TIMELINE.map((event) => (
                <li key={event.id} className={styles[`timeline-${event.tone}`] || ""}>
                  <strong>{event.label}</strong>
                  <span>{event.at} — {event.actor}</span>
                </li>
              ))}
            </ul>
          </section>
        </div>
      </div>
    </div>
  );
}
