# Monthly Savings Plan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a real-data monthly savings summary and goal breakdown to Plan, and make every goal available to Penny chat.

**Architecture:** SwiftUI derives six calendar months of actual `Invest Deposit` savings contributions from the transactions already held by `AppStore` and renders the summary with Swift Charts. The iOS chat request sends a minimized goal list; the backend validates it, deterministically computes the monthly target, and exposes redacted planning facts to both coach paths.

**Tech Stack:** Swift 6, SwiftUI, Swift Charts, TypeScript, Zod, Next.js

**Spec:** `docs/superpowers/specs/2026-11-14-monthly-savings-plan-design.md`

## Global Constraints

- Goals and monthly savings are read-only planning information; never create accounts, reserve funds, or move money.
- Income and ordinary spending do not affect the savings-contribution figure.
- Preserve contextual goal chat and local goal persistence.
- Do not add or run UI tests or large-font checks; verify with one native build and backend build.
- Commit only scoped files directly to `main` and preserve unrelated dirty work.

## Review Focus

- Calendar boundaries across year changes produce exactly six ordered months.
- Empty contribution months render as zero.
- Completed goals do not contribute to the target or breakdown; unfinished €0 goals remain visible.
- Older clients without `goals` still pass backend validation.
- Model-visible goal facts redact titles, omit IDs, and describe values as user-entered planning data.

---

### Task 1: Goal-aware Penny request contract

**Files:**
- Modify: `PennyApp/backend/src/lib/coach.ts`
- Modify: `PennyApp/backend/src/lib/coach-tools.ts`
- Modify: `PennyApp/PennyApp/Services/PennyChatService.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`

**Interfaces:**
- Consumes: `[PennyGoalPlan]` from `AppStore.goalPlans`
- Produces: optional/default-empty backend `goals` request field and deterministic model-visible goal facts

- [ ] Add the bounded goal schema and default-empty `goals` field to the backend contract.
- [ ] Add a shared goal-instructions helper that computes the unfinished monthly target, redacts titles, omits IDs, and marks data as user-entered.
- [ ] Include those instructions in both backend coach paths.
- [ ] Encode all local goals in `PennyChatService` and pass `store.goalPlans` from every chat send.
- [ ] Run the backend build and confirm it succeeds.
- [ ] Commit the four scoped files.

### Task 2: Monthly savings summary and compact breakdown

**Files:**
- Modify: `PennyApp/PennyApp/Features/Penny/PennyPlanView.swift`

**Interfaces:**
- Consumes: `store.transactions`, `store.financialReferenceDate`, and `store.goalPlans`
- Produces: six monthly savings-contribution points, monthly target, latest-month saved amount, and compact goal rows

- [ ] Add six-month `Invest Deposit` contribution grouping and active-goal derived values inside the Plan feature.
- [ ] Add the glass monthly summary card with real saved/target figures, zero baseline, and six-month line/area chart.
- [ ] Replace large repeated goal cards with compact Savings breakdown rows that retain discuss, edit, add, progress, and empty-state behavior.
- [ ] Run one native simulator build and confirm `BUILD SUCCEEDED`.
- [ ] Commit only `PennyPlanView.swift`.
