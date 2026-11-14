import type { FinancialSnapshot } from "./coach";
import { categoryAliases, classifyBasket, isExpense, isIncome, normalizeTransactionCategory } from "./finance-engine";
import type { DateRange } from "./sbank-repository";
import { SBankRepository } from "./sbank-repository";

type SummaryQuery = DateRange & { category?: string; basket?: string; institutions?: string[] };
type SimulationQuery = SummaryQuery & { percentage: number };

function round(value: number): number {
  return Math.round((value + Number.EPSILON) * 100) / 100;
}

function inside(date: string, range: DateRange): boolean {
  const day = date.slice(0, 10);
  return day >= range.from && day <= range.to;
}

function daysInclusive(range: DateRange): number {
  return Math.max(1, Math.round((new Date(`${range.to}T12:00:00Z`).getTime() - new Date(`${range.from}T12:00:00Z`).getTime()) / 86_400_000) + 1);
}

function fullCalendarMonth(range: DateRange): boolean {
  const start = new Date(`${range.from}T12:00:00Z`);
  const end = new Date(`${range.to}T12:00:00Z`);
  return start.getUTCDate() === 1
    && end.getUTCFullYear() === start.getUTCFullYear()
    && end.getUTCMonth() === start.getUTCMonth()
    && end.getUTCDate() === new Date(Date.UTC(end.getUTCFullYear(), end.getUTCMonth() + 1, 0)).getUTCDate();
}

export class ChallengeAnalytics {
  constructor(private readonly repository: SBankRepository, private readonly connected: FinancialSnapshot) {}

  private externalInstitutions() {
    return [...new Set(this.connected.accounts.filter((account) => account.institution !== "S-Bank").map((account) => account.institution))].sort();
  }

  private validateCategory(category: string | undefined) {
    if (!category) return;
    const aliases = new Set(categoryAliases(category));
    const externalMatch = this.connected.transactions.some((transaction) => aliases.has(transaction.category.trim().toLowerCase()));
    if (!this.repository.hasCategory(category) && !externalMatch) {
      throw new Error(`Unknown category “${category}”. Use category_breakdown to see available categories.`);
    }
  }

  private connectedExpenses(query: SummaryQuery) {
    return this.connected.transactions.filter((transaction) => {
      if (transaction.institution === "S-Bank" || !isExpense(transaction.amount, transaction.category) || !inside(transaction.date, query)) return false;
      if (query.institutions && !query.institutions.includes(transaction.institution)) return false;
      if (query.category && normalizeTransactionCategory(transaction.category).toLowerCase() !== normalizeTransactionCategory(query.category).toLowerCase()) return false;
      if (query.basket && classifyBasket(transaction.category, transaction.merchant) !== query.basket) return false;
      return true;
    });
  }

  private connectedIncome(range: DateRange) {
    return this.connected.transactions.filter((transaction) => transaction.institution !== "S-Bank" && isIncome(transaction.amount, transaction.category) && inside(transaction.date, range));
  }

  spendingSummary(query: SummaryQuery) {
    this.validateCategory(query.category);
    const bank = query.institutions && !query.institutions.includes("S-Bank")
      ? { total: 0, transactionCount: 0 }
      : this.repository.spendingSummary(query);
    const external = this.connectedExpenses(query);
    const total = bank.total + external.reduce((sum, transaction) => sum + Math.abs(transaction.amount), 0);
    return {
      total: round(total),
      transactionCount: bank.transactionCount + external.length,
      from: query.from,
      to: query.to,
      category: query.category,
      basket: query.basket,
      institutions: [
        ...(query.institutions && !query.institutions.includes("S-Bank") ? [] : ["S-Bank"]),
        ...new Set(external.map((transaction) => transaction.institution)),
      ].sort(),
    };
  }

  compareSpending(current: SummaryQuery, previous: SummaryQuery) {
    const currentResult = this.spendingSummary(current);
    const previousResult = this.spendingSummary({ ...previous, category: current.category, basket: current.basket });
    const change = currentResult.total - previousResult.total;
    return {
      current: currentResult,
      previous: previousResult,
      change: round(change),
      changePercentage: previousResult.total > 0 ? round((change / previousResult.total) * 100) : null,
    };
  }

  basketProfile(range: SummaryQuery) {
    const totals = new Map<string, { total: number; transactionCount: number }>();
    if (!range.institutions || range.institutions.includes("S-Bank")) {
      for (const row of this.repository.basketProfile(range)) totals.set(row.basket, { total: row.total, transactionCount: row.transactionCount });
    }
    for (const transaction of this.connectedExpenses(range)) {
      const basket = classifyBasket(transaction.category, transaction.merchant);
      const current = totals.get(basket) ?? { total: 0, transactionCount: 0 };
      current.total += Math.abs(transaction.amount);
      current.transactionCount += 1;
      totals.set(basket, current);
    }
    return [...totals.entries()].map(([basket, value]) => ({ basket, total: round(value.total), transactionCount: value.transactionCount }));
  }

