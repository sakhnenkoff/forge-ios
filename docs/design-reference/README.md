# Design Reference Library

The design reference library feeds `forge-design` with visual direction. It bridges the gap between "I want my app to look like X" and a concrete iOS-native `DESIGN.md` contract.

## Input Sources (priority order)

1. **User-provided references** (priority 1) — Screenshots, URLs, Mobbin links, Dribbble shots. The user's explicit visual direction always wins.
2. **awesome-design-md** (priority 2) — Curated design system references scraped from real apps. Provides proven color palettes, spacing systems, and typography scales.
3. **Built-in preset axes** (fallback) — When no references are provided, `forge-design` falls back to preset combinations defined in `presets.md`. These encode common design personalities as axis combinations.

## How References Flow

```
User picks references (or skips)
    ↓
Saved to .forge/references/       ← gitignored, ephemeral per-project
    ↓
forge-design reads references
    ↓
Translates to iOS-native DESIGN.md
    ↓
forge-build uses DESIGN.md as build contract
```

## Translation: Web References to iOS Native

References often come from web-first design tools. `forge-design` translates them to iOS conventions:

| Web / CSS | iOS / DESIGN.md |
|-----------|-----------------|
| CSS spacing (`px`, `rem`) | DS spacing tokens (`space2`, `space4`, `space8`) |
| CSS typography (`font-size`, `font-weight`) | DS text styles (`.title`, `.body`, `.caption`) |
| CSS colors (`hex`, `rgb`, `hsl`) | DS semantic palette (`primary`, `surface`, `onSurface`) |
| Web layout patterns (cards, grids, navbars) | iOS conventions (NavigationStack, TabView, List) |
| Web interaction (hover, click) | iOS interaction (tap, swipe, long-press, haptics) |

## Adding References

Drop files into `docs/design-reference/examples/` to expand the built-in library. Each file should follow the format in `presets.md` — define the visual personality across the four axes (spacing, corners, typography weight, surface treatment).
