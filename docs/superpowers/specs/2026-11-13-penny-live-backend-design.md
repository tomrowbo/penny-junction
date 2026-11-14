# Penny Live Backend Design

## Intent

Turn the polished Penny concept into an end-to-end hackathon demo: the iOS app can connect a Finnish bank through PSD2, merge returned accounts and transactions with the supplied S-Bank data, and discuss goals with an AI coach grounded in the user's account and transaction data.

## Goals

- A Next.js backend owns all OpenAI and Enable Banking secrets.
- Enable Banking sandbox authorization works through an external browser and returns to the iOS app.
- Accounts and transactions are normalized into the app's existing domain model.
- Penny chat uses OpenAI's Responses API and receives only the financial context needed for the current request.
- A deterministic mock mode keeps the demo usable without third-party credentials or reliable venue internet.

## Non-goals

- Production customer authentication, durable multi-user storage, payments, or regulated financial advice.
- Receipt capture or SKU-level product analysis.
- Real app notifications; proactive alerts are a future deck concept only.
- A large test suite or production operations stack.

## Approaches

1. **Enable Banking + Next.js (selected):** extends the existing Finnish AIS adapter, supports the relevant Finnish sandboxes, and keeps secrets server-side.
2. **GoCardless Bank Account Data:** credible, but discards working Enable Banking integration and adds provider risk during the hackathon.
3. **Dataset-only demo:** reliable but cannot substantiate the multi-bank/open-banking story.

## Architecture

The Next.js App Router exposes health, bank discovery, authorization, callback, session-data, mock-connection, and chat routes. Enable Banking requests use short-lived RS256 JWTs generated from a server-only private key. A signed state token binds authorization callbacks without requiring a database. The callback redirects to the registered `penny://open-banking` URL with either a session ID or error.

The iOS app defaults to the backend service when a `PENNY_API_BASE_URL` Info.plist value is configured. It opens authorization using `ASWebAuthenticationSession`, processes the callback, downloads normalized data, and merges it into `AppStore`. Chat sends the current accounts, transactions, and conversation to the backend. If the backend is unavailable, the UI shows a concise retryable error rather than fabricating a model answer.

Mock mode uses the same API contracts and returns synthetic external-bank data immediately. It is a fallback, not a claim of live bank access.

## Security and demo constraints

- Never expose `OPENAI_API_KEY`, `ENABLEBANKING_APP_ID`, or the RSA private key to iOS.
- Treat bank data as read-only and do not implement payment endpoints.
- Keep the OpenAI prompt educational, plain-language, and explicit that outputs are guidance rather than guarantees.
- Use `gpt-6-luna` by default for responsive, cost-efficient coaching; allow `OPENAI_MODEL` to override it.
- Target local Mac development and a public HTTPS tunnel for the Enable Banking callback.
