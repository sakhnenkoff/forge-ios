# Codex Prompt Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite forge-build's PROMPT.md to use Codex-native XML structure with per-screen-type fragments and a one-pass self-check.

**Architecture:** One base template (XML-structured) + 7 screen-type fragment files + forge-app assembly update. Total: 9 files changed.

**Tech Stack:** Markdown (skill files), XML prompt blocks (gpt-5-4-prompting conventions)

**Spec:** `docs/superpowers/specs/2026-04-13-codex-prompt-optimization-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `skills/forge-build/PROMPT.md` | Rewrite | Base XML prompt template |
| `skills/forge-build/prompts/dashboard.md` | Create | Dashboard screen guidance |
| `skills/forge-build/prompts/detail.md` | Create | Detail screen guidance |
| `skills/forge-build/prompts/list.md` | Create | List screen guidance |
| `skills/forge-build/prompts/form.md` | Create | Form screen guidance |
| `skills/forge-build/prompts/onboarding.md` | Create | Onboarding screen guidance |
| `skills/forge-build/prompts/paywall.md` | Create | Paywall screen guidance |
| `skills/forge-build/prompts/settings.md` | Create | Settings screen guidance |
| `skills/forge-app/SKILL.md` | Modify | Add SCREEN_TYPE_FRAGMENT to assembly, drop SKILL_KNOWLEDGE |

---

### Task 1: Rewrite PROMPT.md to XML structure

**Files:**
- Modify: `skills/forge-build/PROMPT.md`

- [ ] **Step 1: Replace the entire PROMPT.md with the XML template**

Write this exact content to `skills/forge-build/PROMPT.md`:

~~~markdown
# Forge Build — Codex Code Generation Prompt

<task>
Build the {feature_name} screen for this iOS app.
Write complete, compilable Swift files: View + ViewModel + Manager (if needed) + Model + Navigation wiring.
Do NOT build, run, screenshot, or navigate — only write code files.

Feature spec:
{{FEATURE_SPEC}}

Files to create:

1. **View** (`{App}/Features/{FeatureName}/{FeatureName}View.swift`)
   - Root container: `DSScreen`
   - Must include: `.toast(toast: $viewModel.toast)`, `.onAppear { viewModel.onAppear(services: services, session: session) }`
   - Use `@State private var viewModel = {FeatureName}ViewModel()`
   - Never use `@StateObject`, `AsyncImage`
   - Use DS components: DSButton, DSCard, DSListRow, DSScreen, DSTextField, etc.
   - Use DS typography: `.display()`, `.titleLarge()`, `.bodyMedium()`, etc.
   - Use semantic colors: `.themePrimary`, `.textPrimary`, `.textSecondary`, etc.
   - Use DS spacing: `DSSpacing.xs` (4), `.sm` (8), `.smd` (12), `.md` (16), `.mlg` (20), `.lg` (24), `.xl` (32), `.xxlg` (40), `.xxl` (52)
   - Use DS radii: `DSRadii.xs` (8), `.sm` (12), `.md` (16), `.lg` (20), `.xl` (28), `.pill` (999)

2. **ViewModel** (`{App}/Features/{FeatureName}/{FeatureName}ViewModel.swift`)
   - `@MainActor @Observable final class {FeatureName}ViewModel`
   - Must include: `var toast: Toast?`, `private var hasLoaded = false`
   - `onAppear(services:session:)` with `guard !hasLoaded else { return }` pattern
   - `enum Event: LoggableEvent` for analytics

3. **Manager** (only if `has_manager: true` in spec)
   - Protocol + Mock implementation
   - Register in AppServices

4. **Model** (only if models listed in spec)
   - `static let placeholders: [ModelName]`
   - `static let mockList: [ModelName]`
   - `StringIdentifiable` conformance

5. **Navigation** — add route to AppRoute/AppSheet/AppTab as specified
</task>

<design_contract>
```
{{DESIGN_BLUEPRINT}}
```
</design_contract>

<architecture_rules>
```
{{AGENTS_RULES}}
```
</architecture_rules>

<preset_tokens>
{{PRESET_TOKENS}}
</preset_tokens>

<shared_files>
```swift
{{SHARED_FILES}}
```
</shared_files>

<screen_type_guidance>
{{SCREEN_TYPE_FRAGMENT}}
</screen_type_guidance>

<action_safety>
Keep changes tightly scoped to this feature.
Do not refactor, rename, or restructure existing code unless the feature requires it.
Append to shared files (AppRoute, AppServices) — do not reorganize them.
</action_safety>

<final_check>
Before finishing, check the files you just wrote ONCE.
Use the actual file paths you created (not placeholders).

View file:
- grep -q "DSScreen" <your-view-file> || fix it
- grep -q "\.toast(" <your-view-file> || fix it
- grep -q "\.onAppear" <your-view-file> || fix it
- grep -q "AsyncImage" <your-view-file> && remove it
- grep -q "@StateObject" <your-view-file> && replace with @State

ViewModel file:
- grep -q "@Observable" <your-viewmodel-file> || fix it
- grep -q "var toast: Toast?" <your-viewmodel-file> || add it
- grep -q "hasLoaded" <your-viewmodel-file> || add the guard pattern

Fix any violations. Do NOT re-check after fixing. Return your final files regardless.
</final_check>
~~~

- [ ] **Step 2: Verify the file looks correct**

```bash
head -5 skills/forge-build/PROMPT.md
grep -c "{{" skills/forge-build/PROMPT.md
```

Expected: 6 placeholder markers (FEATURE_SPEC, DESIGN_BLUEPRINT, AGENTS_RULES, PRESET_TOKENS, SHARED_FILES, SCREEN_TYPE_FRAGMENT).

- [ ] **Step 3: Commit**

```bash
git add skills/forge-build/PROMPT.md
git commit -m "feat: rewrite PROMPT.md to Codex-native XML structure with action_safety and final_check"
```

---

### Task 2: Create screen type fragment files

**Files:**
- Create: `skills/forge-build/prompts/dashboard.md`
- Create: `skills/forge-build/prompts/detail.md`
- Create: `skills/forge-build/prompts/list.md`
- Create: `skills/forge-build/prompts/form.md`
- Create: `skills/forge-build/prompts/onboarding.md`
- Create: `skills/forge-build/prompts/paywall.md`
- Create: `skills/forge-build/prompts/settings.md`

- [ ] **Step 1: Create the prompts directory**

```bash
mkdir -p skills/forge-build/prompts
```

- [ ] **Step 2: Write dashboard.md**

Write to `skills/forge-build/prompts/dashboard.md`:

```markdown
# Dashboard Screen Guidance

