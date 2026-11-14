# Actionable Dashboard Insight Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Penny's passive dashboard subtitle with one clickable, personal-baseline saving recommendation that opens a saved contextual chat with evidence, a compact chart, and follow-up actions.

**Architecture:** A deterministic native calculator compares the last complete month with the preceding three complete months for supported discretionary categories using comparable institution coverage. `AppStore` turns the strongest eligible result into a pre-populated saved `PennyChatThread`; the existing tab and contextual-chat navigation opens it from a tappable `PennyRootHeader` subtitle.

**Tech Stack:** Swift 6, SwiftUI, Observation, existing Penny visualization and conversation persistence models, existing TypeScript request validation.

**Spec:** `docs/superpowers/specs/2026-11-14-actionable-dashboard-insight-design.md`

## Global Constraints

- Use only loaded official S-Bank data plus currently connected open-banking data.
- Calculate all amounts deterministically outside the language model.
- Show one recommendation only; never call spending unnecessary or imply that money moved.
- Preserve the current light-mode typography and compact header layout.
- Do not introduce new automated test files for this hackathon change; verify with focused builds and the physical-device flow.

## Review Focus

- Partial current months must not enter either side of the comparison.
- A newly connected institution without four comparable complete months must not create a false opportunity.
- Categories without a positive, meaningful increase must fall back to truthful existing copy.
- Opening the insight must create and persist one conversation rather than duplicating it on view refresh.
- Follow-up chat requests must accept the new insight context without backend validation errors.

---

### Task 1: Deterministic personal-baseline insight

**Files:**
- Create: `PennyApp/PennyApp/Domain/DashboardSavingInsight.swift`
- Modify: `PennyApp/PennyApp/AppStore.swift`

**Interfaces:**
- Produces: `DashboardSavingInsight` with category, whole-euro opportunity, latest spend, three-month average, comparison period, institutions, source transaction IDs, and optional goal.
- Produces: `DashboardSavingInsightCalculator.make(transactions:goals:asOf:calendar:) -> DashboardSavingInsight?`.
- Produces: `AppStore.dashboardSavingInsight: DashboardSavingInsight?`.

- [ ] Implement the calculator over the previous complete calendar month and three preceding complete months.
- [ ] Restrict candidates to supported discretionary categories, require comparable institution coverage in all four months, and require a positive difference of at least €5.
- [ ] Rank by the largest whole-euro monthly opportunity and attach the first incomplete goal when available.
- [ ] Build the iOS target and confirm the new domain model compiles.
- [ ] Commit the deterministic insight model.

### Task 2: Saved contextual explanation

**Files:**
- Modify: `PennyApp/PennyApp/Domain/PennyChatContext.swift`
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`
- Modify: `PennyApp/backend/src/lib/coach.ts`

**Interfaces:**
- Consumes: `DashboardSavingInsight` from Task 1.
- Produces: `AppStore.startPennyChat(for insight: DashboardSavingInsight)`.
- Produces: `AppStore.pendingPennyChatThread: PennyChatThread?`.
- Extends: `PennyChatContext.Kind.insight` and backend selected-context validation.

- [ ] Build an insight context and a new chat thread containing two short Penny messages: evidence first, achievable adjustment and goal impact second.
- [ ] Attach a local two-bar baseline-versus-last-month visualization and the quick replies `Show me where`, `Try another idea`, and `Adjust my goal`.
- [ ] Persist the thread once when it is created, switch to Ask Penny, and have `PennyCoachView` open the pending thread before a plain pending context.
- [ ] Add the insight icon/context-card handling and allow `insight` through backend request validation.
- [ ] Build the backend and iOS target to confirm both context contracts compile.
- [ ] Commit contextual insight chat support.

### Task 3: Clickable dashboard header and device handoff

**Files:**
- Modify: `PennyApp/PennyApp/Shared/PennyGlassChrome.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennySpendView.swift`
- Modify: `PennyApp/PennyApp/Domain/DashboardSubtitleBuilder.swift`

**Interfaces:**
- Consumes: `AppStore.dashboardSavingInsight` and `startPennyChat(for:)`.
- Extends: `PennyRootHeader` with an optional subtitle action while preserving existing call sites.

- [ ] Render `Save an extra €N a month →` as the single tappable subtitle when an eligible insight exists.
- [ ] Remove random subtitle selection; retain deterministic truthful fallback copy when there is no supported opportunity or data is loading.
- [ ] Give the subtitle a clear button hit target and accessibility label without changing the profile button.
- [ ] Build, install, and launch the signed app on the connected physical iPhone.
- [ ] Manually confirm dashboard tap → contextual saved chat → chart → follow-up prompt.
- [ ] Commit and push the complete feature to `main`.
