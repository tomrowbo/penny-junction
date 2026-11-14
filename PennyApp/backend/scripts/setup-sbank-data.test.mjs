import { afterEach, describe, expect, it } from "vitest";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { DatabaseSync } from "node:sqlite";
import { basketFor, downloadURLFor, importSBankData, normalizeTimestamp } from "./setup-sbank-data.mjs";

const temporaryDirectories = [];

afterEach(() => {
  for (const directory of temporaryDirectories.splice(0)) {
    rmSync(directory, { recursive: true, force: true });
  }
});

function fixtureDirectory() {
  const directory = mkdtempSync(join(tmpdir(), "penny-data-"));
  temporaryDirectories.push(directory);
  writeFileSync(join(directory, "tx_customers_junction.csv"), "\ufeffcustomer_id,customer_postal_code,customer_age\nCUST1,00100,30\nCUST2,00200,44\n");
  writeFileSync(join(directory, "tx_junction_transactions.csv"), [
    "\ufeffcustomer_id,bank_account_id,tx_date,tx_timestamp,category,tx_amount_eur,balance_after_eur,transaction_type,merchant_id,mcc_code",
    "CUST1,A1,2026-10-01,2026-10-01T08:00:00Z,Housing,-900,2100,debit,M1,6513",
    "CUST1,A1,2026-10-02,2026-10-02T08:00:00Z,Salary,3000,5100,credit,M2,0000",
    "CUST1,A1,2026-10-03,2026-10-03T08:00:00Z,Mystery,-20,5080,debit,M3,9999",
    "CUST2,B1,2026-10-01,2026-10-01T08:00:00Z,Groceries,-40,800,debit,M4,5411",
    "",
  ].join("\n"));
  writeFileSync(join(directory, "mtg_negotiation_history.csv"), "\ufeffmortgage_customer_id,event_timestamp,event_type\nMORT1,2026-09-01T08:00:00Z,application\n");
  writeFileSync(join(directory, "mtg_tx_customer_link_and_final_mtg_infio.csv"), "\ufeffmortgage_customer_id,customer_id,final_outcome\nMORT1,CUST1,approved\n");
  return directory;
}

describe("official S-Bank dataset import", () => {
  it("normalizes the official SAS timestamps before date comparisons", () => {
    expect(normalizeTimestamp("31OCT25:23:59:58")).toBe("2025-10-31T23:59:58Z");
    expect(normalizeTimestamp("01APR25:19:25:48")).toBe("2025-04-01T19:25:48Z");
  });

  it("uses the LFS media endpoint only for the large transaction file", () => {
    expect(downloadURLFor("tx_junction_transactions.csv")).toContain("media.githubusercontent.com/media/");
    expect(downloadURLFor("tx_customers_junction.csv")).toContain("raw.githubusercontent.com/");
  });

  it("maps the official challenge categories into pedagogical baskets", () => {
    expect(basketFor("Health", -40, "debit")).toBe("mandatory_irregular");
    expect(basketFor("Home & Tech", -400, "debit")).toBe("mandatory_irregular");
    expect(basketFor("Restaurants", -20, "debit")).toBe("everyday");
    expect(basketFor("Transportation", -15, "debit")).toBe("everyday");
    expect(basketFor("Invest Deposit", -500, "debit")).toBe(null);
    expect(basketFor("Salary Sweep", -500, "debit")).toBe(null);
  });

  it("imports BOM-prefixed CSVs and derives indexed basket data", async () => {
    const sourceDirectory = fixtureDirectory();
    const databasePath = join(sourceDirectory, "penny.sqlite");

    const result = await importSBankData({ sourceDirectory, databasePath });

    expect(result).toMatchObject({ customers: 2, transactions: 4 });
    const database = new DatabaseSync(databasePath, { readOnly: true });
    expect(database.prepare("SELECT customer_id FROM customers ORDER BY customer_id").all()).toEqual([
      { customer_id: "CUST1" },
      { customer_id: "CUST2" },
    ]);
    expect(database.prepare("SELECT category, basket FROM transactions WHERE customer_id = 'CUST1' ORDER BY tx_timestamp").all()).toEqual([
      { category: "Housing", basket: "mandatory_regular" },
      { category: "Salary", basket: null },
      { category: "Mystery", basket: "unclassified" },
    ]);
    const indexes = database.prepare("SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = 'transactions'").all().map((row) => row.name);
    expect(indexes).toEqual(expect.arrayContaining([
      "idx_transactions_customer_time",
      "idx_transactions_customer_category_time",
      "idx_transactions_customer_basket_time",
    ]));
    expect(database.prepare("SELECT value FROM dataset_metadata WHERE key = 'anchor_date'").get()).toEqual({ value: "2026-10-03T08:00:00Z" });
    database.close();
  });

  it("is idempotent when the same official files are imported twice", async () => {
    const sourceDirectory = fixtureDirectory();
    const databasePath = join(sourceDirectory, "penny.sqlite");

    await importSBankData({ sourceDirectory, databasePath });
    await importSBankData({ sourceDirectory, databasePath });

    const database = new DatabaseSync(databasePath, { readOnly: true });
    expect(database.prepare("SELECT COUNT(*) AS count FROM transactions").get()).toEqual({ count: 4 });
    database.close();
  });
});
