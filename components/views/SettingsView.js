import styles from "./SimpleView.module.css";

export default function SettingsView() {
  return (
    <div className={styles.root}>
      <section className={styles.card}>
        <h2>Workspace Settings</h2>
        <p className={styles.subtext}>
          Configure integrations, permissions, and automation rules across your ScanBooks environment.
        </p>
        <div className={styles.sectionList}>
          <div>
            <strong>Integrations</strong>
            <div>Manage connections to QuickBooks, Xero, and email inboxes.</div>
          </div>
          <div>
            <strong>Team</strong>
            <div>Invite collaborators, assign roles, and control access.</div>
          </div>
          <div>
            <strong>Automation</strong>
            <div>Define approval chains, routing rules, and notifications.</div>
          </div>
        </div>
      </section>
    </div>
  );
}
