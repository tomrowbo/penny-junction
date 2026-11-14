# Penny Ruthless Simplification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace text-heavy Penny screens with personal, visual, minimal roots and grounded item-specific chat handoffs.

**Architecture:** Typed `PennyChatSubject` and `PennyChatContext` values carry verified item context from AppStore navigation through the native chat request and backend coach schema. Spend, Plan, Goal Editor and Ask Penny remain independent SwiftUI surfaces sharing the existing Pearl Emerald tokens and native SF typography.

**Tech Stack:** Swift 6, SwiftUI, Observation, XCTest, TypeScript, Next.js route handlers, Zod, Vitest.

**Spec:** `docs/superpowers/specs/2026-11-14-penny-ruthless-simplification-design.md`

## Global Constraints

- Native SwiftUI with iOS 17 minimum and native SF Pro Dynamic Type roles.
- No estimate, confidence, completeness, date-range, assumption or calculation filler on root screens.
- No pale-green surfaces, competitor fonts or black text on filled green buttons.
- The supplied Penny mark remains unchanged.
- Contextual navigation never automatically sends a model request.
- Preserve financial calculations, goal persistence and editor validation semantics.
- Do not run the UI test target; verify with unit tests, builds and bounded simulator screenshots.
- Preserve unrelated working-tree changes in `AppStore.swift`, `PennyGoalPlanTests.swift`, decks and research files; never revert another worker's edits.

## Review Focus

- A payday-backed safe-to-spend result must say `until payday`; fallback results may say `over the next 30 days`.
- Missing/stale transaction, account, goal or upcoming IDs must not crash or invent context; fall back to a generic new chat.
- Selected-item context must be encoded to the backend and included in both tool-enabled and fallback coach instructions.
- Large Dynamic Type must stack goal/editor content without clipping controls or hiding Cancel/Save.
- Goal-card primary tap must open chat while the ellipsis remains an independent 44-point edit action.

---

### Task 1: Grounded contextual chat contract and routing

**Files:**
- Create: `PennyApp/PennyApp/Domain/PennyChatContext.swift`
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Modify: `PennyApp/PennyApp/Services/PennyChatService.swift`
- Modify: `PennyApp/backend/src/lib/coach.ts`
- Modify: `PennyApp/backend/src/lib/coach-tools.ts`
- Modify: `PennyApp/PennyAppTests/AppStoreTests.swift`
- Modify: `PennyApp/backend/src/lib/backend.test.ts`

**Interfaces:**
- Produces: `enum PennyChatSubject: Hashable, Codable, Sendable`, `struct PennyChatContext: Hashable, Codable, Sendable`, `var pendingPennyChatContext: PennyChatContext?`, `func startPennyChat(about subject: PennyChatSubject?)`, `func context(for subject: PennyChatSubject) -> PennyChatContext?`.
- Produces: `PennyChatService.reply(goal:messages:accounts:transactions:context:)` with optional context encoded as `selectedContext`.
- Consumes: existing accounts, transactions, goal plans and `upcomingMoney` from `AppStore`.

- [ ] **Step 1: Write failing native routing/context tests**

Add tests proving transaction, account, goal and upcoming subjects resolve only repository-backed facts; `startPennyChat` selects `.askPenny`, stores context, clears preview routes, and a missing ID yields generic chat with nil context.

- [ ] **Step 2: Run native tests and verify RED**

Run: `xcodebuild test -project PennyApp/PennyApp.xcodeproj -scheme PennyApp -destination 'platform=iOS Simulator,id=B612929B-A84C-43F7-8254-BBC4CC751925' -only-testing:PennyAppTests/AppStoreTests CODE_SIGNING_ALLOWED=NO`

- [ ] **Step 3: Implement native context resolution and request encoding**

Use verified display facts only. Keep the existing no-argument `discussWithPenny()` as a compatibility wrapper around `startPennyChat(about: nil)` until all callers migrate. Preserve the concurrent `resetGoalPlans()` change in `AppStore.swift`.

