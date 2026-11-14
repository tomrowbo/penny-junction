# Penny Live Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect the Penny iOS concept to a Next.js API that supports Finnish open banking and data-grounded AI coaching.

**Architecture:** Next.js route handlers wrap Enable Banking and OpenAI. The iOS app uses a live service for bank authorization/data import and a chat client for goal conversations, with mock banking mode available for demo reliability.

**Tech Stack:** Next.js 16, TypeScript, OpenAI JavaScript SDK, Node crypto, SwiftUI, ASWebAuthenticationSession

**Spec:** `docs/superpowers/specs/2026-11-13-penny-live-backend-design.md`

## Global Constraints

- iOS 17 minimum and Swift 6.
- Secrets remain server-side.
- Read-only account information; no payments.
- Keep verification hackathon-sized: route smoke tests and app builds only.

## Review Focus

- Invalid or replayed callback state returns an error rather than a session.
- Missing provider credentials leaves mock mode usable and explains live configuration clearly.
- Provider payload variation does not crash normalization.
- OpenAI failures become retryable API errors and never expose secrets.
- iOS callback cancellation and malformed deep links leave the existing data unchanged.

---

### Task 1: Next.js API foundation

**Files:**
- Create: `PennyApp/backend/package.json`
- Create: `PennyApp/backend/src/app/api/health/route.ts`
- Create: `PennyApp/backend/src/lib/config.ts`

**Interfaces:**
- Produces: `GET /api/health` with provider/model configuration state.

- [ ] Scaffold a minimal TypeScript App Router project and environment template.
- [ ] Implement validated server configuration and health response.
- [ ] Run lint/typecheck and call the health endpoint.

### Task 2: Enable Banking adapter and routes

**Files:**
- Create: `PennyApp/backend/src/lib/enable-banking.ts`
- Create: `PennyApp/backend/src/lib/open-banking-types.ts`
- Create: `PennyApp/backend/src/app/api/open-banking/**/route.ts`

**Interfaces:**
- Produces: bank list, authorization URL, callback redirect, and normalized `BankConnection` JSON.

- [ ] Implement RS256 authentication, signed state, provider calls, pagination, and normalization.
- [ ] Implement deterministic mock bank discovery and connections using the same contract.
- [ ] Smoke-check mock bank discovery, connect, and session retrieval.

### Task 3: OpenAI coaching route

**Files:**
- Create: `PennyApp/backend/src/lib/coach.ts`
- Create: `PennyApp/backend/src/app/api/chat/route.ts`

**Interfaces:**
- Consumes: conversation plus normalized accounts and transactions.
- Produces: `{ message: string }`.

- [ ] Validate and cap incoming financial context.
- [ ] Call the Responses API with a financial-literacy prompt and grounded context.
- [ ] Smoke-check missing-key and malformed-request behavior; exercise the live call when a key is present.

### Task 4: iOS live open-banking flow

**Files:**
- Modify: `PennyApp/PennyApp/Services/EnableBankingService.swift`
- Modify: `PennyApp/PennyApp/Features/OpenBanking/ConnectBankView.swift`
- Modify: `PennyApp/project.yml`

**Interfaces:**
- Consumes: backend bank and connection contracts.
- Produces: `BankConnection` merged through the existing `AppStore.merge(connection:)`.

- [ ] Add backend DTO decoding and browser-based authentication callback.
- [ ] Select backend or deterministic demo service from app configuration.
- [ ] Build for simulator and physical-device targets.

### Task 5: iOS AI chat flow and handoff

**Files:**
- Create: `PennyApp/PennyApp/Services/PennyChatService.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`
- Create: `PennyApp/backend/README.md`

**Interfaces:**
- Consumes: current `AppStore` financial context and chat history.
- Produces: live assistant messages in the existing goal conversation UI.

- [ ] Replace the placeholder reply with an async backend request and visible loading/error states.
- [ ] Document Enable Banking sandbox registration, OpenAI key setup, tunnel URL, and iPhone base URL.
- [ ] Run backend checks, iOS build, and an end-to-end mock request.
