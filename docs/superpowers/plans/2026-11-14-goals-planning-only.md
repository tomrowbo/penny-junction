# Goals Planning-Only Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make Goals an unambiguously read-only planning and chat feature.

**Architecture:** Remove savings-pool derivation and account-linked allocation validation. Keep `PennyGoalPlan` as a locally persisted plan and retain the existing contextual Penny chat route.

**Tech Stack:** Swift 6, SwiftUI, Observation

**Spec:** `docs/superpowers/specs/2026-11-14-goals-planning-only-design.md`

## Global Constraints

- Do not create accounts, move money, or imply that goal values reserve real funds.
- Preserve the existing goal card and contextual Penny conversation behavior.
- Do not add or run UI tests; verify with one native simulator build.

## Review Focus

- Existing saved goals continue to load after removal of account linking.
- Editing a goal accepts any valid non-negative “Saved so far” amount.
- Goal saves contain no new bank-account references.
- No savings-account or allocation copy remains on the Plan screen or editor.
- Tapping a goal still opens its contextual Penny conversation.

---

### Task 1: Remove the savings-pool layer

**Files:**
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyPlanView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyGoalPlanEditor.swift`

**Interfaces:**
- Consumes: existing `PennyGoalPlan` persistence and `startPennyChat(about:)`
- Produces: planning-only goal creation and editing

- [ ] Remove savings-pool derived properties from `AppStore`.
- [ ] Remove the pool summary and pool arguments from `PennyPlanView`.
- [ ] Rename the editor field to “Saved so far,” remove pool notes and limits, and save no account references.
- [ ] Run `xcodebuild build -project PennyApp/PennyApp.xcodeproj -scheme PennyApp -destination 'platform=iOS Simulator,id=B612929B-A84C-43F7-8254-BBC4CC751925' CODE_SIGNING_ALLOWED=NO` and confirm `BUILD SUCCEEDED`.
- [ ] Commit only the three scoped Swift files.
