# S-mobiili Visual Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconstruct the public S-mobiili 2.43.0 iPhone screens in SwiftUI, preserve Penny functionality as the only additional tab, and produce like-for-like visual comparison evidence.

**Architecture:** A reference-driven design layer (`SMobiiliPalette`, `SMobiiliMetrics`, shared chrome and rows) supplies every host and Penny surface. `AppStore` owns deterministic tab/page/route state so both UI tests and simulator launch states can reach each reference screen. A capture script launches pinned demo states on one simulator and builds normalized reference/build pairs without bundling the copyrighted reference material into the application.

**Tech Stack:** Swift 6, SwiftUI, Observation, XCTest, XcodeGen, `xcodebuild`, `simctl`, ImageMagick.

**Spec:** `docs/superpowers/specs/2026-11-13-smobiili-visual-parity-design.md`

## Global Constraints

- Native SwiftUI application with iOS 17 minimum; no third-party UI dependency.
- Penny is the only additional top-level tab: S-Etukortti, Bank, Penny, Me.
- Preserve existing account, transaction, connected-bank, goal, and chat behavior.
- Light-mode S-mobiili 2.43.0 screenshots are the visual authority.
- Authoritative capture: iPhone 17 Pro, iOS 26.2, light appearance, English UI, `en_FI` formatting, default Dynamic Type.
- Measurable target: geometry within 1 point, flat RGB values within 3/255, identical visible copy and line breaks, and no material mismatch at 2× inspection.
- Keep public reference files outside the app bundle under `PennyApp/VisualReferences/SMobiili-2.43.0/`.
- Do not request real credentials or imply production affiliation.
- The workspace has no `.git` metadata, so this plan cannot require commits; every task ends with an independently verifiable build or test instead.

## Review Focus

- iOS 26 must not replace the pinned tab-bar appearance with Liquid Glass; Task 6's raw shell capture verifies the custom bar, safe area, and Task 2 verifies 44-point hit areas.
- Long or accessibility-sized text must not clip service rows; Task 2 Step 6 and Task 6 Step 5 verify expansion at a large Dynamic Type size.
- Navigation into Accounts, Wallet, Receipt, Saver, Penny goals, transactions, and external-bank connection must remain reachable; Tasks 1, 3, 4, and 5 pin route/destination contracts in tests.
- Static reference-only actions must not resemble successful real banking operations; Tasks 3 and 4 test that their destination is `.conceptInfo`, not a functional route.
- Reference crops must preserve aspect ratio and disclose clipped/perspective-limited regions; Task 6 validates both script behavior and required limitations metadata.

---

### Task 1: Pin the visual references and deterministic launch states

**Files:**
- Create: `PennyApp/VisualReferences/SMobiili-2.43.0/README.md`
- Create: `PennyApp/VisualReferences/SMobiili-2.43.0/metadata.json`
- Create: `PennyApp/VisualReferences/SMobiili-2.43.0/01.png` through `08.png`
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Modify: `PennyApp/PennyAppTests/AppStoreTests.swift`

**Interfaces:**
- Produces: `enum AppTab: String, CaseIterable` with cases `.card`, `.bank`, `.penny`, `.me`, and exact ordered `allCases`.
- Produces: `enum DemoLaunchState: String` with `.cardOverview`, `.cardBenefits`, `.bank`, `.penny`, `.me`, `.wallet`, `.receipt`, `.saver`, `.transaction`, `.connected`, `.chat`.
- Produces: `AppStore.applyDemoState(_ state: DemoLaunchState)` and state properties `cardPage: Int`, `presentedReferenceRoute: SMobiiliRoute?`.
- Produces: immutable reference metadata including source URL, retrieval date, original pixel dimensions, and SHA-256.

- [ ] **Step 1: Write failing store tests**

Add tests named `testTopLevelTabsMatchReferenceOrderWithPennyInserted`, `testCardBenefitsLaunchStateSelectsSecondCardPage`, and `testReferenceDetailLaunchStatesExposeExpectedRoute`. Assert the exact four-tab order and deterministic state/route values without reading process environment in the test body.

- [ ] **Step 2: Run tests and verify RED**

Run:

```bash
xcodebuild test -project PennyApp/PennyApp.xcodeproj -scheme PennyApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:PennyAppTests/AppStoreTests
```

Expected: compile/test failure because `DemoLaunchState`, `cardPage`, `presentedReferenceRoute`, and the four-case ordered tab contract do not exist.

- [ ] **Step 3: Implement deterministic application state**

