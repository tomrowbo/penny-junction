import { existsSync } from "node:fs";
import { NextResponse } from "next/server";
import { getConfig } from "@/lib/config";
import { SBankRepository } from "@/lib/sbank-repository";

export const runtime = "nodejs";

export async function GET() {
  try {
    const config = getConfig();
    if (!existsSync(config.sBankDatabasePath) || !config.sBankDemoCustomerID) {
      return NextResponse.json({ error: "Official S-Bank demo data is not configured." }, { status: 503 });
    }
    const repository = SBankRepository.open(config.sBankDatabasePath, config.sBankDemoCustomerID);
    try {
      return NextResponse.json(repository.customerSummary());
    } finally {
      repository.close();
    }
  } catch (error) {
    console.error("S-Bank customer summary failed", error instanceof Error ? error.name : "UnknownError");
    return NextResponse.json({ error: "Official S-Bank demo data is unavailable." }, { status: 503 });
  }
}
