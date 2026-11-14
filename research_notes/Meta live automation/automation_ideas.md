# Meta live multimodal automation ideas

## Which everyday or professional tasks benefit from continuous visual and audio context?

### Takeaway
The strongest opportunity is repetitive physical work whose state is obvious from first-person video but whose digital record or downstream action is still manual. A winning concept should go beyond identifying or coaching: it should learn a short workflow from demonstration, recognize its state live, and visibly execute the next digital or physical action.

### Cited Findings
- Meta positions the Device Access Toolkit (DAT) as a way for apps to respond in real time to what wearers “see, hear, and do”; official examples already span POV streaming, industrial assistance, navigation, drawing instruction, plant care, accessibility, study coaching, and location tracking. This means a generic visual coach or object recognizer will be hard to differentiate. — [Meta developer blog](https://developers.meta.com/blog/explore-whats-possible-with-wearables-device-access-toolkit/)
- DAT 1.0 exposes camera, microphone/audio, motion, and IMU context across Meta’s supported AI-glasses portfolio. — [Meta Wearables FAQ](https://developers.meta.com/wearables/faq/)
- Meta’s official camera sample supports a live glasses feed, photo capture, and video recording with optional glasses-microphone audio. — [CameraAccess sample](https://github.com/meta/meta-wearables-dat-ios/blob/main/samples/CameraAccess/README.md)
- Meta already advertises continuous real-time visual help, long-term reminders, translation, messaging, and object/environment assistance as built-in or partner use cases. — [Meta AI glasses feature announcement](https://about.fb.com/news/2024/09/ray-ban-meta-glasses-new-ai-features-and-partner-integrations/)

### Inferences
- **1. “Show Me Once” packing-station autopilot — strongest recommendation.** Live input: an expert packs two or three sample orders while narrating. Learned state: item-to-box workflow, expected item sequence, packing material, and completion cue. Action: on subsequent orders, verify each SKU, stop a wrong/missing item, decrement inventory, and automatically print the shipping label only when the box is correct. Value: fewer mis-packs and zero scanner/checklist handling. Weekend feasibility: high with 5–10 visually distinct props, a simple order feed, temporal event log, and a label-print webhook. Demo beat: deliberately insert the wrong item; the system refuses to print, then prints instantly when corrected.
- **2. Field-service “watch one, guide the next” agent.** Live input: an expert demonstrates a filter change, bike adjustment, or machine reset and narrates why. Learned state: ordered steps, tool/part identities, visual completion criteria, and expert exceptions. Action: guide a novice, create a completed service record with photo evidence, update asset status, and open a parts order if a component is missing. Value: turns tacit knowledge into a living SOP. Feasibility: high if scoped to one tabletop device. Demo beat: expert teaches once; a second person performs it out of order and the agent catches the deviation, then closes the work order.
- **3. Smart retail restock loop.** Live input: a worker walks a shelf or pop-up store. Learned state: desired shelf arrangement and product facings from an initial “golden shelf” walkthrough. Action: create restock tasks, update counts, and trigger a back-room pick/label when a gap is detected. Value: removes manual shelf audits. Feasibility: high with a miniature shelf and distinctive products. Demo beat: remove or misplace an item, walk past, and show the exact restock ticket appear automatically.
- **4. Kitchen-line assembly verifier.** Live input: a cook demonstrates a menu item; later, POV video watches plate or drink assembly while microphones capture verbal orders. Learned state: recipe sequence, portion proxies, allergy-specific substitutions, and typical preparation time. Action: advance the kitchen display, decrement ingredient stock, start timers, and mark the order ready only after the correct assembly. Value: fewer missing components and hands-free operations. Feasibility: medium-high with fake ingredients/cups. Demo beat: omit a component; the order stays blocked until it is added, then a pickup light turns green.
- **5. Lab bench chain-of-custody assistant.** Live input: scientist demonstrates a sample-transfer protocol; the stream sees tube labels and actions. Learned state: sample lineage, step order, volumes/containers, and completion evidence. Action: write the experiment log, update a mock LIMS, and print the child-sample label after correct transfer. Value: eliminates manual documentation and labeling while preserving provenance. Feasibility: medium; use water, colored tubes, QR labels, and never control hazardous equipment. Demo beat: swap two tubes and visibly block the label printer.
- **6. Event-room reset autopilot.** Live input: staff demonstrate the correct room layout and AV startup once. Learned state: chair/table positions, required objects, screen state, and spoken setup checks. Action: create missing-item tasks, control smart lights/plug, start the display deck, and mark the room ready. Value: fast repeatable venue turnover. Feasibility: high with a miniature room or actual hackathon booth. Demo beat: a missing cable creates a task; replacing it turns lights green and launches the presentation.
- **7. Construction/property punch-list agent.** Live input: an expert walkthrough names defects and what “finished” looks like. Learned state: local quality standards, room/asset identity, and issue categories. Action: create location-tagged punch-list tickets with captured evidence and route them to the correct trade. Value: turns a walkthrough directly into accountable work. Feasibility: high with staged defects. Demo beat: say “this type of gap is a carpenter issue” once, then recognize a second gap and assign the ticket automatically.
- **8. Adaptive stockroom memory.** Live input: workers naturally put tools and materials away over several minutes. Learned state: where this team actually stores each class of item and which items travel together. Action: maintain a live inventory/location map, generate a pick list in walking order, and reorder consumables after confirmed depletion. Value: less hunting and fewer duplicate purchases. Feasibility: medium-high with a small rack and QR fallback. Demo beat: move an item; ask for a job kit and have the system light up/order the missing component.
- **9. Personalized routine support for cognitive accessibility.** Live input: a user or caregiver demonstrates a safe morning/closing routine. Learned state: that person’s own sequence and recognizable completion cues. Action: show/speak the next step, check off the routine, and contact a chosen supporter only after the user confirms they are stuck. Value: supports independence without forcing a rigid generic routine. Feasibility: medium, but restrict the prototype to benign actions such as packing a bag or locking up—not medication or emergency decisions. Demo beat: skip keys; the glasses prompt before departure and, after confirmation, message the trusted contact.
- **10. Gesture-to-action accessibility layer.** Live input: the user demonstrates a small set of personalized visible gestures or points at objects while naming intended actions. Learned state: user-specific gesture examples and object/action bindings. Action: call Home Assistant/WebMCP tools to control a lamp, fan, media, or communication shortcut. Value: gives people with speech or mobility differences a personalized interface rather than a fixed command set. Feasibility: medium; use explicit enrolment and a confirmation gesture for consequential actions. Demo beat: teach a new gesture live, then immediately use it to change a real lamp.
- **11. Sports drill orchestrator.** Live input: coach demonstrates a drill and calls out good/bad repetitions; POV/motion stream tracks the athlete’s attempts. Learned state: personalized cadence, common mistake states, and recovery time. Action: adapt the next drill, play a cadence, control interval timers/camera capture, and log only completed reps. Value: hands-free practice that changes the session rather than merely narrating form. Feasibility: medium-high for a simple ball, squat, or footwork drill. Demo beat: performance degrades, so the system automatically changes cadence and the next interval.
- **12. “First example becomes policy” waste-sorting station.** Live input: a venue manager demonstrates how ambiguous local items are sorted and explains exceptions. Learned state: venue-specific item-to-bin rules rather than generic recycling knowledge. Action: illuminate/unlock the right bin, update waste counts, and create a contamination task on a wrong placement. Value: local policy adapts instantly and produces operational data. Feasibility: high with colored bins and smart LEDs/servo. Demo beat: teach an unusual cup rule, then correctly route the next matching cup and physically open the proper bin.

### Gaps
- Exact challenge judging criteria may change which vertical is best; the separate challenge-page researcher should verify whether Meta rewards a general platform, accessibility, industrial workflows, on-device processing, or a named SDK capability.
- The hardware available at Junction (display vs displayless glasses, SDK version, network reliability, and access credentials) is not established in this note.

## Which ideas can safely act through existing APIs, computer control, or smart devices?

### Takeaway
The safest hackathon architecture is a bounded action layer: the learned model proposes a typed action, deterministic rules verify current workflow state, and the user confirms any consequential or outward-facing operation. Low-risk reversible actions can execute automatically and make the demo feel genuinely agentic.

### Cited Findings
- WebMCP lets developers define exactly which web-app features/actions Meta AI may control; Meta describes this as hands-free action while the developer remains in control of the available tool set. — [Meta Wearables FAQ](https://developers.meta.com/wearables/faq/)
- Meta’s official agentic sample apps show that WebMCP can perform multi-step UX operations such as adding, annotating, checking off, and reordering tasks; shopping ingredients; and making game moves. — [Official WebMCP samples](https://github.com/meta/meta_glasses_webmcp)
- Meta AI Connectors similarly expose developer-defined service actions as tools callable from Meta AI, although the program is in developer preview. — [Meta Wearables FAQ](https://developers.meta.com/wearables/faq/)
- DAT applications can process data locally or through cloud/edge services, so a hackathon prototype can route glasses frames to an inference backend and call ordinary APIs from the phone/server. — [Meta Wearables FAQ](https://developers.meta.com/wearables/faq/)
- Meta’s display APIs can render text, buttons, images, and video, while its device tooling supports mock camera feeds and simulated devices for deterministic testing. — [Display Access guide](https://github.com/meta/meta-wearables-dat-ios/blob/main/plugins/mwdat-ios/skills/display-access/SKILL.md); [CameraAccess sample](https://github.com/meta/meta-wearables-dat-ios/blob/main/samples/CameraAccess/README.md)

### Inferences
- Best action targets for a weekend prototype are: a network label printer; Home Assistant/MQTT smart plug or light; a Slack/Discord/WhatsApp test channel; Linear/Trello/Jira; a mock inventory/order API; calendar; a web dashboard; or a small servo. They are visible, fast, reversible, and easy to stub if venue networking fails.
- Use four action tiers: **automatic** for reversible local state (advance checklist, change light, start timer); **confirm once** for external side effects (send message, create ticket, print label); **double-confirm** for purchases/locks/machinery; **never autonomous** for medical dosing, dangerous equipment, financial transfers, or emergency escalation.
- The model should emit a constrained object such as `{workflow, observed_step, confidence, proposed_action, evidence_frame}`. A deterministic state machine—not free-form model text—decides whether the action is legal from the current state.
- Preserve a “why this happened” timeline with the evidence frame, detected event, learned rule, and action result. This makes the demo legible to judges and helps correct mistakes.
- A strong physical demo can use a browser-based simulator or prerecorded feed for rehearsal and swap in glasses on stage; official tooling supports simulated devices, though Meta notes that its current Mock Device Kit does not support display glasses.

### Gaps
- Whether Junction teams receive access to WebMCP, Meta AI Connectors, display hardware, or only DAT camera streaming must be verified from the challenge page and mentor briefing.
- Third-party API credentials and venue network/printer discovery could be unreliable; every action needs a local demo fallback.

## Which concepts are distinctive, feasible in a weekend, and visually impressive?

### Takeaway
The packing-station autopilot and field-service apprentice are the best overall bets. Both demonstrate genuine learning from a live expert stream, temporal understanding, error detection, and an undeniable action in under 90 seconds; the packing concept has the cleanest, most objective success metric.

### Cited Findings
- Existing official prototypes already perform plant analysis, object/text finding, study tracking, drawing guidance, location tracking, and live human visual assistance, so variants that stop at identification, summarization, or prompts risk looking incremental. — [Meta developer showcase](https://developers.meta.com/blog/explore-whats-possible-with-wearables-device-access-toolkit/)
- Meta’s platform framing emphasizes hands-free, eyes-up experiences “in the flow of the moment,” with native camera, speech, motion, display, and input paths. — [Meta Wearables overview](https://developers.meta.com/wearables/)
- Official WebMCP examples show that simple, animated state changes make agent actions easy to understand on a small display, including groceries visibly dropping into a cart as the agent acts. — [Official WebMCP samples](https://github.com/meta/meta_glasses_webmcp)

### Inferences
- **Rank 1: packing-station autopilot.** Novelty 5/5; weekend feasibility 5/5; visual demo 5/5; useful action 5/5. It has an objective ground truth and a satisfying final physical action (label prints / green light).
- **Rank 2: field-service apprentice.** Novelty 5/5; feasibility 4/5; visual demo 5/5; useful action 4/5. It best communicates “AI learned tacit knowledge from a person,” but visual step recognition is less deterministic than SKU checking.
- **Rank 3: event-room reset.** Novelty 4/5; feasibility 5/5; visual demo 5/5; useful action 4/5. It can control real AV/lights and uses the venue itself, but the learned policy may appear rule-based unless the teaching moment is explicit.
- **Rank 4: waste-sorting station.** Novelty 4/5; feasibility 5/5; visual demo 5/5; useful action 4/5. Physical bin actuation is memorable, though it risks being perceived as simple classification unless local rules are learned live.
- **Rank 5: retail shelf restock.** Novelty 3/5; feasibility 5/5; visual demo 4/5; useful action 5/5. Commercially legible but a familiar computer-vision use case.
- **Recommended 75-second demo story:** (1) Expert says “learn this workflow” and packs one box. (2) A timeline extracts 4–5 steps. (3) Novice starts a new order and adds one wrong SKU. (4) Glasses/phone show the mismatch and the printer stays locked. (5) Novice corrects it. (6) The agent prints the label, decrements inventory, and displays evidence that it learned the policy from the first stream. This is a complete **observe → learn → intervene → act → prove** loop.
- To make “learning” credible, have the expert label only one or two moments verbally (“fragile items go in last”; “this sticker means cold chain”). The second run must apply that rule to a different but analogous item. If the second run is identical, judges may assume the flow is hardcoded.
- Scope the prototype to one workflow, 5–10 objects, 4–6 states, and 2 downstream tools. Breadth will weaken temporal reliability and the clarity of the demo.

### Gaps
- It is not known whether the AI-ATL reference project’s core novelty is imitation learning, event memory, live scene understanding, or tool invocation. The repository researcher should align the final recommendation to the actual mechanism rather than the broad “stream → learn → act” interpretation used here.

## What privacy and safety controls are essential?

### Takeaway
Continuous first-person capture is only defensible if recording is obvious, scoped to a named task, minimized, and easy to stop. Actions must be auditable and gated by reversibility, confidence, and user confirmation.

### Cited Findings
- Meta states that AI-glasses capture uses a front-facing white capture LED; on newer models, blocking or tampering with the LED disables the camera. Meta explicitly frames bystander trust as necessary for wearable adoption. — [Meta AI glasses privacy Q&A](https://about.fb.com/news/2026/07/metas-ai-glasses-your-questions-answered/)
- Meta says photos/videos captured for the gallery remain private on the glasses until the user chooses to import or share them. A custom live-streaming prototype has a different data path and therefore must explain its own processing/storage behavior. — [Meta AI glasses privacy Q&A](https://about.fb.com/news/2026/07/metas-ai-glasses-your-questions-answered/)
- Meta requires integrations and apps to comply with its Wearables Developer Acceptable Use Policy. — [Meta Wearables FAQ](https://developers.meta.com/wearables/faq/)

### Inferences
- Start capture only after a clear voice/button action such as “learn this packing workflow,” show a persistent live/capture indicator, and stop automatically when the named task reaches a terminal state.
- Prefer extracting task events locally or ephemerally; retain embeddings/events and a few user-approved evidence frames rather than raw continuous video. Provide a one-tap “forget this session” control.
- Avoid identifying faces, inferring sensitive traits, or retaining bystander speech. Blur faces/screens when possible and demonstrate in a controlled booth with visible consent signage.
- Separate **learning** from **activation**: a newly inferred rule should be shown back to the user (“Fragile items go in last—use this rule?”) before it can trigger real actions.
- Display every action with evidence and an undo path. External communications should remain drafts until confirmed; physical controls need safe default/off states and rate limits.
- Treat low confidence, conflicting observations, unknown objects, or a changed environment as reasons to ask—not to act. A persuasive safety line for judges is: “The agent automates known states and asks on unknown ones.”

### Gaps
- The precise retention, cloud-processing, and prohibited-use requirements for the hackathon’s chosen model/API need review once the team selects its inference provider and action integrations.
