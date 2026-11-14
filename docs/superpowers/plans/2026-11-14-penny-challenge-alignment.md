# Penny Challenge Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Penny use the official S-Pankki challenge dataset and deliver freely explorable, structured, explainable coaching across the three spending baskets.

**Architecture:** A streaming setup script imports the official CSVs into indexed SQLite. The lightweight Next.js API binds a configured synthetic customer to typed read-only analytical capabilities, merges request-scoped PSD2 data, and gives only aggregate tool results to OpenAI. SwiftUI loads the same customer's S-Bank summary and renders starter prompts plus structured calculation evidence.

**Tech Stack:** Next.js 16, TypeScript, Node `node:sqlite`, OpenAI Responses API, Zod, Vitest, Swift 6, SwiftUI, URLSession

**Spec:** `docs/superpowers/specs/2026-11-14-penny-challenge-alignment-design.md`

## Global Constraints

- Use the official `hackjunction/Junction-2026-S-pankki` CSV files without rewriting their synthetic dates.
- Anchor relative time expressions to the selected customer's latest transaction.
- Scope every dataset query to the server-configured demo customer; never accept a model-supplied customer ID.
- Keep raw transaction rows, SQL, customer IDs and direct account identifiers out of model input.
- Preserve the existing Enable Banking and deterministic fallback flows.
- iOS 17 minimum and Swift 6.
- Receipt, SKU, loyalty, payments and investment recommendations remain out of scope.
- Keep tests focused on financial correctness, customer isolation, privacy and the canonical demo path.

## Review Focus

- CSV files beginning with a UTF-8 BOM import with the correct first column and do not load fully into memory; Task 1 tests a BOM fixture.
- A request cannot access a different synthetic customer through tool arguments or route input; Tasks 2 and 4 test enforced server scope.
- Relative periods use the dataset anchor rather than the device clock; Tasks 2 and 3 test a historical fixture.
- Income, transfers and unclassified spending do not silently distort the three baskets or confidence; Task 3 tests each case.
- Missing database, model failure or malformed structured output falls back visibly without fabricating official-data results; Tasks 2, 4 and 5 test or manually verify each boundary.

---

### Task 1: Official dataset importer and basket mapping

**Files:**
- Create: `PennyApp/backend/src/data/basket-mapping.json`
- Create: `PennyApp/backend/scripts/setup-sbank-data.mjs`
- Create: `PennyApp/backend/scripts/setup-sbank-data.test.ts`
- Modify: `PennyApp/backend/package.json`
- Modify: `PennyApp/backend/.gitignore`
- Modify: `PennyApp/backend/.env.example`

**Interfaces:**
- Produces: `backend/data/penny.sqlite` with `customers`, `transactions`, `mortgage_events`, `mortgages` and `dataset_metadata` tables.
- Produces: `npm run data:setup -- [source-directory]` for download/import and `npm run data:verify` for counts, coverage and selected-customer output.

- [ ] **Step 1: Write failing importer tests**

Add fixtures containing a UTF-8 BOM, two customers, income, transfer, known categories and an unknown category. Assert preservation of source fields, mapped `basket`, internal `unclassified`, metadata coverage and customer/date/category/basket indexes.

- [ ] **Step 2: Run the importer test and verify it fails**

Run: `npm test -- scripts/setup-sbank-data.test.ts`

Expected: FAIL because the setup module and mapping do not exist.

- [ ] **Step 3: Implement the streaming, idempotent importer**

Implement CSV streaming with batched SQLite transactions, BOM-safe headers, schema creation, versioned basket mapping and dataset metadata. Accept already-downloaded official files and download missing files from the official repository's raw/LFS URLs.

- [ ] **Step 4: Add scripts, environment defaults and ignored data paths**

Add `data:setup` and `data:verify`; ignore `data/*.csv`, `data/*.sqlite` and SQLite journal files. Add `SBANK_DATABASE_PATH` and `SBANK_DEMO_CUSTOMER_ID` examples.

- [ ] **Step 5: Run the focused test and official import**

Run: `npm test -- scripts/setup-sbank-data.test.ts`

Expected: PASS.

Run: `npm run data:setup`

Expected: the official files import and verification reports row counts, actual date coverage and a valid demo customer.

### Task 2: Customer-scoped repository and matching S-Bank summary

**Files:**
- Create: `PennyApp/backend/src/lib/sbank-repository.ts`
- Create: `PennyApp/backend/src/app/api/customer/summary/route.ts`
- Modify: `PennyApp/backend/src/lib/config.ts`
- Modify: `PennyApp/backend/src/lib/backend.test.ts`

**Interfaces:**
- Produces: `SBankRepository` with `coverage()`, `customerSummary()`, `spendingSummary()`, `compareSpending()`, `basketProfile()`, `latestLiquidBalance()` and `mortgageSummary()` methods whose public arguments never include `customerId`.
- Produces: `GET /api/customer/summary` returning `{ source, anchorDate, accounts, transactions, coverage }` for the configured customer.

