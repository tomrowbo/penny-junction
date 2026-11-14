# Penny open-banking adapter

This small server keeps Enable Banking credentials out of the iOS app and implements the Finnish AIS flow used by the concept.

## Demo mode

With no environment variables, `GET /api/banks` returns the three banks bundled in the app. The iOS app itself uses `DemoOpenBankingService`, so the judged flow works offline.

## Enable Banking sandbox

1. Register a sandbox application in the Enable Banking control panel.
2. Whitelist `PUBLIC_BASE_URL/api/callback` as its redirect URL.
3. Start the adapter:

```bash
ENABLEBANKING_APP_ID="your-app-id" \
ENABLEBANKING_PRIVATE_KEY_PATH="/absolute/path/to/private.pem" \
PUBLIC_BASE_URL="https://your-tunnel.example" \
node server.mjs
```

The server signs short-lived RS256 JWTs, starts `/auth`, exchanges the callback code through `/sessions`, and loads account details, balances and transactions. Never commit the private key.

