# S-mobiili Visual Parity Design

## Intent

Reconstruct the public S-mobiili iPhone interface in the Penny SwiftUI prototype so like-for-like screens can be compared side by side. Penny remains the only intentional structural addition.

## Why

The current prototype communicates the concept but uses generic SwiftUI cards, placeholder tabs, approximate spacing, and current system tab-bar styling. That makes the demo read as an S-mobiili-inspired app rather than an extension of S-mobiili. The target is immediate visual continuity for a Junction presentation.

## Goals

- Match the eight public English iPhone App Store references for S-mobiili 2.43.0 as closely as the available evidence permits.
- Match font family, text styles, weights, line wrapping, colors, dimensions, corner radii, borders, icon scale, spacing, and safe-area placement.
- Replace the current five-tab structure with S-Etukortti, Bank, Penny, and Me, making Penny the only added tab.
- Recreate the reference-visible S-Etukortti, bank service list, wallet, receipt, Saver, and Me screens with navigable demo content.
- Keep existing Penny, account, transaction, connected-bank, goal, and chat behavior working.
- Produce same-size reference/build pairs and side-by-side composites for visual review.

## Non-goals

- Reverse engineering private S-mobiili code, APIs, or screens not visible in the public reference material.
- Implementing real S Group benefits, receipts, card provisioning, authentication, or production banking actions.
- Reproducing App Store marketing typography or backgrounds outside the depicted in-app phone frames.
- Changing Penny's product scope to receipt or SKU-level analysis.

## Anti-goals

- A loose brand-inspired interpretation.
- Generic rounded-card styling that only approximates the references.
- Leaving placeholder top-level tabs or making Penny visually dominate the host app.
- Hard-coding one screenshot as a raster image instead of building accessible, navigable SwiftUI.
- Claiming pixel equality for states that are not present in the public references.

## Constraints

- Native SwiftUI, iOS 17 minimum, existing Xcode project and data/services.
- The immutable visual source of truth is the eight-image English iPhone screenshot set returned for S-mobiili 2.43.0 by Apple's Finnish App Store lookup endpoint on 13 November 2026. The implementation must store the original downloaded files, their source URLs, dimensions, retrieval date, and SHA-256 hashes under `PennyApp/VisualReferences/SMobiili-2.43.0/`.
- San Francisco system typography is used for in-app UI; no evidence supports a separate proprietary in-app font.
- The authoritative build capture uses the existing iPhone 17 Pro simulator with iOS 26.2, light appearance, English UI with `en_FI` formatting, default Dynamic Type, and the simulator's native screenshot scale. Reference/build comparison tooling normalizes crops to the same visible-content width without stretching either axis.
- The public references are marketing composites rather than raw app screenshots. Straight device frames are cropped to visible app content. Angled S-Etukortti frames stay unrectified because their phone edges and hidden regions are clipped; `perspective: true` marks them as qualitative topology, copy, color, and proportion evidence only. No comparison may imply that hidden or clipped source regions were verified.
- Other supported iPhone sizes must preserve the same visual hierarchy without clipping.
- The prototype must retain its concept disclaimer and must not request real credentials.

## Approaches Considered

### 1. Bank-only facelift

Rebuild only the existing bank landing screen. This is fast, but the placeholder tabs, tab count, and remaining screens still reveal the prototype immediately. Rejected because it does not satisfy like-for-like app parity.

### 2. Native approximation

Keep standard SwiftUI `TabView`, navigation styling, generic SF Symbols, and semantic spacing while moving colors and copy closer to S-mobiili. This is robust across OS versions but reproduces iOS 26 chrome rather than the public S-mobiili reference. Rejected because the user explicitly requires side-by-side fidelity.

### 3. Reference-driven SwiftUI reconstruction — selected

Build reusable S-mobiili tokens and components from measured screenshot evidence, reproduce every public in-app reference surface, and use a controlled four-item bottom navigation shell so OS-version visual changes do not alter the comparison. Preserve native navigation behavior, accessibility semantics, and safe-area handling beneath that visual layer.

## Screen Architecture

### Top-level shell

Four sections in this order:

1. S-Etukortti
2. Bank
3. Penny
4. Me

