# US bank customer assistants

## What customer data can each assistant access and what can it do?

### Takeaway
The leading US assistants are authenticated features embedded in bank apps. They retrieve account facts and trigger narrowly defined banking workflows; public evidence describes controlled capabilities and purpose-built analytics rather than open-ended database access.

### Cited Findings
- Bank of America says Erica can obtain balances, initiate transfers, pay bills, search transactions, monitor subscriptions, explain spending, and surface proactive cash-flow insights after the customer signs into the mobile app. Its service agreement calls it a bot feature of Digital Banking and says availability depends on the customer's eligible accounts. — [Bank of America service agreement](https://www.bankofamerica.com/content/documents/agreement/OnlineBankingServiceAgreementUpdateEN.pdf); [Erica product page](https://info.bankofamerica.com/en/digital-banking/erica); [Bank of America newsroom](https://newsroom.bankofamerica.com/content/newsroom/press-releases/2023/07/bofa-s-erica-surpasses-1-5-billion-client-interactions--totaling)
- Bank of America describes linked-account behavior: after Bank of America and Private Bank accounts are linked, Erica can provide information and personalized insights about accounts and spending, find past transactions, and set notifications. — [Bank of America Private Bank digital capabilities](https://www.privatebankfssit2.bankofamerica.com/solutions/digital-capabilities.html)
- Capital One says Eno can answer current account-balance, available-credit, and next-payment questions; monitor transactions; and alert on duplicate charges, increases in recurring charges, unusually large tips, and suspicious activity. Eno is available through authenticated web/app experiences and selected SMS, email, and app notifications, with features depending on account eligibility. — [Capital One digital tools](https://www.capitalone.com/digital/tools/); [Capital One security features](https://www.capitalone.com/learn-grow/privacy-security/capital-one-credit-card-security-features/); [Capital One Eno architecture](https://www.capitalone.com/tech/cloud/eno-real-time-alerts-powered-by-serverless/)
- Capital One's published Eno insights architecture listens to card-transaction events in real time, passes them through reusable filters and transformations, and applies specific business logic for a particular insight such as an unusually generous tip. — [Capital One Eno architecture](https://www.capitalone.com/tech/cloud/eno-real-time-alerts-powered-by-serverless/)
- Wells Fargo says Fargo can turn cards on or off, check credit limits, search transactions by date, amount, or type, identify recurring-spend increases and merchant spikes, calculate a safe-to-spend amount while covering bills and savings goals, and surface possible debt-consolidation or investment actions. — [Wells Fargo Fargo launch](https://newsroom.wf.com/news-releases/news-details/2022/Wells-Fargos-New-Virtual-Assistant-Fargo-to-Be-Powered-by-Google-Cloud-AI/)

### Inferences
- “All data” in practice means all authorized data relevant to a supported capability, reached inside an authenticated customer context. None of these sources supports the claim that a conversational model receives an unrestricted dump of every customer record.
- The documented pattern is intent detection followed by a controlled retrieval, calculation, insight, or transaction workflow—not model-generated arbitrary SQL.

### Gaps
- The banks do not publish exact field-level entitlements, retention for every structured account datum, or whether every account type is included in every assistant capability.

## Do these assistants use generative AI, rules, or machine learning?

### Takeaway
Bank of America explicitly rejects generative AI for Erica; Capital One documents ML plus deterministic event-processing for Eno; Wells Fargo documents Google Dialogflow intent recognition and predictive analytics for Fargo. These are materially more controlled than a general LLM with database access.

### Cited Findings
- Bank of America explicitly says Erica uses natural-language processing grounded in machine learning to understand intent, then selects from a predefined set of answers. It says Erica does **not** use generative AI or large language models and does not automatically generate new answers from customer interactions. — [Erica product FAQ](https://info.bankofamerica.com/en/digital-banking/erica); [Bank of America service agreement](https://www.bankofamerica.com/content/documents/agreement/OnlineBankingServiceAgreementUpdateEN.pdf)
- Bank of America calls Erica “controlled AI” and says clients trust that it uses proprietary, vetted data. — [Bank of America newsroom](https://newsroom.bankofamerica.com/content/newsroom/press-releases/2023/07/bofa-s-erica-surpasses-1-5-billion-client-interactions--totaling)
- Capital One's official architecture describes Eno insights as an event-driven AWS system using Lambda microservices, Kinesis message buses, transformations, filters, and application-specific logic. The source does not describe an LLM or generative response layer for Eno. — [Capital One Eno architecture](https://www.capitalone.com/tech/cloud/eno-real-time-alerts-powered-by-serverless/)
- Capital One separately describes its current AI strategy as building proprietary AI, and describes a generative RAG tool for **employees**, but its public Eno materials do not claim that the customer assistant is generative. — [Capital One AI](https://www.capitalone.com/tech/ai/)
- Wells Fargo says Fargo was built on Google Cloud Dialogflow and uses that platform's language processing to recognize customer intent and provide tailored responses; it separately describes predictive analytics for proactive financial-wellness insights. — [Wells Fargo Fargo launch](https://newsroom.wf.com/news-releases/news-details/2022/Wells-Fargos-New-Virtual-Assistant-Fargo-to-Be-Powered-by-Google-Cloud-AI/)

### Inferences
- Penny's safest credible analogue is a hybrid: deterministic bank-side analytics and allow-listed functions produce facts; a generative model, if used, only explains those facts. That advances conversational quality without granting the model authority over calculations or the database.
- Capital One's published architecture strongly supports computing alerts and financial facts before the conversation layer, rather than asking an LLM to infer them from transaction rows.

### Gaps
- Capital One does not state in the reviewed official sources whether any current Eno response path uses an LLM.
- Wells Fargo does not state whether Fargo has added a generative model since its original Dialogflow architecture announcement; its 2026 material continues to call Fargo AI-powered but does not publish a replacement architecture.

## What is disclosed about privacy, third parties, and arbitrary SQL?

### Takeaway
The banks disclose authentication, recording, cloud/service-provider involvement, masking, and governance at a high level. None publicly documents arbitrary model-generated SQL; the disclosed architectures instead constrain access through app functions, event pipelines, intent handling, and governed services.

### Cited Findings
- Bank of America says Erica interactions receive the same protections as its app and online banking, the customer must authenticate in the app, conversations are recorded, a third-party provider handles voice responses, voice interactions are retained for 90 days, and personal data is masked in retained transcripts. It also tells users not to provide secrets such as an SSN or PIN. — [Erica product FAQ](https://info.bankofamerica.com/en/digital-banking/erica); [Bank of America service agreement](https://www.bankofamerica.com/content/documents/agreement/OnlineBankingServiceAgreementUpdateEN.pdf)
- Capital One's Eno architecture identifies secret management, monitoring, uniform logging, retries, message deduplication, throttling, and fault tolerance as built-in controls around its cloud microservices. — [Capital One Eno architecture](https://www.capitalone.com/tech/cloud/eno-real-time-alerts-powered-by-serverless/)
- Capital One's code of conduct requires approval before employees use generative-AI tools, prohibits sending data or code to an approved tool without proper approval, and requires output review for accuracy and bias. This is enterprise governance evidence, not a disclosure of Eno's customer-data flow. — [Capital One Code of Conduct](https://www.investor.capitalone.com/static-files/06fb4034-f0ae-4291-9e14-0731b749f013)
- Wells Fargo openly discloses Google Cloud as Fargo's conversational-AI provider and says the platform architecture keeps Wells Fargo customer data secure and private. Its general terms also say virtual-assistant conversations may be monitored, recorded, analyzed, and retained by Wells Fargo and service providers. — [Wells Fargo Fargo launch](https://newsroom.wf.com/news-releases/news-details/2022/Wells-Fargos-New-Virtual-Assistant-Fargo-to-Be-Powered-by-Google-Cloud-AI/); [Wells Fargo terms](https://www.wellsfargo.com/privacy-security/terms/)
- Wells Fargo's responsible-AI statement describes explainability, bias management, model-risk management, performance monitoring, governance over data and model use, and cross-functional review involving the business, risk/compliance, legal, and AI specialists. — [Wells Fargo Sustainability and Governance Report](https://www.wellsfargo.com/assets/pdf/about/corporate-responsibility/sustainability-and-governance-report.pdf)

### Inferences
- Use of a third-party AI/cloud provider is not itself unusual in banking: Wells Fargo publicly uses Google Cloud. The differentiator is the contractual/technical boundary, data minimization, governance, and keeping bank actions behind controlled APIs.
- For a Junction pitch, “the model never runs SQL” is closer to documented banking practice than “the model can query everything.” A bank-owned query service can access the full authorized history while exposing only typed, read-only tools and aggregated results to the conversation model.
- A claim that no personal data ever leaves a bank would require deployment and contractual evidence. Public bank sources often say data is protected or masked but do not provide enough detail to prove that every derived datum stays on bank infrastructure.

### Gaps
- No reviewed official source publishes SQL permissions, query-generation mechanisms, model prompts, full data lineage, cloud-region details, or field-by-field payloads. Therefore arbitrary SQL cannot be ruled out as an internal implementation detail, but there is no evidence supporting it and the described systems point to controlled workflows.
- Public sources do not establish whether third-party providers can retain or train on customer content under each bank's private commercial contracts.
