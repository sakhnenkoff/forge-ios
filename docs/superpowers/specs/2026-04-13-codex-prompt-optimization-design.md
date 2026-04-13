# Codex Prompt Optimization

## Overview

Rewrite `skills/forge-build/PROMPT.md` from flat markdown to Codex's native XML prompt structure. Add per-screen-type prompt fragments and a one-pass self-check. Goal: maximize code quality from Codex by speaking its native language.

## Problem

The current PROMPT.md is flat markdown. Codex (GPT-5.4) is designed to work with XML-tagged prompts (`<task>`, `<verification_loop>`, etc.) as defined in the `gpt-5-4-prompting` skill. Using flat markdown works but loses structure that helps Codex stay focused, scoped, and self-verifying.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Prompt format | Codex-native XML blocks | Matches how GPT-5.4 processes instructions |
| Self-verification | One-pass grep check, no loop | Catches obvious mistakes before returning, no infinite loop risk |
| Screen type handling | Per-type fragment files assembled by forge-app | Different screens need different guidance (paywall vs settings vs dashboard) |
| Which XML blocks to include | Only Forge-specific ones | Rely on Codex defaults for follow-through/safety — saves context budget |

---

## Prompt Structure

Base template (`skills/forge-build/PROMPT.md`) uses these XML blocks:

```xml
<task>
Build the {feature_name} screen for this iOS app.
Write complete, compilable Swift files: View + ViewModel + Manager (if needed) + Model + Navigation wiring.
Do NOT build, run, screenshot, or navigate — only write code files.

Feature spec:
{{FEATURE_SPEC}}
</task>

<design_contract>
{{DESIGN_BLUEPRINT}}
</design_contract>

<architecture_rules>
{{AGENTS_RULES}}
</architecture_rules>

<preset_tokens>
{{PRESET_TOKENS}}
</preset_tokens>

<shared_files>
{{SHARED_FILES}}
</shared_files>

<screen_type_guidance>
{{SCREEN_TYPE_FRAGMENT}}
</screen_type_guidance>

<verification_loop>
Before finishing, check your output files ONCE:

View file:
- grep -q "DSScreen" {ViewFile} || fix it
- grep -q "\.toast(" {ViewFile} || fix it
- grep -q "\.onAppear" {ViewFile} || fix it
- grep -q "AsyncImage" {ViewFile} && remove it
- grep -q "@StateObject" {ViewFile} && replace with @State

ViewModel file:
- grep -q "@Observable" {VMFile} || fix it
- grep -q "var toast: Toast?" {VMFile} || add it
- grep -q "hasLoaded" {VMFile} || add the guard pattern

Fix any violations. Do NOT re-check after fixing. Return your final files regardless.
</verification_loop>
```

### Blocks NOT included (rely on Codex defaults)

- `<action_safety>` — Codex's default scoping behavior is sufficient
- `<default_follow_through_policy>` — Codex keeps going by default
- `<completeness_contract>` — the `<task>` block states "complete, compilable" which is enough
- `<grounding_rules>` — not applicable to code generation

---

## Screen Type Fragments

Separate files in `skills/forge-build/prompts/`, ~20-30 lines each. forge-app loads the relevant fragment based on `screen_type` from spec.json.

### `prompts/dashboard.md`
- Hero section with greeting pattern (time-based)
- Stats/metrics using DSCard with numeric emphasis
- Quick action shortcuts using DSButton grid or horizontal scroll
- Activity feed or recent items using DSListRow
- Avoid: cramming everything above the fold, equal-weight cards

### `prompts/detail.md`
- Scrollable content with hero image/header area
- Primary action button (sticky or inline based on blueprint)
- Metadata section (date, author, tags) using caption typography
- Related items section at bottom
- Avoid: too many CTAs competing, missing back navigation

### `prompts/list.md`
- DSListRow as primary component
- Search bar using .searchable modifier if specified
- Empty state with illustration + CTA
- Pull-to-refresh if data is dynamic
- Avoid: mixing card and row styles, missing empty/loading states

