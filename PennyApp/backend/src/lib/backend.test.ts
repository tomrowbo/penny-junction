import { describe, expect, it } from "vitest";
import { createState, verifyState } from "./state";
import { mockConnection, normalizeProviderConnection } from "./open-banking";
import { buildCoachModelInput, buildFinancialContext } from "./coach";
import { analyzeFinances, classifyBasket } from "./finance-engine";
import { redactPII } from "./privacy";
import { DatabaseSync } from "node:sqlite";
import { SBankRepository } from "./sbank-repository";
import { ChallengeAnalytics } from "./challenge-analytics";
import { runCoachWithTools, type CoachModel } from "./coach-tools";

describe("signed open-banking state", () => {
  it("round-trips a state and rejects tampering", () => {
    const token = createState({ bank: "Nordea", country: "FI" }, "a-secret-long-enough-for-tests");
    expect(verifyState(token, "a-secret-long-enough-for-tests")).toMatchObject({ bank: "Nordea", country: "FI" });
    expect(() => verifyState(`${token}x`, "a-secret-long-enough-for-tests")).toThrow();
  });
});

describe("open-banking normalization", () => {
  it("returns deterministic account and transaction data in mock mode", () => {
    const connection = mockConnection("Nordea");
    expect(connection.institution).toBe("Nordea");
    expect(connection.accounts.some((account) => account.kind === "mortgage")).toBe(true);
    expect(connection.transactions.length).toBeGreaterThan(0);
    expect(connection.transactions.every((transaction) => transaction.date.slice(0, 10) <= "2026-09-30")).toBe(true);
    expect(connection.transactions.filter((transaction) => transaction.category === "Housing")).toHaveLength(3);
  });

  it("normalizes representative Enable Banking payloads", () => {
    const connection = normalizeProviderConnection("OP", [{
      uid: "account-1",
      details: { name: "Everyday", account_id: { iban: "FI1234567890123456" }, cash_account_type: "CACC" },
      balances: { balances: [{ balance_amount: { amount: "1250.25", currency: "EUR" } }] },
      transactions: { transactions: [{
        entry_reference: "tx-1",
        booking_date: "2026-11-10",
        transaction_amount: { amount: "12.40", currency: "EUR" },
        credit_debit_indicator: "DBIT",
        creditor: { name: "Cafe Helsinki" },
        remittance_information: ["Coffee"],
      }] },
    }]);
    expect(connection.accounts[0]).toMatchObject({ id: "account-1", institution: "OP", balance: 1250.25, maskedNumber: "•• 3456" });
    expect(connection.transactions[0]).toMatchObject({ id: "account-1:tx-1", merchant: "Cafe Helsinki", amount: -12.4 });
  });

  it("skips provider transactions with invalid dates", () => {
    const connection = normalizeProviderConnection("OP", [{
      uid: "account-1",
      details: { name: "Everyday" },
      balances: { balances: [] },
      transactions: { transactions: [{ booking_date: "unknown", transaction_amount: { amount: "5" } }] },
    }]);
    expect(connection.transactions).toEqual([]);
  });
});

