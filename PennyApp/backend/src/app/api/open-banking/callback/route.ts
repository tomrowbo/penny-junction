import { NextResponse } from "next/server";
import { getConfig } from "@/lib/config";
import { enableBankingRequest } from "@/lib/open-banking";
import { verifyState } from "@/lib/state";

export const runtime = "nodejs";

const consumedNonces = new Map<string, number>();

function appRedirect(parameters: Record<string, string>): NextResponse {
  const url = new URL("penny://open-banking");
  for (const [key, value] of Object.entries(parameters)) url.searchParams.set(key, value);
  return NextResponse.redirect(url);
}

export async function GET(request: Request) {
  try {
    const url = new URL(request.url);
    const code = url.searchParams.get("code");
    const stateToken = url.searchParams.get("state");
    if (!code || !stateToken) return appRedirect({ error: "The bank did not return a valid authorization." });
    const config = getConfig();
    const state = verifyState(stateToken, config.stateSigningSecret);
    const now = Date.now();
    for (const [nonce, expires] of consumedNonces) if (expires < now) consumedNonces.delete(nonce);
    if (consumedNonces.has(state.nonce)) return appRedirect({ error: "This bank authorization has already been used." });
    consumedNonces.set(state.nonce, state.exp * 1000);
    const session = await enableBankingRequest("/sessions", {
      method: "POST",
      body: JSON.stringify({ code }),
    });
    const sessionID = typeof session.session_id === "string" ? session.session_id : undefined;
    if (!sessionID) throw new Error("Enable Banking did not return a session ID.");
    return appRedirect({ session_id: sessionID });
  } catch (error) {
    return appRedirect({ error: error instanceof Error ? error.message : "Unable to finish bank authorization." });
  }
}
