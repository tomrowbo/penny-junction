# Penny leading bank AI specification

Penny follows the strongest pattern already visible across leading banking assistants: the assistant can use the customer's complete authorised financial picture, but the language model does not receive unrestricted database access or raw banking records. Bank-controlled services authenticate the customer, retrieve the permitted data, calculate financial facts and expose only bounded capabilities to the conversational layer.

This is deliberately a leading-market specification rather than a claim that conversational multi-bank access is unique. Penny's differentiation is the way it combines that established architecture with S-Bank's three-basket pedagogy, explainable recommendations and deterministic safe-to-spend guidance.

## Leading products and the pattern Penny adopts

| Product | Publicly documented approach | Specification adopted by Penny |
|---|---|---|
| **Bank of America Erica** | Searches transactions and retrieves balances through defined capabilities. Bank of America states that Erica selects predefined responses and does not use generative AI or LLMs. | Bound the assistant to approved banking capabilities rather than arbitrary database access. |
| **Capital One Eno** | Uses event-driven processing and insight-specific business logic for alerts such as duplicate charges and subscription increases. | Calculate financial facts deterministically before conversation. |
| **bunq Finn** | Answers questions over bunq and connected external-bank accounts. bunq documents a temporary request snapshot and controlled use of Azure OpenAI, Gemini and Anthropic services with no permanent partner retention or training. | Support the customer's authorised multi-bank picture while minimising what reaches the model. |
| **Revolut AIR** | Uses transaction, card and investment information and can initiate bounded tasks. Revolut documents consent-based disclosure to technology partners with zero-retention and no-training terms. | Make processor use transparent and keep actions explicit and constrained. |
| **NatWest Spending Insights** | Uses proprietary small language models for conversational transaction insights; its detailed query and hosting architecture is not public. | Preserve the option to run inference within a bank-controlled environment when customer-derived data must not leave it. |