describe("AI context", () => {
  it("caps transaction history", () => {
    const context = buildFinancialContext({
      accounts: [],
      transactions: Array.from({ length: 600 }, (_, index) => ({
        id: `tx-${index}`,
        accountID: "account",
        institution: "S-Bank",
        merchant: "Prisma",
        amount: -10,
        date: "2026-11-10T10:00:00Z",
        category: "Groceries",
      })),
    });
    expect(context.transactions).toHaveLength(500);
    expect(context.transactions[0].merchant).toBe("Prisma");
  });

  it("sends aggregates and redacted text, not raw banking records, to the model", () => {
    const modelInput = buildCoachModelInput({
      goal: "Help alex@example.com save",
      messages: [{ role: "user", text: "Review FI2112345600000785 please" }],
      financialData: {
        accounts: [{ id: "secret-account-id", institution: "S-Bank", name: "Alex's account", kind: "Everyday", balance: 1_000, maskedNumber: "•• 0785" }],
        transactions: [{ id: "secret-transaction-id", accountID: "secret-account-id", institution: "S-Bank", merchant: "Private Merchant", amount: -20, date: "2026-11-10T10:00:00Z", category: "Dining out" }],
      },
    });
    const serialized = JSON.stringify(modelInput);
    expect(serialized).toContain("Calculated financial facts");
    expect(serialized).toContain("plain text only");
    expect(serialized).toContain("blank line");
    expect(serialized).not.toContain("alex@example.com");
    expect(serialized).not.toContain("FI2112345600000785");
    expect(serialized).not.toContain("secret-account-id");
    expect(serialized).not.toContain("secret-transaction-id");
    expect(serialized).not.toContain("Private Merchant");
    expect(serialized).not.toContain("•• 0785");
  });
});

describe("personal economic trainer", () => {
  it("classifies S-Bank's three pedagogical baskets", () => {
    expect(classifyBasket("Housing", "Rent")).toBe("mandatory_regular");
    expect(classifyBasket("Healthcare", "Dentist")).toBe("mandatory_irregular");
    expect(classifyBasket("Dining out", "Coffee shop")).toBe("everyday");
  });

  it("calculates grounded coaching facts from a 90-day window", () => {
    const analysis = analyzeFinances({
      accounts: [
        { id: "current", institution: "S-Bank", name: "S-Tili", kind: "Everyday account", balance: 4_000, maskedNumber: "•• 1234" },
        { id: "mortgage", institution: "Nordea", name: "Mortgage", kind: "Mortgage", balance: -180_000, maskedNumber: "•• 5678" },
      ],
      transactions: [
        { id: "income", accountID: "current", institution: "S-Bank", merchant: "Salary", amount: 9_000, date: "2026-11-10T12:00:00Z", category: "Salary" },
        { id: "rent", accountID: "current", institution: "S-Bank", merchant: "Rent", amount: -3_000, date: "2026-11-09T12:00:00Z", category: "Housing" },
        { id: "dentist", accountID: "current", institution: "S-Bank", merchant: "Dentist", amount: -300, date: "2026-10-20T12:00:00Z", category: "Healthcare" },
        { id: "dining", accountID: "current", institution: "S-Bank", merchant: "Restaurants", amount: -600, date: "2026-10-15T12:00:00Z", category: "Dining out" },
      ],
    });
    expect(analysis.coverage.transactionCount).toBe(4);
    expect(analysis.baskets.mandatoryRegular.total).toBe(3_000);
    expect(analysis.baskets.mandatoryIrregular.total).toBe(300);
    expect(analysis.baskets.everyday.total).toBe(600);
    expect(analysis.whatIf.reduceDiningOutBy20.monthlySaving).toBe(40);
    expect(analysis.guidance.safeToSpendThisWeek).toBeGreaterThan(0);
    expect(analysis.guidance.safeToSavePerMonth).toBeGreaterThan(0);
  });

  it("redacts direct identifiers before model use", () => {
    const redacted = redactPII("Email me at alex@example.com about FI2112345600000785 or +358 40 123 4567");
    expect(redacted).not.toContain("alex@example.com");
    expect(redacted).not.toContain("FI2112345600000785");
    expect(redacted).not.toContain("358 40 123 4567");
  });

  it("preserves explicit ISO date ranges while redacting phone numbers", () => {
    const redacted = redactPII("From 2026-08-01 to 2026-08-31, call +358 40 123 4567");
    expect(redacted).toContain("2026-08-01");
    expect(redacted).toContain("2026-08-31");
    expect(redacted).not.toContain("358 40 123 4567");
  });
});

