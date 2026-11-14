import { NextResponse } from "next/server";
import { z } from "zod";
import { getConfig } from "@/lib/config";
import { createState } from "@/lib/state";
import { enableBankingRequest, supportedBanks } from "@/lib/open-banking";

export const runtime = "nodejs";

const requestSchema = z.object({
  name: z.enum(["Nordea", "OP", "Danske Bank"]),
  country: z.literal("FI").default("FI"),
});

export async function POST(request: Request) {
  try {
    const bank = requestSchema.parse(await request.json());
    if (!supportedBanks.some((candidate) => candidate.name === bank.name)) {
      return NextResponse.json({ error: "Unsupported bank." }, { status: 400 });
    }
    const config = getConfig();
    if (config.openBankingMode === "mock") {
      return NextResponse.json({ mode: "complete", sessionId: `mock:${bank.name}` });
    }
    const state = createState({ bank: bank.name, country: bank.country }, config.stateSigningSecret);
    const authorization = await enableBankingRequest("/auth", {
      method: "POST",
      body: JSON.stringify({
        access: { valid_until: new Date(Date.now() + 89 * 24 * 60 * 60 * 1000).toISOString() },
        aspsp: bank,
        state,
        redirect_url: `${config.publicBaseURL}/api/open-banking/callback`,
        psu_type: "personal",
        language: "en",
      }),
    });
    const url = typeof authorization.url === "string" ? authorization.url : undefined;
    if (!url) throw new Error("Enable Banking did not return an authorization URL.");
    return NextResponse.json({ mode: "redirect", url });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({ error: "Invalid bank connection request." }, { status: 400 });
    }
    return NextResponse.json({ error: error instanceof Error ? error.message : "Unable to start authorization." }, { status: 502 });
  }
}
