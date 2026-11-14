# Penny Loading, History, and Profile Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace fake loading data, make chat feel conversational, persist real recent conversations, clarify the dashboard balance, and use a real profile affordance on every root screen.

**Architecture:** Keep the existing chat API response shape. Add reusable SwiftUI loading primitives, a local conversation store owned by `AppStore`, and deterministic client-side reply chunking; strengthen backend prompt style without weakening tool-grounding. Shared root-header changes propagate the supplied profile asset to all four tabs.

**Tech Stack:** Swift 5.9, SwiftUI/iOS 17, Observation, UserDefaults/JSONEncoder, TypeScript backend, asset catalogs.

**Spec:** `docs/superpowers/specs/2026-11-14-penny-loading-history-profile-design.md`

## Global Constraints

- Work directly on `main` and preserve unrelated dirty files/hunks.
- Build and inspect one default iPhone only; do not add/run UI tests or a large-font matrix.
- Keep the current chat API JSON schema and existing financial grounding/privacy rules.
- Keep light mode, current S-Bank typography, Penny mark, and navigation icons unchanged.
- Copy `pfp.png` byte-for-byte; never redraw, crop, tint, or recompress it.

## Review Focus

- API-configured cold launch must never flash demo balances before loading begins.
- Failed official-data loading must leave an honest unavailable/fallback state rather than an endless skeleton.
- Reopening a saved conversation must restore its actual messages and correct context without duplicating it.
- Reply chunking must preserve every character in order and attach evidence/charts/prompts exactly once.
- Logging out must return to login without deleting goals or chat history.

---

### Task 1: Profile asset and root settings affordance

**Files:**
- Create: `PennyApp/PennyApp/Assets.xcassets/ProfileAvatar.imageset/Contents.json`
- Create: `PennyApp/PennyApp/Assets.xcassets/ProfileAvatar.imageset/pfp.png`
- Modify: `PennyApp/PennyApp/Shared/PennyGlassChrome.swift`
- Modify: `PennyApp/PennyApp/Features/Profile/MeView.swift`

**Interfaces:**
- Produces: `ProfileAvatar(size:)` and the existing `PennyRootHeader` opening `MeView`.

- [ ] Copy the profile PNG byte-for-byte and add an original-rendering asset manifest.
- [ ] Add `ProfileAvatar(size:)` with a circular white/glass plate and replace the `PennyMark` inside `PennyRootHeader` only.
- [ ] Use the same avatar in the profile identity card and add a destructive `Log out` button setting `store.isAuthenticated = false`.
- [ ] Confirm the bundled hash equals `f22a2ac70de918b60579175205e4c6d7675bb699c62dd9a4c5d5a0f3d2c0e25e`.
- [ ] Commit only owned files as `Use profile avatar across Penny roots`.

### Task 2: Honest skeleton loading and available balance

**Files:**
- Create: `PennyApp/PennyApp/Shared/PennySkeleton.swift`
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennySpendView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyIncomingView.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/SafeToSpendCard.swift`

**Interfaces:**
- Produces: `PennySkeletonBlock`, `SpendLoadingSkeleton`, `IncomingLoadingSkeleton`, and `AvailableBalanceCard(amount:accountCount:)`.

- [ ] Initialize `sBankDataStatus` to `.loading` synchronously when `PennyAPIConfiguration.baseURL != nil`; retain `.fallback` for unconfigured demo launches.
- [ ] Build a reusable fixed-geometry skeleton block with one restrained left-to-right highlight and no fabricated copy.
- [ ] Branch Spend and Incoming on `.loading`, keeping their real header and showing skeleton shapes for unloaded financial sections.
- [ ] Replace `SafeToSpendCard` usage with `AvailableBalanceCard(amount: store.totalPositiveBalance, accountCount: store.accounts.count)` and remove all safe-to-spend copy from the dashboard hero.
- [ ] Commit only owned changes as `Make Penny loading honest and clear`.

### Task 3: Persist real conversation history

**Files:**
- Create: `PennyApp/PennyApp/Services/PennyConversationStore.swift`
- Modify: `PennyApp/PennyApp/AppStore.swift`
- Modify: `PennyApp/PennyApp/Domain/Models.swift`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`

**Interfaces:**
- Produces: `PennyStoredConversation`, `PennyStoredMessage`, `PennyConversationStore`, `AppStore.chatHistory`, and `AppStore.saveConversation(...)`.

- [ ] Define Codable stored conversation/message records containing ID, title, preview, updated date, symbol, optional context, and ordered role/text messages; cap history at 30 conversations and messages at 100 per conversation.
- [ ] Load history in `AppStore.init`, save atomically through a UserDefaults-backed store, and upsert newest-first without seeding hard-coded samples.
- [ ] Render `chatHistory` in Recent conversations, show an honest empty state when none exists, and format relative times from `updatedAt`.
- [ ] Derive icons deterministically from context and known transaction/goal data; generic chats keep Penny.
- [ ] Persist after every user send and each received Penny chunk so previews and reopened transcripts stay current.
- [ ] Commit only owned changes as `Persist Penny conversations`.

### Task 4: Conversational thinking and concise replies

**Files:**
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`
- Modify: `PennyApp/backend/src/lib/coach-tools.ts`
- Modify: `PennyApp/backend/src/lib/coach.ts`

**Interfaces:**
- Produces: `PennyReplyChunker.chunks(from:maxChunks:)` and `PennyThinkingBubble`.

- [ ] Replace `ProgressView` with a Penny-avatar `Thinking…` bubble using a subtle masked moving highlight and fixed geometry.
- [ ] Implement deterministic paragraph/sentence chunking into at most three non-empty bubbles, preserving text order and content.
- [ ] Reveal chunks sequentially with a short bounded delay; attach evidence, visualizations, prompts, and source only to the last chunk.
- [ ] Tighten both backend prompts: verified statistic first, casual shorthand, one interpretation, one useful next action, no generic preamble, and no invented numbers.
- [ ] Commit only owned changes as `Make Penny replies feel conversational`.

### Task 5: Default-screen build and handoff

**Files:**
- No production files unless a build-blocking issue is found.

**Interfaces:**
- Consumes: Tasks 1–4.

- [ ] Build the native app once with code signing disabled.
- [ ] Inspect one default iPhone flow covering Spend loading/loaded state, Ask thinking/reply/history, and the root profile button.
- [ ] Fix only build blockers or clear default-screen defects in one bounded pass.
- [ ] Verify the profile asset hash and confirm Penny/nav asset hashes remain unchanged.
- [ ] Commit any bounded fix separately and report final SHAs; do not run UI tests or large-font checks.

