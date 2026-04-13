# DESIGN.md Format Specification

A DESIGN.md is a prescriptive design contract that AI build agents read to produce consistent, non-generic UI. It replaces vague design aspirations ("make it feel clean") with exact tokens, explicit bans, and greppable constraints that LLMs follow reliably.

**Who reads this file:**
- **Orchestrator (forge-app)** — generates a DESIGN.md during Phase 2
- **Visual Design (forge-design)** — informs mockup generation and design DNA extraction
- **Generator (forge-build)** — reads DESIGN.md before writing every screen
- **Judge (forge-judge)** — grades output against DESIGN.md rules

**Key principle:** Constraints beat aspirations. "Don't use StaggeredVStack" works. "Make the entrance feel natural" doesn't. Every rule in a DESIGN.md must be machine-verifiable — greppable in code, visible in screenshots, or checkable against a token list.

---

## Stitch-to-Forge Translation Mapping

awesome-design-md (via `npx getdesign`) produces web-native DESIGN.md files in the **Stitch 9-section format**. forge-design translates these into the **Forge 9-section format** for iOS. The mapping:

| # | Forge Section (Output) | Stitch Section (Input) | Translation |
|---|----------------------|----------------------|-------------|
| 1 | Mood | Visual Theme & Atmosphere | Condense to 2 lines max. Extract mood + reference apps. |
| 2 | Color Palette | Color Palette & Roles | Map hex values to DS semantic tokens. Add light+dark pairs. |
| 3 | Typography | Typography Rules | Map web fonts → SF Pro variants. Map sizes → DS text styles. |
| 4 | Component Rules | Component Stylings | Map web components → DS components with KEEP/COMPOSE/CREATE/SKIP verdicts. |
| 5 | Layout Principles | Layout Principles | Map CSS spacing → DSSpacing tokens. Map border-radius → DSRadii. |
| 6 | Depth & Elevation | Depth & Elevation | Map CSS shadows → DSShadows tokens. Declare elevation strategy. |
| 7 | Do's and Don'ts | Do's and Don'ts | Adapt web patterns to iOS. Make every Don't greppable. |
| 8 | Screen Blueprints | *(no equivalent)* | Forge-native. One blueprint per screen from spec.json. |
| 9 | Voice & Copy | *(no equivalent)* | Forge-native. Every user-facing string. |

**Dropped Stitch sections:**
- "Responsive Behavior" — not relevant for iOS (single device at a time)
- "Agent Prompt Guide" — the entire DESIGN.md IS the agent guide

---

## Section 1: Mood

**Purpose:** Set the emotional target for the entire app in two lines or fewer. The mood anchors every downstream decision — color warmth, typography weight, animation speed, surface depth.

**Format:**

```markdown
## Mood

This app feels like [specific sensory/emotional description — not "clean" or "modern"].
Reference: [1-2 real apps that embody this mood] — take [specific aspect] from each.
```

**Rules:**
- Maximum 2 lines
- Must name a concrete feeling, not an abstract quality ("a calm morning journal" not "minimalist")
- Must name 1-2 reference apps with WHAT to take from each (not "like Notion" but "like Notion — the density and typography confidence")
- The mood statement is the tiebreaker for every design decision downstream

**Example:**

```markdown
## Mood

This app feels like a confident coach's whiteboard — bold data, tight layout, zero decoration.
Reference: Mercury (flat numbers, monospaced confidence), Streaks (single-color discipline).
```

---

## Section 2: Color Palette

**Purpose:** Map every semantic color role to exact hex values (light + dark), the SwiftUI DS token it binds to, and a usage rule that prevents misuse.

**Format:**

```markdown
## Color Palette

| Role | Light | Dark | Token | Usage Rule |
|------|-------|------|-------|------------|
| brand | #RRGGBB | #RRGGBB | Color.themePrimary | Primary actions, active states, brand accent only — never backgrounds |
| background | #RRGGBB | #RRGGBB | Color.backgroundPrimary | Root screen background — all screens |
| ... | ... | ... | ... | ... |
```

**Required roles (11 minimum):**

