# European banking AI assistants

## Which products genuinely converse over personal transaction data and offer financial insights?

### Takeaway
bunq Finn, Revolut AIR, and NatWest's newer Spending Insights are genuine conversational financial-data products rather than FAQ-only chatbots. bunq is the closest established analogue to Penny because it answers detailed spending questions across both bunq and connected external-bank accounts; Revolut is the closest current product in breadth and action-taking; NatWest is the clearest example of a traditional bank moving sensitive spending conversations onto a proprietary model.

### Cited Findings
- bunq says Finn answers detailed questions such as average grocery spend, annual Amazon expenditure, payment arrival times, a restaurant visited in London, and café spending near Central Park; it includes external bank accounts added by the user and supports follow-up questions. bunq explicitly says Finn does not provide financial or investment advice. — [bunq Finn help](https://help.bunq.com/en/articles/meet-finn-your-personal-assistant)
- bunq's privacy policy says Finn's operating context is the user's data and use of bunq services; it answers questions about spending, accounts, group expenses, and app activity, and can provide proactive advice, tips, and suggestions based on activity and usage patterns. — [bunq privacy policy](https://www.bunq.com/documents/privacy-policy)
- bunq's open-banking policy says customers explicitly select linked external accounts, bunq retrieves account data and balances regularly throughout the day, consent must be renewed periodically, and withdrawal stops collection and triggers deletion of retrieved data as soon as possible. — [bunq privacy policy, Open Banking section](https://www.bunq.com/documents/privacy-policy)
- Revolut launched AIR in April 2026 as an in-app assistant that can provide granular spending breakdowns, track investments, manage subscriptions, freeze a lost card, plan trip budgets, and purchase eSIMs; it accesses transactions, investments, and cards already visible to the customer. — [Revolut AIR launch](https://www.revolut.com/news/revolut_enters_new_era_of_money_intelligence_with_launch_of_ai_assistant/)
- Revolut's legal AI notice says the assistant uses spending data, plan details, investments or crypto holdings, registered address, rewards, usage information, transaction history, and in transfer flows payee names and account numbers/IBANs. It can provide proactive factual insights, initiate certain tasks such as transfers, but does not provide financial advice or execute investment orders. — [Revolut AI Assistant notice](https://www.revolut.com/legal/rita-disclaimer/)
- NatWest announced a 2026 trial of a fully generative audio-visual Spending Insights tool that turns complex transaction data into personalised insights and graphs and supports natural follow-ups, interruptions, and topic changes; it follows an earlier Cora trial allowing natural-language questions about recent spending. — [NatWest 2026 Spending Insights announcement](https://www.natwestgroup.com/news-and-insights/news-room/press-releases/2026/natwest-group-first-to-unveil-next-generation-of-ai-tools-to-hel.html)
- NatWest reports that Cora handled 12.9 million conversations in 2025, with 50% requiring no human intervention; it added GenAI to 17 additional journeys, bringing the total to 21. — [NatWest innovation and digitalisation](https://www.natwestgroup.com/sustainability/society/innovation-and-digitisation.html)

### Inferences
- Penny's multi-bank angle is not unprecedented: bunq already combines periodic open-banking refresh with conversational insights over connected accounts. Penny needs differentiated pedagogy, safe-to-spend methodology, explainable three-basket classification, or S-Bank-native integration rather than claiming multi-bank chat alone is novel.
- These assistants expose task-specific capabilities and customer-scoped data, not a visible general-purpose database interface. No official source reviewed says the language model itself receives unrestricted SQL access.

### Gaps
- None of the official product pages publishes its database schema, query planner, tool definitions, SQL-generation controls, or whether calculations are performed deterministically before generation.
- Public sources do not establish whether bunq Finn can analyse the customer's entire retained history in a single request or whether product-side retrieval imposes time/window limits.

## Do official sources say raw transaction data or personal data goes to external LLM providers?

### Takeaway
The public disclosures show three different privacy patterns: bunq processes request-related data through contracted cloud-model partners in an EU-hosted/private environment; Revolut explicitly discloses necessary information to technology partners under user consent and banking-secrecy waiver while claiming zero third-party retention/training; NatWest is bringing sensitive spending conversation onto a proprietary bank model, but its public materials do not fully describe the data path.

### Cited Findings
- bunq says Finn creates a temporary snapshot only when a conversation begins, retrieves only necessary data, starts new conversations with a clean slate, and retains data temporarily for 30 days to monitor misuse. — [bunq Finn privacy help](https://help.bunq.com/articles/how-does-finn-safeguard-my-privacy)
- The same bunq help page says question-related data is processed using models from AWS, Azure ChatGPT, and Google; partners process only data bunq sends, do not permanently store it or use it for their own training, and processing occurs in the EU. It also describes the model as running in bunq's cloud environment. — [bunq Finn privacy help](https://help.bunq.com/articles/how-does-finn-safeguard-my-privacy)
- bunq's formal privacy policy names Microsoft Azure OpenAI, Google Gemini, and AWS Anthropic as vendors whose APIs support Finn, customer support, onboarding, document review, and transaction monitoring; it says most operational data is stored on AWS servers in Frankfurt. — [bunq privacy policy](https://www.bunq.com/documents/privacy-policy)
- Revolut's legal notice says use of the assistant constitutes consent to disclose relevant information to technology partners, including protected client secrets, strictly limited to what is necessary for the specific request; it also describes the interaction as an express waiver of banking secrecy and says conversations are generally recorded for quality. — [Revolut AI Assistant notice](https://www.revolut.com/legal/rita-disclaimer/)
- Revolut's launch announcement says third-party AI partners operate under zero-data-retention terms: personal information is not retained by those partners or used to train external models. — [Revolut AIR launch](https://www.revolut.com/news/revolut_enters_new_era_of_money_intelligence_with_launch_of_ai_assistant/)
- NatWest's 2024 Cora+ used IBM's enterprise watsonx platform and multiple secure information sources to answer product/service questions; NatWest described the collaboration as an enterprise-grade, responsible-AI deployment. — [NatWest and IBM Cora+ announcement](https://www.natwestgroup.com/news-and-insights/news-room/press-releases/innovation-and-partnerships/2023/nov/natwest-and-ibm-collaborateon-generative-ai-initiative-to-enhanc.html)
- NatWest's separate 2026 Spending Insights product is developed by its Chief AI Research Office and powered by NatWest proprietary Small Language Models. — [NatWest 2026 Spending Insights announcement](https://www.natwestgroup.com/news-and-insights/news-room/press-releases/2026/natwest-group-first-to-unveil-next-generation-of-ai-tools-to-hel.html)

### Inferences
- “Data does not leave the bank perimeter” does not necessarily mean no external vendor computes on it: bunq simultaneously states that data stays in its perimeter and that partner models process the subset it sends inside its controlled cloud environment. The credible promise is controlled processing, EU residency, purpose limitation, no vendor training, and short retention—not “no third party touches data.”
- Revolut is unusually explicit that personal financial data can reach technology partners. Its protection is contractual/technical minimisation and zero retention, not an assertion that all inference is on-bank.
- NatWest's proprietary SLM is the strongest public precedent for keeping sensitive spending inference under bank control, but “proprietary” alone does not prove on-premises deployment or that no cloud processor is involved.

### Gaps
- Revolut does not identify AIR's model providers or disclose exactly which fields are sent for each request in the cited public notices.
- NatWest does not publicly specify model hosting, data residency, retention, prompt logging, or whether raw transaction rows versus derived features reach its proprietary Spending Insights model.
- bunq's public wording does not enumerate the precise transaction fields sent to each partner model or explain routing among Azure OpenAI, Gemini, and AWS Anthropic.

## What guardrails are confirmed, and how close is each product to Penny?

### Takeaway
Production banks layer product limitations, consent, human escalation, controlled data retrieval, retention rules, and model governance. Penny's proposed “bank-side calculations plus a constrained language layer” is consistent with these patterns, but an absolute claim that no personal data reaches an external model would exceed what bunq and Revolut themselves claim and would require bank-hosted inference like NatWest's direction.

### Cited Findings
- bunq prevents Finn from making legally or similarly significant automated decisions without explicit consent, and it limits Finn from giving financial or investment advice. — [bunq privacy policy](https://www.bunq.com/documents/privacy-policy); [bunq Finn help](https://help.bunq.com/en/articles/meet-finn-your-personal-assistant)
- Revolut makes the AI assistant optional, redirects users to human support when needed, allows proactive insights to be disabled, labels outputs as informational rather than financial/investment/legal/tax advice, blocks investment-order execution, and warns users AI may be wrong, incomplete, or biased. — [Revolut AI Assistant notice](https://www.revolut.com/legal/rita-disclaimer/)
- During NatWest's earlier Cora+ pilot, a bank colleague reviewed every generated response; NatWest later formalised broader AI governance through an AI and Data Ethics Code of Conduct. — [NatWest Cora+ staff account](https://jobs.natwestgroup.com/posts/my-career-journey-from-branches-to-bots); [NatWest innovation and digitalisation](https://www.natwestgroup.com/sustainability/society/innovation-and-digitisation.html)
- NatWest's Cora roadmap distinguishes informational/support journeys from sensitive spending analysis: IBM watsonx extended Cora's conversational product-information capability, while the newer transaction-based Spending Insights tool uses a proprietary NatWest model. — [NatWest IBM Cora+ announcement](https://www.natwestgroup.com/news-and-insights/news-room/press-releases/innovation-and-partnerships/2023/nov/natwest-and-ibm-collaborateon-generative-ai-initiative-to-enhanc.html); [NatWest 2026 Spending Insights announcement](https://www.natwestgroup.com/news-and-insights/news-room/press-releases/2026/natwest-group-first-to-unveil-next-generation-of-ai-tools-to-hel.html)

### Inferences
- For the hackathon, Penny can credibly mirror production patterns by keeping raw rows and calculations in the bank backend, exposing allow-listed customer-scoped analysis tools, minimising model context, showing coverage and assumptions, prohibiting regulated advice/actions, and offering a human or conventional UI fallback.
- A safe-to-spend number is closer to guidance than the factual spending lookup provided by bunq/Revolut. Penny should present it as an explainable estimate, show assumptions, allow corrections, and avoid guaranteed or prescriptive language.
- Best positioning: “private-by-design financial coaching—raw transaction records stay in the bank analytics layer; the language model receives only the minimum derived facts needed.” Avoid claiming “this is how all banks do it” because public architectures vary and are only partially disclosed.

### Gaps
- No reviewed bank publishes evidence that its customer-facing LLM is permitted to author arbitrary SQL. Absence of disclosure is not proof it never uses model-generated queries internally, but granting unrestricted SQL would be inconsistent with the visible minimisation and governance posture.
- Public materials do not provide error rates, hallucination rates, financial-harm incident data, or detailed evaluation criteria for these assistants.
