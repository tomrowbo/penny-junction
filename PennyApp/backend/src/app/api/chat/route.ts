import { NextResponse } from "next/server";
import { z } from "zod";
import { chatRequestSchema, coach } from "@/lib/coach";

export const runtime = "nodejs";

export async function POST(request: Request) {
  try {
    const input = chatRequestSchema.parse(await request.json());
    return NextResponse.json(await coach(input));
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({ error: "Invalid coaching request.", details: error.issues }, { status: 400 });
    }
    const isConfigurationError = error instanceof Error && error.message.includes("OPENAI_API_KEY");
    console.error("Penny chat request failed", error instanceof Error ? error.name : "UnknownError");
    return NextResponse.json(
      { error: isConfigurationError ? "Penny AI is not configured." : "Penny could not answer right now. Please try again." },
      { status: isConfigurationError ? 503 : 502 },
    );
  }
}
