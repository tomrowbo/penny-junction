---
name: "Penny for S-mobiili"
description: "A faithful S-mobiili host system with Penny added as a familiar financial-coach surface."
colors:
  primary-green: "#008540"
  bright-green: "#00B845"
  deep-green: "#00572E"
  pale-green-canvas: "#E8F7EB"
  mint-highlight: "#E8F7ED"
  pale-green-accent: "#D1EDD6"
  warning-cream: "#FFF0B8"
  surface: "#FFFFFF"
  text-primary: "#000000"
  text-secondary: "#6C6C70"
  separator: "#C6C6C8"
typography:
  display:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "42px"
    fontWeight: 700
    lineHeight: 1.1
    fontFeature: "tnum"
  headline:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1.2
  title:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "17px"
    fontWeight: 700
    lineHeight: 1.25
  body:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.35
  label:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "11px"
    fontWeight: 400
    lineHeight: 1.2
  receipt-mono:
    fontFamily: "SF Mono, ui-monospace, monospace"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.3
rounded:
  bonus-panel: "3px"
  content-tile: "5px"
  service-surface: "7px"
  wallet-card: "9px"
  compact-control: "12px"
  chat-bubble: "17px"
  composer-field: "18px"
  circle: "50%"
spacing:
  micro: "3px"
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "20px"
  xl: "24px"
components:
  service-row:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.service-surface}"
    padding: "14px 18px"
    height: "112px"
  action-row:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    padding: "0 16px"
    height: "66px"
  tab-item-active:
    textColor: "{colors.primary-green}"
    typography: "{typography.label}"
    height: "62px"
  tab-item-inactive:
    textColor: "{colors.text-primary}"
    typography: "{typography.label}"
    height: "62px"
  brand-card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.service-surface}"
    padding: "16px"
  primary-action:
    backgroundColor: "{colors.primary-green}"
    textColor: "{colors.surface}"
    rounded: "{rounded.compact-control}"
    height: "44px"
  penny-message:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.chat-bubble}"
    padding: "13px"
  user-message:
    backgroundColor: "{colors.primary-green}"
    textColor: "{colors.surface}"
    rounded: "{rounded.chat-bubble}"
    padding: "13px"
  composer-field:
    backgroundColor: "{colors.pale-green-canvas}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.composer-field}"
    padding: "11px 14px"
---

# Design System: Penny for S-mobiili

## Overview

**Creative North Star: "The Familiar Green Ledger"**

The system should feel like opening S-mobiili, not entering a separate Penny product. Familiar banking structure does the work: a pale-green service canvas, compact white surfaces, centered native-scale headers, green interaction cues, and dense but calm information rows. Penny is additive and deliberately inherits this world.

The visual character is trustworthy, practical, and lightly branded rather than decorative. Public S-mobiili references govern reproduced host surfaces; unseen states combine the reconstructed component grammar with native iOS behavior. Semantic system colors, Dynamic Type, SF Symbols, native push navigation, and 44-point touch targets remain part of the design, even where light-mode screenshots are the parity authority.

**Key Characteristics:**

- S-mobiili green is the single interactive and brand voice.
- Pale-green canvases separate sections; white surfaces carry tasks and data.
- SF Pro and native iOS text roles keep financial content familiar and readable.
- Corners are compact on host surfaces, with larger radii reserved for Penny conversation.
- Penny adopts the host chrome and spacing instead of introducing a second theme.

## Colors

The palette is a compact green hierarchy surrounded by adaptive iOS neutrals; green signals identity, progress, selection, and action rather than decoration.

### Primary

- **S-mobiili Green:** The default tint for interactive controls, selected navigation, service titles, icons, progress, positive balance cues, and user chat messages.
- **Bonus Green:** A brighter branded fill for the S-Etukortti header, wallet cards, and selective benefit accents.
- **Deep Trust Green:** Used where long-form or sensitive financial context needs quieter emphasis, including total-balance and privacy messaging.

