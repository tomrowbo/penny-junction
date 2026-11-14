# Actionable Junction winning advice

## What have official Junction sources and past winners or judges advised?

### Takeaway
The strongest Junction-specific signal is to optimize for a real, important problem and a crisp, memorable proof of value—not raw feature count. A winning entry must satisfy its partner's explicit criteria first, then survive face-to-face peer review and, if selected, a live jury pitch.

### Cited Findings
- Junction 2026 uses three different selection contexts: challenge partners select track winners against their own criteria; face-to-face peer review selects the overall top five; those five pitch live to a seven-person grand jury. This means “win the sponsor” and “win the room” are distinct jobs. — [Official Junction 2026 site](https://2026.hackjunction.com/)
- Junction's general event terms say challenge criteria typically cover relevance to the brief, novelty/creativity, technical quality, UX, completeness/demo-ability, and feasibility/impact. Judges or partners may actually run binaries, call endpoints, and use supplied demo credentials. — [Junction Terms of Service](https://www.hackjunction.com/terms-of-service)
- The Junction Platform describes a submission as a name, punchline, description, challenge selection, demo link, video link, and source-code link; its default scoring interface uses weighted innovation, impact, and implementation criteria. — [Junction Platform guide](https://hackjunction.app/blogs/how-to-run-a-hackathon-with-junction-platform)
- The 2026 grand-jury profiles are unusually explicit: Kia Kanninen wants a problem worth solving, not merely an easy feature; Otto Söderlund wants a real user problem and something users would return to; Hubertus van der Drift wants speed, pragmatism, and one unique insight that is 10x better/faster; Arturs Polis wants hard problems with a credible production/scale path; Daksh Raghuvanshi wants teams to explain agent failure modes and show a reward/evaluation that remains valid under attack. — [Official Junction 2026 judges](https://2026.hackjunction.com/)
- Frank Sandqvist, Junction 2024 overall winner and 2025 overall runner-up, advises identifying your strengths, composing a team around them, building something that genuinely excites you, and making the final product look clean and realistic while presenting it in an interesting/fun, attention-catching way. His 2024 presentation used an AI rap video, which he thought helped. — [Official Junction profile of Frank Sandqvist](https://www.hackjunction.com/blog/frank-sandqvist-story)
- The 2026 JunctionX Lisbon winner chose the challenge he believed had both the greatest winning potential and the most creative room. He later said he had overestimated perfect implementation: originality, stakeholder-oriented presentation, demonstrated potential, and future vision could matter even when the prototype was incomplete. — [CIÊNCIAS ULisboa winner interview](https://ciencias.ulisboa.pt/en/news/student-from-ciencias-wins-junctionx-lisbon-and-advances-to-the-international-competition-in-finland)
- Junction's 2025 retrospective says partners sought fresh perspectives rather than technical perfection: Bank of Finland wanted unfamiliar approaches; Supercell wanted something unpredictable; SAS wanted combinations of technology that turn insight into tangible impact. Junction specifically encouraged teams to brainstorm with partner representatives throughout the weekend. — [Official Junction 2025 retrospective](https://www.hackjunction.com/blog/48-hours-junction-2025)
- In a JunctionX Korea 2026 sponsor retrospective, judges praised the winning work for strong presentation structure, demo polish, purposeful UI, a universal rather than narrow implementation, and a technical view combining visualization with inspectable logs. The runner-up was praised for a clear problem, scientifically precise process, creativity without superfluous UI, and full reporting of intermediate steps and evidence. — [Lablup partner retrospective](https://www.lablup.com/blog/culture/2026-08-junctionx-hackathon-retrospective)
- That partner concluded that the hackathon loop is: scout possibilities, focus on an MVP, implement the minimum set, preserve time to present, and iterate through this loop several times; teams repeatedly approached mentors with questions and refined their interpretation of the task. — [Lablup partner retrospective](https://www.lablup.com/blog/culture/2026-08-junctionx-hackathon-retrospective)

### Inferences
- Write one sentence before coding: “For [specific user], [pain] causes [measurable consequence]; we make it [10x improvement] by [unique insight].” If that sentence is weak, the 2026 jury profiles imply the project is weak regardless of polish.
- Treat the sponsor brief and rubric as a test suite. Make a checklist with one proof/demo moment for every criterion and ask partner mentors early whether your interpretation matches their intent.
- For AI/agents, show an evaluation panel or before/after benchmark, failure cases, citations/logs, cost/latency, and one adversarial test. “It generated an answer” is unlikely to satisfy the explicitly evaluation-minded jury.
- Build the pitch story from hour one: problem, live proof, unique insight, evidence, plausible route to production, memorable close. A playful flourish can help recall, but only after the proof is solid.

### Gaps
- The public 2026 site does not publish one universal numeric overall-winner rubric; challenge partners control their own criteria, while the grand jury's final weighting is not stated. — [Official Junction 2026 site](https://2026.hackjunction.com/)
- Public sources do not state the exact peer-review ballot/question or live-pitch duration, so the team must confirm both with organizers on site.

## What common failure modes recur?

### Takeaway
The recurrent failure pattern is a technically busy but strategically thin project: easy feature, unclear user/pain, weak evidence, no sponsor feedback, brittle demo, and a pitch assembled at the deadline.

### Cited Findings
- Junction's 2026 jury language directly warns against starting with a feature that is easy to build instead of a worthwhile problem, agent claims whose evaluation breaks under scrutiny, products users would not return to, and prototypes without a credible scale/production path. — [Official Junction 2026 judges](https://2026.hackjunction.com/)
- The 2026 Saturday Hostinger keynote is framed around the idea that AI/vibe coding has made building cheap, so merely shipping no longer stands out; attention, timing, real problems, user discovery, and testing demand become scarce differentiators. — [Official Junction 2026 schedule](https://2026.hackjunction.com/)
- The Lisbon winner explicitly describes “perfect implementation is decisive” as his mistaken prior belief and says insufficient attention to originality, stakeholders, presentation, and future potential would be an error. — [CIÊNCIAS ULisboa winner interview](https://ciencias.ulisboa.pt/en/news/student-from-ciencias-wins-junctionx-lisbon-and-advances-to-the-international-competition-in-finland)
- Junction's terms permit judges to run the submission and use provided credentials, making dead links, missing setup instructions, excessive permissions, real customer data, or a demo that works only on the builder's laptop material risks. Demo credentials must be restricted and data should be synthetic/sanitized. — [Junction Terms of Service](https://www.hackjunction.com/terms-of-service)
- Sandqvist says solo participation is more stressful, requires more planning, and can force sacrifices such as sleep to ship in time; Junction 2026 has no dedicated sleeping area even though the venue stays open. — [Official winner profile](https://www.hackjunction.com/blog/frank-sandqvist-story); [Official Junction 2026 FAQ](https://2026.hackjunction.com/)
- The final submission is due Sunday at 10:00, immediately followed by review; the final ceremony begins at 14:00. A preliminary submission is due Friday at 23:59. — [Official Junction 2026 schedule](https://2026.hackjunction.com/)

### Inferences
- Failure modes to actively prevent: (1) solution hunting for a problem, (2) generic “AI wrapper,” (3) no quantified baseline, (4) opaque AI output with no evaluation, (5) coding past the point of demo stability, (6) ignoring the sponsor mentor until judging, (7) overlong setup, (8) no offline/fallback recording, (9) submission fields and video left to Sunday morning, and (10) both teammates exhausted simultaneously.
- Freeze new features Saturday evening. From then on, favor reliability, sample data, README/setup, screenshots/backup video, submission copy, and pitch rehearsal.
- A polished fake or hard-coded demo is dangerous if represented as functional; instead, clearly distinguish what is live, what is simulated, and what the next build step is. Candor plus a credible future path matches the evidence better than bluffing.

### Gaps
- No rigorous public loss analysis exists for rejected Junction main-event projects; these failure modes are inferred from the positive criteria and winner/sponsor retrospectives rather than a published dataset of losing teams.

## How should a two-person sibling team allocate roles and structure the 48 hours?

### Takeaway
Use paired product/technical ownership with deliberate overlap: one sibling owns user, sponsor, UX, submission, and pitch; the other owns architecture, core technical risk, deployment, and demo reliability. Both must be able to deliver the 60-second explanation and recover the demo.

### Cited Findings
- Junction 2026 permits teams of one to four, so a two-person team is valid but has half the maximum headcount. — [Official Junction 2026 FAQ](https://2026.hackjunction.com/)
- Hacking starts Friday at 19:30; preliminary submission is 23:59 Friday; final submission is 10:00 Sunday; review starts 10:30; top-five pitches occur at the final ceremony beginning 14:00. — [Official Junction 2026 schedule](https://2026.hackjunction.com/)
- Sandqvist's advice is to play into each team member's strengths, while the Lablup sponsor retrospective emphasizes rapid, repeated build/test/refine loops rather than one long implementation pass. — [Official winner profile](https://www.hackjunction.com/blog/frank-sandqvist-story); [Lablup partner retrospective](https://www.lablup.com/blog/culture/2026-08-junctionx-hackathon-retrospective)
- The public 2026 program puts partner/technology workshops early: Google DeepMind at 20:00 Friday; Verda and Arduino at 20:30; MLH/GitHub at 21:00; additional workshops run Saturday. — [Official Junction 2026 schedule](https://2026.hackjunction.com/)

### Inferences
- **Role A — product/pitch/integration:** interview sponsor and 3–5 target users/peers; write the value proposition; sketch UX; own frontend/demo flow, submission copy/video, and rehearsals; keep the rubric checklist.
- **Role B — technical/evidence/reliability:** spike the hardest assumption first; own backend/model/hardware, deployment, instrumentation/evaluation, test data, README, and fallback demo. Pair for architecture decisions and final integration rather than creating two disconnected halves.
- **Friday 19:30–23:59:** watch the challenge material, shortlist at most three, speak to partners, score them, select one by about 21:00, perform a 60–90 minute “kill-risk” spike, define MVP and demo script, then submit a coherent preliminary concept. Attend only workshops directly tied to the chosen risk.
- **Overnight/early Saturday:** establish the thinnest end-to-end vertical slice and deploy immediately. Sleep in staggered blocks so one person can protect momentum and the demo environment; this is general fatigue-risk advice, not an official Junction prescription.
- **Saturday morning–afternoon:** run repeated two-to-three-hour loops: build one proof, test with a user/mentor, cut or revise. By mid-afternoon, obtain partner confirmation that the solution actually answers the brief. Capture metrics, quotes/feedback (with consent), and screenshots while they exist.
- **Saturday evening:** feature freeze. Make the golden path work from a clean browser/device; prepare synthetic data and restricted demo credentials; add graceful failure handling; record a short clean fallback video. Complete every submission field well before sleep.
- **Sunday pre-10:00:** no architectural changes. Run two timed rehearsals, one hostile demo test (bad network, empty result, expired key), final link check, then submit early. After submission, practice a 60-second peer-review version and a longer live-jury version; both siblings should be ready to answer technical and commercial questions.
- Use a shared stop rule: if a task cannot improve one of relevance, novelty, technical proof, UX/demo, or feasibility/impact within two hours, cut it.

### Gaps
- The sources do not prescribe a two-person role split or sleep schedule; those recommendations are strategic synthesis from the event timetable, team-size constraint, and winner advice.

## How should they choose between overall-win potential and less-crowded sponsor prizes?

### Takeaway
Pick the challenge where you have an unfair advantage, creative freedom, direct mentor access, and a demonstrable outcome—not simply the biggest prize. Then deliberately build a “two-layer” entry: exact sponsor-brief compliance for the track and a universally legible, memorable story for peer review and the grand jury.

### Cited Findings
- Challenge partners choose their own winners and criteria, whereas the main-event path uses participant peer review followed by a generalist grand jury. — [Official Junction 2026 judging process](https://2026.hackjunction.com/)
- The Lisbon 2026 winner explicitly selected the challenge with the best perceived winning potential and most room for creativity, rather than choosing arbitrarily. — [CIÊNCIAS ULisboa winner interview](https://ciencias.ulisboa.pt/en/news/student-from-ciencias-wins-junctionx-lisbon-and-advances-to-the-international-competition-in-finland)
- Serial Junction winner Sandqvist starts by mapping available tracks to technologies he already knows and recommends choosing work that genuinely excites the team. — [Official Junction profile](https://www.hackjunction.com/blog/frank-sandqvist-story)
- Junction differentiates challenge partners, who define tracks and select winners, from tech partners, whose tools can be used across tracks; the official challenges archive shows cross-track side challenges have existed in prior editions. — [Official Junction 2026 partner model](https://2026.hackjunction.com/); [Junction challenge archive](https://www.hackjunction.com/challenges/)
- Overall judges span startup selection, RL/agent evaluation, consumer AI/gaming, venture, developer ecosystems, web/search infrastructure, and cloud scale. Their stated preferences converge on real problems, repeat use, unique insight, robustness, speed/pragmatism, and production potential. — [Official Junction 2026 judges](https://2026.hackjunction.com/)

### Inferences
- Score every announced challenge from 1–5 on: team skill advantage, genuine excitement, access to users/data/hardware, clarity of rubric, mentor responsiveness, ability to show a live before/after, room for a unique insight, production plausibility, and likely crowding. Weight “can prove value by Sunday” twice. Ask organizers/partners how many preliminary teams picked each track if that information is available.
- **Track-prize strategy:** prefer a narrow challenge with crisp testable criteria, accessible sponsor data/API, responsive mentors, and few teams. Mirror the sponsor's language, prove every rubric item, and show a handoff path the company can imagine continuing.
- **Overall-win strategy:** favor a problem any peer can understand in ten seconds, visible transformation in under a minute, a surprising insight, strong proof, and a story that crosses industries. A sponsor-specific backend can still win overall if the front-end narrative is universal.
- **Recommended hedge:** do not build separate projects. Choose one strong track project and add an eligible tech-partner integration only if it strengthens the core proof and costs little. The same project should have a sponsor-facing explanation and a peer/jury-facing explanation.
- Avoid an obscure low-competition track if the team cannot credibly solve or demo it; low crowding does not compensate for low relevance, and the partner controls that award.

### Gaps
- The public sources do not reveal live per-track team counts, historic odds per challenge, or a complete 2026 prize/criterion table at the time of research. The team must gather this on site from preliminary submissions, partner desks, Discord, or organizers.
