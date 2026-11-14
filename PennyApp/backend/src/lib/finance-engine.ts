import type { FinancialSnapshot } from "./coach";

export type SpendingBasket = "mandatory_regular" | "mandatory_irregular" | "everyday";

const nonSpending = /invest deposit|invest withdraw|salary sweep|internal transfer|account transfer/i;

export function normalizeTransactionCategory(category: string): string {
  const value = category.trim();
  if (/^(dining|dining out|restaurant|restaurants|cafe|coffee)$/i.test(value)) return "Dining";
  if (/^(transport|transportation|taxi|fuel)$/i.test(value)) return "Transportation";
  if (/^(health|healthcare|medical)$/i.test(value)) return "Healthcare";
  if (/^(income|salary|payroll)$/i.test(value)) return "Salary";
  return value;
}

export function categoryAliases(category: string): string[] {
  switch (normalizeTransactionCategory(category).toLowerCase()) {
    case "dining": return ["dining", "dining out", "restaurant", "restaurants", "cafe", "coffee"];
    case "transportation": return ["transport", "transportation", "taxi", "fuel"];
    case "healthcare": return ["health", "healthcare", "medical"];
    case "salary": return ["income", "salary", "payroll"];
    default: return [category.trim().toLowerCase()];
  }
}

export function isNonSpendingCategory(category: string): boolean {
  return nonSpending.test(category);
}

export function isExpense(amount: number, category: string): boolean {
  return amount < 0 && !isNonSpendingCategory(category);
}

export function isIncome(amount: number, category: string): boolean {
  return amount > 0 && !isNonSpendingCategory(category);
}

const mandatoryRegular = /housing|rent|mortgage|utilities|insurance|childcare|telecom|internet|loan|debt/i;
const mandatoryIrregular = /health|medical|dentist|repair|maintenance|tax|education|appliance|emergency/i;

export function classifyBasket(category: string, merchant: string): SpendingBasket {
  const value = `${category} ${merchant}`;
  if (mandatoryRegular.test(value)) return "mandatory_regular";
  if (mandatoryIrregular.test(value)) return "mandatory_irregular";
  return "everyday";
}

function round(value: number): number {
  return Math.round((value + Number.EPSILON) * 100) / 100;
}

export function analyzeFinances(snapshot: FinancialSnapshot) {
  const validTransactions = snapshot.transactions
    .map((transaction) => ({ ...transaction, parsedDate: new Date(transaction.date) }))
    .filter((transaction) => !Number.isNaN(transaction.parsedDate.getTime()))
    .sort((a, b) => b.parsedDate.getTime() - a.parsedDate.getTime());
  const anchor = validTransactions[0]?.parsedDate ?? new Date();
  const from = new Date(anchor);
  from.setUTCDate(from.getUTCDate() - 89);
  const period = validTransactions.filter((transaction) => transaction.parsedDate >= from && transaction.parsedDate <= anchor);
  const expenses = period.filter((transaction) => isExpense(transaction.amount, transaction.category));
  const incomes = period.filter((transaction) => isIncome(transaction.amount, transaction.category));

  const basketTotals: Record<SpendingBasket, { total: number; count: number }> = {
    mandatory_regular: { total: 0, count: 0 },
    mandatory_irregular: { total: 0, count: 0 },
    everyday: { total: 0, count: 0 },
  };
  const categories = new Map<string, { total: number; count: number }>();
  for (const transaction of expenses) {
    const amount = Math.abs(transaction.amount);
    const basket = classifyBasket(transaction.category, transaction.merchant);
    basketTotals[basket].total += amount;
    basketTotals[basket].count += 1;
    const current = categories.get(transaction.category) ?? { total: 0, count: 0 };
    current.total += amount;
    current.count += 1;
    categories.set(transaction.category, current);
  }

  const totalIncome = incomes.reduce((sum, transaction) => sum + transaction.amount, 0);
  const totalExpenses = expenses.reduce((sum, transaction) => sum + Math.abs(transaction.amount), 0);
  const months = 3;
  const monthlyIncome = totalIncome / months;
  const monthlyExpenses = totalExpenses / months;
  const regularMonthly = basketTotals.mandatory_regular.total / months;
  const irregularMonthly = basketTotals.mandatory_irregular.total / months;
  const everydayMonthly = basketTotals.everyday.total / months;
  const liquidBalance = snapshot.accounts
    .filter((account) => !account.kind.toLowerCase().includes("mortgage") && !account.kind.toLowerCase().includes("loan"))
    .reduce((sum, account) => sum + Math.max(0, account.balance), 0);
  const protectedBalance = regularMonthly + irregularMonthly * 0.5;
  const liquidityBasedWeekly = Math.max(0, liquidBalance - protectedBalance) / 4.345;
  const sustainableWeekly = Math.max(0, monthlyIncome - regularMonthly - irregularMonthly) / 4.345;
  const safeToSpendThisWeek = Math.min(liquidityBasedWeekly, sustainableWeekly);
  const monthlySurplus = monthlyIncome - monthlyExpenses;
  const dining = [...categories.entries()].find(([category]) => /dining|restaurant|coffee|cafe/i.test(category))?.[1].total ?? 0;
  const everydayShare = totalExpenses > 0 ? basketTotals.everyday.total / totalExpenses : 0;

  const basket = (key: SpendingBasket) => ({
    total: round(basketTotals[key].total),
    monthlyAverage: round(basketTotals[key].total / months),
    transactionCount: basketTotals[key].count,
  });

  return {
    coverage: {
      from: from.toISOString().slice(0, 10),
      to: anchor.toISOString().slice(0, 10),
      transactionCount: period.length,
      accountCount: snapshot.accounts.length,
      institutions: [...new Set(snapshot.accounts.map((account) => account.institution))].sort(),
      confidence: period.length >= 60 && incomes.length >= 2 ? "high" : period.length >= 20 ? "medium" : "low",
    },
    baskets: {
      mandatoryRegular: basket("mandatory_regular"),
      mandatoryIrregular: basket("mandatory_irregular"),
      everyday: basket("everyday"),
    },
    cashFlow: {
      liquidBalance: round(liquidBalance),
      monthlyIncome: round(monthlyIncome),
      monthlyExpenses: round(monthlyExpenses),
      monthlySurplus: round(monthlySurplus),
    },
    guidance: {
      safeToSpendThisWeek: round(safeToSpendThisWeek),
      safeToSavePerMonth: round(Math.max(0, monthlySurplus) * 0.8),
      protectedBalance: round(protectedBalance),
    },
    whatIf: {
      reduceDiningOutBy20: {
        currentMonthlyAverage: round(dining / months),
        monthlySaving: round((dining / months) * 0.2),
        annualSaving: round((dining / months) * 0.2 * 12),
      },
    },
    spenderProfile: everydayShare > 0.5 ? "everyday-heavy" : everydayShare < 0.25 ? "essentials-heavy" : "balanced",
    categoryBreakdown: [...categories.entries()]
      .map(([category, value]) => ({ category, total: round(value.total), monthlyAverage: round(value.total / months), transactionCount: value.count }))
      .sort((a, b) => b.total - a.total),
    assumptions: [
      "Estimates use the latest 90 days of available data and convert that period to a monthly average.",
      "Safe-to-spend protects one month of regular mandatory costs plus half a month of irregular mandatory costs.",
      "Basket classification is category-based and should be presented as an explainable estimate.",
    ],
  };
}
