import { createHmac, randomUUID, timingSafeEqual } from "node:crypto";

type StateInput = {
  bank: string;
  country: string;
};

export type SignedState = StateInput & {
  exp: number;
  nonce: string;
};

function encode(value: string): string {
  return Buffer.from(value).toString("base64url");
}

function signature(payload: string, secret: string): string {
  return createHmac("sha256", secret).update(payload).digest("base64url");
}

export function createState(input: StateInput, secret: string, now = Date.now()): string {
  const body: SignedState = {
    ...input,
    exp: Math.floor(now / 1000) + 10 * 60,
    nonce: randomUUID(),
  };
  const payload = encode(JSON.stringify(body));
  return `${payload}.${signature(payload, secret)}`;
}

export function verifyState(token: string, secret: string, now = Date.now()): SignedState {
  const [payload, receivedSignature, extra] = token.split(".");
  if (!payload || !receivedSignature || extra) throw new Error("Invalid authorization state.");
  const expectedSignature = signature(payload, secret);
  const received = Buffer.from(receivedSignature);
  const expected = Buffer.from(expectedSignature);
  if (received.length !== expected.length || !timingSafeEqual(received, expected)) {
    throw new Error("Invalid authorization state signature.");
  }
  const state = JSON.parse(Buffer.from(payload, "base64url").toString("utf8")) as SignedState;
  if (!state.bank || !state.country || !state.nonce || state.exp < Math.floor(now / 1000)) {
    throw new Error("Authorization state has expired.");
  }
  return state;
}
