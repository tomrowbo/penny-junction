# Casual Chart Replies Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace repetitive analytical walls of text with short, casual bubbles and compact charts.

**Architecture:** The backend prompt owns tone and information density, the deterministic visualization builder owns chart density, and SwiftUI owns message pacing. Financial calculations and source payloads remain untouched.

**Tech Stack:** TypeScript, Next.js backend, SwiftUI, Swift Charts

**Spec:** `docs/superpowers/specs/2026-11-14-casual-chart-replies-design.md`

## Global Constraints

- Preserve governed analytics and native charts.
- Do not add or run tests at the user's request.
- Commit directly to `main`.

## Review Focus

- Short responses must retain the leading verified value.
- Chart responses must not enumerate every plotted value.
- One-sentence responses must remain one bubble.
- Two-sentence responses must never exceed two bubbles.
- Category charts must preserve descending order when capped.

---

### Task 1: Casual analytical copy

**Files:**
- Modify: `PennyApp/backend/src/lib/coach-tools.ts`
- Modify: `PennyApp/PennyApp/Features/Penny/PennyCoachView.swift`

- [ ] Tighten model instructions to fewer than 35 words, three mentioned values maximum, and a clear insight/follow-up sentence split.
- [ ] Restore client reply chunking with a maximum of two bubbles.

### Task 2: Compact category chart

**Files:**
- Modify: `PennyApp/backend/src/lib/penny-visualization.ts`

- [ ] Limit category visualization points to the five largest calculated categories.
- [ ] Run backend type/build verification and a native iOS build.
- [ ] Commit and push the scoped changes to `main`.
