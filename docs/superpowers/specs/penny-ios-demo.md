# Penny iOS Demo Design

## Intent

Build a polished native iOS concept that feels like a credible extension of S-mobiili and demonstrates how Penny completes an incomplete financial picture. The demo is for Junction judges and must remain dependable without production banking credentials.

## Product story

The user signs into a fake S-mobiili account and initially sees only S-Bank balances and the synthetic S-Bank transaction data. The supplied demo data contains merchant-level transactions only; it must not imply automatic SKU data from S Group.

The user can then:

1. Connect another Finnish bank through an open-banking flow, adding an external mortgage/account to the financial picture.
2. Open any transaction and attach a photographed or uploaded receipt.
3. See product-level line items and a clearer Penny coaching insight after the receipt is processed.

The future story is that S Group and other loyalty programmes could attach product data automatically. That future capability is labelled clearly and is not simulated as existing challenge data.

## Goals

- Native SwiftUI app runnable in an iPhone simulator.
- Visual language closely follows public S-mobiili App Store screenshots: green brand palette, system typography, pale green surfaces, white cards, four-tab navigation and simple outlined icons.
- Fake login requiring no credentials.
- S-Bank-only initial state.
- Reliable judged demo of connecting another bank.
- Real open-banking integration boundary using Enable Banking's Finnish AIS flow through a server-side adapter.
- Receipt upload from Photos, OCR-capable parsing, and a bundled deterministic demo receipt path.
- Visible before/after coaching improvement when receipt context is added.

## Non-goals

- Production authentication, money movement or payment initiation.
- Storing banking secrets in the iOS app.
- Claiming that the challenge dataset contains SKU data.
- Rebuilding every S-mobiili section.
- Production-grade receipt reconciliation across arbitrary merchants.

## Approaches considered

### Provider-only live integration

Most realistic, but external certificates, sandbox availability and redirect configuration could block the hackathon demo.

### Native demo with a real provider adapter (selected)

The app uses one `OpenBankingService` interface. Demo mode completes locally and predictably; configured mode calls a small backend that performs Enable Banking JWT authentication, `/auth`, `/sessions`, account and transaction retrieval. This proves the production architecture while preserving demo reliability.

### Web wrapper

Faster to prototype but visually less credible beside S-mobiili and weaker for camera, Photos and native bank-auth redirects.

## Experience

### Login

An S-mobiili-branded welcome screen with a prominent “Log in” action. It is explicitly a concept/demo and never asks for real bank credentials.

### Bank overview

The default Bank tab shows the S-Bank account, available balance and transactions. A Penny card explains that only S-Bank is visible and offers “Connect another bank.”

### Open banking

The user selects Nordea, OP or Danske Bank, reviews the requested read-only access, and completes a branded bank-auth step. Demo mode returns a connected external mortgage and account. Configured mode opens the Enable Banking authorization URL in an authentication session and refreshes data after callback.

### Receipt

A Prisma transaction initially shows only merchant, amount, date and category. The user chooses a receipt image or “Use demo receipt.” OCR/parser output is attached to the transaction, revealing item rows and spending-basket totals. Penny then gives a more specific insight.

### Future loyalty layer

A small explanatory card says that connecting loyalty programmes could provide the same SKU detail instantly in a future product. It does not appear as present data.

## Constraints

- iOS 17 minimum, SwiftUI, system SF typography.
- Enable Banking secrets and private keys remain server-side.
- Public brand assets are included only for this non-production Junction concept.
- All core demo paths work offline in demo mode.