- [ ] **Step 4: Write failing backend schema/instruction tests**

Assert Zod accepts the four bounded context types, rejects oversized/free-form facts, and both `buildCoachModelInput` and tool instructions include redacted selected context.

- [ ] **Step 5: Implement backend `selectedContext` support**

Add an optional bounded schema with `type`, `referenceID`, `title`, `subtitle`, related IDs and suggested prompts. Feed it to fallback and tool-enabled instructions without treating it as a source for new numeric calculations.

- [ ] **Step 6: Run native and backend tests**

Run the focused native command above, then `cd PennyApp/backend && npm test && npm run typecheck`.

- [ ] **Step 7: Commit**

Commit: `Add grounded contextual Penny chats`

### Task 2: Distill Spend to one personal decision

**Files:**
- Modify: `PennyApp/PennyApp/Features/Penny/PennySpendView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/SafeToSpendCard.swift`

**Interfaces:**
- Consumes: `AppStore.safeToSpend`, `PennyProfileContent.customerName`, accounts and transactions.
- Produces: no new shared API.

- [ ] **Step 1: Remove the competing balance and filler**

Replace the root title with `Hi Tom` / `Here’s what your money can do today.` Remove `balanceSummary` entirely. In `SafeToSpendCard`, remove period dates, estimate/completeness/confidence text, assumptions, evidence rows and the calculation/disclosure control.

- [ ] **Step 2: Recompose the hero and account rows**

Keep only a large shield, `Safe to spend`, `safeToday`, `Today`, and truthful dynamic `safeUntilPayday` scope. Reduce hero height, grow institution badges to 44–48 points, and ensure the account balance appears only in the account row.

- [ ] **Step 3: Build and inspect Spend**

Run: `xcodebuild -project PennyApp/PennyApp.xcodeproj -scheme PennyApp -sdk iphonesimulator -destination 'platform=iOS Simulator,id=B612929B-A84C-43F7-8254-BBC4CC751925' CODE_SIGNING_ALLOWED=NO build`

Capture a simulator screenshot and verify one dominant amount, no clipped large text and none of the forbidden filler strings.

- [ ] **Step 4: Commit**

Commit: `Distill the Spend experience`

### Task 3: Replace goal reports with visual goal tiles

**Files:**
- Modify: `PennyApp/PennyApp/Features/Penny/PennyPlanView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyGoalPlanCard.swift`

**Interfaces:**
- Consumes: `AppStore.startPennyChat(about: .goal(plan.id))` from Task 1 and existing `PennyGoalProjection`.
- Produces: `PennyGoalPlanCard(plan:asOf:onDiscuss:onEdit:)`.

- [ ] **Step 1: Build the visual tile**

Use a derived semantic symbol, a 48–56 point icon plate, circular progress indicator and dark-forest-to-emerald tile. Show only title, current/target, percentage, status, monthly contribution and short target month/year.

- [ ] **Step 2: Remove report copy and split actions**

Delete monthly-needed, projected-completion and assumption paragraphs. Make the tile primary tap call `onDiscuss`; add an independent 44-point ellipsis for `onEdit`, with VoiceOver labels/hints.

- [ ] **Step 3: Simplify Plan chrome and empty state**

Use a circular 44-point plus button. Empty state gets one large icon, `What are you saving for?`, one sentence maximum and a white-on-deep-emerald Create Goal action.

- [ ] **Step 4: Build and inspect Plan**

Run the Task 2 build command. Capture Plan at default and accessibility text sizes; verify card content remains visible and the edit target does not trigger chat.

- [ ] **Step 5: Commit**

Commit: `Make goals visual and conversational`

### Task 4: Redesign Create/Edit Goal

**Files:**
- Modify: `PennyApp/PennyApp/Features/Penny/PennyGoalPlanEditor.swift`
- Test: `PennyApp/PennyAppTests/PennyGoalPlanTests.swift` only if existing validation behavior changes; otherwise preserve concurrent user edits untouched.

