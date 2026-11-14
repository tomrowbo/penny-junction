# Penny Loading, Conversation History, and Profile Design

## Intent

Make Penny feel like a real native product during loading and conversation, remove misleading demo-data flashes, keep useful chats, and make the root-screen profile affordance unambiguous.

## Approved direction

- Prefer a fast client-side implementation over changing the chat API response schema.
- When an API is configured, enter loading state before the first root-screen render. Never briefly present demo account or transaction figures as if they were live.
- Spend and Incoming keep their real headers but replace unloaded financial content with layout-shaped neutral skeletons and a restrained moving highlight.
- Replace the dashboard's vague `Safe to spend` estimate with a factual `Available now` hero showing the total positive balance across connected non-mortgage accounts and the line `Across your connected accounts`.
- Replace the chat spinner with a Penny-avatar `Thinking…` bubble whose text/highlight shimmers subtly.
- Update both backend coach prompts to lead with verified numbers, use casual concise language, provide one practical action, and avoid generic coaching prose. Numeric claims must still come from analytics/tools.
- Keep the current single-string API contract. Split a returned answer client-side at paragraph/sentence boundaries into at most three short bubbles, revealed in order. Evidence, visualizations, and suggested prompts attach only to the final bubble.
- Remove hard-coded recent conversations from the user-facing list. Persist real conversations and their messages locally, update their preview/time after every sent or received message, and sort newest first.
- Conversation icons are deterministic: goal uses the same semantic goal-title icon rules; transaction uses category when known and otherwise a credit card; account uses a bank; upcoming uses a calendar; generic chat uses Penny.
- Use the exact `/Users/tomrowbotham/Downloads/pfp.png` bytes as a `ProfileAvatar` asset. Every root header uses it in the top-right 48-point profile button. Tapping opens the existing profile/settings sheet.
- The profile sheet uses the profile avatar, retains connected data/privacy/about/reset controls, and adds a working destructive `Log out` action that clears the presented sheet and returns to login. Penny remains the assistant avatar everywhere chat-related.

## Visual behavior

- Light mode and existing S-Bank/SF typography remain unchanged.
- Skeletons mirror hero, account-row, transaction-row, and incoming-card geometry; they never contain fabricated text or numbers.
- Loading motion is quiet and functional: one continuous highlight, no spinner, no pulsing layout or shifting dimensions.
- Chat bubbles remain visually grouped like iMessage. Consecutive Penny chunks use compact vertical spacing; supporting evidence appears once under the last chunk.

## Constraints and non-goals

- Hackathon scope: build and inspect one default iPhone screen; no UI tests, large-font matrix, or new test suite.
- Do not invent a financial-health score or claim monthly savings without reliable savings-transfer data.
- Do not change the backend JSON schema or weaken existing grounding/privacy requirements.
- Do not alter the supplied profile artwork, Penny mark, or the three supplied navigation icons.
- Preserve unrelated dirty work in `AppStore.swift`, `PennyGoalPlanTests.swift`, decks, reports, and research files.

## Approaches considered

1. **Chosen:** keep one backend reply string, strengthen the prompt, split and stage bubbles on-device. Lowest integration risk and fastest visible improvement.
2. Return an array of bubbles from the API. Cleaner as a long-term contract, but adds schema/decoding/client migration cost without improving the hackathon experience.

