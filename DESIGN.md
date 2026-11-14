---
name: "Penny — Obsidian Emerald"
description: "A calm, high-contrast native financial coach shaped by deep atmosphere, luminous emerald and purposeful glass."
colors:
  obsidian: "#050706"
  deep-forest: "#061D15"
  emerald: "#15D16E"
  bright-emerald: "#42F592"
  opaque-glass: "#0B1311"
  glass-edge: "rgba(255,255,255,0.14)"
  text-primary: "#FFFFFF"
  text-secondary: "rgba(255,255,255,0.68)"
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

# Design System: Penny — Obsidian Emerald

## North star

Penny should feel like money moving through a calm, dark environment: clear white facts over deep obsidian, with emerald appearing only where the product is active, progressing or selected. The first screen is a financial instrument rather than a dashboard collage. A person should understand what they can spend, where to go next and why the number is trustworthy within seconds.

## Structure

The product has four equal top-level destinations: Spend, Plan, Ask Penny and Incoming. Spend is the default financial snapshot; Plan owns persistent goals; Ask Penny owns conversation; Incoming owns predicted bills and income. Profile is a top-right root action. Native push navigation and focused sheets remain intact.

The bottom bar is one floating capsule. Ask Penny uses the supplied portrait mark on a white plate; all other icons are SF Symbols. Selection is expressed through white emphasis and emerald state, never a second palette.

## Colour and material

- Obsidian is the permanent product canvas in both system appearances.
- Deep forest gradients create atmosphere without reducing text contrast.
- Emerald is the only action, selection and progress colour.
- Glass is functional: it separates navigation, grouped financial data and focused controls from the atmosphere behind them.
- Reduce Transparency replaces material with `opaque-glass`. Increased Contrast strengthens the white edge.
- Pale green, white card walls and pastel mint fills are not part of this system.

## Imagery

`SpendAurora` is the single authored image plate. It sits behind the Spend thesis with a strong dark overlay and may be cropped responsively. Do not repeat it in ordinary cards, navigation, chat or other roots. The supplied `PennyMark` remains byte-identical and is never recoloured.

## Typography

Use native Dynamic Type roles and SF Pro throughout. Financial values use bold display hierarchy and tabular numerals. Supporting copy stays compact and white at 68% or higher opacity. There are no all-caps kickers, gradient text or decorative monospaced labels.

## Surfaces

Glass panels use 20–28pt continuous corners, a sub-point white edge and soft downward depth. Avoid nested glass panels: use separators and spacing inside a grouped surface. A background image is allowed only for the primary Spend thesis. Lists remain lists; sheets remain native forms adapted to the dark system.

## Motion

The single authored moment is top-level navigation: selected-state emphasis and a short content crossfade/slide using a snappy native curve. Reduce Motion uses a crossfade. No independent card entrances, ambient loops or decorative parallax.

## Accessibility

All targets are at least 44pt. The four navigation labels remain visible through `xxxLarge` Dynamic Type and expose selected traits. Money uses stable numerals. Charts always retain accessible tables. Glass never carries the only copy of a state, and opaque fallbacks preserve contrast.

## Do

- Lead each destination with its one primary task.
- Use generous black space and short copy.
- Use emerald for interaction, progress and selection only.
- Keep evidence and assumptions one deliberate disclosure away.
- Keep native navigation gestures and controls.

## Do not

- Reintroduce pale green, mint card fills or white dashboard cards.
- Put every section in its own floating rounded rectangle.
- Stack glass inside glass.
- Invent financial values for visual effect.
- Recolour, redraw or replace the supplied Penny portrait.
