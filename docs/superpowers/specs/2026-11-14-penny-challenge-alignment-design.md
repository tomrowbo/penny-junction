# Penny challenge alignment design

## Intent

Make Penny demonstrate the S-Pankki challenge as directly as possible: a mobile, conversational personal economic trainer that uses the official synthetic S-Bank dataset, supports free exploration and what-if questions, teaches the three spending baskets, and optionally incorporates connected-bank data through PSD2.

The backend remains hackathon-sized. Production-like means trustworthy data boundaries, deterministic financial calculations and explainable answers—not recreating a bank's infrastructure.

## Goals

- Use the official Junction S-Pankki transaction, customer and mortgage files in the live demo.
- Let a fake authenticated customer explore their complete dataset history without sending raw rows to the language model.
- Support questions across arbitrary periods, categories and the three challenge baskets.
- Support deterministic safe-to-spend, safe-to-save, comparisons and percentage-reduction what-if scenarios.
- Add clickable inspiration starters for the three baskets, safe-to-spend and what-if use cases while preserving free text.
- Return responses with a consistent answer, basis, data coverage, confidence, assumptions and relevant follow-up suggestions.
- Keep the existing Enable Banking flow and merge connected-bank data into the same analysis when present.
- Keep a reliable fallback for the stage demo if the dataset or external services are unavailable.

## Non-goals

- Production customer authentication, distributed storage, bank-grade operations or formal regulatory certification.
- Payments, transfers, investment advice or autonomous financial actions.
- Receipt, SKU or loyalty-program data.
- A generic natural-language SQL endpoint or unrestricted model database access.
- Statistics Finland benchmarking unless the core challenge flows are complete and reliable.

## Challenge requirement mapping

| Requirement | Design response |
|---|---|
| Chat with personal banking data | Model selects approved analytical tools; bank code queries customer-scoped data and returns facts. |
| Simple factual questions | Period/category spending and transaction-count capabilities. |
| “What kind of spender am I?” | Three-basket profile with shares, trends and plain-language interpretation. |
| Safe to spend/save | Deterministic calculations with protected commitments, coverage, confidence and assumptions. |
| What-if scenarios | Generic category or basket percentage-reduction simulation. |
| Three pedagogical baskets | Derived basket tag, visible starter prompts and explicit basket evidence in answers. |
| MyData/free exploration | Free-text chat plus typed tools over the customer's complete indexed history. |
| Mobile | Existing native S-mobiili concept and goal conversation interface. |
| Provided data | Official GitHub CSVs imported into a local analytical database. |
| Multi-bank bonus | Existing Enable Banking accounts and transactions merged into analysis. |

## Approaches

### Selected: indexed challenge dataset with bounded analytical tools

Import the official CSV files into a local SQLite database. Preserve source fields and derive only a `basket` classification used by the challenge. Add indexes for customer, timestamp, category and basket. The conversational layer selects typed, read-only analytical tools; backend code owns queries and calculations.

This gives fast free exploration, real challenge-data evidence and a leading-bank-style trust boundary without adding a heavy service stack.

### Rejected: continue sending a mobile transaction snapshot

This is reliable but caps history, does not substantiate use of the supplied dataset and makes arbitrary periods or comparisons incomplete.

### Rejected: unrestricted model-generated SQL

This is flexible but creates unnecessary reliability and data-isolation risks. It also weakens the documented positioning that the financial engine decides and the model explains.

## Data setup

The GitHub repository is a dataset rather than a hosted API. A setup script downloads or accepts these official files:

- `tx_junction_transactions.csv`
- `tx_customers_junction.csv`
- `mtg_negotiation_history.csv`
- `mtg_tx_customer_link_and_final_mtg_infio.csv`

The files are imported into `backend/data/penny.sqlite`, which is ignored by version control. Import is streaming and idempotent so the 346 MB transaction file is never loaded fully into memory. Source data remains unchanged.

The transaction table preserves `customer_id`, `bank_account_id`, timestamp, category, amount, balance, transaction type, merchant ID and MCC code. It adds a derived `basket` with one of:

- `mandatory_regular`
- `mandatory_irregular`
- `everyday`

Indexes cover `(customer_id, tx_timestamp)`, `(customer_id, category, tx_timestamp)` and `(customer_id, basket, tx_timestamp)`. Customer and mortgage link fields retain their original identifiers.

## Demo customer

The fake login resolves server-side to one configured synthetic `customer_id`. The demo customer is chosen during setup for meaningful history and, preferably, linked mortgage data. The client does not choose arbitrary customer IDs.

The S-Bank account and transaction screens load the same selected customer's latest balances and recent transactions through a customer-summary endpoint. Penny and the visible banking UI therefore cannot silently describe different people or balances.

Relative periods such as “today,” “this month” and “last month” anchor to the selected customer's latest transaction timestamp. The UI and responses disclose the actual calendar coverage; the importer does not rewrite synthetic dates to the device date.