In `AppStore.swift`, remove `.home`, add raw/case-iterable tab metadata, introduce `SMobiiliRoute`, parse `PENNY_DEMO_STATE` once into `DemoLaunchState`, and centralize all preview mutations in `applyDemoState(_:)`. Preserve the existing defaults: unauthenticated on normal launch and Bank selected after fake login.

- [ ] **Step 4: Run store tests and verify GREEN**

Run the Task 1 test command. Expected: all `AppStoreTests` pass.

- [ ] **Step 5: Download and pin reference evidence**

Download the eight exact URLs returned by Apple's lookup endpoint for app ID `740514933`, country `fi`, version `2.43.0`. Record every URL, `2026-11-13`, actual dimensions, and `shasum -a 256` output in `metadata.json`; explain the marketing-composite and perspective limitations in `README.md`.

- [ ] **Step 6: Verify reference integrity**

Run `jq empty PennyApp/VisualReferences/SMobiili-2.43.0/metadata.json`, `shasum -a 256 PennyApp/VisualReferences/SMobiili-2.43.0/*.png`, and `sips -g pixelWidth -g pixelHeight` for all eight files. Expected: valid JSON, eight non-empty hashes, and dimensions matching metadata.

---

### Task 2: Establish the measured S-mobiili design system and app shell

**Files:**
- Create: `PennyApp/PennyApp/Design/SMobiiliDesignSystem.swift`
- Create: `PennyApp/PennyApp/Shared/SMobiiliChrome.swift`
- Modify: `PennyApp/PennyApp/Design/Theme.swift`
- Modify: `PennyApp/PennyApp/Shared/BrandComponents.swift`
- Modify: `PennyApp/PennyApp/PennyApp.swift`
- Modify: `PennyApp/PennyAppTests/DomainModelTests.swift`

**Interfaces:**
- Produces: `enum SMobiiliPalette` for measured brand/background/surface/label/separator values.
- Produces: `enum SMobiiliMetrics` for content inset, row heights, radii, icon frames, gaps, navigation height, and tab-bar height.
- Produces: `SMobiiliHeader`, `SMobiiliServiceRow`, `SMobiiliActionRow`, `SMobiiliMessageButton`, and `SMobiiliTabBar`.
- Consumes: ordered `AppTab.allCases` from Task 1.

- [ ] **Step 1: Write failing token and tab metadata tests**

Add `testSMobiiliPaletteMatchesPinnedFlatColors`, `testSMobiiliMetricsMatchMeasuredReferenceGeometry`, and `testEveryTopLevelTabHasReferenceLabelAndSymbol`. Assert the measured values recorded during reference inspection and the exact labels `S-Etukortti`, `Bank`, `Penny`, `Me`.

- [ ] **Step 2: Run tests and verify RED**

Run the full `PennyAppTests` suite. Expected: compile failure because design tokens and tab metadata are absent.

- [ ] **Step 3: Implement tokens and reusable components**

Measure the pinned screenshots at full available resolution, record the values in `SMobiiliDesignSystem.swift`, keep visible icon glyphs smaller than their 44-point hit areas, and map semantic text colors for accessibility. Retain `PennyTheme` as compatibility aliases during the migration so unchanged functional screens continue compiling.

- [ ] **Step 4: Replace the top-level shell**

Replace `MainTabView`'s system `TabView` presentation with content switching plus `SMobiiliTabBar`, respecting safe-area insets and accessibility selection traits. Remove `PlaceholderTab` and the Home tab. Host each section in its own `NavigationStack` so navigation history does not leak between tabs.

- [ ] **Step 5: Run tests and build**

Run the full tests, then:

