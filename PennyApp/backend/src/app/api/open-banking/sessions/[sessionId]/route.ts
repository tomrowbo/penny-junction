import { NextResponse } from "next/server";
import { getConfig } from "@/lib/config";
import { fetchProviderConnection, mockConnection, supportedBanks } from "@/lib/open-banking";

export const runtime = "nodejs";

export async function GET(_request: Request, context: { params: Promise<{ sessionId: string }> }) {
  try {
    const { sessionId } = await context.params;
    const config = getConfig();
    if (sessionId.startsWith("mock:")) {
      if (config.openBankingMode !== "mock") return NextResponse.json({ error: "Mock sessions are disabled." }, { status: 404 });
      const name = decodeURIComponent(sessionId.slice("mock:".length));
      const bank = supportedBanks.find((candidate) => candidate.name === name);
      if (!bank) return NextResponse.json({ error: "Unknown mock bank." }, { status: 404 });
      return NextResponse.json(mockConnection(bank.name));
    }
    if (config.openBankingMode !== "enable-banking") {
      return NextResponse.json({ error: "Live open banking is not configured." }, { status: 503 });
    }
    return NextResponse.json(await fetchProviderConnection(sessionId));
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : "Unable to retrieve bank data." }, { status: 502 });
  }
}
