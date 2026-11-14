# Monthly savings Plan page and goal-aware Penny

## Intent

Make Plan answer three questions immediately: how much the customer aims to save each month, how much their connected transaction activity shows they saved in the latest month, and which goals make up the target. Penny must also understand every locally saved goal in any conversation.

This remains a read-only planning feature. It does not create accounts, earmark funds, initiate transfers, or claim that net cash flow was deposited into a goal.

## Approved calculation

- Monthly target is the sum of `monthlyContribution` for unfinished goals.
- Monthly saved is net connected cash flow for the latest data month: the sum of positive income and negative spending transactions.
- The six-month chart uses the same net-cash-flow calculation for each calendar month ending with `financialReferenceDate`.
- Negative months remain visible below zero.
- Goal breakdown rows show each unfinished goal's monthly contribution and together equal the displayed target.
- Goal progress remains based on the locally entered `currentAmount` and `targetAmount`.
- “Unfinished” means `currentAmount < targetAmount`; unfinished €0/month goals remain visible but add zero to the target.
- Do not cap a positive or negative monthly net figure at the target.

## Plan page

Keep the light S-Bank typography and Penny glass styling. Under the Plan header, show one concise summary card:

1. “Monthly savings”
2. “€saved / €target” with “saved this month”
3. A six-month line/area chart with month labels and a visible zero baseline

Below it, show “Savings breakdown” with the add button and compact goal rows. Each row includes the goal icon, name, monthly amount, and progress. Tapping the row opens a new contextual Penny conversation; the trailing action edits the goal. Do not repeat the existing large goal cards below the breakdown.

If there are no goals, the target is zero and the existing create-goal empty state remains. Missing months appear as zero because the chart represents the connected transactions supplied to Penny.

## Penny goal context

Every chat request sends a bounded read-only list of all locally saved goals: ID, title, target amount, saved-so-far amount, target date, and monthly contribution. The backend validates at most 50 goals and computes the aggregate monthly target deterministically before exposing goal facts to the model.

The backend field defaults to an empty list so older installed clients remain compatible. The selected goal context remains highlighted when a conversation begins from a goal. Goal data is explicitly described to the model as user-entered planning data, not verified bank balances. Goal titles are redacted and internal goal IDs stay out of model-visible JSON. No account IDs are sent with goals.

## Approaches considered

- Manual monthly savings history: rejected because no history exists yet and the chart would initially be empty.
- Synthetic goal deposits: rejected because fabricated savings would undermine the read-only product.
- Transaction-derived net savings plus user-entered goal targets: selected because it uses real connected data and keeps the distinction between actual cash flow and planned goals.

## Verification and constraints

- No UI test suite or large-font testing for this hackathon change.
- Run one native simulator build and the backend compile/build check.
- Preserve unrelated dirty work and commit only scoped files directly to `main`.