- [ ] **Step 1: Write failing repository isolation and historical-anchor tests**

Seed an in-memory database with two customers. Assert all repository methods return only the constructor-bound customer, “last month” derives from that customer's maximum timestamp, and missing database state produces an explicit unavailable result.

- [ ] **Step 2: Run the focused repository tests and verify they fail**

Run: `npm test -- src/lib/backend.test.ts`

Expected: FAIL because `SBankRepository` is missing.

- [ ] **Step 3: Implement the read-only repository**

Use parameterised statements, query only indexed aggregate ranges, cap evidence rows and expose no generic SQL method. Open the file database read-only in request paths; allow an injected in-memory database for tests.

- [ ] **Step 4: Implement server-bound configuration and summary route**

Resolve `SBANK_DEMO_CUSTOMER_ID` only in server config. Return `503` with a safe message when official data is unavailable; never silently label fallback content as official.

- [ ] **Step 5: Run repository tests, typecheck and route smoke test**

Run: `npm test && npm run typecheck`

Expected: PASS.

Call `GET /api/customer/summary` and verify its anchor, balance and recent transactions correspond to the configured official customer.

### Task 3: Deterministic challenge analytics

**Files:**
- Create: `PennyApp/backend/src/lib/challenge-analytics.ts`
- Modify: `PennyApp/backend/src/lib/finance-engine.ts`
- Modify: `PennyApp/backend/src/lib/backend.test.ts`

**Interfaces:**
- Consumes: `SBankRepository` aggregate methods and request-scoped connected-bank `FinancialSnapshot`.
- Produces: `ChallengeAnalytics` methods `spendingSummary`, `compareSpending`, `basketProfile`, `safeToSpend`, `safeToSave`, `simulateReduction`, `mortgageSummary` and `dataCoverage`.
- Produces: every result with `value`, `coverage`, `institutions`, `transactionCount`, `confidence`, `assumptions` and relevant `baskets`.

- [ ] **Step 1: Write failing calculation tests**

Test arbitrary category periods, basket totals excluding income/transfers, internal unclassified share, period comparisons, generic 1–100% reduction, the specified 90/180-day safe guidance formulas, zero floors, connected-bank merging and confidence thresholds.

- [ ] **Step 2: Run focused analytics tests and verify they fail**

Run: `npm test -- src/lib/backend.test.ts`

Expected: FAIL because `ChallengeAnalytics` and generic calculations do not exist.

- [ ] **Step 3: Implement the minimal deterministic analytics**

Keep all arithmetic in TypeScript, use repository aggregates for S-Bank data, merge normalised connected-bank aggregates and round currency only at output boundaries. Reject invalid ranges, unknown categories and percentages outside 1–100 with typed safe errors.

- [ ] **Step 4: Refactor the existing fixed analysis through shared calculation helpers**

Retain current fallback behaviour but remove duplicate formulas. Ensure the fallback labels its source and uses the same evidence type.

- [ ] **Step 5: Run the complete backend test suite**

Run: `npm test`

Expected: PASS with no financial-calculation failures.

### Task 4: Bounded tool orchestration and structured chat response

**Files:**
- Create: `PennyApp/backend/src/lib/coach-tools.ts`
- Modify: `PennyApp/backend/src/lib/coach.ts`
- Modify: `PennyApp/backend/src/app/api/chat/route.ts`
- Modify: `PennyApp/backend/src/lib/backend.test.ts`

**Interfaces:**
- Consumes: conversation, goal and optional request-scoped connected-bank snapshot; S-Bank identity comes only from server configuration.
- Produces: `ChatResponse` with `message`, `evidence`, `suggestedPrompts` and `source`.
- Produces: allow-listed tools `spending_summary`, `compare_spending`, `basket_profile`, `safe_to_spend`, `safe_to_save`, `simulate_reduction`, `mortgage_summary`, `data_coverage`.

- [ ] **Step 1: Write failing orchestration and privacy tests**

Use a deterministic fake model adapter to assert tool validation, maximum tool-call rounds, server-bound customer scope, structured evidence accumulation and suggested prompts. Assert serialized model inputs exclude customer ID, SQL, account IDs, account numbers, raw merchant rows and unrelated tool results.

- [ ] **Step 2: Run focused orchestration tests and verify they fail**

Run: `npm test -- src/lib/backend.test.ts`

Expected: FAIL because the tool registry and structured response do not exist.

- [ ] **Step 3: Implement the allow-listed tool registry**

Define Zod argument schemas, validated date/category/basket inputs and typed execution. Derive evidence and follow-up prompts from executed tool results rather than asking the model to fabricate structure.

- [ ] **Step 4: Implement the bounded Responses API tool loop**

Allow at most four tool rounds. Redact goal and conversation text. Give the model only the selected tool outputs, require numeric claims to come from those outputs and preserve a concise non-judgmental response style.

