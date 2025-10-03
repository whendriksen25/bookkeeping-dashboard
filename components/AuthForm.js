import { useState } from "react";

export default function AuthForm({ onSuccess }) {
  const [mode, setMode] = useState("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [status, setStatus] = useState("");

  const handleModeChange = (nextMode) => {
    setMode(nextMode);
    setError("");
    setStatus("");
  };

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setStatus("");
    setLoading(true);

    try {
      const endpoint =
        mode === "login" ? "login" : mode === "register" ? "register" : "reset-password";
      const resp = await fetch(`/api/auth/${endpoint}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });
      const data = await resp.json();
      if (!resp.ok) {
        throw new Error(data?.error || "Er is iets misgegaan");
      }
      if (typeof onSuccess === "function") {
        onSuccess(data.user);
      }
    } catch (err) {
      setError(err.message || "Actie mislukt");
    } finally {
      setLoading(false);
    }
  }

  const heading =
    mode === "login" ? "Log in" : mode === "register" ? "Maak een account" : "Reset wachtwoord";
  const passwordLabel = mode === "reset" ? "Nieuw wachtwoord" : "Wachtwoord";
  const submitText =
    mode === "login" ? "Inloggen" : mode === "register" ? "Registreren" : "Reset wachtwoord";

  return (
    <div className="max-w-md mx-auto bg-white shadow rounded p-6 space-y-4">
      <h1 className="text-2xl font-semibold text-center">{heading}</h1>
      {mode === "reset" && (
        <p className="text-sm text-gray-600 text-center">
          Voer je emailadres en een nieuw wachtwoord in. Na het resetten ben je direct ingelogd.
        </p>
      )}
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-1" htmlFor="auth-email">
            Email
          </label>
          <input
            id="auth-email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="w-full border rounded px-3 py-2"
            placeholder="jij@example.com"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1" htmlFor="auth-password">
            {passwordLabel}
          </label>
          <input
            id="auth-password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            className="w-full border rounded px-3 py-2"
            placeholder="••••••••"
          />
        </div>
        {error && <p className="text-sm text-red-600">{error}</p>}
        {status && <p className="text-sm text-green-600">{status}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full bg-blue-600 text-white rounded py-2 font-medium disabled:opacity-50"
        >
          {loading ? "Bezig..." : submitText}
        </button>
      </form>
      <div className="text-sm text-center text-gray-600 space-y-2">
        {mode === "login" && (
          <>
            <div>
              Nog geen account?{" "}
              <button
                type="button"
                onClick={() => handleModeChange("register")}
                className="text-blue-600 hover:underline"
              >
                Registreer
              </button>
            </div>
            <div>
              Wachtwoord vergeten?{" "}
              <button
                type="button"
                onClick={() => handleModeChange("reset")}
                className="text-blue-600 hover:underline"
              >
                Reset wachtwoord
              </button>
            </div>
          </>
        )}
        {mode === "register" && (
          <div>
            Heb je al een account?{" "}
            <button
              type="button"
              onClick={() => handleModeChange("login")}
              className="text-blue-600 hover:underline"
            >
              Log in
            </button>
          </div>
        )}
        {mode === "reset" && (
          <div>
            Wachtwoord onthouden?{" "}
            <button
              type="button"
              onClick={() => handleModeChange("login")}
              className="text-blue-600 hover:underline"
            >
              Terug naar inloggen
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
