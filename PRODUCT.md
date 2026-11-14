# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Users

The primary immediate users are Junction judges, challenge partners, and demo attendees evaluating a native S-mobiili concept. The represented end user is an existing S-mobiili customer who wants one familiar view of S-Bank and connected-bank finances.

## Product Purpose

Penny is a native SwiftUI prototype that demonstrates how an AI financial coach and open-banking data can live inside the familiar S-mobiili experience. Success means the prototype reads as S-mobiili at a glance, while Penny is clearly the only intentional product addition.

## Positioning

Penny completes the customer's financial picture by combining S-Bank and connected-bank account and transaction data, then grounding a conversational financial coach in that consolidated view.

Penny follows the leading banking-assistant specification: authenticated bank services calculate customer-scoped financial facts, while the language model receives only approved, minimised results to explain. Its differentiation is S-Bank's three-basket pedagogy, deterministic safe-to-spend guidance and transparent assumptions—not multi-bank chat alone. See `PennyApp/docs/LEADING_BANK_AI_SPEC.md`.

## Operating Context

The app is used as a guided iPhone demo. Demo data and mock open-banking connections provide reliable presentation states without requesting or storing real banking credentials.

## Capabilities and Constraints

- Native SwiftUI application with a minimum deployment target of iOS 17.
- Existing account, transaction, external-bank connection, goal, and Penny chat behavior must remain functional.
- Account and transaction-level analysis is in scope; receipt capture and SKU-level analysis remain out of scope for Penny.
- Public S-mobiili screens that are reproduced for visual parity may use static demonstration content where the prototype has no corresponding service.
- Penny is the only additional top-level tab. The S-mobiili top-level structure otherwise remains S-Etukortti, Bank, and Me.
- No real banking credentials, RSA keys, or OpenAI credentials are stored in the app.

## Brand Commitments

- The host experience must reproduce the public S-mobiili visual language as closely as the supplied App Store screenshots allow, including typography, color, sizing, spacing, icon treatment, and navigation structure.
- The product remains labelled as a non-production Junction concept and not an official S-Bank application.
- Existing public S-mobiili and bank marks in the asset catalog are demonstration assets only.

## Evidence on Hand

- Current S-mobiili App Store listing and eight English iPhone screenshots for version 2.43.0.
- Existing SwiftUI implementation in `PennyApp/PennyApp`.
- Existing S-Bank and connected-bank logo assets in `PennyApp/PennyApp/Assets.xcassets`.
- Synthetic account, transaction, goal, and chat data in `PennyApp/PennyApp/Domain`.
- No private S-mobiili source assets, design files, or proprietary fonts are available; unseen states must be faithful extrapolations from public references and native iOS conventions.

## Product Principles

1. Familiarity first: a current S-mobiili user should immediately recognize the host application.
2. Penny is additive: existing S-mobiili structure and visual hierarchy should not be redesigned around the coach.
3. Demonstrate with reliable data: every presentation path must work without external credentials.
4. Preserve financial clarity: balances, commitments, transactions, and actions remain scannable and unambiguous.
5. Be honest about the concept: do not imply production affiliation or fabricate live banking behavior.

## Accessibility & Inclusion

Preserve native VoiceOver semantics, 44-point minimum touch targets, sufficient contrast, Dynamic Type behavior, and reduced-motion compatibility. Pixel comparison is performed at the reference text size without disabling system accessibility behavior.
