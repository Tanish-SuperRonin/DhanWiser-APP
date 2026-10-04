---
project: DhanWiser
platform: Mobile app (iOS / Android, Flutter)
mode: Dark (primary), Light (secondary)
---

# DESIGN.md — DhanWiser

## 1. Visual theme and atmosphere

DhanWiser embodies "quiet luxury fintech." It is a group expense-splitting app that wants to be judged next to Stripe Dashboard, Cash App, and Revolut — not next to a generic student project. The feel is confident, precise, and a little expensive, while staying warm enough for splitting a dinner bill with friends.

Radical clarity comes first — this is a money app, and confusion is the enemy. Premium *feel* comes from confident ink-and-iris color, decisive type scale, soft tinted depth, and deliberate motion. Keep the violet as a flat, selective focal color; no gradient washes or fluorescent accents.

## 2. Color palette and roles

**Dark mode (primary)**

| Role | Token | Value | Usage |
|---|---|---|---|
| Background | `--bg-primary` | `#11120F` | Warm charcoal canvas |
| Surface | `--bg-surface` | `#191A17` | Elevated sections |
| Card | `--bg-card` | `#1B1C19` | Cards, list rows |
| Primary accent | `--accent-iris` | `#A99AE8` | Primary CTAs and selected states; used sparingly |
| Positive (semantic) | `--positive` | `#91B59A` | "Owed to you" balances, settled states |
| Negative (semantic) | `--negative` | `#E58D86` | "You owe" balances, destructive actions, failed states |
| Supporting accent | `--accent-lilac` | `#B7AEC9` | Secondary actions and category tags |
| Text primary | `--text-primary` | `#F1F0EA` | Headlines, balances |
| Text secondary | `--text-secondary` | `#A6A69E` | Captions, metadata, timestamps |
| Text disabled | `--text-disabled` | `#6C6D65` | Placeholder, disabled state |

**Light mode (secondary)**

| Role | Token | Value | Usage |
|---|---|---|---|
| Background | `--bg-primary-light` | `#F5F4F0` | Warm porcelain canvas |
| Card | `--bg-card-light` | `#FFFFFF` | Cards, list rows |
| Text primary | `--text-primary-light` | `#171815` | Headlines, balances |
| Text secondary | `--text-secondary-light` | `#696A63` | Captions, metadata |
| Primary accent | `--accent-iris` | `#5F50A6` | Primary actions; white foreground |
| Positive (semantic) | `--positive` | `#3F6A4A` | "Owed to you" balances |
| Negative (semantic) | `--negative` | `#B44A43` | "You owe" balances and destructive actions |
| Supporting accent | `--accent-lilac` | `#716A84` | Secondary actions and category tags |

Iris carries the action hierarchy; green and coral are reserved for balance meaning. Tones shift between modes for legibility.

## 3. Typography rules

Font family: **Plus Jakarta Sans** throughout, with tight tracking and heavier display weights. Use **tabular figures** so currency amounts align in lists without jitter.

| Level | Font | Size | Weight | Line-height | Notes |
|---|---|---|---|---|---|
| Display | Plus Jakarta Sans | 42px | 800 | 1.1 | Hero balance numbers only |
| H1 | Plus Jakarta Sans | 34px | 800 | 1.1 | Screen titles |
| H2 | Plus Jakarta Sans | 23px | 700 | 1.25 | Section headers |
| Body | Plus Jakarta Sans | 15px | 400 | 1.45 | Default UI text |
| Body — numeric | Plus Jakarta Sans (tabular) | 16px | 600 | 1.5 | List-item amounts, right-aligned |
| Caption | Plus Jakarta Sans | 13px | 400 | 1.4 | Timestamps, metadata |
| Label | Plus Jakarta Sans | 11px | 700 | 1.2 | Uppercase tags, badges |

## 4. Component styles

### Primary button
- Background: iris (`--accent-iris`), with a legible foreground in each mode
- Padding: 16px vertical, pill-shaped (border-radius: 999px)
- Pressed state: scale to 96%, no color change (physical press, not a flat-color hover)

### Hero balance card
- Background: quiet charcoal/white surface, with sage or coral balance states
- Display-size balance number, two stat chips below (owe / owed) in `Body — numeric`
- Shadow: soft colored glow matching the active tint (see Section 6), not a black shadow

### Expense list row
- Background: `--bg-card`, radius 16px
- Left: category icon (custom rounded-line style) in a tinted circle
- Right: amount in `Body — numeric`, color-coded only when it represents a balance (not for neutral expense totals)
- Swipe-to-delete reveals `--error` action background

### Bottom navigation (glass)
- Frosted/blurred glass background (glassmorphism), floating with margin from screen edges, radius 24px
- 4–5 icon-only or icon+label tabs, active tab indicated with a small iris marker, not a filled background
- This is one of the *only* two places glass is used — see Do's and Don'ts

### Skeleton / shimmer loader
- Shape-matched placeholders (never a generic spinner) — a shimmering `--bg-surface` block in the exact shape of the real content it replaces

### Segmented control (tabs)
- Pill-shaped container, `--bg-surface`, active segment fills with `--bg-card` and lifts with a subtle shadow (elevation level 1)

## 5. Layout principles

- Base unit: 8px
- Spacing scale: 4, 8, 16, 24, 32, 48px
- Card radius: 18px · Button radius: 999px (pill) · Sheet/modal radius: 32px (top corners)
- Money screens (balance card, expense detail): generous whitespace, fewer elements per view
- Scrolling feeds (expenses, activity): denser spacing optimized for scanability

## 6. Depth and elevation

Shadows are soft and tinted to the nearby accent color — never flat black.

| Level | Usage | Shadow value |
|---|---|---|
| 0 | Background, flat list rows | none |
| 1 | Cards, segmented control active state | `0 2px 8px rgba(95,80,166,0.08)` (iris tint) |
| 2 | Hero balance card | `0 8px 24px rgba(95,80,166,0.12)` with subtle semantic tint when needed |
| 3 | Modals, bottom sheets, floating nav bar | `0 12px 32px rgba(0,0,0,0.35)` + glass blur |

## 7. Do's and don'ts

**Do:**
- Use iris for key actions and selection; use green/coral only for balance meaning — not as decoration
- Keep glassmorphism to exactly two places: the floating bottom nav and modals/sheets
- Use tabular figures for every currency amount, everywhere
- Give every loading state a shape-matched skeleton, never a spinner

**Don't:**
- Don't apply glass to regular cards — it stops feeling premium and starts feeling noisy
- Don't use flat black drop shadows — always tint toward the nearest accent
- Don't mix positive and negative colors in the same data point (a single balance is either owed-to-you or you-owe, never both at once)
- Don't default to Material's standard flat-color hover/press states — buttons must show a physical press (scale-down)

## 8. Responsive behavior

- Mobile-first, single-column throughout (this is a phone app, not a responsive web layout)
- Bottom sheet pattern for forms (Add Expense, Settlement) on all screen sizes
- On larger phones/tablets, cap content width and center it rather than stretching cards edge-to-edge

## 9. Agent prompt guide

When generating any DhanWiser screen:
1. Always pull colors, type, spacing, and shadow values from Sections 2–6 — never introduce a new hex value or font.
2. Every currency amount uses the `Body — numeric` style with tabular figures, right-aligned in lists.
3. Glass effects are reserved for bottom nav and sheets/modals only (see Section 7).
4. Loading states are shimmer skeletons shaped like the real content.
5. Maintain WCAG AA contrast minimums; use primary text instead of an accent for small text where contrast is borderline.
