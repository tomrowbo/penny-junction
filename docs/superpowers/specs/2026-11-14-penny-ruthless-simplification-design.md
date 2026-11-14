# Penny ruthless simplification design

## Intent

Make Penny feel personal, immediate and visual. Each root screen must answer one question without exposing analytical metadata, duplicated totals or explanatory filler. The product keeps its grounded calculations and evidence internally, but the ordinary UI shows only what helps a person decide or act.

## Goals

- Make Spend lead with one personal safe-to-spend decision, not two competing balances.
- Make Plan visual, icon-led and glanceable.
- Make goal editing readable, branded and concise.
- Make Ask Penny begin like a modern chat app: composer first, compact suggestions, history second.
- Let people open a new Penny chat with the selected financial item's verified context already attached.

## Anti-goals

- Do not show confidence, completeness, estimate labels, coverage dates, assumptions or calculation prose on root screens.
- Do not add another dashboard, disclosure accordion or large marketing CTA.
- Do not make context a free-form invented prompt or automatically send a model request.
- Do not replace S-Bank's native SF Pro typography or the supplied Penny mark.
- Do not reintroduce pale-green surfaces or black text on green buttons.

## Chosen approach

Use a **decision-first** hierarchy. Spend keeps safe-to-spend as its only dominant amount and removes the separate aggregate-balance block. Accounts remain compact source rows. Goals become visual tiles with a large icon and progress ring. Ask Penny uses an inline composer rather than a full-width “Start a conversation” button.

A bank-first alternative—total balance as the hero with safe-to-spend as a smaller insight—was rejected because it repeats conventional banking UI and works against the more personal coaching goal. A disclosure-heavy alternative was rejected because the user explicitly does not consider confidence, dates or calculation mechanics key information.

## Spend

The root header becomes personal: `Hi Tom` and `Here’s what your money can do today.` The dark image-backed hero contains only:

- a large shield icon;
- `Safe to spend`;
- `safeToday` as the only dominant amount;
- `Today`;
- one compact secondary line using the truthful scope already calculated: `until payday` when a payday exists, otherwise `over the next 30 days`.

Remove `Across your accounts`, exact period dates, estimate/completeness/confidence labels and `How this is calculated`. Do not replace them with another disclosure. The Accounts section follows immediately and shows each real account balance once. Recent spending remains a compact list.

## Plan

Each goal is one dark-forest-to-emerald visual tile containing only:

- a large semantic symbol;
- a circular percentage indicator;
- goal name;
- current amount of target amount;
- status with icon;
- monthly contribution and short target month/year.

Remove monthly-needed copy, projected-completion copy and the assumptions paragraph. The entire tile opens a new contextual Penny chat. A separate 44-point ellipsis button opens Edit Goal. The section-level add action is a 44-point emerald circular plus button.

## Goal editor

Replace the default Form with a ScrollView containing a visual header and two neutral glass panels: `Goal` and `Your plan`. Keep the existing name, target, target date, saved amount and monthly contribution data and validation rules. Remove instructional footer copy.

Cancel remains in the navigation bar with explicit dark text and an opaque light toolbar background. Save becomes a full-width 52-point deep-emerald button with white semibold text. Validation appears only after an invalid save attempt, directly above Save. Decimal-pad fields receive a keyboard Done action.

## Ask Penny

Replace the large green `Start a conversation` button with a neutral glass composer labelled `Ask Penny anything…`, a deep-emerald circular send/forward control with a white icon, and at most three compact prompt chips. Recent conversations stay below. This follows the established chat pattern of making the composer the primary entry rather than a marketing CTA.

## Contextual chat

Introduce reusable typed context for transactions, accounts, goals and upcoming items. Opening contextual chat selects Ask Penny, creates a new route and displays a compact context card plus two tailored prompt chips. It does not automatically send a message.

Goal tiles open contextual chat on their main tap. Transaction, account and incoming rows preserve their normal detail behavior and expose a separate Penny portrait action labelled `Discuss with Penny` so normal banking navigation is not broken.

The context payload contains identifiers and domain-verified facts only. Extend the native and backend coach request schema so the selected context reaches the model grounding layer; a UI-only context card is insufficient. The server treats these facts as selected-item context alongside the existing minimized financial snapshot. Existing calculation and evidence data remain available to Penny without being rendered as root-screen filler.

## Accessibility and platform constraints

- Native SwiftUI, iOS 17 minimum.
- Native SF Pro Dynamic Type roles; no rounded or competitor font.
- All actions at least 44 points.
- White text on filled deep-emerald actions; minimum WCAG AA contrast.
- Icons reinforce but never replace text/status meaning.
- Large Dynamic Type stacks values vertically without truncation.
- Reduce Motion removes nonessential animations.
- No UI test target is required for this work; verify with native unit tests, builds and bounded simulator screenshots.

## Completion criteria

- Spend has no competing aggregate-balance hero and none of the removed metadata/filler.
- Goal tiles are visually dominant and contain no assumptions or projection paragraphs.
- Cancel and Save are visibly readable in the rendered goal editor.
- Ask Penny starts from an inline composer and has no large green marketing CTA.
- Contextual chat opens with the selected item attached and no automatic send.
- Spend, Plan, Goal Editor, Ask Penny and one contextual chat are visually inspected on the simulator.
