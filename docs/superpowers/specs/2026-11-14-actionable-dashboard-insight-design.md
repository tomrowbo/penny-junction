# Actionable Dashboard Insight Design

## Intent

Turn Penny's passive dashboard subtitle into one personalised, evidence-backed action. The header should help the customer identify a realistic saving opportunity immediately and give judges a visible example of proactive financial coaching.

## Experience

- Replace the rotating descriptive subtitle with Penny's highest-value eligible personal-baseline insight.
- Present it as a concise tappable line, for example: **Save an extra €39 a month →**.
- Calculate the amount from the discretionary spending category furthest above the customer's own recent monthly baseline, using only loaded official S-Bank data plus any currently connected open-banking data.
- On tap, open a new contextual Penny conversation and immediately show two short assistant messages: first the evidence, then the suggested achievable adjustment and relevant goal impact.
- The conversation may include a compact comparison chart and quick follow-ups such as **Show me where**, **Try another idea**, and **Adjust my goal**.
- If no sufficiently supported opportunity exists, retain a truthful non-actionable dashboard subtitle rather than inventing a recommendation.

## Trust Boundaries

- Deterministic code calculates the category, baseline, difference, data period, and goal impact; the language model only explains those facts.
- Describe spending as discretionary or above the customer's baseline, never as unnecessary.
- Do not claim money was saved, allocated, transferred, or protected.
- Do not recommend removing a subscription merely because a recurring charge exists; Penny may ask whether the customer still uses it.
- Use comparable complete months and comparable institution coverage so a newly connected bank does not create a false trend.

## Goals and Non-goals

The goal is one calm, prominent recommendation that turns dashboard insight into a contextual conversation. This change does not add automatic transfers, notifications, product recommendations, a feed of competing cards, or multiple simultaneous dashboard actions.

## Approaches Considered

1. **Personal baseline — selected.** Find the discretionary category furthest above the customer's own recent average. It is personal, explainable, and defensible.
2. **Goal-gap coaching.** Start with the savings-target shortfall and construct reductions to close it. Rejected for the primary insight because it can feel prescriptive.
3. **Opportunity bundle.** Combine several small category changes. Rejected for the primary insight because it adds complexity and text; it remains suitable as an optional chat follow-up.

## Builder Calls

- Show only one recommendation at a time and rank it by credible monthly saving opportunity.
- Prefer a three-complete-month baseline; fall back only when enough comparable history exists to avoid misleading results.
- Deep-link using Penny's existing contextual-chat route and create a genuinely saved recent conversation.
- Keep the existing light-mode typography and compact header treatment; the line should look like part of the header, not another dashboard card.
