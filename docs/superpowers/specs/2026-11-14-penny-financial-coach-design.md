# Penny Financial Coach Design

## Intent

Make Penny useful before the customer asks a question. The home experience should answer what is safe to spend, what money is coming next, and whether active goals are on track. Chat answers should be able to present trustworthy native charts and tables backed by the same calculated data.

## Product shape

- **Safe to spend:** one current amount for today and until payday, after reserving known commitments and goal contributions. Always show the period, assumptions and data completeness.
- **Upcoming money:** detected bills, subscriptions and income in chronological order, including total committed outflow and price-change indicators where supported.
- **Persistent goal plans:** Codable plans with target amount/date, current progress, required contribution, status and scenario impact. They survive relaunch and can be created from chat.
- **Evidence visualizations:** typed native Swift Charts and tables for category bars, trends, goal projections, cash-flow breakdowns, transactions and upcoming payments. Every visual names its period and accounts and links back to underlying evidence.

## Trust boundary

The language model selects from a closed visualization schema and references backend-calculated values. It never supplies unaudited arbitrary chart values, edits financial records or moves money. Missing data and assumptions remain visible.

## UX

Use the existing S-mobiili/Penny canvas, compact white surfaces, green interaction voice, SF Pro, Dynamic Type and 44-point targets. Prioritize one number and one action per card. Use native Swift Charts and native scrolling tables/lists; charts must remain understandable with VoiceOver and without color alone.

## Approaches

1. **Typed domain modules plus central integration (chosen):** four isolated calculators/components feed the existing AppStore and Penny views. This supports parallel ownership and keeps calculations testable.
2. One large dashboard view: faster initially but couples calculations, storage, AI schema and rendering.
3. Free-form AI-generated JSON/UI: rejected because it weakens financial correctness and accessibility.

## Constraints

- iOS 17+, SwiftUI and Swift Charts; no new third-party app dependency.
- Preserve current bank connection, account, transaction and chat behavior.
- Demo mode must remain deterministic without credentials.
- Do not redesign Accounts, Me or the host navigation.