```bash
xcodebuild build -project PennyApp/PennyApp.xcodeproj -scheme PennyApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected: tests pass and app builds without Swift warnings or errors.

- [ ] **Step 6: Check large-text shell behavior**

Launch the Bank state, set the simulator to an accessibility Dynamic Type size, and verify by screenshot that labels remain readable, tab actions remain at least 44 points, and the selected state is not color-only. Restore default text size afterward.

---

### Task 3: Recreate the S-Etukortti, Wallet, and Receipt references

**Files:**
- Create: `PennyApp/PennyApp/Features/Card/SEtukorttiHomeView.swift`
- Create: `PennyApp/PennyApp/Features/Card/WalletView.swift`
- Create: `PennyApp/PennyApp/Features/Card/ReceiptView.swift`
- Create: `PennyApp/PennyApp/Features/Card/SEtukorttiDemoContent.swift`
- Modify: `PennyApp/PennyAppTests/DomainModelTests.swift`

**Interfaces:**
- Produces: `struct SEtukorttiDemoContent` with exact reference-visible benefit, wallet-card, merchant, total, and receipt-line copy.
- Produces: `SEtukorttiHomeView`, bound to `AppStore.cardPage`, with two horizontally paged states and reference page indicator.
- Consumes: `.wallet` and `.receipt` routes from Task 1 and shared chrome/tokens from Task 2.

- [ ] **Step 1: Write failing reference-content tests**

Add `testSEtukorttiDemoContentMatchesVisibleReferenceCopy`, `testReceiptDemoTotalAndMerchantMatchReference`, `testCardPagerHasExactlyTwoStates`, and `testCardActionsRouteOnlyToWalletReceiptOrConceptInfo`. Assert exact public strings, `60,00 €` formatting, and that no reference-only action maps to a production operation.

- [ ] **Step 2: Run tests and verify RED**

Run `DomainModelTests`. Expected: compile failure because `SEtukorttiDemoContent` is absent.

- [ ] **Step 3: Implement the two-page S-Etukortti surface**

Build the bonus/account overview and benefits/receipts page with a page-style `TabView` whose system indicator is hidden in favor of the measured two-dot reference indicator. Keep the top-level S-Etukortti tab selected during horizontal paging and expose Wallet/Receipt navigation actions.

- [ ] **Step 4: Implement Wallet and Receipt**

Build both screens from real SwiftUI text, shapes, logo assets, and accessible actions. Receipt body may use a monospaced system face because the reference depicts printed receipt data. Do not rasterize the UI or make barcode/share actions perform real operations.

- [ ] **Step 5: Run tests and build**

Run `DomainModelTests`, the full test suite, and the Task 2 build command. Expected: all pass.

---

### Task 4: Recreate Bank, Saver, and Me while preserving functional flows

**Files:**
- Create: `PennyApp/PennyApp/Features/Bank/SMobiiliBankContent.swift`
- Create: `PennyApp/PennyApp/Features/Bank/SaverView.swift`
- Create: `PennyApp/PennyApp/Features/Profile/MeView.swift`
- Modify: `PennyApp/PennyApp/Features/Bank/SBankHomeView.swift`
- Modify: `PennyApp/PennyApp/Features/Bank/BankOverviewView.swift`
- Modify: `PennyApp/PennyApp/Features/Bank/TransactionDetailView.swift`
- Modify: `PennyApp/PennyAppTests/DomainModelTests.swift`

**Interfaces:**
- Produces: `SMobiiliBankContent.services` in exact reference order and visible copy.
- Produces: `SaverView` with the reference goal amount, progress, dates, status, and action rows.
- Produces: `MeView` with reference identity, account rows, authentication actions, and service grouping.
- Consumes: existing `BankOverviewView`, `AllTransactionsView`, and Task 2 components.

- [ ] **Step 1: Write failing host-screen content tests**

Add `testBankServicesMatchReferenceOrderAndCopy`, `testBankServiceDestinationsSeparateFunctionalAndConceptRoutes`, `testSaverReferenceValuesAreStable`, and `testMeReferenceActionsAreConceptSafe`. Assert all six service labels, exact visible detail text, Accounts/Saver functional routing, and `.conceptInfo` for unsupported banking/profile actions.

- [ ] **Step 2: Run tests and verify RED**

Run `DomainModelTests`. Expected: compile failure because the new content types do not exist.

- [ ] **Step 3: Rebuild the Bank landing screen**

Replace generic `BankService` rows with measured shared rows and authored S-mobiili glyph treatments. Keep Accounts navigable to the consolidated functional screen; route Säästäjä to `SaverView`; keep other reference-only rows concept-safe.

- [ ] **Step 4: Build Saver and Me**

Match the public screen hierarchy and copy using the shared header/action components. Make all visible controls accessible; reference-only operations remain inert or explain the prototype boundary.

- [ ] **Step 5: Restyle functional Bank detail screens**

Apply reconstructed backgrounds, typography, separators, row geometry, and navigation chrome to Accounts and Transaction Detail without changing their data or Penny handoff behavior.

- [ ] **Step 6: Run tests and build**

Run the full suite and Task 2 build command. Expected: all pass.

---

### Task 5: Integrate Penny into the reconstructed host system

**Files:**
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`
- Modify: `PennyApp/PennyApp/Features/OpenBanking/ConnectBankView.swift`
- Modify: `PennyApp/PennyApp/Features/Transactions/AllTransactionsView.swift`
- Modify: `PennyApp/PennyApp/Features/Login/LoginView.swift`
- Modify: `PennyApp/PennyAppTests/AppStoreTests.swift`

