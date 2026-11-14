# Meta Junction challenge

## What does the challenge explicitly ask teams to build?

### Takeaway
Meta's challenge is **“AI Glasses for Everyone, Everyday.”** Teams must demonstrate how a first-person field of view enables a materially new or better interaction in an everyday scenario, using Meta AI glasses; the submission needs a clearly defined problem and audience, a functional prototype, and a deck.

### Cited Findings
- The exact challenge title is **“AI Glasses for Everyone, Everyday”** by Meta. The central prompt is: “Demonstrate how a first-person field of view enables new or better interactions in everyday scenarios.” — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)
- The brief asks teams to build the best everyday use case using Meta AI glasses, clearly articulate the problem and intended audience, and produce both a functional prototype and presentation deck. — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)
- The brief treats display-first and audio-first experiences equally, and also treats web apps and mobile integrations built with the Wearables Device Access Toolkit as equal build paths. — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)
- Meta's official developer page confirms three build routes: native iOS/Android via Device Access Toolkit, standalone web apps, or Meta AI Connectors; its stated glass capabilities include camera, audio, display and input. — [Meta Wearables developer hub](https://developers.meta.com/wearables/)
- Device Access Toolkit provides native mobile access to motion, camera, speech/audio, display, and inputs/gestures. — [Meta Device Access Toolkit](https://developers.meta.com/wearables/device-access-toolkit/)
- The supplied hardware pool is 10 Meta Ray-Ban Display units and 10 Ray-Ban Meta Gen 2 units. — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)
- The winning team's members each receive Ray-Ban Meta glasses. — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)

### Inferences
- A strong entry should choose the device deliberately. A Display concept should need glanceable visual feedback; a Gen 2/audio concept should work when the wearer cannot or should not look at a display.
- “Everyday” implies repeatable utility rather than a one-off spectacle: a common activity, frequent enough that wearing glasses is natural, with a benefit delivered at the exact moment the user's hands and attention are occupied.

### Gaps
- The public challenge URL returns a 404 when accessed without a logged-in Junction participant session. The challenge statements above were transcribed from the logged-in page on 13 November 2026; there is no separately indexed public copy.

## What does live stream to learn to act mean in this challenge context?

### Takeaway
“Live stream → learn → act” is not a stated mandatory architecture in the Meta brief. It is a useful pattern inferred from the recommended InstaRizz example: continuously obtain first-person sensory context, extract a small amount of useful understanding, and immediately return or trigger an in-the-moment action that could not work as well from a phone.

### Cited Findings
- The recommended AI-ATL project, **InstaRizz**, streams live video from Ray-Ban smart glasses to Instagram Live, samples frames for OpenCV face recognition, queries a custom identity-search pipeline, and uses GPT-4 to generate a short bio and three pickup lines for immediate display. — [AI-ATL-2024 repository](https://github.com/coderkai03/AI-ATL-2024)
- The repo explicitly describes latency optimization through snapshot intervals rather than necessarily processing every video frame. — [AI-ATL-2024 repository](https://github.com/coderkai03/AI-ATL-2024)
- Meta frames the form factor around “nothing to hold,” “at a glance,” and “in the moment”: pinch/gesture/question input, display or spoken output, and motion/location-aware experiences. — [Meta Wearables developer hub](https://developers.meta.com/wearables/)
- Meta says the toolkit enables apps to respond in real time to what users “see, hear, and do” using glasses sensors. — [Meta developer blog](https://developers.meta.com/blog/explore-whats-possible-with-wearables-device-access-toolkit/)

### Inferences
- The reusable architecture is: **observe** a first-person stream or event → **detect** a relevant moment → **interpret** only the context needed → **ask/confirm when risk is non-trivial** → **act** through audio, display, phone/app automation, or a connected service → **learn** from a lightweight correction.
- The strongest “act” is not merely generating a caption. It changes the user's next step: guide, capture, warn, log, communicate, control, or complete a task.
- Continuous streaming is not essential. Event-driven snapshots can reduce latency, battery use, bandwidth, privacy exposure and demo fragility while preserving the live-agent effect.
- Directly copying face identification/personal-data lookup would score poorly on trust and safe data use. The reference is best treated as an interaction architecture, not as a recommended problem domain.

### Gaps
- The challenge does not prescribe an agent loop, persistent learning, a specific model, Instagram Live, facial recognition, or automated external actions.

## What constraints, APIs, devices, and evaluation criteria are stated?

### Takeaway
Judging is evenly split across four 25% categories. A winning demo must prove not just novelty but robust device integration, plausible adoption, accessible interaction, permission/error handling and trustworthy data practices.

### Cited Findings
- Judging weights are: **Creativity and use case 25%; Technical execution 25%; Real-world value and feasibility 25%; UX, input, accessibility and trust 25%.** — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)
- Creativity requires an original and relevant use case with a clear benefit from the wearable form factor. — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)
- Technical execution expects a working integration that handles permissions, errors, performance trade-offs, connectivity, and device-state changes rather than a happy-path mock. — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)
- Real-world value expects plausible adoption or a credible pilot path, not only technical possibility. — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)
- UX judging explicitly includes inclusive interaction design for people of all abilities, appropriate consent and safe data practices. — [Junction challenge 342](https://hackjunction.app/participate/45/challenges/342)
- Meta's FAQ says Device Access Toolkit supports Ray-Ban Meta Gen 1/2, Meta Ray-Ban Display, Oakley Meta HSTN and Vanguard, but capabilities vary by device; the SDK supports iOS and Android. — [Meta Wearables FAQ](https://developers.meta.com/wearables/faq/)

### Inferences
- The live demo should visibly include one non-happy-path moment: lost connectivity, camera permission denied, device removed/disconnected, uncertain recognition, or an action requiring confirmation. Recovering cleanly will make “technical execution” legible to judges.
- Consent should be part of the UX, not a slide disclaimer. For example: visible listening/capture state, on-device cue, explicit confirmation before an external action, and clear retention/deletion behavior.
- The pitch should show a before/after comparison against phone use and answer: why first-person view, why hands-free, why now, and who would adopt or pilot it first.
- A narrow, high-frequency problem with a crisp trigger and a visible action can score in all four categories better than a general-purpose “AI assistant that sees everything.”

### Gaps
- No explicit requirement for a particular AI model, cloud service, or third-party action platform was identified in the challenge wording supplied from the logged-in page.
