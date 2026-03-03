# Pipeline Quality Fix — Design

## Problem

The Forge pipeline consistently produces apps worse than the template it starts from. Agents rebuild screens with raw SwiftUI, ignoring DS components, architectural patterns, and quality patterns. Three failure modes appear in a mix: rebuild from scratch (ignoring template), use DS components badly (no hierarchy/rhythm), and chase impossible specs (aspirational features beyond DS capability).

**Core insight:** Text-based rules don't work — agents ignore them. Fix requires mechanical enforcement (code checks), contradiction removal (fix bad examples), and structural constraints (spec fields).

## Design

### Change 1: Post-Build Floor Checks

**Where:** New Step 8c in `forge-craft-agent.md` (between final build verify and return proof).

Three layers of grep-based checks run against files the agent created/modified.

#### Layer 1 — Architecture (every screen)

| Check | What to grep | Type |
|-------|-------------|------|
| ViewModel is `@Observable` | `ObservableObject` | violation |
| View uses `@State private var viewModel` | `@StateObject` | violation |
| `DSScreen` as root container | `DSScreen` | required |
| `.toast($viewModel.toast)` modifier | `.toast(` | required |
| `.onAppear { viewModel.onAppear(services:` | `.onAppear` + `services` | required |
| `var hasLoaded` guard in ViewModel | `hasLoaded` | required |
| `Event` enum with `LoggableEvent` | `LoggableEvent` | required |
| `@Environment(AppServices.self)` in View | `AppServices.self` | required |
| No `AsyncImage` | `AsyncImage` | violation |
| No `@StateObject` | `@StateObject` | violation |
| File in correct location | path matches `Features/{Feature}/` | required |

#### Layer 2 — Data Patterns (screens with domain data only)

| Check | What to grep | Type |
|-------|-------------|------|
| Manager protocol exists | file at `Managers/{Feature}/` | required |
| Mock implementation exists | `Mock{Feature}Manager` | required |
| `Model.placeholders` on model | `static let placeholders` or `static var placeholders` | required |
| `Model.mockList` on model | `static let mockList` or `static var mockList` | required |
| Skeleton loading | `.redacted(reason:` | required |
| Empty state | `ContentUnavailableView` | required |
| Error handling | `Toast.error(` or `toast = .error` | required |
| Model conformances | `StringIdentifiable, Codable, Sendable` | required |

#### Layer 3 — Component Quality

| Check | What to grep | Type |
|-------|-------------|------|
| No raw font sizes | `Font.system(size:` or `font(.system(size:` | violation |
| No raw buttons | `Button(` or `Button {` without `DS` prefix nearby | violation |
| No hardcoded colors | `Color(red:` or `Color(#` or `Color(.sRGB` | violation |
| DS spacing tokens | common hardcoded padding values (e.g., `padding(16)`, `padding(8)`) | violation |

#### Failure behavior

- On violation: agent receives specific error message with the fix instruction
- Agent fixes violations, rebuilds, re-runs checks
- Max 2 fix rounds — if still failing after 2, report remaining violations in output and let human decide
- Layer 1 checks are hard gates. Layer 2 applies only when spec's `data_source` is `manager:*`. Layer 3 violations are warnings that must be addressed but don't block the screenshot gate.

### Change 2: Remove Contradictions from design-system.md

**Where:** forge-craft skill's design system research/generation step.

**What:** Add instruction that code sketches in Screen Blueprints must use DS components and tokens exclusively. No raw SwiftUI in any code example when a DS equivalent exists.

Specific patterns to eliminate from code sketches:
- `Font.system(size:` → use `.display()`, `.titleLarge()`, `.bodyMedium()`, etc.
- `LinearGradient` for backgrounds → use `AmbientBackground`
- `Button(` → use `DSButton` or `DSIconButton`
- Hardcoded `Color(` → use `.themePrimary`, `.textPrimary`, etc.
- Hardcoded padding values → use `DSSpacing` tokens

**Size:** ~3 lines added to forge-craft SKILL.md.

### Change 3: Publish Check List in AGENTS.md

**Where:** New `## Post-Build Checks` section in AGENTS.md, after Craft Patterns, before Design System Override Priority.

**Content:** The exact list of checks from Change 1, framed as "After building, your code will be scanned for these patterns. Violations require fixes before the screen is accepted."

**Purpose:** Agents respond better to "this will be checked" than "you should do this." Transparency about consequences, not more rules.

**Size:** ~15 lines.

### Change 4: Structured Spec Fields in forge-ux

**Where:** forge-ux `SKILL.md`, in the Feature Spec Format (Section 6).

**What:** Add an "Implementation contract" section to the spec template:

```markdown
### Implementation contract
- DS components: [e.g., DSButton, DSCard, DSListRow, DSSection]
- Patterns: [skeleton_loading, floating_cta, staggered_entrance, hero_stat]
- Data source: [manager:{ManagerName} | static | parent_injection]
- Screen type: [dashboard | list | detail | form | onboarding | settings | paywall]
```

**Purpose:** Bounds spec ambition by forcing concrete component choices. Build agent uses it as a checklist. Post-build checks can verify listed components are present in the code.

**Size:** ~10 lines added to spec template + ~5 lines of explanation.

## What's NOT in this design

- No new prompt rules for agents to follow
- No quality floor "examples" in AGENTS.md (replaced by published check list)
- No dispatch prompt changes (reference reading was overloading it)
- No "feasibility check" instruction (replaced by structural spec fields)
- No changes to the screenshot/iteration loop (Steps 5-7 already work)
- No changes to human checkpoints (already in place)

## File changes

| File | Change | Lines |
|------|--------|-------|
| `forge-craft-agent.md` | New Step 8c (floor checks) | ~50 |
| `AGENTS.md` | New Post-Build Checks section | ~15 |
| `forge-ux/SKILL.md` | Implementation contract in spec template | ~15 |
| `forge-craft/SKILL.md` | DS code sketch instruction | ~3 |
| **Total** | | **~83** |

## Implementation order

1. **forge-craft-agent.md** — Step 8c floor checks (highest impact, mechanical enforcement)
2. **AGENTS.md** — Post-Build Checks section (makes checks visible to agents)
3. **forge-ux/SKILL.md** — Implementation contract spec fields (bounds spec ambition)
4. **forge-craft/SKILL.md** — DS code sketch instruction (removes contradictions)
