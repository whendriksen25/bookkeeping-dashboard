import { useCallback, useEffect, useState } from "react";
import UploadForm from "../components/UploadForm";
import BookingDropdown from "../components/BookingDropdown";
import ProfileManager from "../components/ProfileManager";
import OnboardingLanding from "../components/OnboardingLanding";

export default function Home() {
  const [user, setUser] = useState(null);
  const [sessionLoading, setSessionLoading] = useState(true);
  const [analysis, setAnalysis] = useState(null);
  const [profiles, setProfiles] = useState([]);
  const [profilesLoaded, setProfilesLoaded] = useState(false);
  const [profileError, setProfileError] = useState("");
  const [selectedAccount, setSelectedAccount] = useState("");

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
  }, []);

  const handleAuthSuccess = useCallback(
    (userData) => {
      setUser(userData || null);
      setAnalysis(null);
      setProfiles([]);
      setProfilesLoaded(false);
      setSelectedAccount("");
      setProfileError("");
    },
    []
  );

  const handleLogout = useCallback(async () => {
    try {
      await fetch("/api/auth/logout", { method: "POST" });
    } catch (err) {
      console.error("[auth] logout failed", err);
    } finally {
      setUser(null);
      setAnalysis(null);
      setProfiles([]);
      setProfilesLoaded(false);
      setSelectedAccount("");
      setProfileError("");
    }
  }, []);

  useEffect(() => {
    loadSession();
  }, [loadSession]);

  useEffect(() => {
    if (!user) {
      setProfiles([]);
      setProfilesLoaded(false);
      setAnalysis(null);
      setSelectedAccount("");
      return;
    }
    loadProfiles();
  }, [user, loadProfiles]);

  useEffect(() => {
    if (!analysis) {
      setSelectedAccount("");
      return;
    }
    const suggested =
      analysis?.ai_ranking?.keuze_nummer || analysis?.db_candidates?.[0]?.number || "";
    setSelectedAccount(suggested || "");
  }, [analysis]);

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

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="flex flex-wrap items-center justify-between gap-4 mb-6">
        <h1 className="text-2xl font-bold">🚀 Bookkeeping Dashboard</h1>
        <div className="flex items-center gap-3 text-sm">
          <span className="text-gray-600">Ingelogd als {user.email}</span>
          <button
            onClick={handleLogout}
            className="px-3 py-1.5 rounded bg-gray-200 text-gray-700 hover:bg-gray-300"
            type="button"
          >
            Uitloggen
          </button>
        </div>
      </div>

      <div className="space-y-6 mb-8">
        {profileError && <p className="text-sm text-red-600">{profileError}</p>}
        {!profilesLoaded && !profileError && (
          <p className="text-sm text-gray-600">Profielen laden...</p>
        )}
        <ProfileManager profiles={profiles} onProfilesChange={setProfiles} />
      </div>

      <UploadForm
        onAnalyze={(result) => setAnalysis(result)}
        profiles={profiles}
        profilesLoaded={profilesLoaded}
        onProfilesChange={setProfiles}
        selectedAccount={selectedAccount}
        onSelectAccount={setSelectedAccount}
      />

      {analysis && (
        <div className="mt-8 space-y-6">
          <div className="p-4 bg-white shadow rounded">
            <h2 className="text-lg font-semibold mb-2">📄 Extracted Invoice Text</h2>
            <pre className="text-sm text-gray-700 whitespace-pre-wrap">
              {analysis.invoice_text || "⚠️ No invoice text extracted"}
            </pre>
          </div>

          <BookingDropdown
            analysis={analysis}
            selectedAccount={selectedAccount}
            onAccountChange={setSelectedAccount}
          />
        </div>
      )}
    </div>
  );
}