## Layout Pattern
- Hero section at top with time-based greeting: use `HomeViewModel.greeting(for:)` pattern
- Current date string below greeting using `.bodyMedium()` + `.textSecondary`
- Stats or metrics section using DSCard with numeric emphasis (`.display()` or `.titleLarge()` for numbers)
- Quick action shortcuts: horizontal ScrollView of DSButton or icon+label tiles
- Activity feed or recent items below using DSListRow in a VStack or List

## DS Components to Prefer
- `DSCard` for metric/stat tiles
- `DSListRow` for activity feed items
- `DSButton(.secondary)` for quick actions
- `DSScreen` as root (required)

## Anti-Patterns
- Do NOT cram everything above the fold — let the user scroll
- Do NOT use equal-weight cards in a grid — create visual hierarchy with one dominant element
- Do NOT use a TabView inside the dashboard — tabs belong at the app level
- Do NOT hardcode greeting strings — use the time-based greeting pattern
```

- [ ] **Step 3: Write detail.md**

Write to `skills/forge-build/prompts/detail.md`:

```markdown
# Detail Screen Guidance

## Layout Pattern
- ScrollView as container (inside DSScreen)
- Hero image or header area at top (use AsyncImage alternative: load via manager, display with Image)
- Title using `.titleLarge()`, subtitle using `.bodyMedium()` + `.textSecondary`
- Metadata row (date, author, category) using `.captionLarge()` + `.textTertiary`
- Body content using `.bodyMedium()`
- Primary action button: DSButton(.primary, size: .large) — sticky at bottom or inline based on blueprint
- Related items section at bottom using horizontal ScrollView of DSCard

