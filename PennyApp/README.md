# Penny for S-Bank

A standalone native SwiftUI Junction prototype showing how an AI financial coach can complete the customer's financial picture. Penny uses a Finnish banking-inspired visual system while remaining clearly separate from S-mobiili.

## Demo flow

1. Launch and use the fake login.
2. Penny opens on the goals dashboard with standalone **Penny**, **Accounts**, and **Me** navigation.
3. Start `backend/`, open Penny, and connect Nordea, OP or Danske Bank. Backend mock mode adds a synthetic current account and mortgage through the real API contract.
4. Create a goal, choose a challenge-inspired starter or type any question. Expand **How this was calculated** to see coverage, confidence, assumptions and the three baskets.
5. Open Accounts to see the consolidated multi-bank transaction view, or Me to inspect connected data and privacy boundaries.

The product deliberately stays at account and transaction level. Receipt capture and SKU-level analysis are out of scope following challenge-partner feedback. Proactive app notifications may appear in the pitch deck as a future concept, but are not implemented in this build.

## Run

```bash
xcodegen generate
open PennyApp.xcodeproj
```

Select an iPhone simulator and run the `PennyApp` scheme. The minimum deployment target is iOS 17.

## Visual-system reference

The immutable public references, source URLs, hashes and crop limitations are in `VisualReferences/SMobiili-2.43.0/`. Create or retain an iOS 26.2 iPhone 17 Pro simulator named `Penny Visual Reference`, then run:

```bash
./Scripts/capture_visual_parity.sh
```

Raw simulator screenshots and historical reference/build pairs are written to `../.impeccable/review/`. These references inform density, spacing and colour; the shipped prototype is a standalone Penny interface rather than a visual replica.

## Backend, open banking and AI

The app uses an injected `OpenBankingService`. Debug builds may connect to the allowlisted local Next.js API in `backend/`; Release builds contain no backend URL and fall back to synthetic demo data. Non-Debug backend URLs must use HTTPS. The backend supports reliable mock sessions and the real Enable Banking Finnish sandbox flow. Penny goal conversations call OpenAI's Responses API through the same backend. No RSA or OpenAI credentials are put in the app.

The backend calculates financial facts before invoking the language model. Raw transaction rows, account identifiers and merchant records are not included in the model request; the model receives minimised analytical results and redacted conversation text.

See [`docs/LEADING_BANK_AI_SPEC.md`](docs/LEADING_BANK_AI_SPEC.md) for the competitor benchmark, target architecture, privacy language and demo acceptance criteria. See [`backend/README.md`](backend/README.md) for setup. `server/server.mjs` is the earlier proof of concept and is no longer used by the app.

See [`docs/CHALLENGE_REQUIREMENTS.md`](docs/CHALLENGE_REQUIREMENTS.md) for the exact S-Pankki requirement-to-demo evidence matrix.

The reconstructed interface rules are recorded in [`../DESIGN.md`](../DESIGN.md).

## Brand note

Penny is the prototype identity. Bank marks identify connected institutions or the challenge partner only. This project is not an official production S-Bank application.
