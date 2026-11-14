import { DatabaseSync } from "node:sqlite";
import { categoryAliases } from "./finance-engine";

export type DateRange = { from: string; to: string };
export type RelativePeriod = "this_month" | "last_month" | "last_90_days" | "last_180_days";

type SpendingQuery = DateRange & { category?: string; basket?: string };

function dateOnly(value: string): string {
  return value.slice(0, 10);
}

function isoDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function monthStart(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), 1));
}

export class SBankRepository {
  constructor(private readonly database: DatabaseSync, private readonly customerID: string) {}

  static open(databasePath: string, customerID: string): SBankRepository {
    return new SBankRepository(new DatabaseSync(databasePath, { readOnly: true }), customerID);
  }

  close() {
    this.database.close();
  }

  coverage() {
    const row = this.database.prepare(`
      SELECT MIN(tx_timestamp) AS from_date, MAX(tx_timestamp) AS to_date, COUNT(*) AS transaction_count
      FROM transactions WHERE customer_id = ?
    `).get(this.customerID) as { from_date: string | null; to_date: string | null; transaction_count: number };
    if (!row.to_date || !row.from_date) throw new Error("The configured S-Bank customer has no transaction history.");
    return { from: dateOnly(row.from_date), to: dateOnly(row.to_date), transactionCount: Number(row.transaction_count) };
  }

  resolvePeriod(period: RelativePeriod): DateRange {
    const anchor = new Date(`${this.coverage().to}T12:00:00Z`);
    if (period === "this_month") return { from: isoDate(monthStart(anchor)), to: isoDate(anchor) };
    if (period === "last_month") {
      const start = new Date(Date.UTC(anchor.getUTCFullYear(), anchor.getUTCMonth() - 1, 1));
      const end = new Date(Date.UTC(anchor.getUTCFullYear(), anchor.getUTCMonth(), 0));
      return { from: isoDate(start), to: isoDate(end) };
    }
    const days = period === "last_180_days" ? 179 : 89;
    const from = new Date(anchor);
    from.setUTCDate(from.getUTCDate() - days);
    return { from: isoDate(from), to: isoDate(anchor) };
  }

  spendingSummary(query: SpendingQuery) {
    const filters = ["customer_id = ?", "tx_timestamp >= ?", "tx_timestamp <= ?", "tx_amount_eur < 0", "LOWER(category) NOT IN ('invest deposit', 'invest withdraw', 'salary sweep')"];
    const parameters: Array<string> = [this.customerID, `${query.from}T00:00:00Z`, `${query.to}T23:59:59Z`];
    if (query.category) {
      const aliases = categoryAliases(query.category);
      filters.push(`LOWER(category) IN (${aliases.map(() => "?").join(", ")})`);
      parameters.push(...aliases);
    }
    if (query.basket) {
      filters.push("basket = ?");
      parameters.push(query.basket);
    }
    const row = this.database.prepare(`
      SELECT COALESCE(SUM(ABS(tx_amount_eur)), 0) AS total, COUNT(*) AS transaction_count
      FROM transactions WHERE ${filters.join(" AND ")}
    `).get(...parameters) as { total: number; transaction_count: number };
    return { total: Number(row.total), transactionCount: Number(row.transaction_count), ...query };
  }

  incomeSummary(query: DateRange) {
    const row = this.database.prepare(`
      SELECT COALESCE(SUM(tx_amount_eur), 0) AS total, COUNT(*) AS transaction_count
      FROM transactions
      WHERE customer_id = ? AND tx_timestamp >= ? AND tx_timestamp <= ? AND tx_amount_eur > 0
        AND LOWER(category) NOT IN ('invest deposit', 'invest withdraw', 'salary sweep')
    `).get(this.customerID, `${query.from}T00:00:00Z`, `${query.to}T23:59:59Z`) as { total: number; transaction_count: number };
    return { total: Number(row.total), transactionCount: Number(row.transaction_count), ...query };
  }

  basketProfile(query: DateRange) {
    const rows = this.database.prepare(`
      SELECT COALESCE(basket, 'non_spending') AS basket,
             COALESCE(SUM(CASE WHEN tx_amount_eur < 0 THEN ABS(tx_amount_eur) ELSE 0 END), 0) AS total,
             SUM(CASE WHEN tx_amount_eur < 0 THEN 1 ELSE 0 END) AS transaction_count
      FROM transactions
      WHERE customer_id = ? AND tx_timestamp >= ? AND tx_timestamp <= ? AND tx_amount_eur < 0
        AND LOWER(category) NOT IN ('invest deposit', 'invest withdraw', 'salary sweep')
      GROUP BY COALESCE(basket, 'non_spending')
    `).all(this.customerID, `${query.from}T00:00:00Z`, `${query.to}T23:59:59Z`) as Array<{ basket: string; total: number; transaction_count: number }>;
    return rows.map((row) => ({ basket: row.basket, total: Number(row.total), transactionCount: Number(row.transaction_count) }));
  }

