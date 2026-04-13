# Design System Personality Presets

Presets encode common visual personalities as combinations of four axes. When users don't provide explicit design references, `forge-design` uses a preset to generate a coherent `DESIGN.md`.

## Axes

### 1. Spacing Rhythm

Controls density and breathing room across all screens.

| Value | Description | Example Apps |
|-------|-------------|--------------|
| `tight` | Dense, information-rich layouts. Minimal padding between elements. | Linear, Notion, Slack |
| `balanced` | Standard iOS spacing. Comfortable without feeling sparse. | Stripe, GitHub, Spotify |
| `airy` | Generous whitespace. Premium, editorial feel. | Airbnb, Apple Music, Calm |

**Token mapping:** `tight` → `space2`/`space4` dominant, `balanced` → `space4`/`space8` dominant, `airy` → `space8`/`space12` dominant.

### 2. Corner Radius

Controls the shape language of cards, buttons, inputs, and containers.

| Value | Description | Example Apps |
|-------|-------------|--------------|
| `sharp` | Small radii (2-4pt). Technical, precise feel. | Linear, Terminal, VS Code |
| `rounded` | Large radii (12-16pt). Friendly, approachable feel. | Airbnb, Duolingo, Headspace |
| `mixed` | Varies by component — pills for buttons, subtle for cards. | Apple apps, Stripe, Figma |

**Token mapping:** `sharp` → `radius.sm=2, radius.md=4, radius.lg=8`, `rounded` → `radius.sm=8, radius.md=12, radius.lg=16`, `mixed` → `radius.sm=4, radius.md=8, radius.lg=16` with pill override for action buttons.

### 3. Typography Weight

Controls the visual weight and hierarchy contrast of text.

| Value | Description | Example Apps |
|-------|-------------|--------------|
| `heavy` | Bold titles, strong weight contrast between hierarchy levels. | Linear, Robinhood, Cash App |
| `light` | Lighter weights, subtle hierarchy. Elegant, minimal. | Apple Music, Airbnb, Medium |

**Token mapping:** `heavy` → title `.bold`/`.heavy`, body `.medium`, `light` → title `.semibold`, body `.regular`.

### 4. Surface Treatment

Controls depth, layering, and material effects.

| Value | Description | Example Apps |
|-------|-------------|--------------|
| `flat` | No shadows, minimal depth. Relies on spacing and borders for separation. | Linear, Notion, Figma |
| `elevated` | Shadow-based depth. Cards float above background. | Airbnb, Google Maps, Uber |
| `glass` | Translucent materials, vibrancy effects. Premium, modern feel. | Apple apps (iOS 26+), Arc |

**Token mapping:** `flat` → `shadow.none`, border separators, `elevated` → `shadow.sm`/`shadow.md` on cards, `glass` → `.ultraThinMaterial`/`.regularMaterial` with vibrancy.

## Named Combinations

Pre-built personality presets that combine all four axes into a coherent design direction.

| Preset | Spacing | Corners | Weight | Surface | Character |
|--------|---------|---------|--------|---------|-----------|
| `.linear` | tight | sharp | heavy | flat | Dense, technical, power-user tool |
| `.airbnb` | airy | rounded | light | elevated | Warm, inviting, content-focused |
| `.stripe` | balanced | mixed | light | flat | Clean, professional, developer-friendly |
| `.apple` | airy | mixed | light | glass | Premium, modern, platform-native |

### Usage

When a user says "I want it to feel like Linear", `forge-design` maps to the `.linear` preset and generates tokens accordingly. When they say "clean and modern", it maps to `.stripe` or `.apple` depending on context.

Users can also mix axes: "Linear-like density but with rounded corners" → `tight + rounded + heavy + flat`.

### Token Generation

Each preset maps directly to DS token values in `DESIGN.md`:

```
Preset: .airbnb
→ spacing: space8/space12 dominant
→ radius: sm=8, md=12, lg=16
→ typography: title .semibold, body .regular
→ shadow: sm=(0,1,3,0.1), md=(0,4,12,0.15)
→ surface: elevated cards, subtle borders
```

The generated `DESIGN.md` uses these token values in its Spacing, Radii, Typography, and Shadow sections. `forge-build` reads these tokens when constructing SwiftUI views.
