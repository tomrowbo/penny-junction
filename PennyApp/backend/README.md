# Penny Next.js API

This is the server-side half of the Junction demo. It keeps OpenAI and Enable Banking credentials out of the iOS app and exposes one normalized API to Penny.

## Run the reliable demo mode

```bash
cd PennyApp/backend
npm install --legacy-peer-deps
cp .env.example .env.local
npm run dev
```

`OPEN_BANKING_MODE=mock` is the default. The iOS app still performs real HTTP calls, but the backend returns deterministic Nordea/OP/Danske accounts so the stage flow does not depend on a bank sandbox.

The checked-in iOS Debug configuration points to:

```text
http://Toms-MacBook-Pro-8.local:3000
```

The Mac and iPhone must be on the same network. Override `PENNY_API_BASE_URL` in Xcode when the hostname or tunnel changes.

## Enable AI coaching

Put the key only in `PennyApp/backend/.env.local`:

```bash
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-6-luna
```

Alternatively set `OPENAI_ENV_FILE` to an existing dotenv file containing `OPENAI_API_KEY`; Penny reads only that variable and does not copy the secret. This workspace currently reuses `/Users/tomrowbotham/dev-agency/web/.env.local`.

Restart the backend after editing the file. Verify that `ai.configured` is `true`:

```bash
curl http://localhost:3000/api/health
```

The app sends the current goal conversation plus connected accounts and a bounded financial snapshot to the bank backend. The open-banking adapter paginates up to 50 provider pages per account. Before invoking the model, the backend deterministically calculates basket totals, cash flow, safe-to-spend, safe-to-save, coverage, confidence and supported what-if results. The model request contains those minimised results and redacted conversation text—not raw transaction rows, merchants, account identifiers or account numbers. The key is never compiled into the app.

S-Bank history is queried from the backend-owned indexed challenge dataset. The iOS app supplies a bounded snapshot only for connected non-S-Bank PSD2 accounts, which is merged into the calculation without replacing the authoritative S-Bank history. A production version should query a governed analytical store containing the customer's complete authorised S-Bank and PSD2 history through customer-scoped, read-only analytical tools. The language model should not receive unrestricted SQL access. See [`../docs/LEADING_BANK_AI_SPEC.md`](../docs/LEADING_BANK_AI_SPEC.md).

## Load the official S-Pankki challenge data

The challenge repository provides CSV files rather than a hosted API. Penny downloads and streams them into a local indexed SQLite database:

```bash
cd PennyApp/backend
npm run data:setup
npm run data:verify
```

The current official import contains 5,100 customers, 3,626,755 transactions and 200 linked mortgage records. The source files and generated database live under `backend/data/` and are ignored by version control. Set `SBANK_DEMO_CUSTOMER_ID` to choose the fake-login customer; the default is `CUST03948`.

Official timestamps use a SAS-style format and are normalised to ISO during import without shifting dates. Relative questions anchor to that customer's latest transaction. The app and Penny both load the same customer through `GET /api/customer/summary`.

The database preserves source columns and adds a versioned pedagogical basket plus indexes for customer/date/category/basket exploration. It is a hackathon query layer, not a claim of production S-Bank infrastructure.

## Enable the live Finnish PSD2 sandbox

1. Sign in to the [Enable Banking control panel](https://enablebanking.com/sign-in/) and create a **Sandbox** application.
2. Create or export its RSA private key and note the application ID.
3. Run an HTTPS tunnel to port 3000, for example `cloudflared tunnel --url http://localhost:3000` or `ngrok http 3000`.
4. Add this exact redirect URL to the Enable Banking application:

   ```text
   https://YOUR-TUNNEL/api/open-banking/callback
   ```

5. Configure `.env.local`:

   ```bash
   OPEN_BANKING_MODE=enable-banking
   PUBLIC_BASE_URL=https://YOUR-TUNNEL
   STATE_SIGNING_SECRET=GENERATE_AT_LEAST_32_RANDOM_CHARACTERS
   ENABLEBANKING_APP_ID=YOUR_APPLICATION_ID
   ENABLEBANKING_PRIVATE_KEY_PATH=/absolute/path/to/private.key
   OPENAI_API_KEY=sk-...
   ```

6. Change the app's `PENNY_API_BASE_URL` build setting to the same HTTPS tunnel and rebuild.

For the S-Pankki sandbox, Enable Banking currently documents username `customera` and password `12345678`. OP documents username `88888881`; Nordea requires no sandbox credentials. Confirm these in the provider docs on demo day because bank sandboxes can change.

## Routes

- `GET /api/health` — configuration status without exposing secrets
- `GET /api/customer/summary` — matching official synthetic S-Bank accounts and recent transactions
- `GET /api/open-banking/banks` — supported Finnish banks
- `POST /api/open-banking/connect` — immediate mock session or live authorization URL
- `GET /api/open-banking/callback` — validates state, exchanges the authorization code, redirects to `penny://`
- `GET /api/open-banking/sessions/:id` — normalized accounts and transactions
- `POST /api/chat` — structured coaching reply with message, evidence, suggestions and data source

## Checks

```bash
npm test
npm run typecheck
npm run build
npm audit --omit=dev
```

This is a hackathon backend, not a production banking system. Before production it needs real customer authentication, durable encrypted storage, consent/session lifecycle management, audit logging, deletion controls, rate limiting, and a security/compliance review.
