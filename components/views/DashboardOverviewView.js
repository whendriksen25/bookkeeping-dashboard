import styles from "./DashboardOverviewView.module.css";

function summarizeInvoices(invoices = []) {
  if (!invoices.length) {
    return {
      revenue: "$0",
      expenses: "$0",
      profit: "$0",
      cash: "$0",
    };
  }
  const total = invoices.reduce((sum, invoice) => sum + (Number(invoice.totalIncl) || 0), 0);
  const paid = invoices.filter((inv) => inv.status === "Paid").reduce((sum, inv) => sum + (Number(inv.totalIncl) || 0), 0);
  const pending = total - paid;
  return {
    revenue: new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(total),
    expenses: new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(pending / 2),
    profit: new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(total - pending / 2),
    cash: new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(paid),
  };
}

export default function DashboardOverviewView({ invoices = [] }) {
  const summary = summarizeInvoices(invoices);

  const SUMMARY = [
    { label: "Revenue (MTD)", value: summary.revenue, delta: "+8.4% vs last month" },
    { label: "Expenses (MTD)", value: summary.expenses, delta: "+2.1% vs last month" },
    { label: "Net Profit (MTD)", value: summary.profit, delta: "+12.7% vs last month" },
    { label: "Cash on Hand", value: summary.cash, delta: "Runway 12.4 months" },
  ];

  const CONNECTIONS = [
    { name: "QuickBooks Online", status: "Connected" },
    { name: "Xero", status: "Connected" },
    { name: "Invoices Inbox", status: "Attention" },
  ];

  const TASKS = [
    "Approve 6 invoices",
    "Review 3 AI suggestions",
    "Reconnect bank feed",
  ];

  return (
    <div className={styles.root}>
      <section className={styles.summaryGrid}>
        {SUMMARY.map((item) => (
          <div key={item.label} className={styles.summaryCard}>
            <h3>{item.label}</h3>
            <div className={styles.summaryValue}>{item.value}</div>
            <div className={styles.summaryDelta}>{item.delta}</div>
          </div>
        ))}
      </section>

      <section className={styles.gridTwo}>
        <div className={styles.card}>
          <h3>Connections</h3>
          <div className={styles.connectionList}>
            {CONNECTIONS.map((connection) => (
              <div key={connection.name} className={styles.connectionItem}>
                <span>{connection.name}</span>
                <span className={connection.status === "Connected" ? styles.badgeSuccess : styles.badgeWarn}>
                  {connection.status}
                </span>
              </div>
            ))}
          </div>
        </div>
        <div className={styles.card}>
          <h3>Tasks & Approvals</h3>
          <div className={styles.tasksList}>
            {TASKS.map((task) => (
              <div key={task} className={styles.connectionItem}>
                {task}
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className={styles.card}>
        <h3>Generate Accountant Report</h3>
        <div className={styles.generateCard}>
          <div className={styles.fieldBox}>Period: Jan 1, 2025 – Mar 31, 2025</div>
          <div className={styles.fieldBox}>Entity: Northshore LLC</div>
          <div className={styles.fieldBox}>Include: P&L, Balance Sheet, AR/AP aging</div>
        </div>
        <button type="button" className={styles.primaryButton}>
          Generate PDF
        </button>
      </section>
    </div>
  );
}
