# Goal Savings Pool Design

## Intent

Make goal progress truthful without guessing which bank deposit belongs to which goal.

## Approved model

- The savings pool is the sum of positive balances in connected accounts whose kind is `savings`.
- Goal `currentAmount` is an explicit allocation from that pool, not an inferred transfer and not an additional balance.
- New savings-account deposits increase the unallocated pool. Penny never automatically assigns them to a goal.
- Creating or editing a goal may allocate up to `pool balance - allocations on other goals`.
- Existing allocations are not silently reduced when an account balance falls. The Plan page instead shows an overallocated state.
- Saving a goal records the IDs of all currently connected savings accounts in `accountIDs` for chat context/provenance.

## UI

- Plan shows one compact `Savings pool` summary with total allocated and available/unallocated amounts.
- Goal cards keep their visual design; the displayed saved amount is the allocation.
- The editor renames `Already saved` to `Allocated to this goal`, shows the available amount directly beneath it, and gives a concise validation error if the allocation exceeds the pool.
- If there are no connected savings accounts, the pool is €0 and the editor clearly says to connect or use a savings account.

## Constraints

- No transaction-level inference, transfer execution, automatic reallocation, interest, or investment-return modeling.
- Preserve stored goal compatibility and existing projection math.
- Hackathon verification: native build and one default-screen inspection only; no UI tests or new test suite.

