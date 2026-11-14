# Obsidian Emerald navigation redesign

## Intent

Make Penny feel calmer, bolder and more premium by replacing the crowded all-in-one dashboard with four task-led destinations. The redesign keeps the financial calculations, goals, connected accounts, evidence and chat behavior intact while removing the pale-green S-mobiili presentation from the Penny product.

## Chosen approach

The selected direction evolved into **Pearl Emerald** after visual review: a neutral light canvas, S-Bank's native SF typography, emerald actions, restrained glass and one high-contrast forest hero. It preserves Penny's green identity while borrowing the calm structure and finish of strong financial-coaching competitors.

## Information architecture

- **Spend** is the financial snapshot: safe-to-spend first, followed by balances, recent spending and connected accounts.
- **Plan** contains persistent goals, progress and scenario planning.
- **Ask Penny** is the branded conversational workspace and uses the supplied Penny portrait as its selected navigation mark.
- **Incoming** contains predicted bills, subscriptions and income with evidence and confidence.
- **Profile** moves to a top-right avatar action on root screens; account settings remain available without occupying a primary tab.
- Existing detail views continue to use native push navigation and sheets. No feature is removed; secondary information moves behind the relevant destination.

## Visual system

- Remove pale green from backgrounds, cards, banners and controls throughout the app.
- Use a neutral white/pearl base with no pale-green surface tint. Emerald is the only interactive accent.
- Root content floats on native SwiftUI material with thin neutral edges and soft, directional depth. Materials remain legible in increased contrast and reduce transparency settings.
- Use the native SF Pro hierarchy observed in S-Bank for key financial values and supporting copy, with tabular numerals for money. Do not substitute a competitor typeface.
- Use one authored abstract background image behind the Spend hero, darkened with a gradient overlay so the value and explanation meet contrast requirements. Other surfaces use gradients and material rather than repeated imagery.
- Keep the supplied Penny logo unchanged. Present it on a contrasting circular plate where necessary rather than recolouring the asset.
- The bottom bar is a single floating glass capsule with four equal 44-point-or-larger destinations. Ask Penny is visually emphasized but remains a destination, not an action button.
- Motion is limited to one coherent transition: the active tab's emerald glow and content crossfade/slide, with a reduced-motion fallback.

## Platform constraints

- Native SwiftUI, iOS 17 minimum. Use `Material` and semantic accessibility fallbacks rather than iOS 26-only Liquid Glass APIs.
- Preserve Dynamic Type, VoiceOver labels, 44-point targets, reduced motion, increased contrast and Reduce Transparency behavior.
- Preserve the existing deterministic demo data, analytical grounding and evidence disclosures.

## Non-goals

- No web-style custom navigation gestures.
- No translucent text fields or data cards whose contrast depends on the background image.
- No decorative glass stacking, pale-green fallback surfaces, or multiple competing accent colours.
- No changes to financial calculations or backend facts as part of this visual restructuring.

## Completion criteria

Each feature is reachable in one tap from the new bar; the initial Spend screen leads with the primary snapshot; the supplied Penny mark is visible in Ask Penny navigation; no pale-green surface remains; and simulator captures demonstrate the intentional light appearance and a large Dynamic Type size.