| Role | Token | Description |
|------|-------|-------------|
| brand | `Color.themePrimary` | Primary brand color — buttons, active indicators, tint |
| background | `Color.backgroundPrimary` | Root screen background |
| surface | `Color.surface` | Card and container fill |
| surfaceVariant | `Color.surfaceVariant` | Secondary container fill, grouped sections |
| textPrimary | `Color.textPrimary` | Headlines, primary body text |
| textSecondary | `Color.textSecondary` | Subtitles, metadata, supporting text |
| textTertiary | `Color.textTertiary` | Timestamps, disabled labels, hints |
| positive | (custom or mapped) | Success states, completion, streaks |
| negative | `Color.error` | Errors, destructive actions, alerts |
| border | `Color.border` | Input field borders, dividers between interactive elements |
| divider | `Color.divider` | Section separators, list dividers |

**Rules:**
- Every role must have BOTH light and dark hex values
- Usage rules must be specific enough to prevent misuse ("never backgrounds" not "use sparingly")
- Additional roles beyond the 11 are encouraged (e.g., `brandSubtle` for tinted backgrounds, `chart1`/`chart2` for data visualization)
- The brand color must appear in fewer than 20% of on-screen pixels — it is an accent, not a wash
- The 11 required roles map directly to DS ColorPalette properties. Additional roles (e.g., brandSubtle, chartIncome) are defined as Color extensions in the app's Theme file, not as ColorPalette properties.

---

## Section 3: Typography

**Purpose:** Bind every DS typography token to a specific font design variant, weight, tracking adjustment, and usage context so all screens share the same type hierarchy.

**Format:**

```markdown
## Typography

| Token | Variant | Weight | Tracking | Usage |
|-------|---------|--------|----------|-------|
| .display() | .rounded | .bold | -0.5 | Hero numbers, main dashboard stat |
| .titleLarge() | .default | .semibold | 0 | Screen titles, section headers |
| ... | ... | ... | ... | ... |
```

**Required tokens (10 minimum):**

| Token | Typical Role |
|-------|-------------|
| `.display()` | Hero numbers, primary dashboard stat, big counts |
| `.titleLarge()` | Screen navigation titles |
| `.titleMedium()` | Section headers within a screen |
| `.titleSmall()` | Card titles, list row primary text |
| `.headlineMedium()` | Emphasized body text, callout labels |
| `.bodyLarge()` | Primary body copy, descriptions |
| `.bodyMedium()` | Standard body text, list row descriptions |
| `.bodySmall()` | Fine print, footnotes, legal text |
| `.captionLarge()` | Timestamps, metadata, secondary labels |
| `.buttonMedium()` | Button text, action labels |

**Variant options:** `.default`, `.rounded`, `.monospaced`, `.serif`

**Rules:**
- Every token must specify a variant — never leave it as "system default"
- Monospaced (`.monospaced`) should be used for numeric data displays (stats, counts, prices) to prevent layout jitter
- Tracking adjustments are optional but recommended for display and title sizes
- Weight must use SwiftUI weight names: `.ultraLight`, `.thin`, `.light`, `.regular`, `.medium`, `.semibold`, `.bold`, `.heavy`, `.black`
- Additional tokens beyond the 10 may be listed (e.g., `.headlineSmall()`, `.buttonSmall()`, `.buttonLarge()`, `.captionSmall()`)
- Tracking values are applied via `.tracking()` modifier in SwiftUI, not as a DS token property. The DS typography tokens (`.display()`, `.titleLarge()`, etc.) set font and weight. Tracking is applied separately in the View.

---

## Section 4: Component Rules

**Purpose:** For every DS component in the Forge template, declare whether to use it as-is (KEEP), customize it with token overrides (COMPOSE), build a replacement from DS tokens (CREATE), or skip it entirely (SKIP). This prevents the generator from defaulting to template components that don't serve the app's mood.

**Format:**

```markdown
## Component Rules

| Component | Verdict | Instructions |
|-----------|---------|-------------|
| DSButton | KEEP | Use for all primary and secondary actions |
| DSHeroCard | CREATE | Too heavy for this mood — build a standalone .display() number on the background instead |
| GlassCard | COMPOSE | Use only for the dashboard hero stat — reduce blur to 8, opacity to 0.6 |
| StaggeredVStack | SKIP | No staggered entrance animations anywhere in this app |
| ... | ... | ... |
```

