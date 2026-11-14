import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { randomUUID, sign } from "node:crypto";

const port = Number(process.env.PORT ?? 8787);
const apiBase = "https://api.enablebanking.com";
const appId = process.env.ENABLEBANKING_APP_ID;
const privateKeyPath = process.env.ENABLEBANKING_PRIVATE_KEY_PATH;
const publicBaseURL = process.env.PUBLIC_BASE_URL ?? `http://localhost:${port}`;
const pendingStates = new Map();

const demoBanks = [
  { name: "Nordea", country: "FI" },
  { name: "OP", country: "FI" },
  { name: "Danske Bank", country: "FI" }
];

function json(response, status, body) {
  response.writeHead(status, {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  });
  response.end(JSON.stringify(body));
}

async function readJSON(request) {
  const chunks = [];
  for await (const chunk of request) chunks.push(chunk);
  return JSON.parse(Buffer.concat(chunks).toString("utf8") || "{}");
}

function encode(value) {
  return Buffer.from(JSON.stringify(value)).toString("base64url");
}

async function jwt() {
  if (!appId || !privateKeyPath) {
    throw new Error("Set ENABLEBANKING_APP_ID and ENABLEBANKING_PRIVATE_KEY_PATH for live sandbox mode.");
  }
  const now = Math.floor(Date.now() / 1000);
  const header = encode({ typ: "JWT", alg: "RS256", kid: appId });
  const payload = encode({ iss: "enablebanking.com", aud: "api.enablebanking.com", iat: now, exp: now + 3600 });
  const unsigned = `${header}.${payload}`;
  const privateKey = await readFile(privateKeyPath, "utf8");
  const signature = sign("RSA-SHA256", Buffer.from(unsigned), privateKey).toString("base64url");
  return `${unsigned}.${signature}`;
}

async function enableBanking(path, options = {}) {
  const token = await jwt();
  const response = await fetch(`${apiBase}${path}`, {
    ...options,
    headers: {
      Accept: "application/json",
      Authorization: `Bearer ${token}`,
      ...(options.body ? { "Content-Type": "application/json" } : {}),
      ...options.headers
    }
  });
  const text = await response.text();
  const body = text ? JSON.parse(text) : {};
  if (!response.ok) {
    throw new Error(body.detail ?? body.message ?? `Enable Banking returned ${response.status}`);
  }
  return body;
}

async function fetchAccount(uid) {
  const [details, balances, transactions] = await Promise.all([
    enableBanking(`/accounts/${uid}/details`),
    enableBanking(`/accounts/${uid}/balances`),
    enableBanking(`/accounts/${uid}/transactions`)
  ]);
  return { uid, details, balances, transactions };
}

const server = createServer(async (request, response) => {
  try {
    const url = new URL(request.url, publicBaseURL);

    if (request.method === "GET" && url.pathname === "/health") {
      return json(response, 200, { ok: true, liveConfigured: Boolean(appId && privateKeyPath) });
    }

    if (request.method === "GET" && url.pathname === "/api/banks") {
      if (!appId || !privateKeyPath) return json(response, 200, demoBanks);
      const data = await enableBanking("/aspsps?country=FI");
      const supported = new Set(demoBanks.map((bank) => bank.name));
      return json(response, 200, data.aspsps.filter((bank) => supported.has(bank.name)));
    }

    if (request.method === "POST" && url.pathname === "/api/connect") {
      const bank = await readJSON(request);
      const state = randomUUID();
      pendingStates.set(state, { bank, createdAt: Date.now() });
      const auth = await enableBanking("/auth", {
        method: "POST",
        body: JSON.stringify({
          access: { valid_until: new Date(Date.now() + 90 * 86400000).toISOString() },
          aspsp: { name: bank.name, country: "FI" },
          state,
          redirect_url: `${publicBaseURL}/api/callback`,
          psu_type: "personal",
          language: "en"
        })
      });
      return json(response, 200, { url: auth.url, state });
    }

    if (request.method === "GET" && url.pathname === "/api/callback") {
      const code = url.searchParams.get("code");
      const state = url.searchParams.get("state");
      if (!code || !state || !pendingStates.has(state)) return json(response, 400, { error: "Invalid callback state" });
      pendingStates.delete(state);
      const session = await enableBanking("/sessions", {
        method: "POST",
        body: JSON.stringify({ code })
      });
      response.writeHead(302, { Location: `penny://open-banking?session_id=${encodeURIComponent(session.session_id)}` });
      return response.end();
    }

    if (request.method === "GET" && url.pathname.startsWith("/api/sessions/")) {
      const sessionId = url.pathname.split("/").pop();
      const session = await enableBanking(`/sessions/${sessionId}`);
      const accounts = await Promise.all((session.accounts ?? []).map(fetchAccount));
      return json(response, 200, { session, accounts });
    }

    return json(response, 404, { error: "Not found" });
  } catch (error) {
    return json(response, 500, { error: error.message });
  }
});

server.listen(port, () => {
  console.log(`Penny open-banking adapter listening on http://localhost:${port}`);
});