**Interfaces:**
- Consumes: Task 2 tokens/chrome and existing Penny services/data.
- Preserves: chat submission, bank connection, transaction filtering, fake login, and transaction-to-Penny handoff.

- [ ] **Step 1: Write failing navigation regression tests**

Add `testLoginStillSelectsBankInFourTabShell`, `testConnectedStateStillSelectsPenny`, and `testTransactionHandoffSelectsPennyTab`. The first two exercise `AppStore`; extract the third handoff into a small store method if necessary so it is testable without rendering SwiftUI.

- [ ] **Step 2: Run tests and verify RED**

Run `AppStoreTests`. Expected: at least the extracted handoff contract fails because the method is absent.

- [ ] **Step 3: Restyle Penny and connected functional flows**

Replace the separate dark hero/card visual theme with the host's measured header, surfaces, typography, rows, and action treatment. Keep Penny's label/content identity, API calls, loading/error states, and data-source semantics unchanged.

- [ ] **Step 4: Align login and functional details**

Bring Login, Connect Bank, and All Transactions into the same host system, retain the explicit demo/no-real-credentials language, and ensure deep navigation hides the custom tab bar only where the reference behavior requires it.

- [ ] **Step 5: Run all tests and build**

Run the full test suite and Task 2 build command. Expected: all pass with no warnings or errors.

---

### Task 6: Capture, compare, correct, and document visual parity

**Files:**
- Create: `PennyApp/Scripts/capture_visual_parity.sh`
- Create: `PennyApp/Scripts/build_reference_crops.sh`
- Create: `PennyApp/VisualReferences/SMobiili-2.43.0/crops.json`
- Create: `.impeccable/review/` captures and side-by-side PNGs
- Modify: `PennyApp/README.md`

**Interfaces:**
- Produces: repeatable commands that build/install once, launch each `DemoLaunchState`, capture the iPhone 17 Pro simulator, normalize only by crop/scale preserving aspect ratio, and generate named pairs.
- Produces: `bonus-pair.png`, `benefits-pair.png`, `wallet-pair.png`, `receipt-pair.png`, `bank-pair.png`, `saver-pair.png`, and `me-pair.png` plus raw build screenshots.

- [ ] **Step 1: Write capture-script validation first**

Create `crops.json` with schema fields `source`, `crop`, `perspective`, `verifiedRegion`, and `limitations`. Before creating scripts, run `jq` assertions that require all seven comparison states, non-empty limitations for every clipped/angled source, and crop dimensions that retain aspect ratio; expected result is failure because the file/scripts are absent.

- [ ] **Step 2: Implement reference crop and simulator capture scripts**

Use explicit simulator UDID resolution, `xcodebuild`, `simctl install/launch/io screenshot`, and ImageMagick crop/scale/pair operations. Refuse to run if the simulator runtime/device, reference hashes, locale, appearance, or image dimensions do not match the pinned contract. Never stretch either axis. Preserve clipped angled sources unrectified and label them `perspective: true` as qualitative evidence; an inverse transform would invent hidden corners.

- [ ] **Step 3: Validate scripts mechanically**

Run:

```bash
bash -n PennyApp/Scripts/build_reference_crops.sh
bash -n PennyApp/Scripts/capture_visual_parity.sh
jq empty PennyApp/VisualReferences/SMobiili-2.43.0/crops.json
```

Expected: zero exit codes.

- [ ] **Step 4: Perform the first bounded visual pass**

Capture all seven states in light/default text, open every raw and paired image, and inspect at 2×. Record measured geometry/color/text mismatches together, then make one batched correction across production Swift files.

- [ ] **Step 5: Confirm once across required conditions**

Recapture all seven pairs, then separately verify Bank and Penny at large Dynamic Type and dark appearance for clipping/contrast (reference parity remains light/default only). Stop self-polishing after this confirmation pass.

- [ ] **Step 6: Run final verification**

Run:

```bash
xcodebuild test -project PennyApp/PennyApp.xcodeproj -scheme PennyApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild build -project PennyApp/PennyApp.xcodeproj -scheme PennyApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected: all tests pass, build succeeds, and every required comparison file exists and opens correctly.

- [ ] **Step 7: Document the workflow**

Update `PennyApp/README.md` with the four-tab flow, exact reference version, capture command, output locations, static-screen limitations, and concept/trademark disclaimer.