**Required components (every DS component must appear):**

| Component | What It Does |
|-----------|-------------|
| `DSButton` | Primary action buttons (filled, outlined, text variants) |
| `DSIconButton` | Icon-only buttons (toolbar, inline actions) |
| `DSCard` | Generic content card with border and shadow |
| `DSHeroCard` | Large featured card with gradient or image background |
| `GlassCard` | Frosted glass card with blur effect |
| `DSSection` | Grouped content section with header |
| `DSSegmentedControl` | Tab-like segment selector |
| `DSChoiceButton` | Selection chip / toggle option |
| `DSTextField` | Text input field with label and validation |
| `DSInfoCard` | Informational callout card (tips, announcements) |
| `DSScreen` | Screen wrapper with ambient background |
| `AmbientBackground` | Gradient/particle background layer |
| `StaggeredVStack` | Staggered entrance animation container |
| `EmptyStateView` | Empty state with icon, title, description, CTA |
| `ErrorStateView` | Error state with retry action |
| `ToastView` | Transient notification banner |
| `DSListCard` | List item with card styling |
| `DSListRow` | List item without card styling (flat row) |

**Verdict definitions:**
- **KEEP** — Use this component as the DS provides it. No modifications needed.
- **COMPOSE** — Use this component but with specific token overrides. Instructions MUST list exact parameter changes (blur radius, opacity, padding, color override).
- **CREATE** — Do not use this component. Build a replacement from DS tokens instead. Instructions MUST name the replacement pattern (e.g., "build a flat VStack with .bodyMedium() text instead").
- **SKIP** — Do not use this component anywhere in the app. No replacement needed.

**Rules:**
- Every component in the table above MUST have a row — no omissions
- CREATE verdicts MUST include an explicit replacement — you cannot replace a component without saying what to build instead
- COMPOSE verdicts MUST include specific parameter values — not "reduce the blur" but "blur: 8, opacity: 0.6"
- The generator treats this table as law — if a component is SKIP or CREATE, it must not appear in any screen file

**Empty state note:** AGENTS.md requires ContentUnavailableView for empty states. The EmptyStateView DS component is a wrapper. If EmptyStateView verdict is SKIP, use ContentUnavailableView directly per AGENTS.md rules.

---

## Section 5: Layout Principles

**Purpose:** Define spacing rules using DS spacing tokens. Maximum 5 bullets to keep it scannable.

**Format:**

```markdown
## Layout Principles

- **Screen padding:** DSSpacing.md (16) horizontal, DSSpacing.lg (24) top
- **Section gap:** DSSpacing.lg (24) between sections
- **Card internal padding:** DSSpacing.md (16) all sides
- **List row height:** 56pt minimum, DSSpacing.sm (8) vertical padding
- **Touch target:** 44pt minimum for all interactive elements
```

**Available DS spacing tokens:**

| Token | Value |
|-------|-------|
| `DSSpacing.xs` | 4pt |
| `DSSpacing.sm` | 8pt |
| `DSSpacing.smd` | 12pt |
| `DSSpacing.md` | 16pt |
| `DSSpacing.mlg` | 20pt |
| `DSSpacing.lg` | 24pt |
| `DSSpacing.xl` | 32pt |
| `DSSpacing.xxl` | 40pt |
| `DSSpacing.xxlg` | 48pt |

**Available DS corner radii:**

| Token | Value |
|-------|-------|
| `DSRadii.xs` | 8pt |
| `DSRadii.sm` | 12pt |
| `DSRadii.md` | 12pt |
| `DSRadii.lg` | 16pt |
| `DSRadii.xl` | 20pt |

**Rules:**
- Maximum 5 bullets
- Every bullet must reference a DS spacing token by name AND numeric value
- No custom spacing values — use only DSSpacing tokens
- If the mood calls for tight density, prefer smaller tokens (xs, sm, smd); if airy, prefer larger (lg, xl, xxl)
- See Section 6 for shadow and elevation tokens

