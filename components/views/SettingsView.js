import ProfileManager from "../ProfileManager";
import styles from "./SimpleView.module.css";

export default function SettingsView({
  profiles = [],
  profilesLoaded = false,
  profileError = "",
  onProfilesChange,
  onReloadProfiles,
}) {
  return (
    <div className={styles.root}>
      <section className={styles.card}>
        <h2>Workspace Settings</h2>
        <p className={styles.subtext}>
          Configure integrations, permissions, and automation rules across your Aiutofin workspace.
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

      {profileError && (
        <section className={styles.card}>
          <h3>Profielen konden niet worden geladen</h3>
          <p className={styles.subtext}>{profileError}</p>
          {typeof onReloadProfiles === "function" && (
            <button type="button" className={styles.retryButton} onClick={onReloadProfiles}>
              Opnieuw proberen
            </button>
          )}
        </section>
      )}

      {profilesLoaded ? (
        <ProfileManager profiles={profiles} onProfilesChange={onProfilesChange} />
      ) : (
        <section className={styles.card}>
          <h3>Profielen laden</h3>
          <p className={styles.subtext}>We halen je bedrijfsprofielen op…</p>
        </section>
      )}
    </div>
  );
}