  categoryBreakdown(range: SummaryQuery) {
    const totals = new Map<string, { category: string; basket: string; total: number; transactionCount: number }>();
    if (!range.institutions || range.institutions.includes("S-Bank")) {
      for (const row of this.repository.categoryBreakdown(range)) {
        const key = normalizeTransactionCategory(row.category).toLowerCase();
        totals.set(key, { ...row, total: row.total, transactionCount: row.transactionCount });
      }
    }
    for (const transaction of this.connectedExpenses(range)) {
      const category = normalizeTransactionCategory(transaction.category);
      const key = category.toLowerCase();
      const current = totals.get(key) ?? { category, basket: classifyBasket(category, transaction.merchant), total: 0, transactionCount: 0 };
      current.total += Math.abs(transaction.amount);
      current.transactionCount += 1;
      totals.set(key, current);
    }
    return [...totals.values()].map((row) => ({ ...row, total: round(row.total) })).sort((a, b) => b.total - a.total);
  }

  simulateReduction(query: SimulationQuery) {
    if (query.percentage < 1 || query.percentage > 100) throw new Error("Reduction percentage must be between 1 and 100.");
    if (!query.category && !query.basket) throw new Error("A category or basket is required for a simulation.");
    const summary = this.spendingSummary(query);
    const periodSaving = summary.total * query.percentage / 100;
    const monthlyFactor = fullCalendarMonth(query) ? 1 : 30.4375 / daysInclusive(query);
    const monthlySaving = periodSaving * monthlyFactor;
    return {
      ...summary,
      percentage: query.percentage,
      currentPeriodAmount: summary.total,
      periodSaving: round(periodSaving),
      monthlySaving: round(monthlySaving),
      annualSaving: round(monthlySaving * 12),
      assumptions: ["Projected savings require the spending reduction to continue."],
    };
  }

  safeGuidance(horizonDays = 7) {
    if (!Number.isInteger(horizonDays) || horizonDays < 1 || horizonDays > 31) throw new Error("Safe-to-spend horizon must be 1–31 days.");
    const range90 = this.repository.resolvePeriod("last_90_days");
    const range180 = this.repository.resolvePeriod("last_180_days");
    const incomeBank = this.repository.incomeSummary(range90);
    const externalIncome = this.connectedIncome(range90);
    const monthlyIncome = (incomeBank.total + externalIncome.reduce((sum, transaction) => sum + transaction.amount, 0)) / 3;
    const monthlyExpenses = this.spendingSummary(range90).total / 3;
    const regularMonthly = this.spendingSummary({ ...range90, basket: "mandatory_regular" }).total / 3;
    const irregularMonthly = this.spendingSummary({ ...range180, basket: "mandatory_irregular" }).total / 6;
    const liquidBalance = this.repository.latestLiquidBalance()
      + this.connected.accounts.filter((account) => account.institution !== "S-Bank").reduce((sum, account) => sum + Math.max(0, account.balance), 0);
    const protectedBalance = regularMonthly + irregularMonthly;
    const availableCash = Math.max(0, liquidBalance - protectedBalance);
    const sustainableDaily = Math.max(0, monthlyIncome - regularMonthly - irregularMonthly) / 30.4375;
    const safeToSpend = Math.min(availableCash, sustainableDaily * horizonDays);
    const monthlySurplus = monthlyIncome - monthlyExpenses;
    const safeToSave = Math.min(availableCash, Math.max(0, monthlySurplus) * 0.8);
    const profile = this.basketProfile(range90);
    const classifiedTotal = profile.reduce((sum, item) => sum + item.total, 0);
    const unclassified = profile.find((item) => item.basket === "unclassified")?.total ?? 0;
    const coverage = this.repository.coverage();
    const coverageDays = daysInclusive({ from: coverage.from, to: coverage.to });
    const incomeEvents = incomeBank.transactionCount + externalIncome.length;
    const unclassifiedShare = classifiedTotal > 0 ? unclassified / classifiedTotal : 0;
    const externalTransactions = this.connected.transactions.filter((transaction) => transaction.institution !== "S-Bank" && inside(transaction.date, range180));
    const hasExternalWithoutCoverage = this.externalInstitutions().length > 0 && externalTransactions.length === 0;
    const confidence = !hasExternalWithoutCoverage && coverageDays >= 90 && incomeEvents >= 2 && unclassifiedShare < 0.1
      ? "high"
      : coverageDays >= 60 && incomeEvents >= 1 ? "medium" : "low";
    return {
      safeToSpend: round(safeToSpend),
      horizonDays,
      safeToSavePerMonth: round(safeToSave),
      protectedBalance: round(protectedBalance),
      monthlyIncome: round(monthlyIncome),
      monthlyExpenses: round(monthlyExpenses),
      confidence,
      coverage: range180,
      institutions: ["S-Bank", ...this.externalInstitutions()].sort(),
      transactionCount: this.spendingSummary(range180).transactionCount,
      baskets: profile.filter((item) => ["mandatory_regular", "mandatory_irregular", "everyday"].includes(item.basket)),
      assumptions: [
        "Income, total spending and regular essentials use the latest 90 days of available data.",
        "The irregular-cost reserve uses the latest 180-day monthly average.",
        "Safe-to-save retains 20% of observed monthly surplus as an uncertainty buffer.",
        ...(unclassified > 0 ? [`€${round(unclassified)} of spending was unclassified and reduced confidence.`] : []),
        ...(hasExternalWithoutCoverage ? ["Connected-bank commitments were outside the analysis window, so combined guidance is provisional."] : []),
      ],
    };
  }

  dataCoverage() {
    const coverage = this.repository.coverage();
    return {
      ...coverage,
      institutions: ["S-Bank", ...this.externalInstitutions()].sort(),
      source: "official-synthetic-dataset",
      categories: this.repository.categoryInventory(),
    };
  }

  mortgageSummary() {
    return this.repository.mortgageSummary();
  }
}
