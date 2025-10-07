import styles from "./AppLayout.module.css";

const NAV_ITEMS = [
  { id: "capture", label: "+ Capture Invoice" },
  { id: "inbox", label: "Inbox" },
  { id: "invoices", label: "Invoices" },
  { id: "bookings", label: "Bookings" },
  { id: "lineItems", label: "Line Items" },
  { id: "dashboard", label: "Dashboard" },
  { id: "reports", label: "Reports" },
  { id: "settings", label: "Settings" },
];

const QUEUES = [
  { label: "Unreviewed", count: 12 },
  { label: "Needs Split", count: 4 },
  { label: "Missing Data", count: 2 },
];

export default function AppLayout({
  user,
  activeSection,
  onNavigate,
  onLogout,
  children,
}) {
  return (
    <div className={styles.root}>
      <aside className={styles.sidebar}>
        <div className={styles.brand}>
          <span>⌘</span>
          ScanBooks
        </div>
        <nav className={styles.nav}>
          {NAV_ITEMS.map((item) => (
            <button
              key={item.id}
              type="button"
              className={`${styles.navButton} ${activeSection === item.id ? styles.navButtonActive : ""}`}
              onClick={() => onNavigate?.(item.id)}
            >
              {item.label}
            </button>
          ))}
        </nav>
        <div className={styles.queueCard}>
          {QUEUES.map((queue) => (
            <div key={queue.label} className={styles.queueItem}>
              <span>{queue.label}</span>
              <strong>{queue.count}</strong>
            </div>
          ))}
        </div>
        <div className={styles.sidebarFooter}>© {new Date().getFullYear()} ScanBooks</div>
      </aside>

      <div className={styles.main}>
        <div className={styles.topbar}>
          <div className={styles.searchGroup}>
            <select className={styles.workspaceSelect} defaultValue="All Workspaces">
              <option>All Workspaces</option>
            </select>
            <input
              type="search"
              className={styles.searchInput}
              placeholder="Search invoices, vendors..."
            />
          </div>
          <div className={styles.userMenu}>
            <span>{user?.email}</span>
            <button type="button" onClick={onLogout} className={styles.logoutButton}>
              Logout
            </button>
          </div>
        </div>

        <div className={styles.content}>{children}</div>
      </div>
    </div>
  );
}
