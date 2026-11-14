# Obsidian Emerald Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Penny's crowded dashboard and three-item navigation with a four-destination Obsidian Emerald experience for Spend, Plan, Ask Penny and Incoming.

**Architecture:** `AppTab` becomes the single source of truth for the four financial destinations. Each destination owns a focused SwiftUI root screen while shared Obsidian tokens, background, header and floating tab bar components provide the visual system. Existing domain calculators, stores, chat transport and detail views remain unchanged and are composed into the new roots.

**Tech Stack:** Swift 6, SwiftUI, Observation, Swift Charts, native `Material`, XcodeGen, asset catalogs.

**Spec:** `docs/superpowers/specs/2026-11-14-obsidian-emerald-navigation-design.md`

## Global Constraints

- Native SwiftUI with iOS 17 minimum; do not call iOS 26-only Liquid Glass APIs.
- The supplied `PennyMark.png` stays byte-identical and must not be recoloured.
- Remove pale-green surfaces and use emerald as the sole interactive accent.
- Preserve calculations, persistence, connected-bank data, transaction details, evidence and chat behavior.
- Preserve Dynamic Type, VoiceOver, Reduce Motion, Increase Contrast, Reduce Transparency and 44-point touch targets.
- Do not run UI tests; verify with unit tests, builds and bounded simulator screenshots.

## Review Focus

- A large Dynamic Type size must not truncate the four tab labels or key financial values.
- Reduce Transparency must replace translucent glass with an opaque high-contrast Obsidian surface.
- Empty goals, no detected recurring payments and disconnected-bank states must retain an obvious next action.
- Deep-link demo states for transactions, chat, wallet and saver must still resolve after the `AppTab` cases change.
- Light and dark system appearance must both remain legible even though Penny deliberately uses a dark product canvas.

---

### Task 1: Navigation model and shell

**Files:**
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Modify: `PennyApp/PennyApp/PennyApp.swift`
- Create: `PennyApp/PennyApp/Shared/PennyGlassChrome.swift`
- Modify: `PennyApp/PennyAppTests/DomainModelTests.swift`
- Modify: `PennyApp/PennyAppTests/AppStoreTests.swift`

**Interfaces:**
- Produces: `AppTab.spend`, `.plan`, `.askPenny`, `.incoming`; `PennyGlassTabBar(selection:)`; `PennyRootHeader(title:subtitle:)`.
- Consumes: `AppStore.selectedTab`, `PennyMark`, `MeView`.

- [ ] Update unit expectations so all four tab titles, symbols and launch-state mappings are pinned; verify the focused tests fail against the old cases.
- [ ] Replace the old cases and route demo states to the closest new destination without changing the deep-link detail states.
- [ ] Implement the floating four-item material tab bar, with Ask Penny using the supplied portrait and every destination exposing a 44-point target and selected trait.
- [ ] Implement a reusable root header with a top-right profile action presenting `MeView`.
- [ ] Switch `MainTabView` to the four focused root views and run the focused unit tests.
- [ ] Commit the working navigation shell.

### Task 2: Obsidian Emerald system and authored hero asset

**Files:**
- Modify: `PennyApp/PennyApp/Design/Theme.swift`
- Modify: `PennyApp/PennyApp/Design/SMobiiliDesignSystem.swift`
- Create: `PennyApp/PennyApp/Assets.xcassets/SpendAurora.imageset/Contents.json`
- Create: `PennyApp/PennyApp/Assets.xcassets/SpendAurora.imageset/SpendAurora.png`
- Modify: `PennyApp/PennyApp/Features/Login/LoginView.swift`
- Modify: `DESIGN.md`
- Create: `.impeccable/design.json`

**Interfaces:**
- Produces: Obsidian/emerald semantic tokens, `PennyAtmosphere`, `pennyGlassSurface(cornerRadius:)`, and `SpendAurora` image asset.
- Consumes: native environment values for contrast, motion and transparency.

- [ ] Generate one abstract emerald-on-obsidian financial atmosphere image with no text, logos, people or UI chrome; embed its generation provenance.
- [ ] Add dark semantic tokens and accessible opaque/translucent glass variants; remove pale-green token values.
- [ ] Restyle login and launch presentation to establish the same visual world while leaving the Penny mark unchanged.
- [ ] Update durable design documentation and machine-readable tokens.
- [ ] Build the application and commit the visual foundation.

### Task 3: Focused Spend, Plan and Incoming destinations

**Files:**
- Create: `PennyApp/PennyApp/Features/Penny/PennySpendView.swift`
- Create: `PennyApp/PennyApp/Features/Penny/PennyPlanView.swift`
- Create: `PennyApp/PennyApp/Features/Penny/PennyIncomingView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/SafeToSpendCard.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/UpcomingMoneyCard.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyGoalPlanCard.swift`
- Modify: `PennyApp/PennyApp/Features/Bank/TransactionDetailView.swift`
- Modify: `PennyApp/PennyApp/Features/OpenBanking/ConnectBankView.swift`

**Interfaces:**
- Produces: `PennySpendView`, `PennyPlanView`, `PennyIncomingView`.
- Consumes: `AppStore.safeToSpend`, `.accounts`, `.transactions`, `.goalPlans`, `.upcomingMoney`, and Task 2 glass components.

- [ ] Build Spend around one image-backed safe-to-spend thesis, followed by compact balances, recent transactions and connected-account disclosure.
- [ ] Build Plan around goal progress, create/edit sheets and a clear empty state; retain persistence and calculations.
- [ ] Build Incoming around the existing recurrence detector, its evidence sheet and an honest no-pattern state.
- [ ] Restyle the reused financial cards and reachable detail/sheet surfaces with Obsidian materials and accessible contrast.
- [ ] Build and commit the three destinations.

### Task 4: Distilled Ask Penny and evidence surfaces

**Files:**
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyEvidenceVisualization.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyGoalPlanEditor.swift`
- Modify: `PennyApp/PennyApp/Features/Profile/MeView.swift`

**Interfaces:**
- Produces: a conversation-first `PennyCoachView` for `.askPenny` with no duplicated spend, incoming or plan cards.
- Consumes: existing `PennyChatView`, structured visualizations, goal editor and profile content.

- [ ] Remove the dashboard calculations and goal cards from Ask Penny, leaving a bold prompt, new-conversation action and recent threads.
- [ ] Restyle chat bubbles, composer, analytical charts/tables, editor and profile for the Obsidian system while preserving their data and accessibility semantics.
- [ ] Verify chat reply decoding and backend visualization tests remain green.
- [ ] Commit the conversation and supporting surfaces.

### Task 5: Integration, accessibility and finish review

**Files:**
- Modify: `PennyApp/PennyApp.xcodeproj/project.pbxproj` via `xcodegen generate`
- Modify: any changed files identified by the bounded review

**Interfaces:**
- Consumes: all prior tasks.
- Produces: a reviewed, documented and committed native app on `main`.

- [ ] Regenerate the Xcode project and run the native unit suite plus backend tests/typecheck; do not run UI tests.
- [ ] Capture one iPhone pass covering all four roots, profile and one detail surface, then repeat only once after batching visible fixes; include dark/light appearance and large Dynamic Type evidence.
- [ ] Run the required fresh native finish reviewer with the spec, screenshots, iOS guidance and craft-floor quality bar; apply its material fix batch if needed.
- [ ] Verify the supplied source and bundled Penny mark checksums still match, `git show --check` passes, and unrelated `.deck-work/` and pitch files remain unstaged.
- [ ] Commit final integration and documentation directly to `main`.
