import { NextResponse } from "next/server";
import { getConfig } from "@/lib/config";

export const runtime = "nodejs";

export function GET() {
  try {
    const config = getConfig();
    return NextResponse.json({
      ok: true,
      openBanking: {
        mode: config.openBankingMode,
        configured: config.openBankingMode === "mock" || Boolean(config.enableBankingAppID),
      },
      ai: {
        configured: Boolean(config.openAIKey),
        model: config.openAIModel,
      },
    });
  } catch (error) {
    return NextResponse.json({ ok: false, error: error instanceof Error ? error.message : "Invalid server configuration." }, { status: 500 });
  }
}