## DS Components to Prefer
- `DSScreen` as root (required)
- `DSCard` for related items
- `DSButton` for primary action
- `TagBadge` for categories/tags

## Anti-Patterns
- Do NOT have multiple competing primary CTAs — one primary, rest secondary/ghost
- Do NOT forget back navigation — NavigationStack handles this, don't add a custom back button
- Do NOT put metadata above the title — title first, metadata second
```

- [ ] **Step 4: Write list.md**

Write to `skills/forge-build/prompts/list.md`:

```markdown
# List Screen Guidance

## Layout Pattern
- List or LazyVStack as container (inside DSScreen)
- DSListRow as the primary repeating component
- Search bar: use `.searchable(text:)` modifier on the NavigationStack if search is specified
- Section headers using `.headlineSmall()` + `.textSecondary` if grouped
- Empty state: centered VStack with SF Symbol (`.font(.system(size: 48))`), title (`.titleSmall()`), subtitle (`.bodyMedium()` + `.textSecondary`), and CTA DSButton
- Pull-to-refresh: `.refreshable { }` modifier if data is dynamic

## DS Components to Prefer
- `DSListRow` for each item
- `DSScreen` as root (required)
- `DSButton` for empty state CTA

## Anti-Patterns
- Do NOT mix DSCard and DSListRow in the same list — pick one style
- Do NOT forget empty state — every list must handle zero items
- Do NOT forget loading state — show placeholder/skeleton while loading
- Do NOT use a plain Text for list items — always use DSListRow
```

- [ ] **Step 5: Write form.md**

Write to `skills/forge-build/prompts/form.md`:

```markdown
# Form Screen Guidance

## Layout Pattern
- ScrollView as container (inside DSScreen) — forms can exceed screen height
- Grouped sections with clear section headers using `.headlineSmall()`
- DSTextField for every input field, with label and placeholder
- Inline validation: show error text below the field using `.captionLarge()` + `.error` color
- Keyboard handling: use `@FocusState` to manage field focus, `.submitLabel(.next)` between fields, `.submitLabel(.done)` on last field
- Primary submit button: DSButton(.primary, size: .large) at bottom, disabled until form is valid

## DS Components to Prefer
- `DSTextField` for all inputs
- `DSButton` for submit
- `DSScreen` as root (required)
- `DSChoiceButton` for single-select options

## Anti-Patterns
- Do NOT show more than 4-5 fields without scrolling — group into sections
- Do NOT forget error states — every field that can fail validation needs inline error
- Do NOT use alerts for validation errors — inline is better
- Do NOT forget keyboard dismiss — tap outside should dismiss keyboard
```

- [ ] **Step 6: Write onboarding.md**

Write to `skills/forge-build/prompts/onboarding.md`:

```markdown
# Onboarding Screen Guidance

## Layout Pattern
- TabView with `.tabViewStyle(.page)` for swipeable steps
- Each step: large SF Symbol or illustration at top, title (`.titleLarge()`), subtitle (`.bodyMedium()` + `.textSecondary`), centered vertically
- Progress indicator: `.indexViewStyle(.page(backgroundDisplayMode: .always))` or custom dot indicator
- Skip button: top trailing, using `.bodyMedium()` + `.textSecondary`, always visible except on last step
- Final step: primary CTA using DSButton(.primary, size: .large) — text should be the app's key action, not "Next" or "Done"
- Max 4-5 steps — respect the user's time

## DS Components to Prefer
- `DSButton` for final CTA
- `DSScreen` as root (required)

## Anti-Patterns
- Do NOT use more than 5 onboarding steps — users will skip
- Do NOT use walls of text — one title + one subtitle per step
- Do NOT hide the skip button — users must always be able to skip
- Do NOT use "Next" on the final step — use the app's primary action verb
- Do NOT auto-advance steps — let the user control the pace
```

- [ ] **Step 7: Write paywall.md**

Write to `skills/forge-build/prompts/paywall.md`:

```markdown
# Paywall Screen Guidance