### Neutral

- **Pale Service Canvas:** The app-level background behind grouped services, cards, and Penny content.
- **System Surface:** The adaptive iOS surface for headers, rows, cards, and incoming messages; light-mode parity renders it white.
- **Primary and Secondary Labels:** Adaptive iOS label roles preserve dark-mode and increased-contrast behavior.
- **System Separator:** Hairline division within lists and between receipt or action rows.

### Named Rules

**The One Green Voice Rule.** Use S-mobiili green for brand and interaction; Penny does not introduce a competing accent.

**The Canvas-and-Surface Rule.** Group screens with a pale-green canvas and place actionable or data-bearing content on white adaptive surfaces.

## Typography

**Display Font:** SF Pro (with the iOS system fallback)
**Body Font:** SF Pro (with the iOS system fallback)
**Label/Mono Font:** SF Mono for receipt data only

**Character:** The hierarchy is compact, sturdy, and native. Weight and color create emphasis; no proprietary display face or ornamental typography appears in the shipped interface.

### Hierarchy

- **Display** (bold, 42pt scaled, 1.1): Hero financial amounts such as the Saver balance; use tabular numerals when alignment matters.
- **Headline** (bold, 22pt, 1.2): Service-row titles and the strongest card-level headings.
- **Title** (bold, 17pt, 1.25): Section headings and grouped-service labels.
- **Body** (regular, 16pt, 1.35): Service descriptions, supporting financial information, and compact interface copy.
- **Label** (regular or semibold, 11pt, 1.2): Bottom navigation and restrained metadata.
- **Receipt Mono** (regular, 15pt, 1.3): Fixed-width receipt bodies where column alignment is content, not decoration.

### Named Rules

**The System-Type Rule.** Use Dynamic Type-compatible SF Pro roles throughout; reserve monospaced type for receipt data that depends on fixed columns.

**The Financial-Numeral Rule.** Use tabular numerals for balances, dates, progress values, and other columns that must remain stable while values change.

## Layout

Top-level screens use a fixed visual shell: a 52-point header, scrolling content, and a controlled 62-point four-item bottom bar ordered S-Etukortti, Bank, Penny, Me. Content respects safe areas and remains inside native navigation stacks so the edge-swipe gesture and push transitions survive.

The recurring outer inset is 20 points for bank and Penny service stacks, with 16-point internal card padding and 12-point compact insets on benefit grids. Bank service rows are at least 112 points high, separated by 16 points, and use 46-point icon frames. All interactive regions preserve a 44-by-44-point minimum target even when their visible glyph is smaller.

Density is intentionally compact. Use vertical lists and grouped rows before bespoke grids; use two equal columns only for short peer actions or benefit cards. Other iPhone widths may reflow or grow vertically, but must not clip financial values, row labels, or controls. Dynamic Type is capped only where required to protect the reconstructed comparison shell.

### Named Rules

**The Four-Tab Continuity Rule.** Penny occupies one equal top-level tab and never displaces or visually outweighs S-Etukortti, Bank, or Me.

**The Forty-Four Point Rule.** A smaller icon may be visible, but every interactive target remains at least 44 points in both dimensions.

## Elevation & Depth

The system is flat by default. Depth comes primarily from tonal layering—pale canvas behind white surfaces—and hairline separators within groups. A soft ambient shadow appears only on compact authentication tiles; standard service rows, cards, navigation, and content tiles remain shadowless.

### Shadow Vocabulary

- **Authentication Lift** (`0 2px 8px rgba(0, 0, 0, 0.08)`): A restrained ambient lift for the paired authentication actions on Me; do not generalize it to ordinary cards.

### Named Rules

**The Tonal-First Rule.** Establish hierarchy with surface color and separators before adding elevation; shadows are exceptional, not a default card treatment.

## Shapes

