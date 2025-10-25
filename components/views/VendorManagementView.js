import styles from "./VendorManagementView.module.css";

const VENDORS = [
  {
    id: "acme",
    name: "Acme Supplies BV",
    vat: "VAT NL123456789B01",
    coc: "CoC 81234567",
    status: "Active",
  },
  {
    id: "northshore",
    name: "Northshore Logistics LLC",
    vat: "VAT US86-451243",
    coc: "CoC 09871234",
    status: "Review",
  },
  {
    id: "hikari",
    name: "Hikari Foods Co.",
    vat: "VAT JP123 44 958B",
    coc: "CoC 55897788",
    status: "Dormant",
  },
];

const TASKS = [
  {
    id: "conflicts",
    label: "Resolve Conflicts",
    description: "2 fields differ across sources for Acme Supplies BV",
    action: "Start",
    tone: "primary",
  },
  {
    id: "credit",
    label: "Run Credit Check",
    description: "Latest check older than 14 days",
    action: "Run",
    tone: "ghost",
  },
  {
    id: "ranking",
    label: "Confirm Ranking",
    description: "Pending confirmation for INV-8897",
    action: "Review",
    tone: "ghost",
  },
];

const ACTION_HISTORY = [
  { id: 1, label: "Booking confirmed", by: "Alex", at: "Apr 12, 09:21", tone: "positive" },
  { id: 2, label: "CoC sync completed", by: "System", at: "Apr 11, 17:26", tone: "neutral" },
  { id: 3, label: "Credit check: Low risk", by: "Creditsafe", at: "Apr 10, 14:22", tone: "positive" },
];

const RECENT_INVOICES = [
  { id: "INV-8891", vendor: "Acme Supplies BV", date: "Mar 22" },
  { id: "INV-8897", vendor: "Acme Supplies BV", date: "Apr 02" },
];