## Layout Pattern
- Presented as a sheet (`.sheet()`) — must have visible close/dismiss button (top leading or trailing)
- Value proposition section at top: 3-4 feature highlights using SF Symbols + short descriptions
- Pricing tiers: clearly differentiate free vs paid, highlight recommended tier with DSCard + `.themePrimary` border
- If trial available: prominent trial messaging ("Start 7-day free trial") on the primary CTA
- Restore purchases: text button at bottom using `.bodySmall()` + `.textSecondary` — required by App Store
- Subscribe CTA: DSButton(.primary, size: .large), full width

## DS Components to Prefer
- `DSCard` for pricing tiers
- `DSButton` for subscribe CTA
- `DSListRow` for feature comparison
- `DSScreen` as root (required)

## Anti-Patterns
- Do NOT hide the close/dismiss button — App Store will reject
- Do NOT forget "Restore Purchases" — App Store will reject
- Do NOT use aggressive language ("Don't miss out!", "Last chance!") — keep it factual
- Do NOT auto-select the most expensive tier — let the user choose
- Do NOT hide pricing information — always show the price clearly
```

- [ ] **Step 8: Write settings.md**

Write to `skills/forge-build/prompts/settings.md`:

```markdown
# Settings Screen Guidance

## Layout Pattern
- List with grouped sections using `Section(header:)` blocks
- Section headers using `.headlineSmall()` + `.textSecondary` + uppercase
- Toggle rows: DSListRow with Toggle for boolean preferences
- Navigation rows: DSListRow with chevron accessory for sub-screens (push navigation)
- Account section at top: user name/email, avatar if available
- Preferences section: notification toggles, appearance settings
- Support section: help, feedback, privacy policy, terms
- Destructive section at bottom: "Sign Out" (`.error` color), "Delete Account" (`.error` color, with confirmation alert)
- App version at very bottom: `.captionLarge()` + `.textTertiary`, centered

## DS Components to Prefer
- `DSListRow` for all rows
- `DSScreen` as root (required)
- Toggle (SwiftUI native) inside DSListRow for boolean settings

## Anti-Patterns
- Do NOT put destructive actions at the top — always at bottom
- Do NOT mix action buttons with navigation rows — be consistent
- Do NOT forget confirmation for destructive actions — always use `.alert()` before sign out or delete
- Do NOT use red for non-destructive actions — reserve `.error` color for sign out and delete only
```

- [ ] **Step 9: Verify all 7 fragment files exist**

```bash
ls skills/forge-build/prompts/
```

Expected: `dashboard.md  detail.md  form.md  list.md  onboarding.md  paywall.md  settings.md`

- [ ] **Step 10: Commit**

```bash
git add skills/forge-build/prompts/
git commit -m "feat: add 7 screen-type prompt fragments for Codex — dashboard, detail, list, form, onboarding, paywall, settings"
```

---

### Task 3: Update forge-app assembly flow

**Files:**
- Modify: `skills/forge-app/SKILL.md:153-161`

- [ ] **Step 1: Read the current assembly section**

```bash
grep -n "FEATURE_SPEC\|DESIGN_BLUEPRINT\|AGENTS_RULES\|PRESET_TOKENS\|SKILL_KNOWLEDGE\|SHARED_FILES\|SCREEN_TYPE" skills/forge-app/SKILL.md
```

- [ ] **Step 2: Update the placeholder list in Step 1 of Phase 3**

In `skills/forge-app/SKILL.md`, find the section starting with `Read \`skills/forge-build/PROMPT.md\`. Replace placeholders:` (around line 153).

Replace:

```markdown
Read `skills/forge-build/PROMPT.md`. Replace placeholders:

- `{{FEATURE_SPEC}}` — the feature entry from spec.json
- `{{DESIGN_BLUEPRINT}}` — Section 7 blueprint for this screen from DESIGN.md
- `{{AGENTS_RULES}}` — extract from AGENTS.md: "Architecture" through "Post-Build Checks" sections (~200 lines)
- `{{PRESET_TOKENS}}` — concrete token values for the selected preset from PresetConfiguration
- `{{SKILL_KNOWLEDGE}}` — if Build iOS Apps skills are installed, extract relevant patterns inline
- `{{SHARED_FILES}}` — current contents of AppRoute.swift, AppServices.swift, and any other shared files the feature will modify
```

With:

