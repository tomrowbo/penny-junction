---
name: "Penny — Pearl Emerald"
description: "A bright native S-Bank financial coach with emerald focus, purposeful glass and one cinematic hero."
colors:
  canvas: "#F6F6F2"
  surface: "rgba(255,255,255,0.68)"
  forest: "#06130E"
  emerald: "#00944F"
  hero-emerald: "#3DF594"
  text-primary: "#0E1311"
  text-secondary: "#505752"
typography:
  financial-display: "SF Pro Display Bold, Dynamic Type, tabular numerals"
  section-title: "SF Pro Display Bold, Dynamic Type"
  body: "SF Pro Text Regular, Dynamic Type"
  label: "SF Pro Text Semibold, Dynamic Type"
rounded:
  glass-panel: "20–28pt continuous"
  compact-control: "14pt continuous"
  conversation: "18pt continuous"
  navigation: "capsule"
spacing:
  outer: "20pt"
  section: "24pt"
  group: "14pt"
  compact: "8pt"
---

# Design System: Penny — Pearl Emerald

## North star

Penny is a bright S-Bank experience with the calm, focused structure of the strongest financial-coaching products. The canvas stays light, information is black and direct, and emerald marks action, progress and selection. The first screen should explain what is safe to spend and why within seconds.

## Structure

The four equal destinations are Spend, Plan, Ask Penny and Incoming. Spend is the default snapshot; Plan owns persistent goals; Ask Penny owns conversation; Incoming owns predicted bills and income. Profile is the top-right root action. Native push navigation and focused sheets remain intact.

The bottom bar is one floating translucent capsule. Ask Penny uses the supplied portrait mark on a white plate; the other icons are SF Symbols.

## Colour and material

- The product is intentionally light mode, including when the system appearance differs.
- Canvas and glass are neutral white/pearl, never pale green.
- Emerald is the only action, selection and progress colour.
- A dark forest image is reserved for the Spend hero, with white text and a bright emerald accent.
- Reduce Transparency replaces material with solid white. Increased Contrast strengthens the dark edge.

## Imagery

`SpendAurora` is the single authored image plate. It sits behind the Spend thesis with a strong dark overlay and may be cropped responsively. Do not repeat it in ordinary cards, navigation, chat or other roots. The supplied `PennyMark` remains byte-identical and is never recoloured.

## Typography

Use S-Bank's observed in-app typography: native SF Pro Dynamic Type roles throughout. Financial values use bold display hierarchy and tabular numerals. Do not substitute a competitor font, rounded system design or unlicensed proprietary face.

## Surfaces

Glass panels use 20–28pt continuous corners, a sub-point neutral edge and soft downward depth. Avoid nested glass panels: use separators and spacing inside grouped surfaces. Lists remain lists; sheets remain native forms.

## Accessibility

All targets are at least 44pt. The four navigation labels remain visible through `xxxLarge` Dynamic Type and expose selected traits. Money uses stable numerals. Charts retain accessible tables. Opaque fallbacks preserve contrast.

## Do

- Lead each destination with its one primary task.
- Use generous neutral space and short copy.
- Use emerald for interaction, progress and selection only.
- Keep evidence and assumptions one deliberate disclosure away.
- Keep native SF typography, navigation gestures and controls.

## Do not

- Reintroduce pale-green or mint surfaces.
- Turn every section into a card.
- Stack glass inside glass.
- Invent financial values for visual effect.
- Recolour, redraw or replace the supplied Penny portrait.