**Interfaces:**
- Preserves: `init(plan:asOf:onSave:)` and all persistence/validation semantics.
- Produces: no new shared API.

- [ ] **Step 1: Replace Form with visual panels**

Use a ScrollView, a 56–64 point goal symbol, one `Goal` glass panel and one `Your plan` panel. Keep name, target, date, saved and monthly fields. Remove footer prose.

- [ ] **Step 2: Fix navigation and primary action contrast**

Give Cancel explicit primary text, a 44-point target and visible light toolbar background. Remove toolbar Save. Add a full-width 52-point deep-emerald `Save changes` button with white semibold text.

- [ ] **Step 3: Preserve concise validation and keyboard behavior**

Show the existing validation as a compact red banner only after attempted save. Add `@FocusState` and keyboard Done for decimal pads. Stack content at accessibility sizes.

- [ ] **Step 4: Run focused goal tests, build and inspect**

Run: `xcodebuild test -project PennyApp/PennyApp.xcodeproj -scheme PennyApp -destination 'platform=iOS Simulator,id=B612929B-A84C-43F7-8254-BBC4CC751925' -only-testing:PennyAppTests/PennyGoalPlanTests CODE_SIGNING_ALLOWED=NO`

Capture Create/Edit Goal and verify Cancel and Save contrast on-device.

- [ ] **Step 5: Commit**

Commit: `Redesign the Penny goal editor`

### Task 5: Make Ask Penny composer-first and render contextual chats

**Files:**
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`
- Modify: `PennyApp/PennyApp/Features/Bank/TransactionDetailView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyIncomingView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/UpcomingMoneyCard.swift`

**Interfaces:**
- Consumes: Task 1 context state/routing and Task 3 goal callback.
- Produces: reusable `PennyChatContextCard` and `DiscussWithPennyAction` within the Penny feature module.

- [ ] **Step 1: Replace the marketing CTA with a composer**

Remove `newChatButton`. Add a glass composer labelled `Ask Penny anything…`, deep-emerald circular forward control with white icon, and at most three compact prompt chips. Composer submission opens a generic new chat with the draft; the root itself stays concise.

- [ ] **Step 2: Render contextual new-chat state**

When `pendingPennyChatContext` exists, open a new chat showing one compact context card and two tailored prompt chips before the composer. Do not auto-send. Pass context to `PennyChatService.reply` only after the user sends.

- [ ] **Step 3: Migrate contextual entry points**

Transaction detail uses `.transaction(id)`. Accounts and upcoming items receive separate 44-point Penny portrait actions without breaking existing row behavior. Goals use Task 3's full-tile discuss action.

- [ ] **Step 4: Build and inspect Ask/context flow**

Run the Task 2 build command. Capture Ask root, a transaction-context chat and a goal-context chat. Verify there is no large green CTA, no automatic message, and filled emerald controls use white text/icons.

- [ ] **Step 5: Commit**

Commit: `Make Ask Penny contextual and composer first`

### Task 6: Integrated verification and visual review

**Files:**
- Modify only defects found in the bounded review.

**Interfaces:**
- Consumes all previous tasks.
- Produces the verified integrated app.

- [ ] **Step 1: Regenerate and run complete non-UI verification**

Run `cd PennyApp && xcodegen generate`, the complete `PennyAppTests` suite, backend `npm test`, backend `npm run typecheck`, and a simulator build. Do not run `PennyAppUITests`.

- [ ] **Step 2: Capture one batched visual pass**

Capture Spend, Plan, Goal Editor, Ask root, contextual transaction chat and contextual goal chat at default size, plus one accessibility-size screen.

- [ ] **Step 3: Fix one batch and confirm once**

Resolve all observed clipping, contrast, hierarchy and routing defects together. Rebuild and perform one confirmation capture only.

- [ ] **Step 4: Independent finish review**

Review the screenshots and diff against the spec; require no blocking/high findings.

- [ ] **Step 5: Commit**

Commit: `Verify the simplified Penny experience`
