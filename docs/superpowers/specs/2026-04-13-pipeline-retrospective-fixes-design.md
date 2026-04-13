# Forge Pipeline Retrospective Fixes — Design Spec

> **Source:** `.forge/retrospective.md` from the Drift build — 22 failures (15 process + 7 architectural).
> **Approach:** Thematic Redesign (Approach B) — group failures into 6 root themes, redesign each affected section cohesively.
> **Scope:** Skill files + DS infrastructure. No backward compatibility constraints.

---

## Theme 1: DS Flexibility

### Problem
AdaptiveTheme takes one hex color and derives everything. Result: monochromatic apps where buttons, charts, tab bars, links, and active states are all the same color at different opacities. DS components (DSCard, DSButton, etc.) have fixed visual shapes that enforce a "Forge look" regardless of what the design references demand.

### Retrospective Entries Addressed
- "Single brand color = flat, monochromatic design" (architectural)
- "The Design System template IS the ceiling" (architectural)

### Changes

**AdaptiveTheme.swift** — Replace single `brandColor` with `ColorStory`:

```swift
struct ColorStory {
    let brand: Color        // Brand identity — buttons, active states, primary actions
    let contrast: Color     // Contrast accent — charts, badges, data viz highlights
    let surprise: Color?    // Surprise detail — one craft moment per screen (optional)
    let surface: Color      // Surface tint — cards, backgrounds, neutral fills
}
```

`brand` and `surface` are required. `contrast` is required for apps with data visualization or multi-color references; optional for minimal 2-color apps (derived from `brand` if nil). `surprise` is optional — used sparingly for craft moments; omit for disciplined single-accent apps.

**Derivation mapping** — ColorStory fields map to ColorPalette semantic roles:
- `brand` → `themePrimary`, active states, tint, button fills
- `contrast` → chart colors, badges, info states, secondary actions
- `surprise` → craft moment highlights only (used in <1% of pixels)
- `surface` → `backgroundSecondary`, `surface`, `surfaceVariant` (lightened/darkened variants)
- `textPrimary`, `textSecondary`, `textTertiary` → derived from `surface` luminance (dark text on light surfaces, light text on dark surfaces)
- `border`, `divider` → derived from `surface` with reduced opacity
- `error` → system red (not part of ColorStory — always semantic)

Apps with rich data visualization (6+ colors) define additional chart colors beyond the story as Color extensions in the Theme file.

**forge-design/SKILL.md Section 2 translation** — Rewrite entirely:
1. Analyze reference apps' color DISTRIBUTION — which color dominates, which provides contrast, which surprises
2. Produce a `ColorStory` with intentional colors, not a monochrome derivation
3. New translation rule: map reference primary → `brand`, reference accent/CTA → `contrast`, reference highlight/special → `surprise`, reference background tint → `surface`
4. If reference uses only 2 colors (e.g., Things 3), set `contrast` to nil (derived from brand) and `surprise` to nil

**forge-design/SKILL.md CREATE verdict guidance** — New rule: *"If 3+ reference components look fundamentally different from their DS counterpart, the default verdict is CREATE, not KEEP. The DS is a floor, not a ceiling. When references demand flat borderless surfaces but DSCard has borders and shadows, verdict is CREATE with explicit replacement pattern."*

### Files
- `Packages/core-packages/DesignSystem/Sources/DesignSystem/Theme/AdaptiveTheme.swift`
- `skills/forge-design/SKILL.md`

---

## Theme 2: Visual-First Design

### Problem
DESIGN.md is hundreds of lines of token specs and zero lines of feel. "Use DSSpacing.lg between sections" produces mechanically correct spacing, not rhythm. Text-to-code produces literal results. Stitch mockups were available but optional. Blueprints list sections with equal weight instead of encoding hierarchy.

### Retrospective Entries Addressed
- "DESIGN.md is prescriptive about tokens, silent about feel" (design/UX)
- "No visual mockup step — text-to-code produces literal results" (design/UX)
- "Template layout preserved — not redesigned" (design/UX)
- "The app doesn't match its own brief" (design/UX)
- "Complexity over simplicity — the brief was lost" (design/UX)
- "Builder agents implement — they don't design" (design/UX)

### Changes

**design-md-format.md Section 1 (Mood)** — Expand from 2-line cap to Design North Star:
- Keep the mood sentence
- Add **Visual Feel paragraph** (3-5 sentences): Describes the experience of using the app, not the anatomy. Example: "Opening this app feels like checking the weather — one number, instant confidence, close."
- Add **Anti-references**: What this app is NOT. Prevents builders from drifting toward adjacent genres.

