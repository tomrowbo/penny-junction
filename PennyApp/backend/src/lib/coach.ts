import OpenAI from "openai";
import { z } from "zod";
import { getConfig } from "./config";
import { analyzeFinances } from "./finance-engine";
import { redactPII } from "./privacy";
import { existsSync } from "node:fs";
import { ChallengeAnalytics } from "./challenge-analytics";
import { goalPlanInstructions, runCoachWithTools, selectedContextInstructions, type CoachModel, type PennyChatResponse } from "./coach-tools";
import { SBankRepository } from "./sbank-repository";

const accountSchema = z.object({
  id: z.string().max(200),
  institution: z.string().max(100),
  name: z.string().max(200),
  kind: z.string().max(100),
  balance: z.number(),
  maskedNumber: z.string().max(50),
});

const transactionSchema = z.object({
  id: z.string().max(200),
  accountID: z.string().max(200),
  institution: z.string().max(100),
  merchant: z.string().max(200),
  amount: z.number(),
  date: z.string().max(100),
  category: z.string().max(100),
});

export const financialSnapshotSchema = z.object({
  accounts: z.array(accountSchema).max(50),
  transactions: z.array(transactionSchema).max(1_000),
});

const selectedContextSchema = z.object({
  type: z.enum(["transaction", "account", "goal", "upcoming"]),
  // Upcoming recurrence IDs include the series identity and predicted date.
  referenceID: z.string().min(1).max(1_000),
  title: z.string().min(1).max(200),
  subtitle: z.string().max(500),
  accountIDs: z.array(z.string().min(1).max(200)).max(20),
  transactionIDs: z.array(z.string().min(1).max(200)).max(50),
  suggestedPrompts: z.array(z.string().min(1).max(300)).max(2),
}).strict();

const goalPlanSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1).max(200),
  targetAmount: z.number().nonnegative(),
  currentAmount: z.number().nonnegative(),
  targetDate: z.string().max(100),
  monthlyContribution: z.number().nonnegative(),
}).strict();

export const chatRequestSchema = z.object({
  goal: z.string().min(1).max(300),
  messages: z.array(z.object({
    role: z.enum(["user", "assistant"]),
    text: z.string().min(1).max(4000),
  })).min(1).max(30),
  financialData: financialSnapshotSchema,
  selectedContext: selectedContextSchema.optional(),
  goals: z.array(goalPlanSchema).max(50).default([]),
});

export type FinancialSnapshot = z.infer<typeof financialSnapshotSchema>;
type ParsedChatRequest = z.infer<typeof chatRequestSchema>;
export type ChatRequest = Omit<ParsedChatRequest, "goals"> & { goals?: ParsedChatRequest["goals"] };

export function buildFinancialContext(snapshot: FinancialSnapshot): FinancialSnapshot {
  return {
    accounts: snapshot.accounts.slice(0, 20),
    transactions: [...snapshot.transactions]
      .sort((a, b) => b.date.localeCompare(a.date))
      .slice(0, 500),
  };
}

export function buildCoachModelInput(request: ChatRequest) {
  const analysis = analyzeFinances(request.financialData);
  const conversation = request.messages.map((message) => ({
    role: message.role,
    content: redactPII(message.text),
  }));

  return {
    instructions: [
      "You are Penny, a trusted personal financial coach inside S-mobiili.",
      "Reply like a smart, casual friend in a banking app. Lead with the most useful verified number or fact.",
      "Use two to four short sentences, usually under 70 words. Shorthand is welcome when it sounds natural.",
      "Give one clear interpretation and one useful next move. Skip generic preambles and lectures.",
      "Return plain text only, never Markdown. Separate paragraphs with a blank line.",
      "Use only the calculated facts below for numeric claims. Never invent or estimate a number yourself.",
      "Mention data coverage, confidence, or assumptions only when they materially change the advice.",
      "Explain spending using three baskets: mandatory regular, mandatory irregular, and everyday discretionary spending.",
      "For recommendations, explain the trade-off and offer a small achievable next step. Never shame the customer.",
      "Safe-to-spend and safe-to-save are educational estimates, not guarantees or regulated investment advice.",
      "The supplied facts are minimized aggregates. Do not ask for or infer names, account numbers, or other direct identifiers.",
      `Current goal: ${redactPII(request.goal)}`,
      ...goalPlanInstructions(request.goals),
      ...selectedContextInstructions(request.selectedContext),
      `Calculated financial facts (JSON): ${JSON.stringify(analysis)}`,
    ].join("\n"),
    conversation,
  };
}

class OpenAICoachModel implements CoachModel {
  constructor(private readonly client: OpenAI, private readonly model: string) {}

  async respond(input: Parameters<CoachModel["respond"]>[0]) {
    const parameters: Record<string, unknown> = {
      model: this.model,
      reasoning: { effort: "low" },
      instructions: input.instructions,
      input: input.input,
      tools: input.tools,
      parallel_tool_calls: false,
    };
    if (input.previousResponseID) parameters.previous_response_id = input.previousResponseID;
    const response = await this.client.responses.create(parameters as never);
    const calls = response.output
      .filter((item) => item.type === "function_call")
      .map((item) => ({ callID: item.call_id, name: item.name, arguments: item.arguments }));
    return { id: response.id, text: response.output_text, calls };
  }
}

async function fallbackCoach(request: ChatRequest, client: OpenAI, model: string): Promise<PennyChatResponse> {
  const modelInput = buildCoachModelInput(request);
  const response = await client.responses.create({
    model,
    reasoning: { effort: "low" },
    instructions: modelInput.instructions,
    input: modelInput.conversation,
  });
  const message = response.output_text.trim();
  if (!message) throw new Error("The coaching model returned an empty response.");
  const analysis = analyzeFinances(request.financialData);
  return {
    message,
    evidence: {
      coverage: `${analysis.coverage.from}–${analysis.coverage.to}`,
      institutions: analysis.coverage.institutions,
      transactionCount: analysis.coverage.transactionCount,
      confidence: analysis.coverage.confidence as "high" | "medium" | "low",
      assumptions: analysis.assumptions,
      baskets: [
        { id: "mandatory_regular", label: "Mandatory and regular", amount: analysis.baskets.mandatoryRegular.total },
        { id: "mandatory_irregular", label: "Mandatory and irregular", amount: analysis.baskets.mandatoryIrregular.total },
        { id: "everyday", label: "Everyday spending", amount: analysis.baskets.everyday.total },
      ],
    },
    suggestedPrompts: ["Show me my three spending baskets", "What is safe for me to spend this week?"],
    source: "fallback-demo",
  };
}

export async function coach(request: ChatRequest): Promise<PennyChatResponse> {
  const config = getConfig();
  if (!config.openAIKey) throw new Error("OPENAI_API_KEY is not configured.");
  const client = new OpenAI({ apiKey: config.openAIKey });
  if (!config.sBankDemoCustomerID || !existsSync(config.sBankDatabasePath)) {
    return fallbackCoach(request, client, config.openAIModel);
  }
  const repository = SBankRepository.open(config.sBankDatabasePath, config.sBankDemoCustomerID);
  try {
    const analytics = new ChallengeAnalytics(repository, request.financialData);
    return await runCoachWithTools(request, analytics, new OpenAICoachModel(client, config.openAIModel));
  } finally {
    repository.close();
  }
}
