# Penny Financial Coach Implementation Plan

**Goal:** Add safe-to-spend, upcoming money, persistent goals, and evidence charts/tables to Penny.

**Architecture:** Four isolated domain/view modules expose typed inputs and outputs. The root integration pass connects them to AppStore, Penny home, chat messages and the backend response schema after parallel work completes.

**Spec:** `docs/superpowers/specs/2026-11-14-penny-financial-coach-design.md`

## Global constraints

- No third-party dependencies; iOS 17 SwiftUI/Swift Charts only.
- Calculations are deterministic and evidence-grounded.
- No agent edits `AppStore.swift`, `PennyCoachView.swift`, `Models.swift`, `project.yml` or another agent's owned files; root integrates shared files.
- Agents must preserve unrelated user changes in the dirty worktree.

## Task 1 — Safe to spend

Own new `Domain/SafeToSpend.swift`, `Features/Penny/SafeToSpendCard.swift`, and focused tests. Produce a calculator result containing today/until-payday amounts, reserved commitments, goal contribution, confidence, assumptions and source transaction IDs.

## Task 2 — Upcoming money

Own new `Domain/UpcomingMoney.swift`, `Features/Penny/UpcomingMoneyCard.swift`, and focused tests. Detect and model recurring outflows/income from transaction history, predict next dates, total the next 30 days and surface price changes without treating guesses as facts.

## Task 3 — Persistent goals

Own new `Domain/PennyGoalPlan.swift`, `Services/PennyGoalPlanStore.swift`, `Features/Penny/PennyGoalPlanCard.swift`, and focused tests. Produce Codable goal plans, deterministic progress/projection math and a persistence abstraction suitable for UserDefaults with an in-memory test store.

## Task 4 — Evidence charts and tables

Own new `Domain/PennyVisualization.swift`, `Features/Penny/PennyEvidenceVisualization.swift`, backend visualization-schema files as needed, and focused tests. Define a closed Codable/Decodable schema and native accessible renderers for bar, line, progress and table presentations. Do not modify existing shared chat models; root will attach the optional payload.

## Task 5 — Root integration

Root modifies shared models, AppStore, Penny home/chat and backend response assembly; regenerates the Xcode project if needed; runs unit/backend tests, simulator build and a bounded light/dark screenshot review.