describe("official S-Bank repository", () => {
  function repositoryFixture() {
    const database = new DatabaseSync(":memory:");
    database.exec(`
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY, customer_id TEXT, bank_account_id TEXT, tx_date TEXT,
        tx_timestamp TEXT, category TEXT, basket TEXT, tx_amount_eur REAL,
        balance_after_eur REAL, transaction_type TEXT, merchant_id TEXT, mcc_code TEXT
      );
      CREATE TABLE mortgages (
        mortgage_customer_id TEXT, customer_id TEXT, final_decision TEXT,
        rejection_reason TEXT, final_property_price_eur REAL, final_requested_loan_eur REAL,
        final_equity_amount_eur REAL, final_collateral_value_eur REAL,
        required_monthly_income_eur REAL, final_loan_to_value REAL, payload_json TEXT
      );
      INSERT INTO transactions VALUES
        (1, 'CUST1', 'A1', '2025-08-10', '2025-08-10T10:00:00Z', 'Healthcare', 'mandatory_irregular', -600, 3500, 'debit', 'DENTIST', '8021'),
        (2, 'CUST1', 'A1', '2025-10-01', '2025-10-01T10:00:00Z', 'Salary', NULL, 3000, 6500, 'credit', 'EMPLOYER', '0000'),
        (3, 'CUST1', 'A1', '2025-10-05', '2025-10-05T10:00:00Z', 'Housing', 'mandatory_regular', -900, 5600, 'debit', 'LANDLORD', '6513'),
        (4, 'CUST1', 'A1', '2025-11-01', '2025-11-01T10:00:00Z', 'Salary', NULL, 3000, 8600, 'credit', 'EMPLOYER', '0000'),
        (5, 'CUST1', 'A1', '2025-11-05', '2025-11-05T10:00:00Z', 'Housing', 'mandatory_regular', -900, 7700, 'debit', 'LANDLORD', '6513'),
        (6, 'CUST1', 'A1', '2025-12-01', '2025-12-01T10:00:00Z', 'Salary', NULL, 3000, 10700, 'credit', 'EMPLOYER', '0000'),
        (7, 'CUST1', 'A1', '2025-12-05', '2025-12-05T10:00:00Z', 'Housing', 'mandatory_regular', -900, 9800, 'debit', 'LANDLORD', '6513'),
        (8, 'CUST1', 'A1', '2025-12-12', '2025-12-12T10:00:00Z', 'Dining', 'everyday', -150, 9650, 'debit', 'CAFE', '5812'),
        (9, 'CUST1', 'A1', '2026-01-05', '2026-01-05T10:00:00Z', 'Groceries', 'everyday', -80, 3020, 'debit', 'SHOP', '5411'),
        (10, 'CUST1', 'A1', '2026-01-20', '2026-01-20T10:00:00Z', 'Dining', 'everyday', -40, 2980, 'debit', 'CAFE', '5812'),
        (11, 'CUST2', 'B1', '2026-01-21', '2026-01-21T10:00:00Z', 'Dining', 'everyday', -999, 1, 'debit', 'PRIVATE', '5812'),
        (12, 'CUST1', 'A1', '2026-01-15', '2026-01-15T10:00:00Z', 'Invest Deposit', NULL, -1000, 2020, 'transfer', 'INVEST', '0000'),
        (13, 'CUST1', 'A1', '2026-01-16', '2026-01-16T10:00:00Z', 'Invest Withdraw', NULL, 500, 2520, 'transfer', 'INVEST', '0000');
      INSERT INTO mortgages VALUES ('M1', 'CUST1', 'approved', NULL, 200000, 170000, 30000, 150000, 3500, 0.85, '{}');
    `);
    return { database, repository: new SBankRepository(database, "CUST1") };
  }

  it("enforces constructor-bound customer scope across aggregates", () => {
    const { database, repository } = repositoryFixture();
    expect(repository.spendingSummary({ from: "2026-01-01", to: "2026-01-31", category: "Dining" })).toMatchObject({ total: 40, transactionCount: 1 });
    expect(JSON.stringify(repository.customerSummary())).not.toContain("CUST2");
    expect(JSON.stringify(repository.customerSummary())).not.toContain("PRIVATE");
    database.close();
  });

  it("anchors relative months to the customer's latest transaction", () => {
    const { database, repository } = repositoryFixture();
    expect(repository.resolvePeriod("this_month")).toEqual({ from: "2026-01-01", to: "2026-01-20" });
    expect(repository.resolvePeriod("last_month")).toEqual({ from: "2025-12-01", to: "2025-12-31" });
    expect(repository.coverage()).toMatchObject({ from: "2025-08-10", to: "2026-01-20", transactionCount: 12 });
    database.close();
  });

  it("excludes investment movements from spending and income", () => {
    const { database, repository } = repositoryFixture();
    expect(repository.spendingSummary({ from: "2026-01-01", to: "2026-01-31" })).toMatchObject({ total: 120, transactionCount: 2 });
    expect(repository.incomeSummary({ from: "2026-01-01", to: "2026-01-31" })).toMatchObject({ total: 0, transactionCount: 0 });
    database.close();
  });

  it("normalizes category aliases and exposes bounded category discovery", () => {
    const { database, repository } = repositoryFixture();
    const analytics = new ChallengeAnalytics(repository, { accounts: [], transactions: [] });
    expect(analytics.spendingSummary({ from: "2026-01-01", to: "2026-01-31", category: "Restaurants" })).toMatchObject({ total: 40, transactionCount: 1 });
    expect(analytics.categoryBreakdown({ from: "2026-01-01", to: "2026-01-31" }).find((row) => row.category === "Dining")).toMatchObject({ category: "Dining", total: 40 });
    expect(() => analytics.spendingSummary({ from: "2026-01-01", to: "2026-01-31", category: "Spaceships" })).toThrow(/Unknown category/);
    database.close();
  });

  it("calculates generic what-if and safe guidance from deterministic history", () => {
    const { database, repository } = repositoryFixture();
    const analytics = new ChallengeAnalytics(repository, { accounts: [], transactions: [] });
    expect(analytics.simulateReduction({ from: "2025-12-01", to: "2025-12-31", category: "Dining", percentage: 20 })).toMatchObject({
      currentPeriodAmount: 150,
      periodSaving: 30,
      monthlySaving: 30,
      annualSaving: 360,
    });
    const safe = analytics.safeGuidance(7);
    expect(safe.safeToSpend).toBeGreaterThan(0);
    expect(safe.safeToSavePerMonth).toBeGreaterThan(0);
    expect(safe.confidence).toBe("high");
    expect(safe.assumptions.join(" ")).toContain("90 days");
    database.close();
  });

  it("merges request-scoped connected-bank spending without exposing raw rows", () => {
    const { database, repository } = repositoryFixture();
    const analytics = new ChallengeAnalytics(repository, {
      accounts: [{ id: "external", institution: "Nordea", name: "Current", kind: "Everyday", balance: 500, maskedNumber: "•• 9999" }],
      transactions: [{ id: "external-tx", accountID: "external", institution: "Nordea", merchant: "Cafe", amount: -25, date: "2026-01-10T12:00:00Z", category: "Dining" }],
    });
    expect(analytics.spendingSummary({ from: "2026-01-01", to: "2026-01-31", category: "Dining" })).toMatchObject({
      total: 65,
      transactionCount: 2,
      institutions: ["Nordea", "S-Bank"],
    });
    database.close();
  });

  it("does not double-count S-Bank rows also present in the mobile snapshot", () => {
    const { database, repository } = repositoryFixture();
    const analytics = new ChallengeAnalytics(repository, {
      accounts: [{ id: "mobile-sbank", institution: "S-Bank", name: "S-Tili", kind: "Everyday", balance: 99999, maskedNumber: "•• 0000" }],
      transactions: [{ id: "mobile-copy", accountID: "mobile-sbank", institution: "S-Bank", merchant: "Copy", amount: -40, date: "2026-01-20T10:00:00Z", category: "Dining" }],
    });
    expect(analytics.spendingSummary({ from: "2026-01-01", to: "2026-01-31", category: "Dining" })).toMatchObject({ total: 40, transactionCount: 1 });
    expect(analytics.safeGuidance(7).institutions).toEqual(["S-Bank"]);
    database.close();
  });

  it("executes bounded tools and returns backend-owned evidence without raw records", async () => {
    const { database, repository } = repositoryFixture();
    const turns: unknown[] = [];
    const model: CoachModel = {
      async respond(input) {
        turns.push(input);
        if (turns.length === 1) {
          return { id: "response-1", text: "", calls: [{ callID: "call-1", name: "safe_to_spend", arguments: "{\"horizonDays\":7}" }] };
        }
        return { id: "response-2", text: "You can spend about €300 this week while protecting essential costs.", calls: [] };
      },
    };
    const reply = await runCoachWithTools({
      goal: "Help alex@example.com save",
      messages: [{ role: "user", text: "Check FI2112345600000785 and tell me what is safe" }],
      financialData: {
        accounts: [{ id: "secret-account", institution: "Nordea", name: "Private account", kind: "Everyday", balance: 500, maskedNumber: "•• 0785" }],
        transactions: [{ id: "secret-row", accountID: "secret-account", institution: "Nordea", merchant: "Private Cafe", amount: -25, date: "2026-01-10T12:00:00Z", category: "Dining" }],
      },
    }, new ChallengeAnalytics(repository, {
      accounts: [{ id: "secret-account", institution: "Nordea", name: "Private account", kind: "Everyday", balance: 500, maskedNumber: "•• 0785" }],
      transactions: [{ id: "secret-row", accountID: "secret-account", institution: "Nordea", merchant: "Private Cafe", amount: -25, date: "2026-01-10T12:00:00Z", category: "Dining" }],
    }), model);
    expect(reply.message).toContain("spend");
    expect(reply.evidence).toMatchObject({ confidence: "high", institutions: ["Nordea", "S-Bank"] });
    expect(reply.suggestedPrompts.length).toBeGreaterThan(0);
    const serializedTurns = JSON.stringify(turns);
    expect(serializedTurns).not.toContain("alex@example.com");
    expect(serializedTurns).not.toContain("FI2112345600000785");
    expect(serializedTurns).not.toContain("secret-account");
    expect(serializedTurns).not.toContain("secret-row");
    expect(serializedTurns).not.toContain("Private Cafe");
    database.close();
  });

  it("returns recoverable tool errors for impossible or reversed dates", async () => {
    const { database, repository } = repositoryFixture();
    const observedInputs: unknown[] = [];
    const model: CoachModel = {
      async respond(input) {
        observedInputs.push(input.input);
        if (observedInputs.length === 1) {
          return { id: "bad-date", text: "", calls: [{ callID: "bad", name: "spending_summary", arguments: '{"from":"2026-99-99","to":"2026-01-01"}' }] };
        }
        return { id: "clarified", text: "Please choose a valid date range.", calls: [] };
      },
    };
    const reply = await runCoachWithTools({
      goal: "Explore spending",
      messages: [{ role: "user", text: "Use the bad dates" }],
      financialData: { accounts: [], transactions: [] },
    }, new ChallengeAnalytics(repository, { accounts: [], transactions: [] }), model);
    expect(reply.message).toContain("valid date range");
    expect(JSON.stringify(observedInputs[1])).toContain("Invalid");
    database.close();
  });

  it("returns matching latest balances, recent transactions and mortgage data", () => {
    const { database, repository } = repositoryFixture();
    const summary = repository.customerSummary();
    expect(summary.accounts[0]).toMatchObject({ id: "A1", institution: "S-Bank", balance: 2980 });
    expect(summary.transactions[0]).toMatchObject({ category: "Dining", amount: -40 });
    expect(repository.mortgageSummary()).toMatchObject({ decision: "approved", requestedLoan: 170000, loanToValue: 0.85 });
    database.close();
  });
});
