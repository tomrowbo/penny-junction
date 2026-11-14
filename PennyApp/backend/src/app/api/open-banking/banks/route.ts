import { NextResponse } from "next/server";
import { getConfig } from "@/lib/config";
import { enableBankingRequest, supportedBanks } from "@/lib/open-banking";

export const runtime = "nodejs";

export async function GET() {
  try {
    const config = getConfig();
    if (config.openBankingMode === "mock") return NextResponse.json(supportedBanks);
    const response = await enableBankingRequest("/aspsps?country=FI");
    const availableNames = new Set(
      (Array.isArray(response.aspsps) ? response.aspsps : [])
        .map((value) => value && typeof value === "object" ? String((value as Record<string, unknown>).name ?? "") : "")
    );
    return NextResponse.json(supportedBanks.filter((bank) => availableNames.has(bank.name)));
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : "Unable to load banks." }, { status: 502 });
  }
}
