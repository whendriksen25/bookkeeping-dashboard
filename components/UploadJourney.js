import styles from "./UploadJourney.module.css";

const STATUS_ICON = {
  done: "✓",
  pending: "",
  error: "!",
};

export default function UploadJourney({
  steps = [],
  title = "What happens next?",
  subtitle = "Track how your document moves from upload to booked transaction.",
}) {
  if (!Array.isArray(steps) || steps.length === 0) {
    return null;
  }

  return (
    <section className={styles.root} aria-label="Invoice processing status">
      <header className={styles.header}>
        <h2 className={styles.title}>{title}</h2>
        <p className={styles.subtitle}>{subtitle}</p>
      </header>
      <ol className={styles.list}>
        {steps.map((step) => {
          const { key, title, description, status = "pending", meta } = step;
          const icon = STATUS_ICON[status] ?? STATUS_ICON.pending;
          return (
            <li key={key} className={`${styles.item} ${styles[status] || ""}`}>
              <div className={styles.marker} aria-hidden="true">
                {status === "current" ? <span className={styles.spinner} /> : icon}
              </div>
              <div className={styles.content}>
                <div className={styles.itemHeader}>
                  <span className={styles.itemTitle}>{title}</span>
                  {status === "current" && <span className={styles.badge}>In progress</span>}
                  {status === "done" && <span className={styles.badgeDone}>Done</span>}
                  {status === "error" && <span className={styles.badgeError}>Needs attention</span>}
                </div>
                {description ? (
                  <p className={styles.itemDescription}>{description}</p>
                ) : null}
                {meta ? <div className={styles.itemMeta}>{meta}</div> : null}
              </div>
            </li>
          );
        })}
      </ol>
    </section>
  );
}