---

## Section 6: Depth & Elevation

**Purpose:** Define the shadow and elevation strategy for the app. Maps web reference depth systems (e.g., Revolut's zero-shadow philosophy, Linear's luminance stepping) to DS shadow tokens. Prevents inconsistent elevation across screens.

**Format:**

```markdown
## Depth & Elevation

| Level | Treatment | Token | Use |
|-------|-----------|-------|-----|
| Flat | No shadow | — | Backgrounds, flat lists, resting surfaces |
| Subtle | Soft drop shadow | DSShadows.soft | Resting cards, text inputs |
| Card | Medium elevation | DSShadows.card | Interactive cards, elevated buttons |
| Lifted | High elevation | DSShadows.lifted | Modals, popovers, floating sheets |
```

**Available DS shadow tokens:**

| Token | Effect |
|-------|--------|
| `DSShadows.soft` | Subtle elevation for flat surfaces |
| `DSShadows.card` | Standard card elevation |
| `DSShadows.lifted` | High elevation for modals, popovers |

**Rules:**
- Every app must declare which DSShadows tokens it uses and where
- If the mood is flat (no shadows), explicitly state: "DSShadows: none used — depth through color contrast only"
- Glass/blur effects belong here too — if GlassCard verdict is KEEP or COMPOSE in Section 4, describe the blur treatment (radius, opacity, tint)
- Match the reference app's shadow philosophy:
  - Zero shadows (Revolut, Streaks) → flat surfaces, depth from color contrast
  - Luminance stepping (Linear) → background opacity gradations instead of drop shadows
  - Elevated (Apple Notes, Reminders) → DSShadows.soft for cards, DSShadows.lifted for modals
- The elevation table should list every distinct level used in the app — typically 2-4 levels

---

## Section 7: Do's and Don'ts

**Purpose:** Prescriptive guardrails the generator must follow. Every Don't must be greppable — it names a specific pattern, component, modifier, or string that should not appear in the code.

**Format:**

```markdown
## Do's and Don'ts

### Do's
1. Use .monospaced variant for all numeric displays (stats, counts, streaks)
2. Add .contentTransition(.numericText()) to every number that updates
3. Use DSSpacing.md (16) as the standard horizontal padding
4. Wrap every screen body in DSScreen { AmbientBackground() }

### Don'ts
1. **Don't use StaggeredVStack** — entrance animations should be .move(edge: .bottom) with manual delay
2. **Don't use DSHeroCard** — hero stats are standalone numbers, not cards
3. **Don't use .title font style** — use .titleLarge() DS token instead
4. **Don't hardcode padding values** — always use DSSpacing tokens
5. **Don't use Color.red/green/blue** — use Color.error, positive/negative semantic roles
6. **Don't write generic empty state copy** — every empty state string comes from Section 9
```

**Rules:**
- 4-6 Do's
- 6-10 Don'ts
- Every Don't must name a specific thing to grep for: a component name (`StaggeredVStack`), a modifier (`.font(.title)`), a color literal (`Color.red`), a string pattern (`"No items"`)
- Don'ts are verified by searching the codebase — if the banned pattern appears, the screen fails review
- Do's should reference specific DS tokens, modifiers, or patterns by name
- Avoid vague rules ("Don't make it look generic") — every rule must be machine-checkable

---

## Section 8: Screen Blueprints

**Purpose:** For every screen in the app, define the exact layout structure. This is the single most important section — it tells the generator WHAT to build, not just which tokens to use.

**Format (one subsection per screen):**

```markdown
## Screen Blueprints

### [ScreenName]

**Design Intent:** [WHY this screen exists — what job it does for the user, what emotion it should create. Not anatomy — purpose.]

**Craft Moment:** [The ONE signature detail that makes this screen memorable. Not a list — one specific thing. Must be verifiable in a screenshot.]

**Visual Reference:** [Path to approved mockup: .forge/design-mockups/{screen}-approved.png]

**Hero element:** [The single most prominent element on this screen — what the eye hits first]

**Sections (top to bottom):**
1. [Section name] — [what it contains, which DS component, layout details]
2. [Section name] — [what it contains, which DS component, layout details]
3. [Section name] — [what it contains, which DS component, layout details]

**Empty state:** "[Exact copy from Section 9]" + [CTA button label]

**Entrance animation:** [Specific animation — e.g., ".opacity with 0.3s delay per section" or "none"]

**Don't:**
- [Screen-specific ban — something the generator might try that would be wrong for THIS screen]
```

