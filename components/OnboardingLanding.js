import { useState } from "react";
import {
  ScanBooksIcon,
  UserPlusIcon,
  LoginIcon,
  HelpIcon,
  CaptureIcon,
  AIIcon,
  ListIcon,
  ShieldCheckIcon,
  GoogleIcon,
  GitHubIcon,
} from "./OnboardingIcons";
import styles from "./OnboardingLanding.module.css";

const featureCards = [
  {
    icon: CaptureIcon,
    text: "Smart capture from email, mobile, and desktop",
  },
  {
    icon: AIIcon,
    text: "AI suggestions for vendors and accounts",
  },
  {
    icon: ListIcon,
    text: "Line item splits with classes and departments",
  },
  {
    icon: ShieldCheckIcon,
    text: "Approvals before booking to QuickBooks, Xero",
  },
];

const teamSizes = ["1-10", "11-50", "51-200", "201-500", "500+"];

const defaultRegister = {
  fullName: "Jane Doe",
  workEmail: "name@company.com",
  password: "Password123!",
  company: "Northshore LLC",
  teamSize: "1-10",
  useCase: "AP automation & booking",
};

const defaultLogin = {
  email: "you@company.com",
  password: "Password123!",
};

export default function OnboardingLanding({ onAuthSuccess }) {
  const [view, setView] = useState("signup");
  const [registerForm, setRegisterForm] = useState(defaultRegister);
  const [loginForm, setLoginForm] = useState(defaultLogin);
  const [message, setMessage] = useState({ type: "", text: "" });
  const [loading, setLoading] = useState(false);

  const isSignup = view === "signup";

  const handleSwitch = (next) => {
    setView(next);
    setMessage({ type: "", text: "" });
  };

  const handleRegisterChange = (field, value) => {
    setRegisterForm((prev) => ({ ...prev, [field]: value }));
  };

  const handleLoginChange = (field, value) => {
    setLoginForm((prev) => ({ ...prev, [field]: value }));
  };

  const submitRegister = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage({ type: "", text: "" });
    try {
      const resp = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: registerForm.workEmail,
          password: registerForm.password,
        }),
      });
      const data = await resp.json();
      if (!resp.ok) {
        throw new Error(data?.error || "Registration failed");
      }
      setMessage({ type: "success", text: "Account created. Redirecting..." });
      onAuthSuccess?.(data.user);
    } catch (err) {
      setMessage({ type: "error", text: err.message || "Registration failed" });
    } finally {
      setLoading(false);
    }
  };

  const submitLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage({ type: "", text: "" });
    try {
      const resp = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(loginForm),
      });
      const data = await resp.json();
      if (!resp.ok) {
        throw new Error(data?.error || "Login failed");
      }
      setMessage({ type: "success", text: "Welcome back!" });
      onAuthSuccess?.(data.user);
    } catch (err) {
      setMessage({ type: "error", text: err.message || "Login failed" });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.root}>
      <aside className={styles.sidebar}>
        <div className={styles.sidebarBrand}>
          <span className={styles.sidebarIcon}>
            <ScanBooksIcon />
          </span>
          <div>
            <p className={styles.sidebarLabel}>ScanBooks</p>
            <p className={styles.sidebarTitle}>AI Invoicing</p>
          </div>
        </div>
        <nav className={styles.navList}>
          <button type="button" className={`${styles.navButton} ${styles.navPrimary}`}>
            <UserPlusIcon />
            Get Started
          </button>
          <button
            type="button"
            onClick={() => handleSwitch("login")}
            className={styles.navButton}
          >
            <LoginIcon />
            Login
          </button>
          <button type="button" className={styles.navButton}>
            <HelpIcon />
            Help
          </button>
        </nav>
        <div className={styles.sidebarFooter}>© {new Date().getFullYear()} ScanBooks</div>
      </aside>

      <main className={styles.main}>
        <header className={styles.header}>
          <div className={styles.headerBrand}>
            <ScanBooksIcon />
            <span>AI Invoicing</span>
          </div>
          <div className={styles.headerActions}>
            <button type="button">Contact Sales</button>
            <button type="button">Docs</button>
          </div>
        </header>

        <div className={styles.content}>
          <section className={styles.promo}>
            <div className={styles.promoContent}>
              <h1>Automate your invoice and receipt workflow</h1>
              <p>
                Capture, extract, and book invoices to your accounting system with AI-assisted data entry, account
                recommendations, and approvals.
              </p>
              <div className={styles.featureGrid}>
                {featureCards.map(({ icon: Icon, text }) => (
                  <div key={text} className={styles.featureCard}>
                    <Icon />
                    <p>{text}</p>
                  </div>
                ))}
              </div>
            </div>
            <div className={styles.previewBox}>Product preview</div>
          </section>

          <section className={styles.panel}>
            {isSignup ? (
            <form className={styles.form} onSubmit={submitRegister}>
              <div className={styles.tabRow}>
                <button type="button" className={`${styles.tabButton} ${styles.tabActive}`}>
                  Create account
                </button>
                <button type="button" onClick={() => handleSwitch("login")} className={styles.tabButton}>
                  Log in
                </button>
              </div>

              <div className={styles.socialRow}>
                <button type="button" className={styles.socialButton}>
                  <GoogleIcon />
                  Continue with Google
                </button>
                <button type="button" className={styles.socialButton}>
                  <GitHubIcon />
                  Continue with GitHub
                </button>
              </div>

              <div className={styles.divider}>
                <span>or</span>
              </div>

              <label className={styles.field}>
                <span>Full name</span>
                <input
                  type="text"
                  value={registerForm.fullName}
                  onChange={(e) => handleRegisterChange("fullName", e.target.value)}
                  className={styles.input}
                />
              </label>
              <label className={styles.field}>
                <span>Work email</span>
                <input
                  type="email"
                  value={registerForm.workEmail}
                  onChange={(e) => handleRegisterChange("workEmail", e.target.value)}
                  required
                  className={styles.input}
                />
              </label>
              <label className={styles.field}>
                <span>Password</span>
                <input
                  type="password"
                  value={registerForm.password}
                  onChange={(e) => handleRegisterChange("password", e.target.value)}
                  required
                  className={styles.input}
                />
              </label>
              <label className={styles.field}>
                <span>Company</span>
                <input
                  type="text"
                  value={registerForm.company}
                  onChange={(e) => handleRegisterChange("company", e.target.value)}
                  className={styles.input}
                />
              </label>
              <label className={styles.field}>
                <span>Team size</span>
                <select
                  value={registerForm.teamSize}
                  onChange={(e) => handleRegisterChange("teamSize", e.target.value)}
                  className={styles.input}
                >
                  {teamSizes.map((size) => (
                    <option key={size} value={size}>
                      {size}
                    </option>
                  ))}
                </select>
              </label>
              <label className={styles.field}>
                <span>Use case</span>
                <input
                  type="text"
                  value={registerForm.useCase}
                  onChange={(e) => handleRegisterChange("useCase", e.target.value)}
                  className={styles.input}
                />
              </label>

              <p className={styles.smallPrint}>
                By creating an account, you agree to the Terms and Privacy Policy.
              </p>

              {message.text && (
                <p className={`${styles.message} ${message.type === "error" ? styles.error : styles.success}`}>
                  {message.text}
                </p>
              )}

              <div className={styles.actionRow}>
                <button type="button" onClick={() => handleSwitch("login")} className={styles.secondaryButton}>
                  Log in instead
                </button>
                <button type="submit" disabled={loading} className={styles.primaryButton}>
                  {loading ? "Processing..." : "Create account"}
                </button>
              </div>
            </form>
          ) : (
            <form className={styles.form} onSubmit={submitLogin}>
              <div className={styles.tabRow}>
                <button type="button" onClick={() => handleSwitch("signup")} className={styles.tabButton}>
                  Create account
                </button>
                <button type="button" className={`${styles.tabButton} ${styles.tabActive}`}>
                  Log in
                </button>
              </div>

              <label className={styles.field}>
                <span>Email</span>
                <input
                  type="email"
                  value={loginForm.email}
                  onChange={(e) => handleLoginChange("email", e.target.value)}
                  required
                  className={styles.input}
                />
              </label>
              <label className={styles.field}>
                <span>Password</span>
                <input
                  type="password"
                  value={loginForm.password}
                  onChange={(e) => handleLoginChange("password", e.target.value)}
                  required
                  className={styles.input}
                />
              </label>

              {message.text && (
                <p className={`${styles.message} ${message.type === "error" ? styles.error : styles.success}`}>
                  {message.text}
                </p>
              )}

              <div className={styles.footerRow}>
                <span>Protect your account with SSO and 2FA after signup.</span>
                <button type="button" onClick={() => handleSwitch("signup")}>
                  Forgot password?
                </button>
              </div>

              <button type="submit" disabled={loading} className={styles.primaryButton}>
                {loading ? "Processing..." : "Log in"}
              </button>
            </form>
          )}
          </section>
        </div>
      </main>
    </div>
  );
}
