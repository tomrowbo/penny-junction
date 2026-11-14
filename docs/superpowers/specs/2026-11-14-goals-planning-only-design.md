# Goals as planning-only data

## Intent

Make the Goals page clearly read-only. Penny may display and discuss a user's goal alongside connected financial data, but it must not imply that Penny creates accounts, reserves funds, or moves money.

## Approved approach

Remove the shared savings-pool summary, account linking, over-allocation state, and pool-based validation. Keep each goal as a locally persisted plan with a target, a user-entered "Saved so far" amount, a target date, and an optional monthly forecast. Tapping a goal continues to open a contextual Penny conversation.

## Alternatives considered

- Keep the pool but rename it: rejected because the underlying account classification still creates a false sense that funds are separated or controlled by Penny.
- Base allocations on total connected balance: rejected because it would imply spendable account money is reserved for goals.
- Planning-only goals: selected because it matches the read-only hackathon product and existing chat behavior.

## Non-goals

- Creating or connecting savings accounts from Goals.
- Initiating transfers, standing orders, or any other banking mutation.
- Automatically assigning real account balances to goals.