**Rules:**
- One blueprint per screen in the app
- Hero element is required for primary and detail screens. For utility screens (Settings, About), hero is optional — use "None" if the screen is a flat utility list
- Sections must name specific DS components (DSCard, DSListRow, DSSection, etc.) or explicit replacements if the component is CREATE or SKIP in Section 4
- Empty state copy must match Section 9 exactly — cross-reference, don't invent
- Entrance animation must be specific (modifier name, duration, delay) or explicitly "none"
- Screen-specific Don'ts catch patterns that are fine elsewhere but wrong for this particular screen
- Section order defines visual hierarchy — the generator renders sections in listed order
- Design Intent is required for every screen — it describes purpose and emotion, not layout structure
- Craft Moment must be exactly ONE thing — not a list of 3-4 details. Must be specific enough to verify in a screenshot ("monospaced hero counter with .contentTransition(.numericText())" not "make it feel premium")
- Visual Reference path is required when mockups were generated (Phase 2b). If no mockup exists for this screen, use "None — derived from {closest screen} mockup"

**Example:**

```markdown
### Dashboard

**Design Intent:** This is the app's confidence moment — the user opens and instantly knows their position. It should feel like a calm, authoritative summary, not a cluttered data dump.

**Craft Moment:** The hero number uses .contentTransition(.numericText()) so it animates smoothly when the period changes — the one detail that says "this app was made with care."

**Visual Reference:** .forge/design-mockups/dashboard-approved.png

**Hero element:** Today's completion count — standalone 48pt .display() .monospaced number, left-aligned

**Sections (top to bottom):**
1. Hero stat — Raw number + ".captionLarge() subtitle below, DSSpacing.xs (4) gap
2. Today's habits — Vertical list of DSListRow, each with checkbox toggle and habit name
3. Weekly spark — Inline 7-day bar chart (Swift Charts), 80pt tall, no axes, brand color fill

**Empty state:** "Your first habit starts here" + "Add Habit" button

**Entrance animation:** .opacity per section, 0.15s stagger delay

**Don't:**
- Don't wrap the hero number in any card or container
- Don't use a progress ring — this app uses raw numbers, not circular progress
```

---

## Section 9: Voice & Copy

**Purpose:** Define every user-facing string so the generator never invents copy. This ensures tonal consistency across all screens and states.

**Format:**

```markdown
## Voice & Copy

| Screen | Context | Copy |
|--------|---------|------|
| Dashboard | empty state title | Your first habit starts here |
| Dashboard | empty state description | Tap + to create a daily habit and start building streaks |
| Dashboard | empty state CTA | Add Habit |
| Add Habit | placeholder: name | e.g., Morning run |
| Add Habit | placeholder: reminder | 8:00 AM |
| Stats | empty state title | Nothing to chart yet |
| Stats | empty state description | Complete a few days of habits to see trends |
| Global | error toast | Something broke — try again |
| Global | success toast | Done |
| Global | destructive confirm | Delete this? It's gone forever |
| Onboarding | slide 1 title | Track daily |
| Onboarding | slide 1 body | Simple habits, visible streaks |
| Paywall | headline | Unlock everything |
| Paywall | CTA | Start free trial |
| ... | ... | ... |
```

**Required contexts (every app must have these):**

| Context Category | Minimum Entries |
|-----------------|----------------|
| Empty state (title + description + CTA) | One per screen that can be empty |
| Error toast | At least 1 global |
| Success toast | At least 1 global |
| Button labels | Every primary action across all screens |
| Placeholder text | Every text input field |
| Onboarding slides | Title + body for each slide |
| Paywall | Headline, value props, CTA, terms link text |
| Destructive confirmation | At least 1 global |