```markdown
Read `skills/forge-build/PROMPT.md` (XML template). Load the screen-type fragment:

```bash
# Load fragment — fail fast if missing
FRAGMENT_FILE="skills/forge-build/prompts/${screen_type}.md"
if [ ! -f "$FRAGMENT_FILE" ]; then
  echo "ERROR: No prompt fragment for screen_type '${screen_type}'. Add skills/forge-build/prompts/${screen_type}.md or use a supported screen type."
  # Mark feature as blocked, move to next
fi
```

Replace placeholders (wrap DESIGN_BLUEPRINT, AGENTS_RULES, and SHARED_FILES in fenced code blocks to prevent XML injection):

- `{{FEATURE_SPEC}}` — the feature entry from spec.json
- `{{DESIGN_BLUEPRINT}}` — Section 7 blueprint for this screen from DESIGN.md (wrapped in ``` block)
- `{{AGENTS_RULES}}` — extract from AGENTS.md: "Architecture" through "Post-Build Checks" sections (~200 lines, wrapped in ``` block)
- `{{PRESET_TOKENS}}` — concrete token values for the selected preset from PresetConfiguration
- `{{SHARED_FILES}}` — current contents of AppRoute.swift, AppServices.swift (wrapped in ```swift block)
- `{{SCREEN_TYPE_FRAGMENT}}` — content of the loaded fragment file
```

- [ ] **Step 3: Verify the update**

```bash
grep -c "SCREEN_TYPE_FRAGMENT" skills/forge-app/SKILL.md
grep -c "SKILL_KNOWLEDGE" skills/forge-app/SKILL.md
```

Expected: SCREEN_TYPE_FRAGMENT = 1, SKILL_KNOWLEDGE = 0.

- [ ] **Step 4: Commit**

```bash
git add skills/forge-app/SKILL.md
git commit -m "feat: update forge-app assembly to load screen-type fragments, drop SKILL_KNOWLEDGE"
```

---

### Task 4: Verify everything — cross-reference check

- [ ] **Step 1: Verify placeholder count matches between PROMPT.md and forge-app**

```bash
echo "PROMPT.md placeholders:"
grep -o '{{[A-Z_]*}}' skills/forge-build/PROMPT.md | sort -u

echo "forge-app injection list:"
grep '{{.*}}' skills/forge-app/SKILL.md | grep -o '{{[A-Z_]*}}' | sort -u
```

Expected: same 6 placeholders in both files.

- [ ] **Step 2: Verify screen types match spec.json schema**

```bash
echo "Fragment files:"
ls skills/forge-build/prompts/ | sed 's/.md//'

echo "Schema screen_types:"
grep -A1 "screen_type" skills/forge-app/references/spec-schema.json | grep enum
```

Expected: fragment names match schema enum values (dashboard, detail, list, form, onboarding, paywall, settings).

- [ ] **Step 3: Verify no stale references to old format**

```bash
grep -n "SKILL_KNOWLEDGE" skills/forge-build/PROMPT.md skills/forge-app/SKILL.md
grep -n "## Your Task\|## Design Contract\|## Architecture Rules" skills/forge-build/PROMPT.md
```

Expected: zero matches — old flat-markdown headers and SKILL_KNOWLEDGE should be gone.

- [ ] **Step 4: Build still works**

```bash
xcodebuildmcp simulator build --scheme "Forge - Mock" --project-path ./Forge.xcodeproj --simulator-name "iPhone 17 Pro"
```

Expected: Build succeeded (skill file changes don't affect Swift compilation, but verify nothing broke).

- [ ] **Step 5: Commit any fixes**

```bash
git add skills/
git commit -m "fix: resolve any cross-reference inconsistencies in prompt template"
```

---

## Summary

| Task | Files | What it does |
|------|-------|-------------|
| 1 | `skills/forge-build/PROMPT.md` | Rewrite to XML structure with 8 blocks |
| 2 | `skills/forge-build/prompts/*.md` (7 files) | Create screen-type fragments |
| 3 | `skills/forge-app/SKILL.md` | Update assembly flow for new placeholders |
| 4 | — | Cross-reference verification |

**Total: 4 tasks, 9 files changed.**
