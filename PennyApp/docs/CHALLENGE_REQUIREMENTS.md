# S-Pankki challenge requirement evidence

Penny is designed to demonstrate the challenge directly rather than merely present a generic banking chatbot. The app uses the official synthetic S-Pankki data, supports free-form exploration through bounded analytical tools, teaches the three spending baskets and adds the optional multi-bank perspective through PSD2.

## Requirement matrix

| Challenge requirement | Penny implementation | Demo evidence |
|---|---|---|
| Talk with personal banking data | Free-text goal conversations backed by approved analytical tools | Ask any category, period, comparison or affordability question |
| “How much did I spend?” | Indexed period and category aggregation over complete customer history | “How much did I spend at restaurants last month?” |
| “What kind of spender am I?” | Three-basket profile with totals, confidence and data coverage | Select **Everyday spending** from New Goal |
| Safe to spend and safe to save | Deterministic 90/180-day calculations with protected essential-cost reserves | Select **Safe to spend** and expand **How this was calculated** |
| What-if scenarios | Generic 1–100% reduction for a category or basket | Select **Try a what-if** |
| Mandatory regular spending | Versioned `mandatory_regular` mapping, visible as a starter and evidence basket | Select **Regular essentials** |
| Mandatory irregular spending | Versioned `mandatory_irregular` mapping, visible as a starter and evidence basket | Select **Unexpected essentials** |
| Everyday spending that slips away | Versioned `everyday` mapping, trend/profile tools and non-judgmental coaching | Ask which everyday category changed most |
| MyData and free exploration | The model chooses typed read-only tools, including category discovery; aliases and explicit date ranges are validated | Type a custom category or date-range question rather than selecting a starter |
| Mobile output | Standalone native SwiftUI Penny app designed for S-Bank | Login → Penny → Create new goal |
| Official challenge dataset | 3,626,755 transactions, 5,100 customers and 200 mortgage records imported locally | The chat banner shows **Official synthetic data** and exact coverage |
| Multi-bank bonus | Enable Banking PSD2 flow merges non-S-Bank balances and transactions at analysis time | Connect Nordea or OP, then repeat a spending question |
| Financial literacy | Direct answer, relevant basket, trade-off and one achievable next step | Compare the answer before and after expanding its evidence |
| Trust and explainability | Coverage, institutions, transaction count, confidence, assumptions and basket totals | Expand **How this was calculated** |

## Canonical judge flow

1. Log in and show that the S-Bank account and recent transactions come from the selected official synthetic customer.
2. Open Penny and connect an external bank to demonstrate the complete financial picture.
3. Create a goal and choose **Everyday spending**. Show the three challenge baskets and expand the evidence.
4. Ask: “What is safe for me to spend this week, and how did you calculate it?”
5. Ask: “How much could I save if I reduced restaurants by 20%?”
6. Type a custom period/category question to prove that Penny is not a collection of fixed dashboards.

## Data and calculation boundary

The local database is an indexed representation of the official CSV files, not a substitute dataset. Source columns remain intact. A versioned `basket` classification and customer/date/category/basket indexes make interactive exploration fast.

The financial engine performs totals, comparisons, category discovery, basket classification, safe guidance and simulations. Investment deposits, withdrawals and internal sweep movements are excluded from income and spending. OpenAI receives redacted conversation text and only the aggregate result of the selected analytical tool. It does not receive SQL, customer IDs, account numbers or raw transaction rows.

Relative phrases such as “this month” and “last month” use the selected customer's latest synthetic transaction date. Responses show the actual coverage so synthetic dates are never represented as live banking activity.

## Current demo boundaries

- S-Bank data is the official synthetic challenge data, not a real customer account.
- Connected-bank access uses Enable Banking sandbox data or deterministic mock mode.
- Guidance is educational and does not initiate payments, credit or investments.
- Statistics Finland benchmarking is not included; the challenge marks it as encouraged rather than mandatory.