**Rules:**
- Every string is final copy — the generator must use it verbatim, not paraphrase
- Copy must match the mood from Section 1 (a "confident coach" app says "Done", not "Great job!")
- No lorem ipsum, no placeholder markers like `[TBD]` or `TODO`
- Empty state descriptions should tell the user what to DO, not what's missing ("Tap + to add" not "No habits found")
- Error copy should be human, not technical ("Something broke" not "Error 500: Internal Server Error")
- Onboarding copy must be short — 3-5 words per title, 1 sentence per body

---

## iOS Platform Constraints (Non-Negotiable)

These constraints apply to EVERY DESIGN.md regardless of mood or app domain. They ensure
the output is native iOS, not web-flavored. The Orchestrator must enforce these when generating,
and the Judge must check them when grading.

### Typography
- **SF Pro is the base font.** Always. No Google Fonts, no web fonts, no custom fonts unless
  the mood specifically calls for a serif display font (and even then, SF Pro for body).
- **Use SF Pro design variants** for personality: `.rounded` (warm), `.monospaced` (precise),
  `.serif` (editorial), `.default` (neutral). These create mood — not custom fonts.
- **Dynamic Type is mandatory.** Use DS typography tokens (`.display()`, `.titleLarge()`, etc.)
  which scale automatically. Never `Font.system(size:)`.
- **SF Pro Display for 20pt+, SF Pro Text for below 20pt.** This is automatic when using
  system fonts, but the Orchestrator should be aware of optical sizing.

### Navigation
- **Use system navigation patterns.** NavigationStack, TabView, .sheet(), .fullScreenCover().
  Never custom navigation chrome that fights the system.
- **iOS 26: system components get Liquid Glass automatically.** Don't apply custom glass
  to tab bars, toolbars, or navigation bars — the system handles it.