The shell reproduces the compact white S-mobiili tab bar with green selected state. Penny uses the same icon/label grammar and spacing as the three host tabs.

### S-Etukortti

- Green branded header and barcode action.
- Bonus and purchases and Receipts actions.
- Benefits and current-content cards using the reference hierarchy and demo imagery/content where available.
- Navigation to the recreated Wallet and Receipt reference screens.
- The section contains a horizontally swipeable two-page top-level state with the reference page indicator: the first page is the bonus/account overview and the second is the S-Etukortti benefits/receipts page. The bottom S-Etukortti tab remains selected for both pages. There is no separate Home tab.

### Bank

- Inline `S-Bank` title and message action.
- Pale green canvas and compact white service rows.
- Services and visible ordering match the reference: Accounts, Payments and e-invoices, Cards, Säästäjä, Investments, and Loans.
- Accounts retains the prototype's functional consolidated account and transaction flow.
- Säästäjä opens the recreated goal screen and can connect onward to existing Penny goal behavior where appropriate.

### Penny

- Existing coach behavior remains intact.
- Its outer chrome, typography, colors, row geometry, and navigation match the host system so it reads as a native S-mobiili section.
- Penny remains identifiable by its label and coach content, not a separate visual theme.

### Me

- Inline title and message action.
- Reference avatar, name, logout, personal-information row, authentication actions, and S-Bank service grouping.
- Static demo actions are visually complete and clearly non-production where invoked.

### Detail references

- Wallet reproduces the two green cards and header actions.
- Receipt reproduces the merchant row, total, barcode and share actions, and monospaced receipt body.
- Saver reproduces goal amount, progress, dates, target status, and action list.

## Visual System

- Extract colors from the source screenshots and record them as named SwiftUI tokens with light-mode values; semantic fallbacks cover unsupported appearances.
- Use Dynamic Type-compatible SF Pro text styles, then tune weights, leading, and width constraints to reproduce reference line breaks at the comparison viewport.
- Record exact row heights, horizontal insets, gaps, corner radii, separator weights, icon frames, and bar heights in a central metrics type.
- Prefer supplied logo assets and SF Symbols that match the visible glyphs. Where an S-mobiili glyph has no faithful SF Symbol equivalent, author a small vector path rather than substitute a semantically different icon.
- Use tabular numerals for balances and dates where the references require stable alignment.
- Preserve 44-point touch targets even when the visible glyph is smaller.

## Interaction and States

- Use `NavigationStack` for detail navigation and retain the system edge-swipe gesture.
- Match reference transitions with native push navigation.
- Static reference-only actions may show a concept-safe informational sheet; functional prototype paths continue to work.
- Support standard, large Dynamic Type, light, and dark appearances without breaking layout. Light mode is the pixel-comparison authority because all references are light.
- Respect Reduce Motion; no decorative motion is needed for parity.

## Visual Verification

- Store the eight pinned public reference screenshots under `PennyApp/VisualReferences/SMobiili-2.43.0/` with source metadata and hashes.
- Capture each corresponding app state from the iOS Simulator at a fixed iPhone device and text size.
- Generate side-by-side composites with reference left and build right, at equal viewport scale.
- Acceptance is reviewer-led because the public sources are cropped marketing composites, but measurable straight regions must meet these targets: geometry within 1 point where an edge is visible, RGB channels within 3/255 for flat fills, identical text content and line breaks, and no visible icon, weight, alignment, clipping, or hierarchy mismatch at 2× inspection. Unrectified angled S-Etukortti imagery is judged qualitatively rather than assigned a global pixel threshold.
- Review in one primary pass, batch all material corrections, then perform one confirmation pass.
- Automated tests cover tab order, visible reference copy, metric/token values, and demo navigation state. Simulator screenshots provide the fidelity evidence that unit tests cannot.

## Builder Calls

- The public in-app screenshots, not the current prototype, are visual authority.
- Light-mode reference parity takes precedence over adopting new iOS 26 visual treatments.
- Publicly unseen screens inherit the reconstructed component system and native iOS behavior.
- Static demo content is acceptable for S-mobiili services outside Penny's functional scope.
- No new third-party UI dependency is required.

## Open Decisions

None. The user approved full visible-surface parity and side-by-side comparison, with Penny as the only added tab.
