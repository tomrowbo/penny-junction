import { readFileSync } from "node:fs";
import { resolve } from "node:path";

export type OpenBankingMode = "mock" | "enable-banking";

export type ServerConfig = {
  openBankingMode: OpenBankingMode;
  publicBaseURL: string;
  stateSigningSecret: string;
  enableBankingAppID?: string;
  enableBankingPrivateKey?: string;
  enableBankingPrivateKeyPath?: string;
  openAIKey?: string;
  openAIModel: string;
  sBankDatabasePath: string;
  sBankDemoCustomerID?: string;
};

function readOpenAIKeyFromEnvFile(path: string | undefined): string | undefined {
  if (!path) return undefined;
  try {
    const line = readFileSync(path, "utf8")
      .split(/\r?\n/)
      .find((candidate) => candidate.startsWith("OPENAI_API_KEY="));
    if (!line) return undefined;
    const value = line.slice("OPENAI_API_KEY=".length).trim();
    return value.replace(/^(["'])(.*)\1$/, "$2") || undefined;
  } catch {
    return undefined;
  }
}

export function getConfig(): ServerConfig {
  const openBankingMode = process.env.OPEN_BANKING_MODE === "enable-banking"
    ? "enable-banking"
    : "mock";

  const config: ServerConfig = {
    openBankingMode,
    publicBaseURL: (process.env.PUBLIC_BASE_URL ?? "http://localhost:3000").replace(/\/$/, ""),
    stateSigningSecret: process.env.STATE_SIGNING_SECRET ?? "penny-local-mock-state-secret",
    enableBankingAppID: process.env.ENABLEBANKING_APP_ID,
    enableBankingPrivateKey: process.env.ENABLEBANKING_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    enableBankingPrivateKeyPath: process.env.ENABLEBANKING_PRIVATE_KEY_PATH,
    openAIKey: process.env.OPENAI_API_KEY || readOpenAIKeyFromEnvFile(process.env.OPENAI_ENV_FILE),
    openAIModel: process.env.OPENAI_MODEL ?? "gpt-6-luna",
    sBankDatabasePath: resolve(
      /* turbopackIgnore: true */ process.env.SBANK_DATABASE_PATH ?? "./data/penny.sqlite",
    ),
    sBankDemoCustomerID: process.env.SBANK_DEMO_CUSTOMER_ID || "CUST03948",
  };

  if (openBankingMode === "enable-banking") {
    if (!config.enableBankingAppID || (!config.enableBankingPrivateKey && !config.enableBankingPrivateKeyPath)) {
      throw new Error("Live open banking requires ENABLEBANKING_APP_ID and an Enable Banking private key.");
    }
    if (!process.env.STATE_SIGNING_SECRET || process.env.STATE_SIGNING_SECRET.length < 32) {
      throw new Error("Live open banking requires STATE_SIGNING_SECRET with at least 32 characters.");
    }
    if (!config.publicBaseURL.startsWith("https://")) {
      throw new Error("Live open banking requires an HTTPS PUBLIC_BASE_URL.");
    }
  }

  return config;
}