When the database is unavailable, the backend uses the current bounded demo snapshot and clearly marks the source as demo data. The UI never silently presents fallback data as the official dataset.

## Analytical capabilities

The model can request only approved tools:

- `spending_summary(from, to, category?, basket?)`
- `compare_spending(current_period, comparison_period, category?, basket?)`
- `basket_profile(from, to)`
- `safe_to_spend(horizon_days)`
- `safe_to_save()`
- `simulate_reduction(from, to, category_or_basket, percentage)`
- `mortgage_summary()`
- `data_coverage()`

Each tool is read-only and automatically scoped to the authenticated demo customer. Dates, percentages, categories and result sizes are validated. Tools return aggregate facts and small evidence samples only when necessary; raw transaction dumps never enter the model context.

Connected-bank transactions from the existing iOS request are normalised and included in calculations. They are not stored durably for the hackathon.

## Calculation behaviour

All monetary arithmetic is deterministic backend code. The model does not calculate totals itself.

Basket classification is explicit and explainable. Dataset categories map to a basket using a versioned mapping. The database permits an internal `unclassified` state for uncertain categories. It is excluded from the three user-facing totals, disclosed in evidence and lowers confidence rather than being silently forced into a basket. User-facing three-basket totals exclude income and transfers.

Safe-to-spend uses history ending at the dataset anchor. Monthly income, total spending and regular mandatory spending use the latest 90 days; the irregular mandatory reserve uses the latest 180-day monthly average. Liquid balance comes from each account's latest `balance_after_eur`. The calculation protects one month of regular mandatory costs plus one month of average irregular mandatory costs, then caps the requested horizon by sustainable daily surplus. The returned value is never negative.

Safe-to-save is 80% of positive observed monthly surplus, capped by liquid cash remaining after the same protected reserve. The retained 20% is an explicit uncertainty buffer. Both calculations disclose coverage, formula assumptions and confidence. Confidence is high only with at least 90 days of history, at least two income events and less than 10% unclassified spending; otherwise it falls to medium or low. Low-confidence results are framed as estimates and never as guarantees.

What-if calculations accept a category or basket and a percentage from 1 through 100. They report the current average, monthly change and annualised change while making clear that projected savings require behaviour to remain changed.

## Chat orchestration and response structure

The language model receives redacted conversation text, tool definitions and tool results. It does not receive the database, SQL, customer identifiers, account numbers or raw transaction rows.

The API returns a structured response:

```json
{
  "message": "Plain-language answer",
  "evidence": {
    "coverage": "1 Aug–31 Oct 2026",
    "institutions": ["S-Bank", "Nordea"],
    "transactionCount": 184,
    "confidence": "high",
    "assumptions": ["..."],
    "baskets": [
      { "id": "everyday", "label": "Everyday spending", "amount": 420.50 }
    ]
  },
  "suggestedPrompts": ["What if I reduced this by 20%?"]
}
```

`message` begins with the direct answer, explains the relevant basket or trade-off, and ends with one achievable next step. Numeric claims must appear in tool results. When data is insufficient, it says what is missing.

## New goal experience

Before the first user message, the New Goal conversation displays inspiration starters:

- **Regular essentials:** “How much of my money goes to rent and other regular essentials?”
- **Unexpected essentials:** “Am I prepared for irregular costs like repairs or a broken appliance?”
- **Everyday spending:** “What everyday spending is slipping through my fingers?”
- **Safe to spend:** “What is safe for me to spend this week?”
- **What if:** “What if I reduced dining out by 20%?”

Tapping a starter sends that question immediately for a clean guided demo. The normal text composer remains available for any question. After an answer, server-provided suggested prompts appear as optional follow-ups.

## Evidence UI

Assistant messages can include a compact “How this was calculated” disclosure showing data coverage, connected institutions, confidence, assumptions and basket totals. This keeps the conversation readable while making trust evidence available to judges and users.

## Safety and privacy

- Raw challenge data and connected-bank rows remain in the backend analysis boundary.
- Direct identifiers are removed from model inputs; user text is redacted for common direct identifiers.
- Customer scope is supplied by trusted server configuration, never by model arguments.
- Calculations are educational estimates, not regulated advice or guarantees.
- The assistant does not shame users, diagnose irresponsibility or recommend credit/investment products.
- Logs contain request IDs, capability names, timing, coverage and status—not raw financial content.

## Verification

The implementation is complete when:

1. The official CSVs import successfully and indexed customer queries return within demo-friendly latency.
2. Tests prove customer scoping, basket mapping, arbitrary-period summaries, comparisons, safe guidance and generic what-if calculations.
3. A model request contains no customer ID, account number, raw merchant row or SQL.
4. The iOS New Goal screen offers all five starter types and free text.
5. Chat renders the structured answer and expandable evidence.
6. The three canonical demo questions work against official data and continue to work with a connected external bank.
7. The existing mock fallback, backend checks and simulator build remain green.
