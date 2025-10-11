/* eslint-disable @next/next/no-img-element */
import { useState } from "react";

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

export default function AppLayout({
  user,
  activeSection,
  onNavigate,
  onLogout,
  children,
  queueCounts,
}) {
  const queues = Array.isArray(queueCounts) && queueCounts.length > 0 ? queueCounts : null;
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleNavigate = (sectionId) => {
    onNavigate?.(sectionId);
    setMobileMenuOpen(false);
  };

  const toggleMobileMenu = () => {
    setMobileMenuOpen((prev) => !prev);
  };

  const sidebarClassName = [styles.sidebar];
  if (mobileMenuOpen) sidebarClassName.push(styles.sidebarMobileOpen);

  return (
    <div className={styles.root}>
      <aside className={sidebarClassName.join(" ")}>
        <div className={styles.brand}>
          <img
            src="/aiutofin-icon-for-black-bg.png"
            alt="Aiutofin icon"
            className={styles.brandIcon}
          />
          <img
            src="/aiutofin-text-for-black-bg.png"
            alt="Aiutofin"
            className={styles.brandWordmark}
          />
        </div>
        <nav className={styles.nav}>
          {NAV_ITEMS.map((item) => (
            <button
              key={item.id}
              type="button"
              className={`${styles.navButton} ${activeSection === item.id ? styles.navButtonActive : ""}`}
              onClick={() => handleNavigate(item.id)}
            >
              {item.label}
            </button>
          ))}
        </nav>
        {queues && (
          <div className={styles.queueCard}>
            {queues.map((queue) => (
              <div key={queue.label} className={styles.queueItem}>
                <span>{queue.label}</span>
                <strong>{queue.count}</strong>
              </div>
            ))}
          </div>
        )}
        <div className={styles.sidebarFooter}>© {new Date().getFullYear()} Aiutofin</div>
      </aside>

      <div className={styles.main}>
        <div className={styles.topbar}>
          <div className={styles.topbarLeft}>
            <button type="button" className={styles.menuButton} onClick={toggleMobileMenu}>
              Menu
            </button>
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

      {mobileMenuOpen && (
        <button
          type="button"
          aria-label="Close menu"
          className={styles.mobileOverlay}
          onClick={toggleMobileMenu}
        />
      )}
    </div>
  );
}