**design-md-format.md Section 2 (Color Palette)** — Replace `brandColor` single-hex with ColorStory:
- Required: `brand` and `surface` with hex values and usage rules
- Optional: `contrast` (required for data viz apps, derived from brand otherwise) and `surprise` (omit for single-accent apps)
- New field: **Color Distribution** — aspirational guidance for the designer: "Brand appears in ~15% of pixels. Contrast in ~5%. Surprise in <1%." (Not validated by pipeline — used by the judge's Vibe Check as a visual reference.)
- Semantic roles still exist but derive from the ColorStory via the derivation mapping in Theme 1

**design-md-format.md Section 8 (Screen Blueprints)** — Three new required fields per blueprint:
- **Visual Feel** (per-screen): How this screen feels to use, in human terms. Not anatomy — experience.
- **Hierarchy**: Primary element (60%+ visual weight), secondary (supporting), tertiary (discoverable on scroll). Replaces flat section lists.
- **Density target**: "1 thing above the fold" or "dense workspace with 3 data panels." Prevents builders from cramming or under-filling.

**Mockups mandatory for complex screens:**
- Any screen with `screen_type: dashboard`, charts, or 3+ sections MUST have a Stitch mockup generated and approved before code generation
- Simple screens (settings, forms) can skip mockups
- `Visual Reference` field in blueprints: required when mockup was generated (path to approved mockup). For simple screens without mockups, use "None — derived from {closest screen} mockup"

**forge-design/SKILL.md** — Add **Simplicity Audit** step after generating blueprints:
1. Count total **sections** across all blueprints (this runs in Phase 2, after blueprints exist)
2. Cross-reference against the pitch in spec.json
3. If pitch implies simplicity ("one glance", "3 seconds", "single purpose") but blueprints have 15+ total sections, flag the conflict and CUT before proceeding
4. The design skill's job is to fight feature creep, not enable it
5. Note: This is distinct from the Phase 1 Simplicity Check in Theme 6, which counts **features** in spec.json before blueprints exist. Phase 1 catches feature bloat early; Phase 2 catches section bloat within features.

**forge-design/SKILL.md** — Add **UX Audit** step:
- Cross-reference Section 8 blueprints against the original pitch in spec.json
- If the pitch says "the trend line IS the app" but the blueprint has the trend line as one of six sections, FAIL the blueprint
- Blueprints must encode hierarchy (primary/secondary/tertiary), not flat lists

### Files
- `skills/forge-app/references/design-md-format.md`
- `skills/forge-design/SKILL.md`

---

## Theme 3: Taste Layer (forge-judge)

### Problem
The judge grades compliance — did you use the right token, did you include `.toast()`? A screen can pass every compliance check and still look dead. No taste metrics. Nobody asks "would I download this app?"

### Retrospective Entries Addressed
- "No taste in the loop — compliance != quality" (architectural)
- "The pipeline optimizes for correctness, not craft" (architectural)

### Changes

**Consolidate judge versions** — Kill the personal repo version (5 criteria, 94 lines). The marketplace agent version (7 criteria, 209 lines) becomes the single source of truth. Copy back to personal repo.

**New: Craft Score** — 5 visual questions evaluated purely from the screenshot, after the 7 compliance criteria. Separate gate — both must pass:

1. **Dominance** — Does the screen have ONE element that commands attention? If everything is the same visual weight, fail.
2. **Rhythm** — Does spacing vary intentionally between sections, or is it uniform padding everywhere? Uniform = fail.
3. **Breathing room** — Is there negative space letting the hero element stand out, or is everything packed tight?
4. **Typography tension** — Do font sizes create visual interest (large vs. small contrast), or is everything within 4pt of each other?
5. **Signature moment** — Does the screen have at least one visual detail that goes beyond functional correctness? A custom animation, an intentional color pop, a typographic choice that creates surprise. If the screen is "technically correct but has zero craft details," fail. (Evaluable from screenshot + code — look for the Craft Moment defined in the blueprint.)

**New: Vibe Check** — When reference app screenshots exist in `.forge/references/screenshots/`, compare the built screenshot against the reference screenshots for feel-matching. Not pixel-matching — same emotional response, same density, same surface treatment, same typography confidence. Replaces the weaker "Visual Target Match" criterion that only checked DESIGN.md text. **Fallback:** If no reference screenshots exist, evaluate against the Visual Feel paragraph from the blueprint and the preset axes from DESIGN.md Section 1.

**Craft Score is a hard gate** — A screen can pass all 7 compliance criteria and still fail on craft. Both compliance AND craft must pass for an overall PASS verdict.

### Files
- `skills/forge-judge/SKILL.md` (personal repo — replace with marketplace version + craft score)
- Marketplace `agents/forge-judge.md` (update with craft score + vibe check)

---

## Theme 4: Builder Context (forge-build)

### Problem
Codex receives text descriptions of what Notion/Stripe look like but has no visual memory. It implements words literally. Codex also can't invoke Claude Code skills (swiftui-expert, axiom-swiftui) because it runs in a separate sandbox.

### Retrospective Entries Addressed
- "No visual references in the build loop — words don't convey feel" (architectural)
- "SwiftUI/Axiom skills not invoked during screen building" (screen-specific)
- "Codex cannot invoke Claude Code skills" (screen-specific)
- "All screens built by general-purpose agents produce template-generic UI" (screen-specific)

### Changes

**PROMPT.md** — Add three new placeholder sections:

```xml
<visual_feel>
{{VISUAL_FEEL}}
</visual_feel>

<visual_references>
{{VISUAL_REFERENCES}}
</visual_references>

<mockup>
{{MOCKUP_PATH}}
</mockup>

<skill_context>
{{SKILL_CONTEXT}}
</skill_context>
```

- `{{VISUAL_FEEL}}` — The Visual Feel paragraph from the blueprint + the Design North Star from Section 1. Gives Codex a prose target, not just tokens.
- `{{VISUAL_REFERENCES}}` — Actual screenshot images from reference apps (captured during Phase 2 — see Screenshot Acquisition below). Codex sees what Notion/Stripe LOOK like. In retry rounds after a judge FAIL, this slot also includes the **failing screenshot** so Codex can see what needs to change, not just read text describing the problem.
- `{{MOCKUP_PATH}}` — The approved Stitch mockup for this screen. Codex builds to match the mockup.
- `{{SKILL_CONTEXT}}` — Pre-extracted patterns from SwiftUI/Axiom skills (see Skill Pre-load below).

**Skill Pre-load Pattern** — Since Codex can't invoke skills, the orchestrator does it before dispatch:
1. Before each feature, invoke the relevant skill (e.g., `swiftui-expert` for SwiftUI layout, `axiom-swiftui` for state patterns)
2. Extract specific patterns/guidance relevant to this `screen_type`
3. Embed that guidance in the `{{SKILL_CONTEXT}}` section of the Codex prompt
4. This turns skill knowledge into prompt context that Codex CAN use

**Screen-type fragments (prompts/*.md)** — Rewrite all 7 to include hierarchy guidance:
- Dashboard: "The hero stat takes 60% of above-the-fold space. Everything else is secondary and muted."
- Detail: "The title/header anchors the top. Content flows below with clear section breaks."
- List: "Each row has ONE primary label. Secondary info is visually subordinate."
- etc.

Replace component shopping lists ("use DSCard for stats") with design intent ("stats are whispered, not shouted — small text, muted color, secondary position").

**Screenshot Acquisition (Phase 2)** — New step in forge-app Phase 2, before DESIGN.md generation:
1. If user provided screenshots during Phase 1 Q5 ("Any apps that feel like what you're building?"), save to `.forge/references/screenshots/`
2. Otherwise, use WebFetch to capture reference app landing pages or App Store preview screenshots
3. Save all reference screenshots to `.forge/references/screenshots/` with descriptive filenames (e.g., `notion-settings.png`, `stripe-dashboard.png`)
4. These screenshots are used by: (a) forge-design for visual translation, (b) forge-build via `{{VISUAL_REFERENCES}}` in the Codex prompt, (c) forge-judge for Vibe Check comparison

### Files
- `skills/forge-build/PROMPT.md`
- `skills/forge-build/prompts/dashboard.md`
- `skills/forge-build/prompts/detail.md`
- `skills/forge-build/prompts/form.md`
- `skills/forge-build/prompts/list.md`
- `skills/forge-build/prompts/onboarding.md`
- `skills/forge-build/prompts/paywall.md`
- `skills/forge-build/prompts/settings.md`

---

## Theme 5: Human Taste Gates (forge-app)

### Problem
The pipeline optimized for speed — parallel dispatch, batch commit, show at the end. The fundamental tension between automation and craft was ignored.

### Retrospective Entries Addressed
- "The fundamental tension: automation vs. craft" (architectural)
- "No Human Gate Per Feature" (systemic)
- "Bad Color Choice" (systemic)
- "No Taste Judge" (systemic)

### Changes

**Gate 1: Color on a Real Screen (Phase 2, after DESIGN.md generation)**
1. Build a minimal "color swatch" screen — hero element with ColorStory applied on a real background
2. Screenshot it via xcodebuildmcp
3. Show to user: "Here's your palette on a real screen. Does this feel right?"
4. No hex table approvals. Colors in pixels, not in text.

**Gate 2: First Screen Review (Phase 3, after first feature passes judge)**
1. After first feature passes compliance + craft score, STOP the pipeline
2. Show screenshot: "This sets the visual tone for the entire app. Does this feel like YOUR app?"
3. If no → redesign blueprint, rebuild, re-judge
4. If yes → proceed to remaining screens
5. This is the highest-leverage gate. If screen 1's taste is wrong, everything inherits the problem.

**Gate 3: Approve-or-Flag Review (Phase 3, per feature)**
1. Each feature is shown individually after passing the judge
2. Focused question: "The hero element is [X]. Does it command attention? Does the screen have one clear focal point?"
3. User can **approve** (continue) or **flag** concerns (note what feels off, pipeline continues building)
4. Flagged concerns are batched into a redesign round after all screens are built — the user reviews all flags at once and the pipeline fixes them as a set
5. This preserves Gate 2 (first screen review) as the highest-leverage blocking gate, while reducing friction for screens 2-7 from mandatory sequential approval to lightweight approve-or-flag
6. Parallel code generation is fine. Review is per-feature but non-blocking (flags don't halt the pipeline)

**Judge step is non-skippable** — The pipeline must error if a feature is marked "done" without a judge PASS (compliance + craft). No shortcutting to show the user an unjudged screen.

### Files
- `skills/forge-app/SKILL.md` (Phase 2 + Phase 3)

---

## Theme 6: Pipeline Discipline (forge-app)

### Problem
The orchestrator read the SKILL.md once then improvised. Features went to general-purpose agents. Raw xcodebuild was used instead of xcodebuildmcp. Skills were never invoked. Fixes were done manually.

### Retrospective Entries Addressed
- "Orchestrator did not follow forge-app SKILL.md" (systemic)
- "Features dispatched to general-purpose agents instead of Codex" (screen-specific)
- "Used raw xcodebuild commands instead of xcodebuildmcp" (screen-specific)
- "UI Fixes Done Manually Instead of Delegated" (systemic)
- "Launched Dev Instead of Mock" (systemic)
- "Template auth gate still active" (screen-specific)

### Changes

**Checkpoint System** — Before each Phase, the orchestrator re-reads the relevant SKILL.md section. Add machine-checkable checklists:

```markdown
### CHECKPOINT: Before Phase 3
Re-read Phase 3 steps. Verify:
- [ ] Codex dispatch uses subagent_type: "codex:codex-rescue" (NEVER general-purpose)
- [ ] Screenshot uses xcodebuildmcp (NEVER raw xcodebuild/simctl)
- [ ] Judge is dispatched after EVERY screenshot (NEVER skipped)
- [ ] Human gate fires after EVERY feature (NEVER batched)
- [ ] Skill pre-load ran before Codex dispatch
- [ ] Bundle ID is verified after launch (must contain ".mock")
```

**Codex-Only Enforcement** — Hard rule in Phase 3: *"ALL code generation and ALL code fixes go through Codex dispatch. The orchestrator NEVER writes or edits Swift code directly. The orchestrator's job is to identify problems and write fix prompts, not to fix code. This includes 'quick fixes.' There are no quick fixes."*

**xcodebuildmcp with Fallback** — *"ALL build, run, screenshot, and UI automation operations use xcodebuildmcp. If xcodebuildmcp fails 4 consecutive times on the same operation, fall back to raw xcodebuild with a warning logged to the retrospective. The xcodebuildmcp-cli skill must be invoked at pipeline start."*

**Bundle ID Assertion** — After every build-and-run, verify: `bundleId contains ".mock"`. If wrong bundle launches, stop and fix scheme selection before proceeding.

**Simplicity Check (Phase 1)** — After generating spec.json, before proceeding to Phase 2:
1. Count total **features** in spec.json (blueprints don't exist yet at this stage)
2. Cross-reference against pitch
3. If pitch implies simplicity ("one glance", "3 seconds") but spec has 6+ features, force scope reduction conversation
4. Note: The Phase 2 Simplicity Audit (Theme 2, in forge-design) catches section bloat within features after blueprints are generated. These are complementary checks at different granularities.

**Auth Gate Stripping (Phase 0)** — During project setup, after spec.json is available:
1. Check spec.json for auth-related features (login, signup, authentication)
2. If no auth feature exists, strip the auth gate from AppRootView.swift (remove the sign-in screen conditional, route directly from onboarding to main app)
3. This prevents the template's default auth flow from blocking no-auth apps like Drift

### Files
- `skills/forge-app/SKILL.md` (Phase 1, 2, 3)

---

## Full Change Surface

| File | Themes | Change |
|------|--------|--------|
| `AdaptiveTheme.swift` | 1 | Replace `brandColor` with `ColorStory` struct |
| `forge-design/SKILL.md` | 1, 2 | Color story translation, CREATE verdicts, simplicity audit, UX audit |
| `design-md-format.md` | 2 | Visual Feel, hierarchy, density target, expanded Mood, Color Story |
| `forge-judge/SKILL.md` | 3 | Consolidate + craft score + vibe check |
| `forge-judge.md` (agent) | 3 | Craft score + vibe check |
| `forge-build/PROMPT.md` | 4 | Visual references, mockup, feel, skill context placeholders |
| `forge-build/prompts/*.md` (7 files) | 4 | Hierarchy-first rewrite |
| `forge-app/SKILL.md` | 5, 6 | Taste gates, checkpoints, Codex-only, simplicity check |

**Total: 13 files modified across 6 themes.**

---

## Implementation Order

Themes have tight cross-dependencies. Partial implementation (shipping some themes without others) will break the pipeline worse than the current state. Implement in two atomic batches:

**Batch A: Foundation (Themes 1 + 2)** — DS infrastructure + design format
- AdaptiveTheme.swift: ColorStory struct + derivation logic
- design-md-format.md: Visual Feel, hierarchy, Color Story format, expanded Mood
- forge-design/SKILL.md: Color story translation, CREATE verdicts, simplicity audit, UX audit, screenshot acquisition

Must ship together because: forge-design produces ColorStory fields that AdaptiveTheme consumes. If format changes ship without DS changes (or vice versa), the pipeline produces incompatible artifacts.

**Batch B: Quality Loop (Themes 3 + 4 + 5 + 6)** — judge + builder + gates + discipline
- forge-judge: Craft score + vibe check (requires Visual Feel from Batch A)
- forge-build/PROMPT.md: New placeholders (requires Visual Feel + screenshots from Batch A)
- forge-build/prompts/*.md: Hierarchy-first rewrites
- forge-app/SKILL.md: Taste gates, checkpoints, Codex-only, simplicity check, auth gate stripping

Must ship together because: The judge's craft score evaluates against standards the builder must receive (Theme 4). The taste gates (Theme 5) require the craft score (Theme 3) to exist. The checkpoints (Theme 6) reference the skill pre-load step (Theme 4).

**Batch A must ship before Batch B.** Batch B depends on the format and infrastructure changes from Batch A.

---

## Retrospective Entry Coverage

All entries from the Drift retrospective are addressed:

| Entry | Theme | Status |
|-------|-------|--------|
| Pipeline Discipline | 6 | Checkpoint system |
| No Taste Judge | 5 | Non-skippable judge gate |
| No Human Gate Per Feature | 5 | Sequential approval |
| Bad Color Choice | 5 | Gate 1: color on real screen |
| Launched Dev Instead of Mock | 6 | Bundle ID assertion |
| UI Fixes Done Manually | 6 | Codex-only enforcement |
| App doesn't match brief | 2 | Simplicity audit + UX audit |
| Template layout preserved | 1, 4 | CREATE verdicts + hierarchy fragments |
| DESIGN.md silent about feel | 2 | Visual Feel paragraphs |
| No visual mockup step | 2 | Mandatory mockups for complex screens |
| Builder agents don't design | 4 | Visual refs + mockup + feel in prompt |
| Complexity over simplicity | 2, 6 | Simplicity check in Phase 1 |
| DS template IS ceiling | 1 | CREATE verdict guidance + ColorStory |
| No taste in loop | 3 | Craft score (5 visual questions) |
| No visual references | 4 | Screenshot refs in Codex prompt |
| Single brand color | 1 | ColorStory replaces brandColor |
| Correctness not craft | 3 | Craft score as separate gate |
| Automation vs. craft tension | 5 | 3 human taste gates |
| Onboarding TabView height | 4 | Updated in onboarding.md fragment |
| General-purpose agents used | 6 | Codex-only enforcement |
| Skills not invoked | 4 | Skill pre-load pattern |
| Raw xcodebuild used | 6 | xcodebuildmcp enforcement + fallback |
| Auth gate still active | 6 | Auth gate stripping in Phase 0 |
