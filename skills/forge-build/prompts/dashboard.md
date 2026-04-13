# Dashboard Screen Guidance

## Hierarchy
- The hero stat/number takes 60%+ of above-the-fold space. This is the screen's reason to exist.
- Supporting elements (secondary stats, quick actions) are visually subordinate — smaller text, muted colors, less padding.
- Activity feeds or lists scroll into view below the fold. They are discoverable, not competing.

## Visual Intent
- This screen answers ONE question instantly. The user opens, sees the answer, and can close.
- Stats are whispered, not shouted — small text, muted color, secondary position below the hero.
- Use `.display()` or `.titleLarge()` with `.monospaced` for the hero number. Everything else uses `.bodyMedium()` or smaller.
- Add `.contentTransition(.numericText())` to any number that updates.

## DS Components
- `DSScreen` as root (required)
- Prefer raw SwiftUI `Text` for the hero number — don't wrap it in DSCard or DSHeroCard unless the blueprint says to
- `DSListRow` for activity feed items below the fold
- `DSButton(.secondary)` for quick actions (if any) — keep them small and horizontal

## Anti-Patterns
- Do NOT give equal visual weight to multiple sections — one hero, everything else secondary
- Do NOT use a grid of same-sized cards for stats — create hierarchy through size contrast
- Do NOT put a greeting/date at the very top taking prime real estate — the hero data comes first
- Do NOT use a TabView inside the dashboard — tabs belong at the app level
