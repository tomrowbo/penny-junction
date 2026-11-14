# Penny Standalone Brand Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the existing native prototype into a standalone Penny app, co-branded “for S-Bank,” while retaining the current banking-inspired design system and all working financial coaching functionality.

**Architecture:** Reuse the existing SwiftUI goals, consolidated accounts and profile surfaces behind a Penny-owned three-tab shell. S-Bank remains an institution/data-provenance label, while Penny owns the installed app name, login, navigation and assistant avatar. Backend contracts and analytics remain unchanged.

**Tech Stack:** Swift 6, SwiftUI, XCTest, XcodeGen, existing Next.js backend

**Spec:** `/Users/tomrowbotham/junction/docs/superpowers/specs/2026-11-14-penny-for-sbank-brand-design.md`

## Global Constraints

- Primary product name is `Penny`; `for S-Bank` is always secondary copy.
- Installed display name is `Penny`.
- Primary navigation contains exactly `Penny`, `Accounts`, and `Me`.
- Preserve the existing green palette, rounded-card system, density and native system typography.
- Use S-Bank branding only for institution, challenge-partner and synthetic-data provenance.
- Keep all backend, open-banking and coaching API contracts unchanged.
- No new font dependency; iOS system typography remains the licensed implementation.
- Workspace is not a Git repository, so verification evidence replaces per-task commits.

## Review Focus

- Cold launch and fake login must land on Penny, never a removed bank-shell tab.
- Demo launch states used for Penny, accounts, connected-bank and chat flows must still resolve safely.
- Transaction “Discuss with Penny” must return to the Penny tab without leaving stale navigation state.
- S-Bank must remain visible on its accounts and official synthetic-data provenance after the rebrand.
- No user-facing screen in the reachable app may claim the standalone product is S-mobiili.

---

### Task 1: Penny Product Identity

**Files:**
- Modify: `PennyApp/project.yml`
- Modify: `PennyApp/PennyApp/Features/Login/LoginView.swift`
- Modify: `PennyApp/PennyApp/Shared/BrandComponents.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`
- Test: `PennyApp/PennyAppTests/DomainModelTests.swift`

**Interfaces:**
- Consumes: existing `PennyTheme`, `InstitutionBadge`, and native system typography.
- Produces: `PennyMark` for product identity; `SMark` remains institution-only.

- [ ] **Step 1: Add failing identity tests**

Assert that the product lockup exposes `Penny`, `for S-Bank`, and `Junction concept using synthetic S-Bank data`, and that assistant surfaces use Penny identity rather than the S-Bank mark.

- [ ] **Step 2: Run the focused tests and verify failure**

Run: `xcodebuild test -project PennyApp.xcodeproj -scheme PennyApp -destination 'platform=iOS Simulator,id=A4897CED-EE77-433A-B5DB-DBA2C8101DD0' -only-testing:PennyAppTests/DomainModelTests`

Expected: FAIL because the Penny lockup model/mark does not exist and current login copy says `S-MOBIILI`.

- [ ] **Step 3: Implement Penny-owned identity**

Add `PennyBrand.productName`, `partnerDescriptor`, `tagline`, and `conceptDisclosure`; add a `PennyMark` built from SF Symbols; use it on login and assistant bubbles. Change `CFBundleDisplayName` to `Penny` and regenerate the Xcode project.

- [ ] **Step 4: Run the focused tests**

Expected: identity tests PASS.

### Task 2: Standalone Three-Tab Shell

**Files:**
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Modify: `PennyApp/PennyApp/PennyApp.swift`
- Modify: `PennyApp/PennyApp/Shared/SMobiiliChrome.swift`
- Modify: `PennyApp/PennyApp/Features/Bank/BankOverviewView.swift`
- Test: `PennyApp/PennyAppTests/AppStoreTests.swift`
- Test: `PennyApp/PennyAppTests/DomainModelTests.swift`

