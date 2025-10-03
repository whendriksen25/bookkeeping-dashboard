// pages/index.js
import { useEffect, useState } from "react";
import UploadForm from "../components/UploadForm";
import BookingDropdown from "../components/BookingDropdown";
import ProfileManager from "../components/ProfileManager";

export default function Home() {
  const [analysis, setAnalysis] = useState(null);
  const [profiles, setProfiles] = useState([]);
  const [profilesLoaded, setProfilesLoaded] = useState(false);
  const [selectedAccount, setSelectedAccount] = useState("");

  useEffect(() => {
    async function loadProfiles() {
      try {
        const resp = await fetch("/api/profiles");
        if (resp.ok) {
          const data = await resp.json();
          setProfiles(Array.isArray(data.profiles) ? data.profiles : []);
        }
      } catch (err) {
        console.error("[profiles] initial load failed", err);
      } finally {
        setProfilesLoaded(true);
      }
    }
    loadProfiles();
  }, []);

  useEffect(() => {
    if (!analysis) {
      setSelectedAccount("");
      return;
    }
    const suggested =
      analysis?.ai_ranking?.keuze_nummer || analysis?.db_candidates?.[0]?.number || "";
    setSelectedAccount(suggested || "");
  }, [analysis]);

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <h1 className="text-2xl font-bold mb-6">🚀 Bookkeeping Dashboard</h1>

      <div className="space-y-6 mb-8">
        <ProfileManager profiles={profiles} onProfilesChange={setProfiles} />
      </div>

      {/* Upload form */}
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
          {/* 1. Show extracted invoice text */}
          <div className="p-4 bg-white shadow rounded">
            <h2 className="text-lg font-semibold mb-2">📄 Extracted Invoice Text</h2>
            <pre className="text-sm text-gray-700 whitespace-pre-wrap">
              {analysis.invoice_text || "⚠️ No invoice text extracted"}
            </pre>
          </div>

          {/* 2. Show booking dropdown */}
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
