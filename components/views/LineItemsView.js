import styles from "./SimpleView.module.css";

const LINE_ITEMS = [
  { description: "Printer paper", account: "Office Supplies", amount: "$750.00", status: "Needs Split" },
  { description: "Delivery fee", account: "Freight & Delivery", amount: "$50.00", status: "Ready" },
  { description: "Printer ink", account: "Maintenance", amount: "$120.00", status: "Pending" },
];

export default function LineItemsView() {
  return (
    <div className={styles.root}>
      <section className={styles.card}>
        <h2>Line Items</h2>
        <p className={styles.subtext}>
          Review extracted line items, adjust splits, and confirm account assignments before booking invoices.
        </p>
        <table className={styles.table}>
          <thead>
            <tr>
              <th>Description</th>
              <th>Account</th>
              <th>Amount</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {LINE_ITEMS.map((item) => (
              <tr key={item.description}>
                <td>{item.description}</td>
                <td>{item.account}</td>
                <td>{item.amount}</td>
                <td>{item.status}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>
    </div>
  );
}