**Interfaces:**
- Consumes: `PennyCoachView`, `BankOverviewView`, `MeView`, `AppStore.discussWithPenny()`.
- Produces: `AppTab.penny`, `.accounts`, `.me`; Penny-owned root navigation.

- [ ] **Step 1: Replace bank-shell assertions with failing standalone-navigation tests**

Assert exactly three tabs titled `Penny`, `Accounts`, `Me`; login defaults to `.penny`; connected state selects `.penny`; transaction handoff selects `.penny`; accounts demo state selects `.accounts`.

- [ ] **Step 2: Run AppStore and domain tests and verify failure**

Expected: FAIL against the current four tabs `[S-Etukortti, Bank, Penny, Me]` and `.bank` login target.

- [ ] **Step 3: Implement the standalone shell**

Replace `AppTab.card/bank` with `.accounts`, render `PennyCoachView`, a `NavigationStack` containing `BankOverviewView`, and `MeView`. Remove S-mark special-casing from the tab bar. Preserve safe mappings for the four supported demo flows; legacy visual-reference states may map to Penny without being reachable in product navigation.

- [ ] **Step 4: Run focused tests**

Expected: AppStore and domain tests PASS.

### Task 3: Penny-Specific Me Surface and Reachable Copy Audit

**Files:**
- Modify: `PennyApp/PennyApp/Features/Profile/MeView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`
- Modify: `PennyApp/README.md`
- Modify: `PennyApp/docs/CHALLENGE_REQUIREMENTS.md`
- Test: `PennyApp/PennyAppTests/DomainModelTests.swift`

**Interfaces:**
- Consumes: `AppStore.accounts`, `AppStore.sBankDataStatus`, and the co-brand copy from Task 1.
- Produces: Penny-specific data sources, privacy and about sections with explicit concept provenance.

- [ ] **Step 1: Add failing reachable-copy tests**

Assert the Me content sections are `Connected data`, `Privacy and permissions`, and `About Penny`; assert the concept disclosure is present and no reachable navigation label contains `S-mobiili` or `S-Etukortti`.

- [ ] **Step 2: Run focused tests and verify failure**

Expected: FAIL because the current Me screen exposes S-Bank services/authentication and reference-shell copy.

- [ ] **Step 3: Implement the Penny Me screen and documentation**

Show connected institutions, read-only access/privacy wording, `Penny for S-Bank`, and the Junction synthetic-data disclosure. Update README and challenge evidence to describe a standalone app using the S-Bank-inspired visual system rather than an S-mobiili replica.

- [ ] **Step 4: Run focused tests**

Expected: Domain model tests PASS.

### Task 4: Full Native Verification and Simulator Handoff

**Files:**
- Modify: `.superpowers/sdd/2026-11-14-penny-standalone-brand/progress.md`

**Interfaces:**
- Consumes: Tasks 1–3.
- Produces: verified simulator build and final screenshot.

- [ ] **Step 1: Regenerate and run the complete native test suite**

Run: `xcodegen generate && xcodebuild test -project PennyApp.xcodeproj -scheme PennyApp -destination 'platform=iOS Simulator,id=A4897CED-EE77-433A-B5DB-DBA2C8101DD0' -only-testing:PennyAppTests`

Expected: all tests PASS with zero failures.

- [ ] **Step 2: Build, install and launch**

Build for simulator `A4897CED-EE77-433A-B5DB-DBA2C8101DD0`, install `PennyApp.app`, and launch `com.tomrowbotham.junction.penny` with `PENNY_DEMO_STATE=penny`.

- [ ] **Step 3: Capture and inspect a screenshot**

Verify Penny is the installed/product identity, `for S-Bank` is secondary, and the visible bottom navigation contains only Penny, Accounts and Me.

- [ ] **Step 4: Run a fresh whole-change review**

Review the implementation against the spec, fixing all Critical and Important findings before completion.