- **Tab bars at the bottom.** Never top-aligned tabs (that's Android/web).
- **Back button is system-provided.** Never custom back buttons unless there's a strong reason.

### Layout
- **Safe areas are respected, not fought.** Content flows within safe areas.
  `safeAreaInset(edge:)` for pinned CTAs, not ignoring safe areas.
- **44pt minimum touch targets.** Every interactive element.
- **Standard iOS margins: 16pt horizontal.** Matches system list insets.
- **No hamburger menus.** Use TabView or NavigationSplitView.

### Colors
- **Support both light and dark mode.** Every color in the palette must have both values.
- **Use semantic system colors where appropriate.** `Color.primary`, `Color.secondary`,
  `.systemBackground`, `.secondarySystemBackground` as starting points for neutral surfaces.
- **No pure black (#000000) backgrounds in light mode.** No pure white (#FFFFFF) backgrounds
  in dark mode. Use the system's off-white/off-black values for comfort.

### Components
- **System controls for system behaviors.** Toggle for on/off, Picker for selection,
  DatePicker for dates. Don't rebuild system controls.
- **SF Symbols for icons.** Not custom icon sets, not emoji, not web icon libraries.
- **Confirmation dialogs for destructive actions.** `.confirmationDialog()`, not `Alert`.
- **Context menus for secondary actions.** `.contextMenu()` on long-press, not action sheets
  for every interaction.

### Motion
- **Respect Reduce Motion.** Check `@Environment(\.accessibilityReduceMotion)` and provide
  alternatives for all custom animations.
- **System springs over custom durations.** `.spring()`, `.snappy`, `.bouncy`, `.smooth`
  rather than `.easeInOut(duration: 0.3)`.

### Anti-Patterns (Never iOS-Native)
- Hamburger menus
- Bottom sheets used as primary navigation (web pattern)
- Floating action buttons (Material Design, not iOS)
- Pull-to-refresh on non-scrollable content
- Toast notifications that cover the status bar
- Custom tab bars that don't match system TabView behavior
- Cards with web-style box shadows (use DS shadows which are brand-tinted)

The Judge should check the screenshot for these anti-patterns even if DESIGN.md doesn't
explicitly ban them. They are ALWAYS wrong on iOS.

---

## Validation Checklist

Use this checklist to verify a DESIGN.md is complete and well-formed before the generator reads it.

### Completeness

- [ ] **Mood** exists and is 2 lines or fewer
- [ ] **Mood** names 1-2 reference apps with specific aspects to take from each
- [ ] **Color Palette** has 11+ roles with light AND dark hex values
- [ ] **Color Palette** every role maps to a DS token
- [ ] **Color Palette** every role has a usage rule (not empty)
- [ ] **Typography** has 10+ tokens with variant, weight, tracking, and usage
- [ ] **Typography** no token has an empty variant field
- [ ] **Component Rules** has a row for every 18 DS components listed in the spec
- [ ] **Component Rules** every CREATE verdict includes a replacement pattern
- [ ] **Component Rules** every COMPOSE verdict includes specific parameter values
- [ ] **Layout Principles** has 5 or fewer bullets
- [ ] **Layout Principles** every bullet references a DSSpacing token by name and value
- [ ] **Depth & Elevation** declares which DSShadows tokens are used (or "none used")
- [ ] **Depth & Elevation** glass/blur treatment is documented if GlassCard is KEEP or COMPOSE
- [ ] **Do's** count is 4-6
- [ ] **Don'ts** count is 6-10
- [ ] **Don'ts** every entry names a greppable pattern (component, modifier, color, or string)
- [ ] **Screen Blueprints** exist for every screen in the app
- [ ] **Screen Blueprints** every primary and detail screen has a hero element (utility screens may use "None")
- [ ] **Screen Blueprints** every screen with potential empty state has empty state copy
- [ ] **Screen Blueprints** empty state copy matches Section 9 exactly
- [ ] **Screen Blueprints** every blueprint has a Design Intent (describes purpose/emotion, not layout)
- [ ] **Screen Blueprints** every blueprint has exactly ONE Craft Moment (not a list of details)
- [ ] **Screen Blueprints** every blueprint has a Visual Reference path (or "None — derived from {screen}")
- [ ] **Screen Blueprints** Craft Moments are specific enough to verify in a screenshot
- [ ] **Voice & Copy** covers all required context categories
- [ ] **Voice & Copy** no entry contains placeholder text (TBD, TODO, lorem ipsum)

### Consistency

- [ ] Component verdicts in Section 4 are respected in Section 8 Screen Blueprints (no blueprint uses a SKIP or CREATE component without the replacement)
- [ ] Typography tokens in Section 3 match the tokens referenced in Section 8 blueprints
- [ ] Spacing tokens in Section 5 match the tokens referenced in Section 8 blueprints
- [ ] Shadow tokens in Section 6 match the tokens referenced in Section 8 blueprints
- [ ] Empty state copy in Section 8 matches Section 9 verbatim
- [ ] Mood in Section 1 aligns with color temperature, typography weight, and animation choices
- [ ] Don'ts in Section 7 are not contradicted by instructions in Section 4 or Section 8
- [ ] Visual Reference paths in Section 8 point to files that exist in .forge/design-mockups/

### iOS-Native Compliance

- [ ] Typography uses SF Pro variants only (no custom/web fonts unless mood requires serif display)
- [ ] All typography tokens use DS token API (never Font.system(size:))
- [ ] Color palette has both light AND dark values for every role
- [ ] No pure black (#000000) for light mode backgrounds, no pure white (#FFFFFF) for dark mode backgrounds
- [ ] Navigation uses system patterns (TabView, NavigationStack, .sheet)
- [ ] No hamburger menus, no floating action buttons, no top-aligned tabs
- [ ] SF Symbols specified for all icons (no custom icon sets)
- [ ] Don'ts list includes at least 2 iOS anti-patterns from the Platform Constraints section
- [ ] Motion uses system springs (.spring, .snappy, .bouncy, .smooth), not custom durations

### Machine-Verifiability

- [ ] Every Don't can be checked with a code search (grep, ripgrep)
- [ ] Every color value is a valid 6-digit hex code
- [ ] Every typography weight is a valid SwiftUI Font.Weight name
- [ ] Every spacing reference uses a valid DSSpacing token name
- [ ] Every component name matches the exact DS component name (case-sensitive)
