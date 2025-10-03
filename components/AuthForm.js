import { useState } from "react";

export default function AuthForm({ onSuccess }) {
  const [mode, setMode] = useState("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const toggleMode = () => {
    setMode((prev) => (prev === "login" ? "register" : "login"));
    setError("");
  };

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const resp = await fetch(`/api/auth/${mode === "login" ? "login" : "register"}`, {
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

  return (
    <div className="max-w-md mx-auto bg-white shadow rounded p-6 space-y-4">
      <h1 className="text-2xl font-semibold text-center">
        {mode === "login" ? "Log in" : "Maak een account"}
      </h1>
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
            Wachtwoord
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
        <button
          type="submit"
          disabled={loading}
          className="w-full bg-blue-600 text-white rounded py-2 font-medium disabled:opacity-50"
        >
          {loading ? "Bezig..." : mode === "login" ? "Inloggen" : "Registreren"}
        </button>
      </form>
      <p className="text-sm text-center text-gray-600">
        {mode === "login" ? "Nog geen account?" : "Heb je al een account?"}{" "}
        <button onClick={toggleMode} className="text-blue-600 hover:underline">
          {mode === "login" ? "Registreer" : "Log in"}
        </button>
      </p>
    </div>
  );
}
