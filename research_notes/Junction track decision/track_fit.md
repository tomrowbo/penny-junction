# Junction 2026 track fit for a two-person experienced team

## Which currently known challenges are genuinely rankable?

### Takeaway
Six partner briefs are public enough to evaluate: S-Pankki, Stoa, Cala, Ignite Next × Intel, Rokoko, and Bahn Express. AstraZeneca is confirmed but its concrete brief is not public; eleven other listed challenge partners likewise cannot be responsibly ranked until their participant-only cards or opening videos are available.

### Cited Findings
- Junction publicly lists six umbrella tracks: Hardware (by Arduino), Healthcare, AI Infrastructure (by Verda), FinTech, Agentic AI, and Data. It also says technology challenges can be combined with any main challenge. — [Official Junction 2026 site](https://2026.hackjunction.com/#this-year)
- The official partner roster names Aalto University, AfterQuery, AstraZeneca, Bahn Express, Cala, City of Espoo, Context.dev, Exa, Hostinger, Ignite Next, Intel, MariaDB, Meta, Rokoko, S-Pankki, Stoa, Tieto, and Valio Aimo as challenge partners. — [Official Junction 2026 partners](https://2026.hackjunction.com/#partners)
- S-Pankki's announced “Personal Economic Trainer” asks for an AI conversational experience using synthetic transaction data modeled on real banking activity; the announcement itself gives examples such as asking where money went or how eating out affects savings. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)
- Stoa asks teams to make AI answer questions about real construction drawings accurately, with answers that can be verified at a glance. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)
- Cala's “Make Unicorns Real” asks for a useful founder/VC product using reliable public data about companies, people, investors, and rounds. — [Official Cala workshop listing](https://2026.hackjunction.com/#workshops)
- Ignite Next × Intel supplies robot arms and cameras so teams can connect code to physical movement; its associated workshop names Intel Core Ultra, OpenVINO, and Physical AI Studio. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction); [official Intel workshop listing](https://2026.hackjunction.com/#workshops)
- Rokoko supplies motion-capture equipment and mentors for experiences driven by human movement in animation, robotics, and software interaction. Rokoko's own event post narrows its emphasis to using human motion for robot learning. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction); [Rokoko's official subreddit announcement](https://www.reddit.com/r/Rokoko/comments/1xv921d/were_sponsoring_junction_hackathon_in_finland/)
- Bahn Express's public announcement describes the operating domain—coordinating European vehicle transport across bookings, drivers, and delivery tracking—but does not publish a precise required output or judging rubric. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)
- AstraZeneca is confirmed as a challenge partner and healthcare perspective, but its announcement contains no concrete challenge statement. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)
- The public Junction Platform response currently returns an empty challenge array to an unauthenticated visitor, so its participant-only briefs cannot be verified from the public page. — [Junction 2026 Platform](https://hackjunction.app/hackathons/junction-2026)

### Inferences
- **Rank now:** S-Pankki, Stoa, Cala, Ignite × Intel, Rokoko, and (with lower confidence) Bahn Express. **Do not pre-commit:** AstraZeneca, Aalto, AfterQuery, City of Espoo, Context.dev, Exa, Hostinger, MariaDB, Meta, Tieto, or Valio Aimo until the team reads their exact cards.
- The umbrella track label is less decision-useful than the sponsor brief: challenge partners choose their own winners, while the overall competition later goes through peer review and a live grand jury.
- Because the official site says most 2026 briefs involve AI or agents, “LLM plus chat/search” is likely the event's most crowded form. Physical motion, a spatial overlay, or a live operations map offers greater visual distinctiveness.

### Gaps
- No public source exposes the full briefs, prizes, required datasets/APIs, judging rubrics, hardware quantities, reservation rules, or current team counts for every partner.
- The challenge cards shown at opening and answers from partner desks should supersede this ranking, especially for Bahn Express and all unannounced partner briefs.

## Which choices create the strongest 60–90 second live demo?

### Takeaway
Rokoko and Ignite × Intel have the highest raw spectacle, but Stoa offers the best spectacle-to-reliability ratio: a question, a highlighted drawing region, and a verifiable answer are understandable in seconds. S-Pankki's iMessage surface is familiar and polished, but the chat itself is not a showstopper because conversation is already the brief.

### Cited Findings
- Junction's selection path makes partner fit and broad stage appeal separate hurdles: partners choose challenge winners, face-to-face peer review selects five overall finalists, and those finalists pitch to the grand jury. — [Official judging process](https://2026.hackjunction.com/#judging)
- The 2025 overall winner WAVELET chose a problem combining technical difficulty with a satisfying visual result and built a real-time GPU-accelerated radio-wave simulation; the sponsor supplied a 200 MB Hong Kong map. — [Junction winner interview](https://www.linkedin.com/posts/hackjunction_funny-coincidence-we-interviewed-the-winners-activity-7395883679862059008-mhFQ); [WAVELET repository](https://github.com/ron0studios/WAVELET)
- Rokoko's Smartsuit Pro II can stream motion in real time through Rokoko Studio and export FBX/BVH; the vendor advertises up to 200 fps, built-in Wi-Fi, and use without external tracking cameras. — [Rokoko Smartsuit Pro II](https://www.rokoko.com/products/smartsuit-pro)
- Rokoko's Device SDK offers direct TCP/IP access on Windows, macOS, and Linux, including suit data up to 200 Hz and quaternions suitable for retargeting robot models. — [Rokoko Device SDK](https://sdk.rokoko.com/)
- OpenVINO's Physical AI runtime can load an exported policy, consume robot-state and camera observations, and send actions through a robot runtime; the official SO-101 example runs a robot and USB camera at 30 fps. — [OpenVINO Physical AI architecture](https://docs.openvino.ai/2026/physical-ai/explanation/architecture.html); [run-policy-on-robot guide](https://docs.openvino.ai/2026/physical-ai/how-to/runtime/run-policy-on-robot.html)
- Stoa's brief explicitly requires answers that are visually verifiable on the construction drawing, naturally creating a “question → highlighted evidence → answer” demonstration. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)
- S-Pankki's own announced brief already specifies conversational financial questions, so a chat interface alone demonstrates compliance rather than novelty. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)

### Inferences
- **Raw spectacle ranking:** (1) a robot physically reproducing or adapting a skill, (2) live human motion controlling/teaching a digital or physical system, (3) construction drawing question with exact highlighted evidence, (4) a live European vehicle-operations map resolving a delay cascade, (5) a sourced founder/investor graph, (6) iMessage financial coaching.
- **Best spectacle adjusted for two-person delivery risk:** Stoa first, Rokoko second if the direct SDK spike works Friday, Bahn Express third if the actual brief permits operational optimization, Ignite fourth because its best moment depends on shared mechanics and calibration.
- A robust 90-second Rokoko sequence is: human performs one movement; a browser-based skeleton mirrors it; the system segments the skill; a simulator or robot replays it; an error/latency score appears. The visual should work with recorded data before the team ever gets the suit.
- A robust 90-second Stoa sequence is: ask “Which fire door serves this room?”; the system zooms to and outlines the exact symbols/route; it answers with drawing/page/coordinate citations; then a deliberately ambiguous question is rejected rather than hallucinated.
- iMessage is best used as the surprising entry point to a stronger computational artifact, not as the artifact itself.

### Gaps
- The public sources do not state how many Rokoko suits, gloves, cameras, or Intel robot arms are available, nor whether teams can reserve them.
- It is unknown whether Stoa provides vector PDFs, raster scans, BIM files, labeled examples, or a test set; those details materially affect both spectacle and feasibility.

## Which can two experienced people finish reliably, and what are the failure modes?

### Takeaway
Stoa, S-Pankki, Cala, and a Bahn Express software workflow are realistically finishable by two people because they can be developed against files or synthetic data and replayed deterministically. Rokoko is viable only with a simulator/record-replay path from hour one; Ignite × Intel has the highest chance of losing the weekend to hardware, calibration, and policy integration.

### Cited Findings
- Junction's preliminary submission is due Friday at 23:55 on the Platform, while the final submission is due Sunday at 10:00, leaving little room for a hardware integration that only begins working late Saturday. — [Junction 2026 Platform schedule](https://hackjunction.app/hackathons/junction-2026); [official event schedule](https://2026.hackjunction.com/#schedule)
- OpenVINO's quickstart expects correctly shaped observations, state/image keys, an exported policy, and an action-selection loop; deploying to a physical robot adds RobotRuntime and camera/device configuration. — [Physical AI quickstart](https://docs.openvino.ai/2026/physical-ai/getting-started/quickstart.html); [runtime architecture](https://docs.openvino.ai/2026/physical-ai/explanation/architecture.html)
- OpenVINO can share a robot over a local network through Zenoh, but its documentation warns the remote mode has no built-in authentication or encryption and should run on an isolated network. — [OpenVINO share-a-robot guide](https://docs.openvino.ai/2026/physical-ai/how-to/runtime/share-a-robot.html)
- Rokoko's direct SDK avoids a game-engine dependency, whereas its Unity livestream workflow requires Rokoko Studio plus a compatible Unity plugin and subscription tier. — [Rokoko Device SDK](https://sdk.rokoko.com/); [Rokoko Unity livestream documentation](https://support.rokoko.com/hc/en-us/articles/4410471183633-Livestream-to-Unity)
- Verda gives credits to all Junction teams regardless of challenge and explicitly rewards documenting the process, attacking hard problems, and showing how the prototype scales; its bounty offers €10,000 in credits to the winner and €2,500 to runners-up. — [Verda Junction 2026 announcement](https://verda.com/blog/junction-2026)
- Junction's judges publicly say they are looking for a real problem rather than an easy feature, explicit agent failure/evaluation behavior, repeat use, one unique “10x” insight, and a path to production and scale. — [Official judges' guidance](https://2026.hackjunction.com/#judges)

### Inferences
- **Scores (5 = best; access score 5 = least dependency risk):**

  | Option | 90-sec spectacle | technical novelty / defensibility | partner fit | two-person reliability | data / hardware access | relative uncrowdedness |
  |---|---:|---:|---:|---:|---:|---:|
  | Stoa evidence-on-drawing | 4.5 | 4.0 | 5.0 | 4.0 | 4.0* | 3.0 |
  | Rokoko motion-to-robot skill | 5.0 | 4.5 | 5.0 | 2.5 | 2.0 | 3.5 |
  | Bahn delay/dispatch twin | 4.0 | 3.5 | 4.0* | 4.0 | 3.5* | 4.0 |
  | Ignite × Intel robot exception recovery | 5.0 | 4.0 | 5.0 | 2.0 | 1.5 | 2.5 |
  | S-Pankki financial decision twin | 3.5 | 3.5 | 5.0 | 5.0 | 5.0 | 2.0 |
  | Cala sourced decision graph | 3.5 | 3.0 | 5.0 | 4.0 | 4.0 | 2.5 |

  Asterisks indicate dependence on the still-private brief/dataset. “Relative uncrowdedness” is an inference from the public brief and the event's AI-heavy mix, not a measured team count.
- **Stoa failure modes:** spending the weekend on generic PDF RAG; no coordinate-level evidence; brittle OCR on rotated/low-resolution drawings; no abstention when symbols conflict. Mitigation: restrict to one drawing question class, keep geometric provenance through the pipeline, and create a 10–20 question mini-evaluation immediately.
- **Rokoko failure modes:** waiting for a suit, Unity/Unreal plugin incompatibility, calibration drift, human-to-robot kinematic mismatch, and a demo that is only “avatar mirrors me.” Mitigation: direct SDK → simple Three.js/WebGL skeleton, a recorded packet fixture, deterministic playback, and one measurable transformation beyond mirroring.
- **Ignite failure modes:** arm unavailable, USB/camera permissions, calibration, unsafe motion, model/action mismatch, and slow policy training. Mitigation: simulator or logged observations first; bounded pre-scripted skill plus on-device perception; hard joint/speed limits and kill switch; treat the real arm as the last output adapter.
- **S-Pankki failure modes:** dozens of teams building transaction categorization plus a chatbot; fake-looking proactive messages; unverifiable LLM arithmetic; privacy/safety objections; iMessage automation failing live. Mitigation: deterministic ledger calculations, explicit uncertainty and data lineage, a recorded/canned message fallback, and a unique decision-simulation core.
- **Cala failure modes:** generic company-search/RAG dashboard, stale or conflicting public sources, and an attractive graph with no decision consequence. Mitigation: one high-value decision, source every edge, expose entity conflicts, and quantify time saved or an otherwise invisible relationship.
- **Bahn Express failure modes:** solving a guessed problem rather than the actual brief, unrealistic synthetic routes, and a dashboard without a decision. Mitigation: confirm the partner's worst exception Friday, model only that exception, and show a before/after dispatch decision with ETA/customer impact.
- If the team chooses hardware, it should set a Friday kill gate: by roughly 22:00, simulated/recorded data must already drive the complete visual loop. If not, switch to Stoa/S-Pankki/Bahn rather than waiting for equipment.

### Gaps
- No live count of preliminary teams per challenge is public, so crowding scores are directional only. Ask each partner how many teams have introduced themselves or submitted preliminary entries.
- No public benchmark reveals expected accuracy, latency, or safety thresholds for the 2026 challenges.

## Is the iMessage finance coach competitive, and what would make it non-incremental?

### Takeaway
As currently framed—open-banking data, LLM, proactive reminders, and iMessage—the idea is polished and very finishable but is likely incremental: it implements S-Pankki's announced conversational trainer almost literally. It becomes competitive if iMessage is merely the doorway to a verifiable **financial decision twin** that resumes after consent, simulates life choices, learns from corrections, and proves every recommendation from ledger data.

### Cited Findings
- S-Pankki's public brief already asks builders to use synthetic modeled transaction data to answer conversational questions about spending and savings counterfactuals. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)
- The official judge guidance rewards one unique 10x insight, recurring user value, explicit failure/evaluation behavior, and a credible production path—not merely a large feature list. — [Official judges' guidance](https://2026.hackjunction.com/#judges)
- Junction's general judging criteria include relevance, novelty, technical quality, UX, completeness/demo-ability, feasibility, and impact; judges may exercise endpoints or binaries using supplied credentials. — [Junction terms](https://www.hackjunction.com/terms-of-service)
- The 2022 overall winner turned a familiar diary flow into a single emotionally legible transformation—an AI-generated artwork from the day's entry—and also won a technology side challenge. — [Asia Business Daily report](https://view.asiae.co.kr/en/article/2022111311381508794)

### Inferences
- **Verdict:** good candidate for the S-Pankki partner prize if exceptionally polished and safe; weak candidate for overall winner if the pitch is “your bank in iMessage.” The channel is a distribution flourish, not a defensible technical core.
- The non-incremental thesis should be: **“A living financial model that turns a vague life choice into a transparent, continuously monitored plan.”** The system should separate deterministic finance math from language generation and show which transactions, assumptions, and confidence bounds produced each conclusion.
- Best 75-second demo: (1) text “Can I afford an €18,000 car?” from an unconnected number; (2) receive a consent URL; (3) complete sandbox connection and automatically resume the pending question; (4) receive two explicit scenarios with emergency-buffer and goal-date effects; (5) reply “keep eating out, extend the loan” and recalculate instantly; (6) fast-forward the ledger one week and receive a proactive alert only because the chosen plan has drifted.
- Three features make this materially stronger than chat:
  1. **Counterfactual engine:** simulate one-off purchases, financing, recurring costs, uncertain income, and goal trade-offs over time.
  2. **Proof ledger:** every number links to source transactions and deterministic calculations; the agent abstains when data is missing.
  3. **Closed-loop plan:** user corrections update categories/preferences, and proactive messages fire against a declared plan rather than generic “you spent too much” moralizing.
- Avoid scolding copy such as “Was this really needed?” It is psychologically brittle and makes the product feel like a notification wrapper. Use neutral, controllable prompts: “Dining is €42 above the weekly range you chose; keeping this pace moves the car goal by 11 days. Ignore, adjust the plan, or inspect transactions?”
- For the stage, show an adjacent compact web “proof view” or generated mini-chart after the iMessage exchange; otherwise peer reviewers only see text bubbles and cannot perceive the underlying technical work.
- A realistic safety story is itself differentiating: no autonomous transfers, clearly labeled estimates, user-controlled proactive cadence, data deletion, and explanation of what happens when categories or future-income assumptions are uncertain.

### Gaps
- S-Pankki's exact prize rubric, required sandbox/API, consent flow, and whether channel integrations are valued are not public. Ask the sponsor whether a conversational UI is expected from nearly every team and what would make them reject one.
- Public sources do not reveal whether persistent account consent is simulated by the supplied sandbox; do not make real open-banking refresh-token behavior part of the judging promise unless the sponsor confirms it.

## What are the strongest concrete concepts to pursue?

### Takeaway
The best reliable bet is Stoa's **Drawing Truth Lens**; the highest-upside bet is Rokoko's **ShadowTeach**, optionally ending on an Intel robot only after the simulation works; the best software fallback is S-Pankki's **Decision Twin**, not a generic coach. Bahn Express may become the contrarian first choice if its private brief confirms exception dispatch and usable data.

### Cited Findings
- Stoa explicitly asks for accurate construction-drawing answers that can be verified at a glance, matching an evidence-overlay product rather than a generic document chatbot. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)
- Rokoko's current event focus is human-motion data for robot learning, and its SDK exposes high-frequency pose data directly enough to build a custom non-game-engine pipeline. — [Rokoko event announcement](https://www.reddit.com/r/Rokoko/comments/1xv921d/were_sponsoring_junction_hackathon_in_finland/); [Rokoko Device SDK](https://sdk.rokoko.com/)
- Intel's documented runtime supports camera observations and robot action loops, making a simulator-first adapter to an SO-101-class arm technically aligned with its stack. — [OpenVINO Physical AI quickstart](https://docs.openvino.ai/2026/physical-ai/getting-started/quickstart.html); [robot runtime guide](https://docs.openvino.ai/2026/physical-ai/how-to/runtime/run-policy-on-robot.html)
- S-Pankki's explicit examples include spending diagnosis and savings counterfactuals, so a deeper decision simulator remains on-brief while offering more than chat. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)
- Bahn Express's public domain includes bookings, drivers, and delivery tracking across Europe, which provides the ingredients for a visible operations twin if the partner confirms that is in scope. — [Junction's current announcement feed](https://se.linkedin.com/company/hackjunction)

### Inferences
- **1 — Drawing Truth Lens (Stoa; recommended for win probability).** Narrow to one safety-critical drawing workflow such as fire-door/egress verification. Parse the plan, preserve symbol/geometry coordinates, answer with highlighted evidence and page/grid citations, and abstain on ambiguity. The 10x insight is that correctness is a spatial proof the user can inspect, not fluent text. Ship a 15-case adversarial evaluation panel beside the demo.
- **2 — ShadowTeach (Rokoko; recommended for overall-win upside).** A person demonstrates one bounded arm/body task once; the system converts high-rate mocap into a normalized skill trajectory, shows a live ghost skeleton plus safety envelope, segments the action, and replays it on a simulator. If an arm slot is available, the same adapter sends the trajectory to the robot. Score latency, trajectory error, and rejected unsafe poses. This directly answers Rokoko's robot-learning focus and remains fully demonstrable without hardware.
- **Ignite variant — Exception Replay.** A camera detects that a routine pick failed because an object moved. A human provides one bounded correction through teleoperation or a recorded demonstration; the local OpenVINO pipeline normalizes and replays it, with the camera verifying success. Do not attempt to train a new general VLA during the weekend.
- **3 — Decision Twin (S-Pankki; recommended software fallback).** The iMessage consent/resume experience fronts a deterministic household cash-flow simulator. It answers “Can I afford this car?” with scenario deltas, evidence, uncertainty, and ongoing plan-drift alerts. The winning unit is one life decision followed through a closed loop, not a catalogue of budgeting features.
- **Contrarian watch — Recovery Dispatcher (Bahn Express).** On a map, inject a driver delay; calculate the cascading ETA/booking consequences; propose one reassignment; show customer and cost impact; send traceable notifications. Promote this above S-Pankki if the actual brief asks for disruption management and the partner provides realistic events/routes, because it is likely less crowded and more visual.
- **Cala fallback — Conflict-Aware Deal Graph.** For one founder, find investors fitting the round while exposing portfolio conflicts, warm-introduction paths, and the public source behind every edge. The demo should end with a ranked action list and conflict explanation, not search results.
- **Decision rule at opening:** choose Stoa by default; choose ShadowTeach only after confirming suit access and direct SDK packets; choose Ignite only if a robot slot plus known working baseline is available; choose Bahn if the private brief/data validate the recovery-dispatch concept; choose S-Pankki when hardware/spatial parsing risks are unacceptable or the team has a genuine finance-modeling advantage.

### Gaps
- Each concept must be checked against the exact challenge card and partner disqualifiers before the preliminary submission.
- No public source establishes whether one project can formally enter both the Rokoko and Ignite × Intel challenges; treat the robot endpoint as an optional demo adapter unless organizers confirm dual-entry eligibility.