- [ ] **Step 5: Update the route contract and safe error handling**

Return `400` for invalid requests, `503` for unavailable official data/configuration and `502` for retryable model failures. Log request ID, tool names, duration and status only.

- [ ] **Step 6: Run tests, typecheck and three canonical API calls**

Run: `npm test && npm run typecheck`

Then call the API for factual breadth, safe-to-spend and 20% dining reduction. Verify every response contains structured evidence and only tool-grounded numbers.

### Task 5: Load the official customer into the iOS banking UI

**Files:**
- Create: `PennyApp/PennyApp/Services/SBankDataService.swift`
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Modify: `PennyApp/PennyApp/PennyApp.swift`
- Modify: `PennyApp/PennyApp/Domain/Models.swift`
- Test: `PennyApp/PennyAppTests/PennyAppTests.swift`

**Interfaces:**
- Consumes: `GET /api/customer/summary`.
- Produces: `AppStore.loadSBankData()` that replaces only S-Bank accounts/transactions and preserves connected-bank data.
- Produces: visible source/coverage state distinguishing official dataset from fallback demo data.

- [ ] **Step 1: Write failing DTO and merge tests**

Assert official summary decoding, synthetic-date decoding, replacement of prior S-Bank rows, preservation of connected-bank rows and explicit fallback source state.

- [ ] **Step 2: Run the focused iOS tests and verify they fail**

Run the `PennyAppTests` scheme with `xcodebuild` on the configured simulator.

Expected: FAIL because the service and merge method do not exist.

- [ ] **Step 3: Implement summary loading and store merge**

Load after fake login/app entry, preserve the current demo snapshot on a visible fallback state and avoid blocking navigation on network failure.

- [ ] **Step 4: Build and visually compare bank figures with the summary API**

Run a simulator build and verify the latest S-Bank balance/transactions match `GET /api/customer/summary`.

### Task 6: New-goal starters and explainable response UI

**Files:**
- Modify: `PennyApp/PennyApp/Services/PennyChatService.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`
- Modify: `PennyApp/PennyApp/Domain/Models.swift`
- Test: `PennyApp/PennyAppTests/PennyAppTests.swift`

**Interfaces:**
- Consumes: structured `ChatResponse` from Task 4.
- Produces: `PennyChatReply`, `PennyEvidence`, `PennyBasketEvidence` and optional message evidence.
- Produces: five starter actions, immediate send, free-text composer, suggested follow-ups and “How this was calculated” disclosure.

- [ ] **Step 1: Write failing response-decoding and starter tests**

Assert decoding all evidence fields, graceful decoding when optional evidence is absent, exact presence of regular-essential, irregular-essential, everyday, safe-to-spend and what-if starters, and preservation of arbitrary free text.

- [ ] **Step 2: Run focused iOS tests and verify they fail**

Run the `PennyAppTests` scheme.

Expected: FAIL because structured reply types and starters do not exist.

- [ ] **Step 3: Implement structured response decoding and message storage**

Return `PennyChatReply` from the service and attach evidence/suggestions only to assistant messages.

- [ ] **Step 4: Implement starter and follow-up actions**

Show starters only before the first user message in New Goal. Tapping sends immediately through the existing send path; free text remains unchanged. Show server suggestions after assistant responses.

- [ ] **Step 5: Implement compact evidence disclosure**

Render coverage, institutions, confidence, assumptions and basket amounts in a native `DisclosureGroup` beneath the assistant message without adding another top-level screen.

- [ ] **Step 6: Build and exercise the canonical flow in the simulator**

Verify all five starters, a custom question, evidence expansion, follow-up prompt and connected-bank context.

### Task 7: Documentation and final verification

**Files:**
- Modify: `PennyApp/backend/README.md`
- Modify: `PennyApp/README.md`
- Modify: `PennyApp/docs/LEADING_BANK_AI_SPEC.md`
- Create: `PennyApp/docs/CHALLENGE_REQUIREMENTS.md`

**Interfaces:**
- Produces: reproducible dataset setup, demo runbook and requirement-to-evidence matrix.

- [ ] **Step 1: Document official-data setup and fallback**

Include download/import commands, database location, customer selection, date-anchor behaviour, expected disk/time requirements and how to verify source coverage.

- [ ] **Step 2: Record the challenge evidence matrix**

Map each challenge requirement to the exact app flow, endpoint, calculation and demo question that proves it.

- [ ] **Step 3: Run final backend verification**

Run: `npm test && npm run typecheck && npm run build`

Expected: all commands pass.

- [ ] **Step 4: Run final iOS verification**

Build the app for the booted iPhone simulator, launch it and exercise login → official S-Bank summary → New Goal starter → structured answer → evidence → external-bank inclusion.

- [ ] **Step 5: Verify privacy boundary**

Inspect a captured model request from the test adapter and confirm it contains no customer ID, SQL, account number, account ID or raw transaction row.