export default function VendorManagementView() {
  return (
    <div className={styles.page}>
      <div className={styles.topRow}>
        <section className={styles.card}>
          <header className={styles.cardHeader}>
            <div>
              <h2>Vendors</h2>
              <p className={styles.muted}>Search vendors, VAT, CoC</p>
            </div>
            <button type="button" className={styles.smallButton}>
              View all
            </button>
          </header>
          <div className={styles.searchRow}>
            <input type="search" placeholder="Search vendors" />
            <select>
              <option>Status: All</option>
              <option>Active</option>
              <option>Review</option>
              <option>Dormant</option>
            </select>
          </div>
          <ul className={styles.vendorList}>
            {VENDORS.map((vendor) => (
              <li key={vendor.id}>
                <div>
                  <strong>{vendor.name}</strong>
                  <span>{vendor.vat}</span>
                  <span>{vendor.coc}</span>
                </div>
                <span className={styles.vendorBadge}>{vendor.status}</span>
              </li>
            ))}
          </ul>
        </section>

        <section className={styles.card}>
          <header className={styles.cardHeader}>
            <div>
              <h2>Task Queue</h2>
              <p className={styles.muted}>5 open</p>
            </div>
          </header>
          <ul className={styles.taskList}>
            {TASKS.map((task) => (
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
              <h2>Spend With Vendor • Results</h2>
              <p className={styles.muted}>Last 12 months</p>
            </div>
          </header>
          <dl className={styles.metricGrid}>
            <div>
              <dt>Total Spend</dt>
              <dd>€18,420</dd>
            </div>
            <div>
              <dt>Avg Monthly</dt>
              <dd>€1,535</dd>
            </div>
            <div>
              <dt>Open Balance</dt>
              <dd>€4,120</dd>
            </div>
            <div>
              <dt>Upcoming Due</dt>
              <dd>€620</dd>
            </div>
          </dl>
        </section>
      </div>

      <div className={styles.mainGrid}>
        <div className={styles.leftColumn}>
          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Vendor Profile</h3>
              <div className={styles.headerActions}>
                <button type="button" className={styles.ghostButton}>
                  Deactivate
                </button>
                <button type="button" className={styles.primaryButton}>
                  Save Vendor
                </button>
              </div>
            </header>
            <dl className={styles.detailList}>
              <div>
                <dt>Vendor Name</dt>
                <dd>Acme Supplies BV</dd>
              </div>
              <div>
                <dt>VAT / Tax ID</dt>
                <dd>NL123456789B01</dd>
              </div>
              <div>
                <dt>Chamber of Commerce</dt>
                <dd>81234567</dd>
              </div>
              <div>
                <dt>Primary Email</dt>
                <dd>billing@acme-supplies.com</dd>
              </div>
              <div>
                <dt>Phone</dt>
                <dd>+31 20 123 4567</dd>
              </div>
              <div>
                <dt>Website</dt>
                <dd>acme-supplies.com</dd>
              </div>
              <div>
                <dt>Address</dt>
                <dd>Keizersgracht 120, 1015 CX Amsterdam, NL</dd>
              </div>
              <div className={styles.twoColRow}>
                <div>
                  <dt>Default Expense Account</dt>
                  <dd>Office Supplies</dd>
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
              <h3>Resolve Differences</h3>
              <div className={styles.headerActions}>
                <button type="button" className={styles.ghostButton}>Re-check</button>
                <button type="button" className={styles.ghostButton}>Update from CoC</button>
              </div>
            </header>
            <div className={styles.diffGrid}>
              <div>
                <span className={styles.diffLabel}>Legal Name</span>
                <div className={styles.diffValue}>
                  <strong>Acme Supplies BV</strong>
                  <small>Invoice / CoC (extract)</small>
                </div>
                <div className={styles.diffValue}>
                  <strong>ACME SUPPLIES B.V.</strong>
                  <small>Vendor DB</small>
                </div>
              </div>
              <div>
                <span className={styles.diffLabel}>Email</span>
                <div className={styles.diffValue}>
                  <strong>billing@acme-supplies.com</strong>
                  <small>From invoice</small>
                </div>
                <div className={styles.diffValue}>
                  <strong>finance@acme-supplies.com</strong>
                  <small>Vendor DB</small>
                </div>
              </div>
            </div>
            <div className={styles.footerActions}>
              <button type="button" className={styles.ghostButton}>Discard Changes</button>
              <button type="button" className={styles.primaryButton}>Apply Selected Updates</button>
            </div>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Recent Invoices</h3>
            </header>
            <table className={styles.simpleTable}>
              <thead>
                <tr>
                  <th>Vendor</th>
                  <th>Invoice #</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                {RECENT_INVOICES.map((invoice) => (
                  <tr key={invoice.id}>
                    <td>{invoice.vendor}</td>
                    <td>{invoice.id}</td>
                    <td>{invoice.date}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>
        </div>

        <div className={styles.centerColumn}>
          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Insights &amp; Spend</h3>
              <div className={styles.headerActions}>
                <button type="button" className={styles.ghostButton}>Period</button>
                <button type="button" className={styles.ghostButton}>Filters</button>
              </div>
            </header>
            <div className={styles.tagGrid}>
              <button type="button" className={styles.tagButton}>Spend With Vendor</button>
              <button type="button" className={styles.tagButton}>Purchase History</button>
              <button type="button" className={styles.tagButton}>Category Breakdown</button>
              <button type="button" className={styles.tagButton}>Line Items Sample</button>
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
                <label>Category</label>
                <select>
                  <option>All</option>
                  <option>Office Supplies</option>
                  <option>Maintenance</option>
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
              <h3>Confirm Booking</h3>
              <div className={styles.headerActions}>
                <button type="button" className={styles.ghostButton}>Previous</button>
                <button type="button" className={styles.ghostButton}>Next</button>
              </div>
            </header>
            <table className={styles.simpleTable}>
              <thead>
                <tr>
                  <th>Line Item</th>
                  <th>Suggested Account</th>
                  <th>Amount</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Printer paper (10x)</td>
                  <td>Office Supplies</td>
                  <td>€120.00</td>
                </tr>
                <tr>
                  <td>Ink cartridges</td>
                  <td>Office Supplies</td>
                  <td>€84.00</td>
                </tr>
              </tbody>
            </table>
            <div className={styles.footerActions}>
              <button type="button" className={styles.ghostButton}>Override Account</button>
              <button type="button" className={styles.primaryButton}>Confirm Booking</button>
            </div>
          </section>
        </div>

        <div className={styles.rightColumn}>
          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Category Breakdown • Results</h3>
            </header>
            <ul className={styles.tagList}>
              <li>
                <span className={styles.tagDot} /> Office Supplies
              </li>
              <li>
                <span className={styles.tagDot} /> Equipment
              </li>
              <li>
                <span className={styles.tagDot} /> Maintenance
              </li>
            </ul>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Data Comparison</h3>
            </header>
            <div className={styles.comparisonGrid}>
              <div>
                <span className={styles.diffLabel}>From Invoices (Extracted)</span>
                <p>ACME SUPPLIES B.V.<br />Keizersgracht 120, 1015 CX Amsterdam</p>
              </div>
              <div>
                <span className={styles.diffLabel}>Vendor Database</span>
                <p>Acme Supplies BV<br />Keizersgracht 120, 1015 CX Amsterdam</p>
              </div>
            </div>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Document Preview</h3>
            </header>
            <div className={styles.previewBox}>Invoice preview placeholder</div>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Credit Status</h3>
            </header>
            <dl className={styles.detailList}>
              <div>
                <dt>Overall Risk</dt>
                <dd>Low</dd>
              </div>
              <div>
                <dt>Credit Score</dt>
                <dd>782 / 900</dd>
              </div>
              <div>
                <dt>Provider</dt>
                <dd>Creditsafe EU</dd>
              </div>
              <div>
                <dt>Recommended Limit</dt>
                <dd>€25,000</dd>
              </div>
            </dl>
          </section>

          <section className={styles.card}>
            <header className={styles.cardHeader}>
              <h3>Activity Timeline</h3>
            </header>
            <ul className={styles.timeline}>
              {ACTION_HISTORY.map((event) => (
                <li key={event.id} className={styles[`timeline-${event.tone}`] || ""}>
                  <strong>{event.label}</strong>
                  <span>{event.at} — {event.by}</span>
                </li>
              ))}
            </ul>
          </section>
        </div>
      </div>
    </div>
  );
}