Sources: [Bank of America Erica](https://info.bankofamerica.com/en/digital-banking/erica), [Capital One Eno architecture](https://www.capitalone.com/tech/cloud/eno-real-time-alerts-powered-by-serverless/), [bunq Finn](https://help.bunq.com/en/articles/meet-finn-your-personal-assistant), [bunq Finn privacy](https://help.bunq.com/articles/how-does-finn-safeguard-my-privacy), [Revolut AIR](https://www.revolut.com/news/revolut_enters_new_era_of_money_intelligence_with_launch_of_ai_assistant/), [Revolut AIR legal notice](https://www.revolut.com/legal/rita-disclaimer/), and [NatWest Spending Insights](https://www.natwestgroup.com/news-and-insights/news-room/press-releases/2026/natwest-group-first-to-unveil-next-generation-of-ai-tools-to-hel.html).

## Target architecture

```text
Authenticated S-mobiili customer
              │
              ▼
Bank-controlled orchestration layer
  - customer identity and consent
  - S-Bank and PSD2 account scope
  - approved analytical capabilities
              │
              ▼
Customer-scoped analytics layer
  - read-only, parameterised queries
  - three-basket classification
  - safe-to-spend and safe-to-save
  - what-if simulations
  - coverage, confidence and assumptions
              │
              ▼
Minimised calculated facts
  - no names, IBANs or account identifiers
  - no merchant-level rows or raw transaction dump
              │
              ▼
Language model explanation
  - plain language
  - pedagogical and non-judgmental
  - no independent arithmetic
  - no autonomous financial decisions
```

The language model selects from typed analytical capabilities such as:

- `spending_by_category(period, account_scope)`
- `compare_periods(period_a, period_b, category)`
- `safe_to_spend(horizon)`
- `safe_to_save(period)`
- `simulate_spending_reduction(category, percentage)`
- `explain_transaction(transaction_reference)`

The authenticated backend supplies the customer identifier and account scope. They are never accepted from model-generated arguments. Bank code owns the query, classification and arithmetic; the model explains the returned result.

## Database and SQL boundary

The production assistant may analyse all data the customer has authorised, including S-Bank history and connected PSD2 accounts. This does not mean placing every record in a prompt or allowing arbitrary SQL.

The default production design uses allow-listed analytical tools with parameterised, customer-scoped queries. If text-to-SQL is added later, execution must still enforce all of the following outside the model:

- server-injected customer and consent scope;
- database row-level security with default-deny access;
- a read-only database role and transaction;
- one validated `SELECT` statement from an allow-listed schema;
- parameter validation plus row, cost and execution-time limits;
- an audit record containing tool, version, scope, parameters and result metadata;
- no raw financial content in ordinary application logs.

The model is never the authentication, authorisation or SQL-validation boundary.

## Calculation and recommendation boundary

The financial engine decides; the language model explains.

Safe-to-spend, safe-to-save, cash-flow forecasts and what-if values are versioned deterministic calculations. Each result includes:

- the institutions and accounts included;
- the coverage period and number of transactions analysed;
- the relevant mandatory regular, mandatory irregular and everyday baskets;
- assumptions and confidence;
- the calculation version;
- one achievable, non-judgmental next step.

The model must not invent missing transactions, silently infer income or commitments, or perform unverified arithmetic. When coverage is insufficient, it says so and identifies what additional data would improve the answer.

## Privacy language

The approved architecture claim is:

> Raw transaction records and direct identifiers remain in the bank analytics layer. The language model receives only the minimum customer-derived facts required for the explanation. A production deployment must use S-Bank-approved retention and no-training terms.

Do not claim that no personal data reaches the language model. A derived result such as a customer's safe-to-spend value can remain personal data under GDPR even after names and account numbers are removed. If S-Bank requires zero customer-derived data outside its controlled environment, the same architecture must use a bank-hosted or otherwise approved private model deployment.

## Penny differentiation

bunq already demonstrates conversational access across connected banks, so multi-bank chat alone is not Penny's innovation. Penny combines:

- the multi-bank breadth demonstrated by bunq;
- the constrained, deterministic insight generation used by established banking assistants;
- S-Bank's three spending baskets;
- transparent coverage, assumptions and confidence;
- versioned classifications and explainable what-if scenarios;
- a standalone Penny mobile experience using a compatible Finnish banking-inspired visual system.

Judge-ready positioning:

> Penny combines the breadth of leading multi-bank assistants with the control of established banking platforms: S-Bank computes every financial fact inside a customer-scoped analytics layer, and AI turns only approved, minimised results into clear coaching across the three spending baskets.

## Prototype status and production gap

The current Junction backend already:

- queries the official S-Pankki synthetic dataset through a customer-scoped indexed repository;
- lets the model select bounded analytical capabilities for arbitrary periods, categories, baskets and simulations;
- calculates the three baskets, safe-to-spend, safe-to-save and a dining-reduction scenario before model invocation;
- removes account names, account numbers, transaction identifiers and merchant rows from the model payload;
- redacts common email, IBAN and phone-number patterns from goals and chat messages;
- instructs the model to use calculated facts as authoritative and disclose material coverage, confidence and assumptions;
- tests that direct identifiers and raw banking records do not enter the model request.

For the hackathon, the backend uses an indexed local representation of the official synthetic dataset and accepts non-S-Bank PSD2 rows request-by-request. A production S-Bank implementation would replace the local database with its governed analytical platform and add durable consent records, strict customer isolation, audit logging, retention and deletion controls, formal data-loss prevention, monitoring and security/compliance review.

## Demo acceptance criteria

The judged demo should prove the specification with three questions:

1. **Factual breadth:** “How much did I spend on dining across all my banks last month?”
2. **Safe recommendation:** “What is safe for me to spend this week, and how did you calculate it?”
3. **Pedagogical simulation:** “How much could I save if I reduced dining out by 20%?”

Every answer should identify the data coverage, use the three baskets where relevant, explain the calculation in plain language and offer one practical next step without shaming the customer.
