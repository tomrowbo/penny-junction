# Goal Savings Pool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Back goals with one truthful connected-savings pool and explicit per-goal allocations.

**Architecture:** `AppStore` derives pool totals from connected savings accounts and stored goal allocations. `PennyPlanView` renders the pool summary and passes allocation limits plus savings-account IDs into the existing editor; the goal model and projection formulas remain compatible.

**Tech Stack:** SwiftUI, Observation, existing Codable goal persistence.

**Spec:** `docs/superpowers/specs/2026-11-14-goal-savings-pool-design.md`

## Global Constraints

- Work directly on `main`; preserve unrelated dirty AppStore/test/UI edits and stage only owned hunks.
- Do not infer goal ownership from transactions or move money.
- Build once on the default simulator; do not add/run UI tests or large-font checks.

## Review Focus

- Editing a goal must exclude its prior allocation when calculating available funds.
- Allocations across goals must never be double-counted as additional bank balance.
- Existing overallocated goals must remain visible and editable.
- Zero/negative savings-account balances must not increase the pool.
- Saving must attach only existing savings account IDs.

---

### Task 1: Savings-pool derivation

**Files:**
- Modify: `PennyApp/PennyApp/AppStore.swift`

- [ ] Add `savingsAccountIDs`, `totalSavingsBalance`, `totalGoalAllocations`, `unallocatedSavings`, and `availableSavings(for:)` derived properties.
- [ ] Keep all derived values non-mutating and clamp only the displayed unallocated amount, not stored goal allocations.
- [ ] Commit as `Derive Penny savings pool`.

### Task 2: Plan summary and allocation editor

**Files:**
- Modify: `PennyApp/PennyApp/Features/Penny/PennyPlanView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyGoalPlanEditor.swift`

- [ ] Add a compact pool summary above goals showing total pool, allocated, and available or overallocated.
- [ ] Extend the editor initializer with `savingsPoolAvailable` and `savingsAccountIDs` defaults.
- [ ] Rename the field to `Allocated to this goal`, show available funds, and reject allocations above the per-goal limit.
- [ ] Save current savings-account IDs into the plan.
- [ ] Pass the correct limit when creating and editing, excluding the edited goal's existing allocation.
- [ ] Build once, inspect the default Plan/editor screen, and commit as `Allocate savings across Penny goals`.