### `prompts/form.md`
- DSTextField for all inputs
- Grouped sections with clear labels
- Inline validation (show errors below fields)
- Keyboard handling (.focused, submit action)
- Primary submit DSButton at bottom
- Avoid: too many fields visible at once, missing error states

### `prompts/onboarding.md`
- TabView with .page style for swipeable steps
- Progress indicator (dots or step counter)
- Skip button in navigation (top trailing)
- Final step has primary CTA (not "Next")
- Avoid: too many steps (max 4-5), walls of text, no skip option

### `prompts/paywall.md`
- Feature comparison or value proposition section
- Pricing tiers with clear recommended option
- Restore purchases button (required by App Store)
- Trial messaging if applicable
- Close/dismiss button always visible
- Avoid: hiding the close button, missing restore, aggressive language

### `prompts/settings.md`
- Grouped sections using Section with headers
- Toggle rows for boolean preferences
- Navigation rows (DSListRow with chevron) for sub-screens
- Destructive actions (sign out, delete account) at bottom, red-tinted
- App version at bottom using caption typography
- Avoid: mixing action buttons with navigation rows, destructive actions at top

---

## Assembly Flow

How forge-app constructs the final prompt per feature:

1. Read `skills/forge-build/PROMPT.md` (base template)
2. Read `skills/forge-build/prompts/{screen_type}.md` (fragment for this screen type)
3. Fill placeholders:
   - `{{FEATURE_SPEC}}` — feature entry from `.forge/spec.json`
   - `{{DESIGN_BLUEPRINT}}` — Section 7 blueprint for this screen from `.forge/DESIGN.md`
   - `{{AGENTS_RULES}}` — AGENTS.md "Architecture" through "Post-Build Checks" (~200 lines)
   - `{{PRESET_TOKENS}}` — concrete token values from the selected PresetConfiguration
   - `{{SHARED_FILES}}` — current contents of AppRoute.swift, AppServices.swift, and any shared files this feature modifies
   - `{{SCREEN_TYPE_FRAGMENT}}` — the loaded fragment content
4. Optionally extract and append `{{SKILL_KNOWLEDGE}}` from installed skills (SwiftUI UI Patterns, swift-concurrency, etc.)
5. Send populated prompt to Codex via `codex:rescue`

Total injected context target: under 4K tokens (same as spec).

---

## Self-Check Details

The `<verification_loop>` block runs **once** at the end of Codex's execution. It is NOT a retry loop.

**What Codex checks:**
- 5 View file patterns (DSScreen, .toast, .onAppear, no AsyncImage, no @StateObject)
- 3 ViewModel file patterns (@Observable, toast property, hasLoaded guard)

**What Codex does NOT check (Opus handles these):**
- DESIGN.md Section 6 Don'ts (app-specific, not in the prompt)
- Hardened-build architecture checks
- Visual taste evaluation
- Cross-file consistency

**Behavior on failure:** Codex fixes the violation in the file. Does not re-check. Returns all files.

**No infinite loop risk:** The block explicitly says "Do NOT re-check after fixing. Return your final files regardless." There is no condition that could restart the check.

---

## What Changes

| File | Action |
|------|--------|
| `skills/forge-build/PROMPT.md` | Rewrite from flat markdown to XML structure |
| `skills/forge-build/prompts/dashboard.md` | Create |
| `skills/forge-build/prompts/detail.md` | Create |
| `skills/forge-build/prompts/list.md` | Create |
| `skills/forge-build/prompts/form.md` | Create |
| `skills/forge-build/prompts/onboarding.md` | Create |
| `skills/forge-build/prompts/paywall.md` | Create |
| `skills/forge-build/prompts/settings.md` | Create |

No changes to forge-app SKILL.md — it already describes the placeholder injection and assembly flow. The `{{SCREEN_TYPE_FRAGMENT}}` placeholder is new but the assembly logic is the same pattern.
