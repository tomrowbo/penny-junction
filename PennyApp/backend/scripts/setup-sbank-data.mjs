import { createReadStream, createWriteStream, existsSync, mkdirSync, readFileSync, rmSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { Readable } from "node:stream";
import { pipeline } from "node:stream/promises";
import { DatabaseSync } from "node:sqlite";
import { parse } from "csv-parse";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const backendDirectory = resolve(scriptDirectory, "..");
const mapping = JSON.parse(readFileSync(join(backendDirectory, "src/data/basket-mapping.json"), "utf8"));

const requiredFiles = [
  "tx_junction_transactions.csv",
  "tx_customers_junction.csv",
  "mtg_negotiation_history.csv",
  "mtg_tx_customer_link_and_final_mtg_infio.csv",
];

const lfsDownloadBase = "https://media.githubusercontent.com/media/hackjunction/Junction-2026-S-pankki/main";
const rawDownloadBase = "https://raw.githubusercontent.com/hackjunction/Junction-2026-S-pankki/main";

export function downloadURLFor(file) {
  const base = file === "tx_junction_transactions.csv" ? lfsDownloadBase : rawDownloadBase;
  return `${base}/${file}`;
}

function normalized(value) {
  return String(value ?? "").trim().toLowerCase();
}

const monthNumbers = {
  JAN: "01", FEB: "02", MAR: "03", APR: "04", MAY: "05", JUN: "06",
  JUL: "07", AUG: "08", SEP: "09", OCT: "10", NOV: "11", DEC: "12",
};

export function normalizeTimestamp(value) {
  const text = String(value ?? "").trim();
  const match = /^(\d{2})([A-Z]{3})(\d{2})(?::(\d{2}):(\d{2}):(\d{2}))?$/i.exec(text);
  if (match) {
    const [, day, monthName, shortYear, hour = "00", minute = "00", second = "00"] = match;
    const month = monthNumbers[monthName.toUpperCase()];
    if (!month) throw new Error(`Unknown dataset month: ${monthName}`);
    return `20${shortYear}-${month}-${day}T${hour}:${minute}:${second}Z`;
  }
  const parsed = new Date(text);
  if (Number.isNaN(parsed.getTime())) throw new Error(`Invalid dataset timestamp: ${text}`);
  return parsed.toISOString().replace(".000Z", "Z");
}

export function basketFor(category, amount, transactionType) {
  const key = normalized(category);
  const type = normalized(transactionType);
  if (Number(amount) >= 0 || mapping.non_spending.includes(key) || /income|credit|transfer/.test(type)) return null;
  for (const basket of ["mandatory_regular", "mandatory_irregular", "everyday"]) {
    if (mapping[basket].includes(key)) return basket;
  }
  return "unclassified";
}

async function records(path) {
  return createReadStream(path).pipe(parse({
    bom: true,
    columns: true,
    skip_empty_lines: true,
    relax_column_count: true,
    trim: true,
  }));
}

function schema(database) {
  database.exec(`
    PRAGMA journal_mode = WAL;
    PRAGMA synchronous = NORMAL;
    CREATE TABLE customers (
      customer_id TEXT PRIMARY KEY,
      customer_postal_code TEXT,
      customer_age INTEGER
    );
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY,
      customer_id TEXT NOT NULL,
      bank_account_id TEXT NOT NULL,
      tx_date TEXT NOT NULL,
      tx_timestamp TEXT NOT NULL,
      category TEXT NOT NULL,
      basket TEXT,
      tx_amount_eur REAL NOT NULL,
      balance_after_eur REAL,
      transaction_type TEXT,
      merchant_id TEXT,
      mcc_code TEXT
    );
    CREATE TABLE mortgage_events (
      id INTEGER PRIMARY KEY,
      mortgage_customer_id TEXT NOT NULL,
      event_timestamp TEXT,
      event_type TEXT,
      payload_json TEXT NOT NULL
    );
    CREATE TABLE mortgages (
      mortgage_customer_id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL,
      final_decision TEXT,
      rejection_reason TEXT,
      final_property_price_eur REAL,
      final_requested_loan_eur REAL,
      final_equity_amount_eur REAL,
      final_collateral_value_eur REAL,
      required_monthly_income_eur REAL,
      final_loan_to_value REAL,
      payload_json TEXT NOT NULL
    );
    CREATE TABLE dataset_metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL);
  `);
}

async function inTransaction(database, iterable, insert) {
  database.exec("BEGIN");
  let count = 0;
  try {
    for await (const row of iterable) {
      insert(row);
      count += 1;
      if (count % 10_000 === 0) {
        database.exec("COMMIT");
        database.exec("BEGIN");
      }
    }
    database.exec("COMMIT");
    return count;
  } catch (error) {
    database.exec("ROLLBACK");
    throw error;
  }
}

function numberOrNull(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

export async function importSBankData({ sourceDirectory, databasePath }) {
  mkdirSync(dirname(databasePath), { recursive: true });
  for (const suffix of ["", "-wal", "-shm"]) rmSync(`${databasePath}${suffix}`, { force: true });
  const database = new DatabaseSync(databasePath);
  schema(database);

  const customerInsert = database.prepare(`
    INSERT INTO customers (customer_id, customer_postal_code, customer_age) VALUES (?, ?, ?)
  `);
  const customers = await inTransaction(database, await records(join(sourceDirectory, "tx_customers_junction.csv")), (row) => {
    customerInsert.run(row.customer_id, row.customer_postal_code || null, numberOrNull(row.customer_age));
  });

  const transactionInsert = database.prepare(`
    INSERT INTO transactions (
      customer_id, bank_account_id, tx_date, tx_timestamp, category, basket,
      tx_amount_eur, balance_after_eur, transaction_type, merchant_id, mcc_code
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);
  let anchorDate = "";
  const transactions = await inTransaction(database, await records(join(sourceDirectory, "tx_junction_transactions.csv")), (row) => {
    const amount = numberOrNull(row.tx_amount_eur) ?? 0;
    const timestamp = normalizeTimestamp(row.tx_timestamp || row.tx_date);
    if (timestamp > anchorDate) anchorDate = timestamp;
    transactionInsert.run(
      row.customer_id,
      row.bank_account_id,
      timestamp.slice(0, 10),
      timestamp,
      row.category,
      basketFor(row.category, amount, row.transaction_type),
      amount,
      numberOrNull(row.balance_after_eur),
      row.transaction_type || null,
      row.merchant_id || null,
      row.mcc_code || null,
    );
  });

  const eventInsert = database.prepare(`
    INSERT INTO mortgage_events (mortgage_customer_id, event_timestamp, event_type, payload_json)
    VALUES (?, ?, ?, ?)
  `);
  const mortgageEvents = await inTransaction(database, await records(join(sourceDirectory, "mtg_negotiation_history.csv")), (row) => {
    const rawTimestamp = row.timestamp ?? row.event_timestamp;
    eventInsert.run(row.mortgage_customer_id, rawTimestamp ? normalizeTimestamp(rawTimestamp) : null, row.event_type ?? null, JSON.stringify(row));
  });

  const mortgageInsert = database.prepare(`
    INSERT INTO mortgages (
      mortgage_customer_id, customer_id, final_decision, rejection_reason,
      final_property_price_eur, final_requested_loan_eur, final_equity_amount_eur,
      final_collateral_value_eur, required_monthly_income_eur, final_loan_to_value, payload_json
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);
  const mortgages = await inTransaction(database, await records(join(sourceDirectory, "mtg_tx_customer_link_and_final_mtg_infio.csv")), (row) => {
    mortgageInsert.run(
      row.mortgage_customer_id,
      row.customer_id,
      row.final_decision ?? row.final_outcome ?? null,
      row.rejection_reason || null,
      numberOrNull(row.final_property_price_eur),
      numberOrNull(row.final_requested_loan_eur),
      numberOrNull(row.final_equity_amount_eur),
      numberOrNull(row.final_collateral_value_eur),
      numberOrNull(row.required_monthly_income_eur),
      numberOrNull(row.lfinal_loan_to_value ?? row.final_loan_to_value),
      JSON.stringify(row),
    );
  });

  database.exec(`
    CREATE INDEX idx_transactions_customer_time ON transactions(customer_id, tx_timestamp);
    CREATE INDEX idx_transactions_customer_category_time ON transactions(customer_id, category, tx_timestamp);
    CREATE INDEX idx_transactions_customer_basket_time ON transactions(customer_id, basket, tx_timestamp);
    CREATE INDEX idx_mortgages_customer ON mortgages(customer_id);
    CREATE INDEX idx_mortgage_events_customer ON mortgage_events(mortgage_customer_id, event_timestamp);
  `);
  const metadataInsert = database.prepare("INSERT INTO dataset_metadata (key, value) VALUES (?, ?)");
  metadataInsert.run("anchor_date", anchorDate);
  metadataInsert.run("basket_mapping_version", String(mapping.version));
  metadataInsert.run("imported_at", new Date().toISOString());
  database.exec("PRAGMA optimize");
  database.close();
  return { customers, transactions, mortgageEvents, mortgages, anchorDate };
}

async function downloadMissing(sourceDirectory) {
  mkdirSync(sourceDirectory, { recursive: true });
  for (const file of requiredFiles) {
    const destination = join(sourceDirectory, file);
    if (existsSync(destination)) continue;
    const response = await fetch(downloadURLFor(file));
    if (!response.ok || !response.body) throw new Error(`Could not download ${file}: HTTP ${response.status}`);
    await pipeline(Readable.fromWeb(response.body), createWriteStream(destination));
  }
}

export function verifyDatabase(databasePath, requestedCustomer) {
  const database = new DatabaseSync(databasePath, { readOnly: true });
  const counts = {
    customers: database.prepare("SELECT COUNT(*) AS count FROM customers").get().count,
    transactions: database.prepare("SELECT COUNT(*) AS count FROM transactions").get().count,
    mortgages: database.prepare("SELECT COUNT(*) AS count FROM mortgages").get().count,
  };
  const selected = requestedCustomer
    ? database.prepare("SELECT customer_id FROM customers WHERE customer_id = ?").get(requestedCustomer)
    : database.prepare(`
        SELECT t.customer_id
        FROM transactions t
        LEFT JOIN mortgages m ON m.customer_id = t.customer_id
        GROUP BY t.customer_id
        ORDER BY (m.customer_id IS NOT NULL) DESC, COUNT(*) DESC
        LIMIT 1
      `).get();
  const coverage = selected ? database.prepare(`
    SELECT MIN(tx_timestamp) AS from_date, MAX(tx_timestamp) AS to_date, COUNT(*) AS transaction_count
    FROM transactions WHERE customer_id = ?
  `).get(selected.customer_id) : null;
  database.close();
  return { ...counts, demoCustomer: selected?.customer_id ?? null, coverage };
}

async function main() {
  const sourceDirectory = resolve(process.argv[2] ?? join(backendDirectory, "data/source"));
  const databasePath = resolve(process.env.SBANK_DATABASE_PATH ?? join(backendDirectory, "data/penny.sqlite"));
  if (process.argv.includes("--verify")) {
    console.log(JSON.stringify(verifyDatabase(databasePath, process.env.SBANK_DEMO_CUSTOMER_ID), null, 2));
    return;
  }
  await downloadMissing(sourceDirectory);
  const result = await importSBankData({ sourceDirectory, databasePath });
  console.log(JSON.stringify({ imported: result, verified: verifyDatabase(databasePath, process.env.SBANK_DEMO_CUSTOMER_ID) }, null, 2));
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main().catch((error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
}
