# Penny iOS Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native S-mobiili-style iOS demo where S-Bank data is the starting point, another bank can be connected, and receipt upload adds product-level context to a transaction.

**Architecture:** A SwiftUI app owns presentation and deterministic demo data behind injected service protocols. An optional Node backend keeps Enable Banking RSA credentials off-device and exposes a narrow mobile API for Finnish institutions, authorization and account synchronization.

**Tech Stack:** Swift 6, SwiftUI, PhotosUI, Vision, XCTest, XcodeGen, Node.js built-ins, Enable Banking AIS API.

**Spec:** `docs/superpowers/specs/penny-ios-demo.md`

## Global Constraints

- iOS 17 minimum.
- The initial dataset contains no SKU detail, including S Group transactions.
- Loyalty-based SKU enrichment is future copy only.
- No production credentials or private keys are embedded in the iOS target.
- Demo mode must complete every judged flow without network access.

## Review Focus

- A fresh launch must show only S-Bank data before connection.
- Cancelling bank connection or receipt selection must preserve current state.
- Duplicate bank connection must not duplicate accounts or transactions.
- Receipt parsing failure must leave the transaction usable and offer retry.
- Amounts, dates and negative/positive signs must remain consistent across screens.

---

### Task 1: Project foundation and domain model

**Files:**
- Create: `PennyApp/project.yml`
- Create: `PennyApp/PennyApp/Domain/Models.swift`
- Create: `PennyApp/PennyApp/Domain/DemoData.swift`
- Create: `PennyApp/PennyApp/Design/Theme.swift`
- Test: `PennyApp/PennyAppTests/DomainModelTests.swift`

**Interfaces:**
- Produces: `BankAccount`, `BankTransaction`, `Receipt`, `ReceiptLineItem`, `BankConnection`, `DemoData`.

- [ ] Write domain tests proving initial data is S-Bank-only and transactions begin without receipt line items.
- [ ] Run the tests and verify failure because the domain types do not exist.
- [ ] Add the XcodeGen configuration, domain types, fixture data and theme tokens.
- [ ] Generate the project and run tests until green.

### Task 2: App shell, login and S-Bank overview

**Files:**
- Create: `PennyApp/PennyApp/PennyApp.swift`
- Create: `PennyApp/PennyApp/AppStore.swift`
- Create: `PennyApp/PennyApp/Features/Login/LoginView.swift`
- Create: `PennyApp/PennyApp/Features/Bank/BankOverviewView.swift`
- Create: `PennyApp/PennyApp/Features/Bank/TransactionDetailView.swift`
- Create: `PennyApp/PennyApp/Shared/BrandComponents.swift`
- Test: `PennyApp/PennyAppTests/AppStoreTests.swift`

**Interfaces:**
- Consumes: Task 1 domain models and demo fixtures.
- Produces: `AppStore.login()`, transaction selection and the main four-tab app shell.

- [ ] Write store tests proving fake login transitions to the Bank tab and no external bank appears initially.
- [ ] Run tests and verify the expected missing-store failure.
- [ ] Implement app state and visually faithful login, overview, tabs and transaction detail.
- [ ] Run tests and build the simulator target until green.

### Task 3: Open-banking connection

**Files:**
- Create: `PennyApp/PennyApp/Services/OpenBankingService.swift`
- Create: `PennyApp/PennyApp/Services/DemoOpenBankingService.swift`
- Create: `PennyApp/PennyApp/Services/EnableBankingService.swift`
- Create: `PennyApp/PennyApp/Features/OpenBanking/ConnectBankView.swift`
- Create: `PennyApp/server/server.mjs`
- Create: `PennyApp/server/README.md`
- Test: `PennyApp/PennyAppTests/OpenBankingTests.swift`
- Test: `PennyApp/server/server.test.mjs`

**Interfaces:**
- Produces: `OpenBankingService.availableBanks()`, `connect(_:)`, and server endpoints `/api/banks`, `/api/connect`, `/api/callback`, `/api/sessions/:id`.
- Consumes: `AppStore` account/transaction merge methods.

- [ ] Write Swift and Node tests for Finnish bank listing, successful demo connection and duplicate suppression.
- [ ] Run both suites and verify failures before implementations exist.
- [ ] Implement the demo service, server-ready service, connection UI and secure backend adapter.
- [ ] Run both suites and the iOS build until green.

### Task 4: Receipt attachment, OCR parsing and coaching

**Files:**
- Create: `PennyApp/PennyApp/Services/ReceiptParser.swift`
- Create: `PennyApp/PennyApp/Services/ReceiptOCRService.swift`
- Create: `PennyApp/PennyApp/Features/Receipts/ReceiptAttachmentView.swift`
- Modify: `PennyApp/PennyApp/Features/Bank/TransactionDetailView.swift`
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Test: `PennyApp/PennyAppTests/ReceiptParserTests.swift`

**Interfaces:**
- Produces: `ReceiptParser.parse(text:)`, `ReceiptOCRService.recognize(data:)`, `AppStore.attachReceipt(_:to:)`.

- [ ] Write parser and store tests proving no initial SKU detail and receipt-derived line items after attachment.
- [ ] Run tests and verify failures for missing parser/attachment behavior.
- [ ] Implement PhotosPicker, Vision OCR, deterministic demo receipt and product-level Penny insight.
- [ ] Run tests and the iOS build until green.

### Task 5: Brand assets, polish and end-to-end verification

**Files:**
- Create: `PennyApp/PennyApp/Assets.xcassets/**`
- Create: `PennyApp/README.md`
- Modify: SwiftUI screens as required by simulator evidence.

**Interfaces:**
- Consumes: all prior tasks.
- Produces: runnable hackathon demo and setup documentation.

- [ ] Add public S-mobiili concept assets and exact brand color assets; document trademark/demo status.
- [ ] Build and test on an available iPhone simulator.
- [ ] Launch the app, capture key screens, and visually compare them with the public App Store references.
- [ ] Verify the full scripted flow: login → connect bank → open transaction → attach receipt → see product insight.

