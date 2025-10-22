import { useCallback, useEffect, useMemo, useState } from "react";
import OnboardingLanding from "../components/OnboardingLanding";
import AppLayout from "../components/AppLayout";
import CaptureInvoiceView from "../components/views/CaptureInvoiceView";
import DashboardOverviewView from "../components/views/DashboardOverviewView";
import InvoicesView from "../components/views/InvoicesView";
import InboxView from "../components/views/InboxView";
import BookingsView from "../components/views/BookingsView";
import LineItemsView from "../components/views/LineItemsView";
import ReportsView from "../components/views/ReportsView";
import SettingsView from "../components/views/SettingsView";

const DEMO_UPLOADS = [
  { id: "demo-1", filename: "Acme_Invoice_1032.pdf", status: "Processing", action: "Open" },
  { id: "demo-2", filename: "Coffee_Receipt.jpg", status: "Ready", action: "Review" },
];

const NAV_DEFAULT = "capture";

export default function Home() {
  const [user, setUser] = useState(null);
  const [sessionLoading, setSessionLoading] = useState(true);
  const [analysis, setAnalysis] = useState(null);
  const [profiles, setProfiles] = useState([]);
  const [profilesLoaded, setProfilesLoaded] = useState(false);
  const [profileError, setProfileError] = useState("");
  const [showSetupFlow, setShowSetupFlow] = useState(false);
  const [setupDismissed, setSetupDismissed] = useState(false);
  const [selectedAccount, setSelectedAccount] = useState("");
  const [selectedProfileId, setSelectedProfileId] = useState("all");
  const [recentUploads, setRecentUploads] = useState(DEMO_UPLOADS);
  const [activeSection, setActiveSection] = useState(NAV_DEFAULT);
  const [invoicesData, setInvoicesData] = useState([]);
  const [inboxEntries, setInboxEntries] = useState([]);
  const [selectedInboxId, setSelectedInboxId] = useState(null);
  const [selectedBookingId, setSelectedBookingId] = useState(null);
  const [financialSummary, setFinancialSummary] = useState(null);
  const [financialSummaryLoading, setFinancialSummaryLoading] = useState(false);
  const [financialSummaryError, setFinancialSummaryError] = useState("");

  const loadSession = useCallback(async () => {
    setSessionLoading(true);
    try {
      const resp = await fetch("/api/auth/session");
      if (!resp.ok) {
        setUser(null);
        return;
      }
      const data = await resp.json();
      setUser(data.user || null);
    } catch (err) {
      console.error("[auth] session check failed", err);
      setUser(null);
    } finally {
      setSessionLoading(false);
    }
  }, []);

  const loadProfiles = useCallback(async () => {
    setProfilesLoaded(false);
    setProfileError("");
    try {
      const resp = await fetch("/api/profiles");
      if (resp.status === 401) {
        if (process.env.NODE_ENV === "production") {
          setUser(null);
        }
        setProfiles([]);
        return;
      }
      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Kon profielen niet ophalen");
      }
      const data = await resp.json();
      setProfiles(Array.isArray(data.profiles) ? data.profiles : []);
    } catch (err) {
      console.error("[profiles] load failed", err);
      setProfiles([]);
      setProfileError(err.message || "Kon profielen niet laden");
    } finally {
      setProfilesLoaded(true);
    }
  }, [setProfiles]);

  const fetchFinancialSummary = useCallback(async () => {
    if (!user) {
      setFinancialSummary(null);
      return;
    }
    setFinancialSummaryLoading(true);
    setFinancialSummaryError("");
    try {
      const resp = await fetch("/api/reports/financial?includeProfiles=true");
      if (!resp.ok) {
        const text = await resp.text();
        throw new Error(text || "Failed to load financial summary");
      }
      const data = await resp.json();
      setFinancialSummary(data.summary || null);
    } catch (err) {
      console.error("[reports] summary failed", err);
      setFinancialSummary(null);
      setFinancialSummaryError(err.message || "Could not load financial summary");
    } finally {
      setFinancialSummaryLoading(false);
    }
  }, [user]);

  const handleGenerateReport = useCallback(
    async ({ summary, currency }) => {
      if (!user) return;
      try {
        const params = new URLSearchParams();
        if (summary?.filters?.startDate) params.set("startDate", summary.filters.startDate);
        if (summary?.filters?.endDate) params.set("endDate", summary.filters.endDate);
        if (currency) params.set("currency", currency);

        const resp = await fetch(`/api/reports/generate?${params.toString()}`);
        if (!resp.ok) {
          const text = await resp.text();
          throw new Error(text || "Unable to generate report");
        }
        const buffer = await resp.arrayBuffer();
        const blob = new Blob([buffer], { type: "application/pdf" });
        const url = URL.createObjectURL(blob);
        const win = window.open(url, "_blank");
        if (!win) {
          const link = document.createElement("a");
          link.href = url;
          link.download = "financial-report.pdf";
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        }
        setTimeout(() => URL.revokeObjectURL(url), 60_000);
      } catch (err) {
        console.error("[reports] generate UI failed", err);
        alert(err.message || "Could not generate report");
      }
    },
    [user]
  );

  const resetAuthenticatedState = useCallback(() => {
    setAnalysis(null);
    setProfiles([]);
    setProfilesLoaded(false);
    setSelectedAccount("");
    setSelectedProfileId("all");
    setProfileError("");
    setShowSetupFlow(false);
    setSetupDismissed(false);
    setRecentUploads(DEMO_UPLOADS);
    setInvoicesData([]);
    setInboxEntries([]);
    setSelectedInboxId(null);
    setSelectedBookingId(null);
    setActiveSection(NAV_DEFAULT);
    setFinancialSummary(null);
    setFinancialSummaryLoading(false);
    setFinancialSummaryError("");
  }, []);

  const handleAuthSuccess = useCallback(
    (userData) => {
      setUser(userData || null);
      resetAuthenticatedState();
    },
    [resetAuthenticatedState]
  );

  const handleLogout = useCallback(async () => {
    try {
      await fetch("/api/auth/logout", { method: "POST" });
    } catch (err) {
      console.error("[auth] logout failed", err);
    } finally {
      setUser(null);
      resetAuthenticatedState();
    }
  }, [resetAuthenticatedState]);

  useEffect(() => {
    loadSession();
  }, [loadSession]);

  useEffect(() => {
    if (!user) {
      resetAuthenticatedState();
      return;
    }
    loadProfiles();
  }, [user, loadProfiles, resetAuthenticatedState]);

  useEffect(() => {
    if (selectedProfileId === "all") return;
    if (selectedProfileId === "default") return;
    const exists = profiles.some((profile) => String(profile.id) === selectedProfileId);
    if (!exists) {
      setSelectedProfileId("all");
    }
  }, [profiles, selectedProfileId]);

  useEffect(() => {
    if (!user || setupDismissed) return;
    if (!profilesLoaded) return;
    if (profiles.length === 0) {
      setShowSetupFlow(true);
    }
  }, [user, profilesLoaded, profiles.length, setupDismissed]);

  const fetchInvoices = useCallback(async () => {
    try {
      const resp = await fetch("/api/invoices?limit=50");
      if (!resp.ok) return;
      const data = await resp.json();
      const invoices = Array.isArray(data.invoices) ? data.invoices : [];
      setInvoicesData(invoices);
      setRecentUploads(
        invoices.slice(0, 5).map((inv) => ({
          id: inv.id,
          filename: inv.displayName || inv.sourceFilename || inv.invoiceNumber || "Invoice",
          status: inv.status === "Paid" ? "Ready" : inv.status,
          action:
            inv.status === "Booked" || inv.status === "Paid"
              ? "View"
              : inv.status === "Pending Review"
              ? "Review"
              : "Review",
          details:
            Array.isArray(inv.bookingSummary) && inv.bookingSummary.length > 0
              ? inv.bookingSummary
                  .map((entry) => {
                    const profileLabel = entry.profileName
                      ? entry.profileName
                      : entry.profile === "default"
                      ? "Default"
                      : `Profile ${entry.profile}`;
                    const accountLabel = entry.account || "—";
                    const amountValue = Number(entry.amount);
                    const amountLabel = Number.isFinite(amountValue)
                      ? new Intl.NumberFormat("en-US", {
                          style: "currency",
                          currency: inv.currency || "EUR",
                        }).format(amountValue)
                      : null;
                    return `${profileLabel} -> ${accountLabel}${amountLabel ? ` (${amountLabel})` : ""}`;
                  })
                  .join("; ")
              : "",
        }))
      );
    } catch (err) {
      console.error("[invoices] fetch failed", err);
    } finally {
      fetchFinancialSummary();
    }
  }, [fetchFinancialSummary]);

  const fetchInbox = useCallback(async () => {
    try {
      const resp = await fetch("/api/inbox?limit=10");
      if (!resp.ok) return;
      const data = await resp.json();
      const entries = Array.isArray(data.entries) ? data.entries : [];
      setInboxEntries(entries);
      if (entries.length > 0) {
        setSelectedInboxId((prev) => prev || entries[0].id);
        setSelectedBookingId((prev) => prev || entries[0].id);
      }
    } catch (err) {
      console.error("[inbox] fetch failed", err);
    }
  }, []);

  useEffect(() => {
    if (!user) return;
    fetchInvoices();
    fetchInbox();
    fetchFinancialSummary();
  }, [user, fetchInvoices, fetchInbox, fetchFinancialSummary]);

  useEffect(() => {
    if (!user) return;
    if (activeSection === "dashboard") {
      fetchInvoices();
    }
  }, [activeSection, user, fetchInvoices]);

  useEffect(() => {
    if (!analysis) {
      setSelectedAccount("");
      return;
    }
    const suggested =
      analysis?.ai_ranking?.keuze_nummer || analysis?.db_candidates?.[0]?.number || "";
    setSelectedAccount(suggested || "");
  }, [analysis]);

  const handleUploadComplete = useCallback((fileMeta) => {
    if (!fileMeta) return;
    const filename = fileMeta.filename || fileMeta.fileName || "Uploaded file";
    setRecentUploads((prev) => {
      const next = [
        { id: `${Date.now()}`, filename, status: "Pending Review", action: "Review" },
        ...prev,
      ];
      return next.slice(0, 5);
    });
    fetchInvoices();
    fetchInbox();
    fetchFinancialSummary();
  }, [fetchInvoices, fetchInbox, fetchFinancialSummary]);

  const queueCounts = useMemo(() => {
    const counts = {
      unreviewed: 0,
      needsSplit: 0,
      missingData: 0,
    };

    invoicesData.forEach((invoice) => {
      const status = (invoice.status || "").toLowerCase();
      if (status === "missing data") {
        counts.missingData += 1;
      } else if (status === "needs split") {
        counts.needsSplit += 1;
      } else if (status === "pending review") {
        counts.unreviewed += 1;
      }
    });

    if (!counts.unreviewed && !counts.needsSplit && !counts.missingData) {
      return null;
    }

    return [
      { label: "Unreviewed", count: counts.unreviewed },
      { label: "Needs Split", count: counts.needsSplit },
      { label: "Missing Data", count: counts.missingData },
    ];
  }, [invoicesData]);

  const baseCurrency = useMemo(() => {
    const withCurrency = invoicesData.find((inv) => inv.currency);
    return withCurrency?.currency || "EUR";
  }, [invoicesData]);

  const handleDeleteInvoices = useCallback(
    async (invoiceIds = []) => {
      if (!Array.isArray(invoiceIds) || invoiceIds.length === 0) return;

      setRecentUploads((prev) => prev.filter((item) => !invoiceIds.includes(item.id)));

      try {
        const resp = await fetch("/api/invoices", {
          method: "DELETE",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ ids: invoiceIds }),
        });

        if (!resp.ok) {
          const text = await resp.text();
          throw new Error(text || "Failed to delete invoices");
        }
      } catch (err) {
        console.error("[invoices] delete failed", err);
      } finally {
        fetchInvoices();
        fetchInbox();
        fetchFinancialSummary();
      }
    },
    [fetchInvoices, fetchInbox, fetchFinancialSummary]
  );

  if (sessionLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
        <p className="text-gray-600">Sessiestatus laden...</p>
      </div>
    );
  }

  if (!user) {
    return (
      <OnboardingLanding
        onAuthSuccess={handleAuthSuccess}
        onSwitchToLogin={() => setSelectedAccount("")}
      />
    );
  }

  const shouldShowSetup = showSetupFlow && !setupDismissed;

  if (shouldShowSetup) {
    const handleCompleteSetup = () => {
      setSetupDismissed(true);
      setShowSetupFlow(false);
    };

    return (
      <OnboardingLanding
        onAuthSuccess={handleAuthSuccess}
        user={user}
        profiles={profiles}
        profilesLoaded={profilesLoaded}
        profileError={profileError}
        onProfilesChange={setProfiles}
        onReloadProfiles={loadProfiles}
        onCompleteSetup={handleCompleteSetup}
        onLogout={handleLogout}
      />
    );
  }

  const renderSection = () => {
    switch (activeSection) {
      case "dashboard":
        return (
          <DashboardOverviewView
            invoices={invoicesData}
            financialSummary={financialSummary}
            profiles={profiles}
            selectedProfile={selectedProfileId}
            currency={baseCurrency}
            loadingFinancial={financialSummaryLoading}
            financialError={financialSummaryError}
            onGenerateReport={handleGenerateReport}
          />
        );
      case "invoices":
        return <InvoicesView invoices={invoicesData} onDeleteSelected={handleDeleteInvoices} />;
      case "inbox":
        return (
          <InboxView
            entries={inboxEntries}
            selectedId={selectedInboxId}
            onSelectEntry={setSelectedInboxId}
          />
        );
      case "bookings":
        return (
          <BookingsView
            entries={inboxEntries}
            selectedId={selectedBookingId}
            onSelectEntry={setSelectedBookingId}
            latestAnalysis={analysis}
          />
        );
      case "lineItems":
        return <LineItemsView />;
      case "reports":
        return <ReportsView />;
      case "settings":
        return (
          <SettingsView
            profiles={profiles}
            profilesLoaded={profilesLoaded}
            profileError={profileError}
            onProfilesChange={setProfiles}
            onReloadProfiles={loadProfiles}
          />
        );
      case "capture":
      default:
        return (
          <CaptureInvoiceView
            analysis={analysis}
            profiles={profiles}
            profilesLoaded={profilesLoaded}
            profileError={profileError}
            onProfilesChange={setProfiles}
            selectedAccount={selectedAccount}
            onSelectAccount={setSelectedAccount}
            recentUploads={recentUploads}
            onUploadComplete={handleUploadComplete}
            onAnalyze={setAnalysis}
            fallbackInvoice={
              inboxEntries.find((entry) => entry.id === (selectedBookingId || selectedInboxId)) ||
              inboxEntries[0]
            }
            onGoToBookings={() => setActiveSection("bookings")}
          />
        );
    }
  };

  return (
    <AppLayout
      user={user}
      activeSection={activeSection}
      onNavigate={setActiveSection}
      onLogout={handleLogout}
      queueCounts={queueCounts}
      profiles={profiles}
      selectedProfile={selectedProfileId}
      onProfileChange={setSelectedProfileId}
    >
      {renderSection()}
    </AppLayout>
  );
}
