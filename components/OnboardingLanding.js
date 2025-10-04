import { useState } from "react";

const tabs = [
  { id: "register", label: "Create account" },
  { id: "login", label: "Log in" },
];

const teamSizeOptions = ["1-10", "11-50", "51-200", "201-500", "500+"];

export default function OnboardingLanding({ onAuthSuccess, onSwitchToLogin }) {
  const [activeTab, setActiveTab] = useState("register");
  const [registerForm, setRegisterForm] = useState({
    fullName: "Jane Doe",
    workEmail: "name@company.com",
    password: "password123",
    company: "Northshore LLC",
    teamSize: teamSizeOptions[0],
    useCase: "AP automation & booking",
  });
  const [loginForm, setLoginForm] = useState({
    email: "you@company.com",
    password: "password123",
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const handleTabChange = (id) => {
    setActiveTab(id);
    setError("");
    setSuccess("");
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
    setError("");
    setSuccess("");
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
        throw new Error(data?.error || "Registratie mislukt");
      }
      setSuccess("Account aangemaakt! Bezig met inloggen...");
      if (typeof onAuthSuccess === "function") {
        onAuthSuccess(data.user);
      }
    } catch (err) {
      setError(err.message || "Registratie mislukt");
    } finally {
      setLoading(false);
    }
  };

  const submitLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setSuccess("");
    try {
      const resp = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: loginForm.email,
          password: loginForm.password,
        }),
      });
      const data = await resp.json();
      if (!resp.ok) {
        throw new Error(data?.error || "Inloggen mislukt");
      }
      setSuccess("Welkom terug! Bezig met inloggen...");
      if (typeof onAuthSuccess === "function") {
        onAuthSuccess(data.user);
      }
    } catch (err) {
      setError(err.message || "Inloggen mislukt");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 flex flex-col md:flex-row">
      {/* Sidebar */}
      <aside className="w-full md:w-64 bg-slate-950 flex flex-col border-b md:border-b-0 md:border-r border-slate-800">
        <div className="px-6 py-6 flex items-center gap-3 border-b border-slate-800">
          <div className="h-10 w-10 rounded bg-emerald-500/10 text-emerald-400 flex items-center justify-center text-xl font-semibold">
            SB
          </div>
          <div>
            <p className="text-sm uppercase tracking-wide text-slate-400">ScanBooks</p>
            <p className="font-semibold text-lg text-white">Control Center</p>
          </div>
        </div>
        <nav className="flex-1 py-6">
          <ul className="space-y-1 px-4">
            <li>
              <button
                type="button"
                className="w-full flex items-center gap-3 px-3 py-3 rounded-lg bg-emerald-500/20 text-emerald-200 font-medium"
              >
                <span className="text-xl">👋</span>
                Get Started
              </button>
            </li>
            <li>
              <button
                type="button"
                onClick={() => {
                  setActiveTab("login");
                  if (typeof onSwitchToLogin === "function") {
                    onSwitchToLogin();
                  }
                }}
                className="w-full flex items-center gap-3 px-3 py-3 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800"
              >
                <span className="text-xl">🔐</span>
                Login
              </button>
            </li>
            <li>
              <button
                type="button"
                className="w-full flex items-center gap-3 px-3 py-3 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800"
              >
                <span className="text-xl">❓</span>
                Help
              </button>
            </li>
          </ul>
        </nav>
        <div className="px-6 py-6 text-xs text-slate-500">
          © {new Date().getFullYear()} ScanBooks
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 bg-slate-100 text-slate-900">
        <header className="h-16 border-b border-slate-200 bg-white flex items-center justify-between px-4 md:px-10">
          <div className="flex items-center gap-3 text-base md:text-lg font-semibold">
            <span className="text-slate-500 text-2xl">⌘</span>
            <span>AI Invoicing</span>
          </div>
          <div className="flex items-center gap-3 md:gap-4 text-xs md:text-sm">
            <button type="button" className="text-slate-600 hover:text-slate-900">
              Contact Sales
            </button>
            <button type="button" className="text-slate-600 hover:text-slate-900">
              Docs
            </button>
          </div>
        </header>

        <div className="px-4 md:px-10 py-8 grid grid-cols-1 xl:grid-cols-[1.1fr,0.9fr] gap-6 xl:gap-8">
          {/* Left content */}
          <section className="bg-white rounded-3xl border border-slate-200 px-6 md:px-10 py-8 md:py-12 shadow-sm order-2 xl:order-1">
            <div className="max-w-lg space-y-6">
              <div className="space-y-4">
                <p className="text-emerald-500 uppercase tracking-widest text-[10px] md:text-xs font-semibold">
                  Automate your invoice workflow
                </p>
                <h1 className="text-2xl md:text-3xl xl:text-4xl font-semibold text-slate-900">
                  Automate your invoice and receipt workflow
                </h1>
                <p className="text-slate-600 leading-relaxed text-sm md:text-base">
                  Capture, extract, and book invoices to your accounting system with AI-assisted data entry,
                  account recommendations, and approvals.
                </p>
              </div>
              <div className="grid sm:grid-cols-2 gap-3 md:gap-4">
                {[
                  {
                    title: "Smart capture",
                    desc: "From email, mobile, and desktop",
                    icon: "📸",
                  },
                  {
                    title: "AI suggestions",
                    desc: "For vendors and accounts",
                    icon: "🤖",
                  },
                  {
                    title: "Line item splits",
                    desc: "With classes and departments",
                    icon: "🧾",
                  },
                  {
                    title: "Approvals",
                    desc: "Before booking to QuickBooks, Xero",
                    icon: "✅",
                  },
                ].map((feature) => (
                  <div key={feature.title} className="rounded-2xl border border-slate-200 bg-slate-50 p-4 md:p-5 shadow-inner">
                    <div className="text-lg md:text-xl">{feature.icon}</div>
                    <p className="mt-3 text-sm font-semibold text-slate-900">{feature.title}</p>
                    <p className="text-xs text-slate-500 leading-relaxed">{feature.desc}</p>
                  </div>
                ))}
              </div>
              <div className="h-40 md:h-48 border border-dashed border-slate-300 rounded-2xl flex items-center justify-center text-slate-400 text-xs md:text-sm">
                Product preview
              </div>
            </div>
          </section>

          {/* Right content: forms */}
          <section className="bg-white rounded-3xl border border-slate-200 p-6 md:p-8 space-y-6 shadow-sm order-1 xl:order-2">
            <div className="flex items-center gap-2">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => handleTabChange(tab.id)}
                  className={`px-4 py-2 rounded-full text-sm font-medium border transition-colors ${
                    activeTab === tab.id
                      ? "bg-emerald-500 text-white border-emerald-500"
                      : "border-slate-200 text-slate-500 hover:text-slate-800"
                  }`}
                >
                  {tab.label}
                </button>
              ))}
            </div>

            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 sm:gap-4">
              <button
                type="button"
                className="flex-1 inline-flex items-center justify-center gap-2 rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100"
              >
                <span>🔒</span>
                Continue with Google
              </button>
              <button
                type="button"
                className="flex-1 inline-flex items-center justify-center gap-2 rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100"
              >
                <span>🐙</span>
                Continue with GitHub
              </button>
            </div>

            <div className="relative">
              <div className="absolute inset-0 flex items-center" aria-hidden="true">
                <div className="w-full border-t border-slate-200" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-white px-3 text-slate-400">or</span>
              </div>
            </div>

            {error && <p className="text-sm text-red-500">{error}</p>}
            {success && <p className="text-sm text-emerald-600">{success}</p>}

            {activeTab === "register" ? (
              <form onSubmit={submitRegister} className="space-y-4">
                <div className="grid grid-cols-1 gap-4">
                  <label className="text-xs font-medium text-slate-500">
                    Full name
                    <input
                      type="text"
                      value={registerForm.fullName}
                      onChange={(e) => handleRegisterChange("fullName", e.target.value)}
                      className="mt-1 w-full rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm focus:border-emerald-500 focus:outline-none"
                      placeholder="Jane Doe"
                    />
                  </label>
                  <label className="text-xs font-medium text-slate-500">
                    Work email
                    <input
                      type="email"
                      value={registerForm.workEmail}
                      onChange={(e) => handleRegisterChange("workEmail", e.target.value)}
                      required
                      className="mt-1 w-full rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm focus:border-emerald-500 focus:outline-none"
                      placeholder="name@company.com"
                    />
                  </label>
                  <label className="text-xs font-medium text-slate-500">
                    Password
                    <input
                      type="password"
                      value={registerForm.password}
                      onChange={(e) => handleRegisterChange("password", e.target.value)}
                      required
                      className="mt-1 w-full rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm focus:border-emerald-500 focus:outline-none"
                      placeholder="••••••••"
                    />
                  </label>
                  <label className="text-xs font-medium text-slate-500">
                    Company
                    <input
                      type="text"
                      value={registerForm.company}
                      onChange={(e) => handleRegisterChange("company", e.target.value)}
                      className="mt-1 w-full rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm focus:border-emerald-500 focus:outline-none"
                      placeholder="Northshore LLC"
                    />
                  </label>
                  <label className="text-xs font-medium text-slate-500">
                    Team size
                    <select
                      value={registerForm.teamSize}
                      onChange={(e) => handleRegisterChange("teamSize", e.target.value)}
                      className="mt-1 w-full rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm focus:border-emerald-500 focus:outline-none"
                    >
                      {teamSizeOptions.map((option) => (
                        <option key={option} value={option}>
                          {option}
                        </option>
                      ))}
                    </select>
                  </label>
                  <label className="text-xs font-medium text-slate-500">
                    Use case
                    <input
                      type="text"
                      value={registerForm.useCase}
                      onChange={(e) => handleRegisterChange("useCase", e.target.value)}
                      className="mt-1 w-full rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm focus:border-emerald-500 focus:outline-none"
                      placeholder="AP automation & booking"
                    />
                  </label>
                </div>
                <p className="text-xs text-slate-400">
                  By creating an account, you agree to the Terms and Privacy Policy.
                </p>
                <div className="flex flex-col sm:flex-row gap-3">
                  <button
                    type="button"
                    onClick={() => handleTabChange("login")}
                    className="flex-1 rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100"
                  >
                    Log in instead
                  </button>
                  <div className="flex-1">
                    <button
                      type="button"
                      onClick={() => handleTabChange("login")}
                      className="w-full rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100"
                    >
                      Back
                    </button>
                  </div>
                  <button
                    type="submit"
                    disabled={loading}
                    className="flex-1 rounded-full bg-emerald-500 px-4 py-2 text-sm font-semibold text-white shadow hover:bg-emerald-600 disabled:opacity-50"
                  >
                    {loading ? "Bezig..." : "Create account"}
                  </button>
                </div>
              </form>
            ) : (
              <form onSubmit={submitLogin} className="space-y-4">
                <div className="grid grid-cols-1 gap-4">
                  <label className="text-xs font-medium text-slate-500">
                    Email
                    <input
                      type="email"
                      value={loginForm.email}
                      onChange={(e) => handleLoginChange("email", e.target.value)}
                      required
                      className="mt-1 w-full rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm focus:border-emerald-500 focus:outline-none"
                      placeholder="you@company.com"
                    />
                  </label>
                  <label className="text-xs font-medium text-slate-500">
                    Password
                    <input
                      type="password"
                      value={loginForm.password}
                      onChange={(e) => handleLoginChange("password", e.target.value)}
                      required
                      className="mt-1 w-full rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm focus:border-emerald-500 focus:outline-none"
                      placeholder="••••••••"
                    />
                  </label>
                </div>
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 text-xs text-slate-500">
                  <span>Protect your account with SSO and 2FA in Settings after signup.</span>
                  <div>
                    <button
                      type="button"
                      onClick={() => handleTabChange("register")}
                      className="text-emerald-600 hover:text-emerald-700 font-medium"
                    >
                      Forgot password
                    </button>
                  </div>
                </div>
                <div className="flex flex-col sm:flex-row gap-3">
                  <button
                    type="button"
                    onClick={() => handleTabChange("register")}
                    className="flex-1 rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100"
                  >
                    Back
                  </button>
                  <button
                    type="submit"
                    disabled={loading}
                    className="flex-1 rounded-full bg-slate-900 px-4 py-2 text-sm font-semibold text-white shadow hover:bg-slate-800 disabled:opacity-50"
                  >
                    {loading ? "Bezig..." : "Log in"}
                  </button>
                </div>
              </form>
            )}
          </section>
        </div>
      </main>
    </div>
  );
}
