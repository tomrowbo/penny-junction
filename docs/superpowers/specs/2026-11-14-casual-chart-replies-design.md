# Casual Chart Replies Design

## Intent

Make analytical Penny replies feel like a casual chat instead of a prose rendering of the chart. The demo should reveal one useful insight quickly, then let the native chart carry the detailed numbers.

## Approach

- Preferred: constrain generated copy, split the two sentences into at most two bubbles, and show only the five largest categories in the compact chart.
- Rejected: client-side truncation could cut financial meaning unpredictably.
- Rejected: visual styling alone would leave the repetitive wall of text intact.

## Behaviour

- Penny replies use at most two short sentences and normally fewer than 35 words.
- When a chart is present, Penny mentions no more than three values and never reads out every plotted value.
- The first sentence gives the standout insight; the second offers one useful next step or question.
- The app may render those sentences as two sequential Penny bubbles.
- Category charts show the five highest-spend categories. The underlying calculated result and evidence remain unchanged.

## Constraints

- Keep native SwiftUI charts and existing governed analytics.
- Do not invent or recalculate financial values on-device.
- Do not add or run tests; this is a hackathon demo change. Verify with native and backend builds only.