Host surfaces use small, continuous corners: 5 points for benefit and campaign tiles, 7 points for service and action containers, and 9 points for wallet cards. Penny may use 12-point compact controls and 17–18-point conversational bubbles or fields, but those softer forms stay inside the coach experience. Circular forms are reserved for avatars, icon buttons, page dots, progress tracks, and institution marks.

**The Compact-Host Rule.** Keep reproduced S-mobiili containers close to square; do not import Penny's bubble radius into bank, receipt, benefit, or profile surfaces.

## Components

### Buttons

- **Shape:** Native prominent controls use a compact continuous corner and a minimum 44-point target; icon-only actions use a 44-point circle.
- **Primary:** S-mobiili green fill, white label, and strong system weight. Use for one clear next action such as creating a goal or sending a message.
- **Pressed / Focus:** Preserve native iOS pressed, disabled, keyboard-focus, and accessibility behavior rather than replacing it with custom web-style states.
- **Secondary:** White or transparent surface with green icon or label; use for navigation and compact service actions.

### Cards / Containers

- **Corner Style:** Small continuous corners on host tiles; slightly softer continuous corners inside Penny.
- **Background:** Adaptive system surface over the pale service canvas.
- **Shadow Strategy:** Flat except for the documented authentication lift.
- **Border:** No enclosing border on standard cards; use system separators inside grouped rows and a half-point separator only around external-institution badges.
- **Internal Padding:** 16 points by default; 12 points for compact benefit grids; 20 points for outer bank and Penny stacks.

### Inputs / Fields

- **Style:** Multi-line native text field on the secondary system surface with an 18-point continuous radius and 11-by-14-point internal padding.
- **Focus:** Native insertion point, keyboard, and accessibility focus behavior; the adjacent send control carries the brand tint.
- **Disabled:** Send actions reduce opacity while the field is empty or a response is in flight.

### Navigation

- **Top Bar:** Centered 15-point semibold title in a 52-point white adaptive header, with 44-point message or leading actions.
- **Bottom Bar:** Four equal-width items in a 62-point white adaptive bar with a top divider. Active icon and label are green and semibold; inactive items use the primary label color and regular weight.
- **Details:** Use native inline navigation titles and push transitions. Sheets remain focused, dismissible subtasks with native Cancel or Done affordances.

### Service Rows

Service rows are the defining host component: a green icon in a 46-point frame, a bold green title, compact supporting text, optional value, and subdued chevron within a white 7-point surface. Rows grow with Dynamic Type but never fall below 112 points.

### Penny Conversation

Incoming Penny messages sit on white 17-point bubbles with the S mark; outgoing messages use the same geometry with S-mobiili green fill and white text. Privacy or data-scope context uses a mint 12-point banner. These bubble forms identify the interaction model without changing the surrounding S-mobiili shell.

## Do's and Don'ts

### Do:

- **Do** reuse the pale-canvas, white-surface, green-accent hierarchy on every new Penny or unseen host screen.
- **Do** keep Penny inside the same header, tab, typography, icon, and spacing grammar as the host application.
- **Do** preserve native iOS semantics, Dynamic Type, dark-mode adaptation, reduced-motion behavior, and 44-point touch targets.
- **Do** use supplied marks and faithful SF Symbols; author a small vector only when no semantically faithful symbol exists.
- **Do** keep balances, commitments, transactions, and actions scannable before adding visual expression.

### Don't:

- **Don't** introduce a second Penny palette, custom display face, or oversized coach chrome that competes with S-mobiili.
- **Don't** turn every group into a large rounded floating card; host surfaces use compact corners and tonal grouping.
- **Don't** replace native push, sheet, list, field, switch, alert, or back-gesture behavior with web-shaped imitations.
- **Don't** use green as ambient decoration when it no longer communicates brand, selection, progress, or action.
- **Don't** rasterize a reference screen or imply parity for clipped or publicly unseen states.
