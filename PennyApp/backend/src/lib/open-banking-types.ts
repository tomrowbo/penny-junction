export type Bank = {
  name: "Nordea" | "OP" | "Danske Bank";
  country: "FI";
  description: string;
};

export type NormalizedAccount = {
  id: string;
  institution: Bank["name"];
  name: string;
  kind: "current" | "savings" | "mortgage";
  balance: number;
  maskedNumber: string;
};

export type NormalizedTransaction = {
  id: string;
  accountID: string;
  institution: Bank["name"];
  merchant: string;
  amount: number;
  date: string;
  category: string;
};

export type BankConnection = {
  institution: Bank["name"];
  accounts: NormalizedAccount[];
  transactions: NormalizedTransaction[];
};

export type ProviderAccountPayload = {
  uid: string;
  details: Record<string, unknown>;
  balances: Record<string, unknown>;
  transactions: Record<string, unknown>;
};
