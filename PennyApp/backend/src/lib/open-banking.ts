import { createHash, createSign } from "node:crypto";
import { readFile } from "node:fs/promises";
import { getConfig } from "./config";
import type { Bank, BankConnection, ProviderAccountPayload } from "./open-banking-types";

const API_BASE = "https://api.enablebanking.com";

export const supportedBanks: Bank[] = [
  { name: "Nordea", country: "FI", description: "Personal accounts and mortgages" },
  { name: "OP", country: "FI", description: "Accounts, loans and cards" },
  { name: "Danske Bank", country: "FI", description: "Personal banking" },
];

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : {};
}

function asArray(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

function text(value: unknown): string | undefined {
  return typeof value === "string" && value.trim() ? value.trim() : undefined;
}

function numeric(value: unknown): number {
  const parsed = typeof value === "number" ? value : Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function nested(record: Record<string, unknown>, ...keys: string[]): unknown {
  let value: unknown = record;
  for (const key of keys) value = asRecord(value)[key];
  return value;
}

function accountNumber(details: Record<string, unknown>): string {
  const accountID = asRecord(details.account_id);
  return text(accountID.iban)
    ?? text(accountID.identification)
    ?? text(asRecord(details.account_number).iban)
    ?? text(details.iban)
    ?? "";
}

function accountKind(details: Record<string, unknown>): "current" | "savings" | "mortgage" {
  const label = [details.name, details.product, details.cash_account_type, details.account_type]
    .map((value) => text(value)?.toLowerCase() ?? "")
    .join(" ");
  if (label.includes("mortgage") || label.includes("loan") || label.includes("lending")) return "mortgage";
  if (label.includes("saving") || label.includes("deposit")) return "savings";
  return "current";
}

function transactionCategory(merchant: string, note: string): string {
  const value = `${merchant} ${note}`.toLowerCase();
  if (/prisma|market|grocery|lidl|k-market|supermarket/.test(value)) return "Groceries";
  if (/mortgage|rent|housing/.test(value)) return "Housing";
  if (/taxi|uber|neste|fuel|hsl|transport/.test(value)) return "Transport";
  if (/restaurant|cafe|coffee|foodora|wolt/.test(value)) return "Dining out";
  if (/salary|payroll/.test(value)) return "Income";
  return "Other";
}

export function normalizeProviderConnection(
  institution: Bank["name"],
  payloads: ProviderAccountPayload[],
): BankConnection {
  const accounts = payloads.map(({ uid, details, balances }) => {
    const balanceResources = asArray(balances.balances).map(asRecord);
    const preferredBalance = balanceResources.find((item) => item.balance_type === "CLAV") ?? balanceResources[0] ?? {};
    const balance = numeric(nested(preferredBalance, "balance_amount", "amount"));
    const number = accountNumber(details);
    return {
      id: uid,
      institution,
      name: text(details.name) ?? text(details.product) ?? "Bank account",
      kind: accountKind(details),
      balance,
      maskedNumber: number ? `•• ${number.slice(-4)}` : "••••",
    };
  });

  const transactions = payloads.flatMap(({ uid, transactions }) =>
    asArray(transactions.transactions).map(asRecord).map((transaction) => {
      const creditor = asRecord(transaction.creditor);
      const debtor = asRecord(transaction.debtor);
      const notes = asArray(transaction.remittance_information).map(text).filter(Boolean).join(" ")
        || text(transaction.note)
        || "";
      const merchant = text(creditor.name) ?? text(debtor.name) ?? (notes || "Bank transaction");
      const dateValue = text(transaction.booking_date) ?? text(transaction.value_date);
      const parsedDate = dateValue ? new Date(dateValue) : new Date(Number.NaN);
      if (Number.isNaN(parsedDate.getTime())) return null;
      const rawAmount = numeric(nested(transaction, "transaction_amount", "amount"));
      const direction = text(transaction.credit_debit_indicator)?.toUpperCase();
      const amount = direction === "DBIT" ? -Math.abs(rawAmount) : direction === "CRDT" ? Math.abs(rawAmount) : rawAmount;
      const entryReference = text(transaction.entry_reference) ?? text(transaction.transaction_id);
      const stableFallback = createHash("sha256")
        .update([uid, parsedDate.toISOString(), amount, merchant, notes].join("|"))
        .digest("hex")
        .slice(0, 24);
      return {
        id: entryReference ? `${uid}:${entryReference}` : `${uid}:${stableFallback}`,
        accountID: uid,
        institution,
        merchant,
        amount,
        date: parsedDate.toISOString(),
        category: transactionCategory(merchant, notes),
      };
    }).filter((transaction): transaction is NonNullable<typeof transaction> => transaction !== null)
  ).sort((a, b) => b.date.localeCompare(a.date));

  return { institution, accounts, transactions };
}

export function mockConnection(institution: Bank["name"]): BankConnection {
  const slug = institution.toLowerCase().replaceAll(" ", "-");
  return {
    institution,
    accounts: [
      { id: `${slug}-current`, institution, name: "Current account", kind: "current", balance: 1640.5, maskedNumber: "•• 7714" },
      { id: `${slug}-mortgage`, institution, name: "Home mortgage", kind: "mortgage", balance: -186450, maskedNumber: "•• 2048" },
    ],
    transactions: [
      { id: `${slug}-fuel`, accountID: `${slug}-current`, institution, merchant: "Neste Helsinki", amount: -74.3, date: "2026-09-21T12:00:00.000Z", category: "Transportation" },
      { id: `${slug}-mortgage-payment-sep`, accountID: `${slug}-current`, institution, merchant: "Mortgage payment", amount: -1120, date: "2026-09-07T12:00:00.000Z", category: "Housing" },
      { id: `${slug}-mortgage-payment-aug`, accountID: `${slug}-current`, institution, merchant: "Mortgage payment", amount: -1120, date: "2026-08-07T12:00:00.000Z", category: "Housing" },
      { id: `${slug}-mortgage-payment-jul`, accountID: `${slug}-current`, institution, merchant: "Mortgage payment", amount: -1120, date: "2026-07-07T12:00:00.000Z", category: "Housing" },
    ],
  };
}

function encodeJSON(value: unknown): string {
  return Buffer.from(JSON.stringify(value)).toString("base64url");
}

async function privateKey(): Promise<string> {
  const config = getConfig();
  if (config.enableBankingPrivateKey) return config.enableBankingPrivateKey;
  if (config.enableBankingPrivateKeyPath) return readFile(config.enableBankingPrivateKeyPath, "utf8");
  throw new Error("Enable Banking private key is missing.");
}

async function providerJWT(): Promise<string> {
  const config = getConfig();
  const now = Math.floor(Date.now() / 1000);
  const header = encodeJSON({ typ: "JWT", alg: "RS256", kid: config.enableBankingAppID });
  const payload = encodeJSON({ iss: "enablebanking.com", aud: "api.enablebanking.com", iat: now, exp: now + 5 * 60 });
  const unsigned = `${header}.${payload}`;
  const signer = createSign("RSA-SHA256");
  signer.update(unsigned);
  signer.end();
  return `${unsigned}.${signer.sign(await privateKey()).toString("base64url")}`;
}

export async function enableBankingRequest(path: string, init: RequestInit = {}): Promise<Record<string, unknown>> {
  const response = await fetch(`${API_BASE}${path}`, {
    ...init,
    headers: {
      Accept: "application/json",
      Authorization: `Bearer ${await providerJWT()}`,
      ...(init.body ? { "Content-Type": "application/json" } : {}),
      ...init.headers,
    },
    cache: "no-store",
  });
  const body = await response.json().catch(() => ({})) as Record<string, unknown>;
  if (!response.ok) {
    throw new Error(text(body.detail) ?? text(body.message) ?? `Enable Banking returned ${response.status}.`);
  }
  return body;
}

export async function fetchProviderConnection(sessionID: string): Promise<BankConnection> {
  const session = await enableBankingRequest(`/sessions/${encodeURIComponent(sessionID)}`);
  const institution = text(asRecord(session.aspsp).name);
  const bank = supportedBanks.find((item) => item.name === institution);
  if (!bank) throw new Error(`Unsupported bank returned by provider: ${institution ?? "unknown"}.`);
  const accountIDs = asArray(session.accounts).map(text).filter((value): value is string => Boolean(value));
  const payloads = await Promise.all(accountIDs.map(async (uid): Promise<ProviderAccountPayload> => {
    const [details, balances, transactions] = await Promise.all([
      enableBankingRequest(`/accounts/${encodeURIComponent(uid)}/details`),
      enableBankingRequest(`/accounts/${encodeURIComponent(uid)}/balances`),
      fetchTransactions(uid),
    ]);
    return { uid, details, balances, transactions };
  }));
  return normalizeProviderConnection(bank.name, payloads);
}

async function fetchTransactions(accountID: string): Promise<Record<string, unknown>> {
  const transactions: unknown[] = [];
  let continuationKey: string | undefined;
  for (let page = 0; page < 50; page += 1) {
    const query = continuationKey ? `?continuation_key=${encodeURIComponent(continuationKey)}` : "";
    const response = await enableBankingRequest(`/accounts/${encodeURIComponent(accountID)}/transactions${query}`);
    transactions.push(...asArray(response.transactions));
    continuationKey = text(response.continuation_key);
    if (!continuationKey) break;
  }
  return { transactions };
}
