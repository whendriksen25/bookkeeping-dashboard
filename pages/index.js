import { useCallback, useEffect, useState } from "react";
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
  const [selectedAccount, setSelectedAccount] = useState("");
  const [recentUploads, setRecentUploads] = useState(DEMO_UPLOADS);
  const [activeSection, setActiveSection] = useState(NAV_DEFAULT);
  const [invoicesData, setInvoicesData] = useState([]);
  const [inboxEntries, setInboxEntries] = useState([]);
  const [selectedInboxId, setSelectedInboxId] = useState(null);
  const [selectedBookingId, setSelectedBookingId] = useState(null);

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
        setUser(null);
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

  const resetAuthenticatedState = useCallback(() => {
    setAnalysis(null);
    setProfiles([]);
    setProfilesLoaded(false);
    setSelectedAccount("");
    setProfileError("");
    setRecentUploads(DEMO_UPLOADS);
    setInvoicesData([]);
    setInboxEntries([]);
    setSelectedInboxId(null);
    setSelectedBookingId(null);
    setActiveSection(NAV_DEFAULT);
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
          filename: inv.sourceFilename || inv.invoiceNumber || "Invoice",
          status: inv.status === "Paid" ? "Ready" : inv.status,
          action: inv.status === "Paid" ? "View" : "Review",
        }))
      );
    } catch (err) {
      console.error("[invoices] fetch failed", err);
    }
  }, []);

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
  }, [user, fetchInvoices, fetchInbox]);

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
        { id: `${Date.now()}`, filename, status: "Ready", action: "Review" },
        ...prev,
      ];
      return next.slice(0, 5);
    });
    fetchInvoices();
    fetchInbox();
  }, [fetchInvoices, fetchInbox]);

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

  const renderSection = () => {
    switch (activeSection) {
      case "dashboard":
        return <DashboardOverviewView invoices={invoicesData} />;
      case "invoices":
        return <InvoicesView invoices={invoicesData} />;
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
          />
        );
      case "lineItems":
        return <LineItemsView />;
      case "reports":
        return <ReportsView />;
      case "settings":
        return <SettingsView />;
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
    >
      {renderSection()}
    </AppLayout>
  );
}