  categoryBreakdown(query: DateRange) {
    return (this.database.prepare(`
      SELECT category, COALESCE(basket, 'unclassified') AS basket,
             SUM(ABS(tx_amount_eur)) AS total, COUNT(*) AS transaction_count
      FROM transactions
      WHERE customer_id = ? AND tx_timestamp >= ? AND tx_timestamp <= ? AND tx_amount_eur < 0
        AND LOWER(category) NOT IN ('invest deposit', 'invest withdraw', 'salary sweep')
      GROUP BY category, basket ORDER BY total DESC
    `).all(this.customerID, `${query.from}T00:00:00Z`, `${query.to}T23:59:59Z`) as Array<Record<string, unknown>>)
      .map((row) => ({ category: String(row.category), basket: String(row.basket), total: Number(row.total), transactionCount: Number(row.transaction_count) }));
  }

  categoryInventory() {
    return (this.database.prepare(`
      SELECT DISTINCT category FROM transactions
      WHERE customer_id = ? AND LOWER(category) NOT IN ('invest deposit', 'invest withdraw', 'salary sweep')
      ORDER BY category
    `).all(this.customerID) as Array<{ category: string }>).map((row) => row.category);
  }

  hasCategory(category: string) {
    const aliases = categoryAliases(category);
    const row = this.database.prepare(`
      SELECT COUNT(*) AS count FROM transactions
      WHERE customer_id = ? AND LOWER(category) IN (${aliases.map(() => "?").join(", ")})
    `).get(this.customerID, ...aliases) as { count: number };
    return Number(row.count) > 0;
  }

  latestLiquidBalance() {
    const row = this.database.prepare(`
      WITH ranked AS (
        SELECT bank_account_id, balance_after_eur,
               ROW_NUMBER() OVER (PARTITION BY bank_account_id ORDER BY tx_timestamp DESC, id DESC) AS rank
        FROM transactions WHERE customer_id = ? AND balance_after_eur IS NOT NULL
      )
      SELECT COALESCE(SUM(MAX(balance_after_eur, 0)), 0) AS balance FROM ranked WHERE rank = 1
    `).get(this.customerID) as { balance: number };
    return Number(row.balance);
  }

  customerSummary() {
    const fullCoverage = this.coverage();
    const range = this.resolvePeriod("last_180_days");
    const accounts = (this.database.prepare(`
      WITH ranked AS (
        SELECT bank_account_id, balance_after_eur,
               ROW_NUMBER() OVER (PARTITION BY bank_account_id ORDER BY tx_timestamp DESC, id DESC) AS rank
        FROM transactions WHERE customer_id = ?
      )
      SELECT bank_account_id, balance_after_eur FROM ranked WHERE rank = 1 ORDER BY bank_account_id
    `).all(this.customerID) as Array<{ bank_account_id: string; balance_after_eur: number }>).map((row) => ({
      id: row.bank_account_id,
      institution: "S-Bank",
      name: "S-Tili",
      kind: "Everyday account",
      balance: Number(row.balance_after_eur),
      maskedNumber: `•• ${row.bank_account_id.slice(-4)}`,
    }));
    const transactions = (this.database.prepare(`
      SELECT id, bank_account_id, category, tx_amount_eur, tx_timestamp, merchant_id
      FROM transactions
      WHERE customer_id = ? AND tx_timestamp >= ? AND tx_timestamp <= ?
      ORDER BY tx_timestamp DESC, id DESC
    `).all(this.customerID, `${range.from}T00:00:00Z`, `${range.to}T23:59:59Z`) as Array<Record<string, unknown>>).map((row) => ({
      id: `sbank-${row.id}`,
      accountID: String(row.bank_account_id),
      institution: "S-Bank",
      merchant: String(row.merchant_id || row.category),
      amount: Number(row.tx_amount_eur),
      date: String(row.tx_timestamp),
      category: String(row.category),
    }));
    const coverage = transactions.length > 0 ? {
      from: dateOnly(transactions[transactions.length - 1].date),
      to: dateOnly(transactions[0].date),
      transactionCount: transactions.length,
    } : { from: range.from, to: range.to, transactionCount: 0 };
    return { source: "official-synthetic-dataset", anchorDate: fullCoverage.to, coverage, accounts, transactions };
  }

  mortgageSummary() {
    const row = this.database.prepare(`
      SELECT final_decision, rejection_reason, final_property_price_eur,
             final_requested_loan_eur, final_equity_amount_eur,
             final_collateral_value_eur, required_monthly_income_eur, final_loan_to_value
      FROM mortgages WHERE customer_id = ? LIMIT 1
    `).get(this.customerID) as Record<string, unknown> | undefined;
    if (!row) return null;
    return {
      decision: row.final_decision ? String(row.final_decision) : null,
      rejectionReason: row.rejection_reason ? String(row.rejection_reason) : null,
      propertyPrice: Number(row.final_property_price_eur || 0),
      requestedLoan: Number(row.final_requested_loan_eur || 0),
      equity: Number(row.final_equity_amount_eur || 0),
      collateralValue: Number(row.final_collateral_value_eur || 0),
      requiredMonthlyIncome: Number(row.required_monthly_income_eur || 0),
      loanToValue: Number(row.final_loan_to_value || 0),
    };
  }
}
