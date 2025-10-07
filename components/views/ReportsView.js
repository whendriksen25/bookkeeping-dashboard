import styles from "./SimpleView.module.css";

export default function ReportsView() {
  return (
    <div className={styles.root}>
      <section className={styles.card}>
        <h2>Reports</h2>
        <p className={styles.subtext}>
          Generate period-based financial reports, export CSVs, and share tailored summaries with accountants.
        </p>
        <div className={styles.sectionList}>
          <div>
            <strong>Profit &amp; Loss</strong>
            <div>Compare revenue and expenses across custom periods.</div>
          </div>
          <div>
            <strong>Balance Sheet</strong>
            <div>Track assets, liabilities, and equity for your entities.</div>
          </div>
          <div>
            <strong>Tasks &amp; Approvals</strong>
            <div>Monitor approval workload across accounting teams.</div>
          </div>
        </div>
      </section>
    </div>
  );
}
