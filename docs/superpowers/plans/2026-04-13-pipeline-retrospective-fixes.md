# Pipeline Retrospective Fixes — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the Forge pipeline's 22 retrospective failures across 6 themes so it produces crafted, non-generic iOS apps instead of reskinned templates.

**Architecture:** Two atomic batches. Batch A (Tasks 1-6) rewrites DS infrastructure and design format. Batch B (Tasks 7-13) rewrites the judge, builder, and orchestrator. Batch A must complete before Batch B starts.

**Tech Stack:** Swift (DesignSystem package), Markdown (skill files)

**Spec:** `docs/superpowers/specs/2026-04-13-pipeline-retrospective-fixes-design.md`

---

# Batch A: Foundation (Themes 1 + 2)

---

### Task 1: ColorStory struct + AdaptiveTheme rewrite

**Files:**
- Create: `Packages/core-packages/DesignSystem/Sources/DesignSystem/Theme/ColorStory.swift`
- Modify: `Packages/core-packages/DesignSystem/Sources/DesignSystem/Theme/AdaptiveTheme.swift`

- [ ] **Step 1: Create ColorStory.swift**

```swift
import SwiftUI

/// Defines the color story for an app — the intentional palette beyond a single brand color.
///
/// `brand` and `surface` are required. `contrast` and `surprise` are optional:
/// - `contrast`: Required for data viz / multi-color references. Derived from `brand` if nil.
/// - `surprise`: Used sparingly for craft moments. Omit for single-accent apps.
public struct ColorStory: Sendable {
    public let brand: Color
    public let contrast: Color
    public let surprise: Color?
    public let surface: Color

    public init(
        brand: Color,
        contrast: Color? = nil,
        surprise: Color? = nil,
        surface: Color
    ) {
        self.brand = brand
        // Naive fallback — specify explicit contrast for muted or desaturated brand colors
        self.contrast = contrast ?? brand.opacity(0.7)
        self.surprise = surprise
        self.surface = surface
    }
}
```

- [ ] **Step 2: Rewrite AdaptiveTheme.swift**

Replace the entire file:

```swift
import SwiftUI

/// Adaptive theme that derives all design tokens from a ColorStory.
///
/// Usage:
///   let story = ColorStory(brand: .indigo, contrast: .teal, surface: Color(hex: "F4F3F1"))
///   DesignSystem.configure(theme: AdaptiveTheme(colorStory: story))
///
public struct AdaptiveTheme: Theme, Sendable {
    public let tokens: DesignTokens

    public init(
        colorStory: ColorStory = ColorStory(
            brand: Color(light: Color(hex: "6B3FA0"), dark: Color(hex: "8B5CF6")),
            surface: Color(light: Color(hex: "F4F3F1"), dark: Color(hex: "161618"))
        ),
        preset: PresetConfiguration = .default
    ) {
        // TODO: Derive text colors from surface luminance (currently hardcoded)
        let colors = ColorPalette(
            primary: colorStory.brand,
            secondary: colorStory.contrast,
            accent: colorStory.surprise ?? colorStory.brand,
            success: Color(light: Color(hex: "34C759"), dark: Color(hex: "30D158")),
            warning: Color(light: Color(hex: "FF9500"), dark: Color(hex: "FF9F0A")),
            error: Color(light: Color(hex: "FF3B30"), dark: Color(hex: "FF453A")),
            info: colorStory.contrast,
            backgroundPrimary: Color(light: Color(hex: "FAFAFA"), dark: Color(hex: "0A0A0C")),
            backgroundSecondary: colorStory.surface,
            backgroundTertiary: Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "1E1E22")),
            textPrimary: Color(light: Color(hex: "000000"), dark: Color(hex: "FFFFFF")),
            textSecondary: Color(light: Color(hex: "3C3C43").opacity(0.6), dark: Color(hex: "EBEBF5").opacity(0.6)),
            textTertiary: Color(light: Color(hex: "3C3C43").opacity(0.3), dark: Color(hex: "EBEBF5").opacity(0.3)),
            textOnPrimary: Color.white,
            surface: Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "1A1A1E")),
            surfaceVariant: colorStory.surface,
            border: Color(light: Color(hex: "3C3C43").opacity(0.29), dark: Color(hex: "545458").opacity(0.65)),
            divider: Color(light: Color(hex: "3C3C43").opacity(0.18), dark: Color(hex: "545458").opacity(0.45))
        )

        let headingWeight: Font.Weight = preset.weight == .heavy ? .bold : .semibold
        let displayWeight: Font.Weight = preset.weight == .heavy ? .black : .bold

        let typography = TypographyScale(
            display:        TextStyle(size: 34, weight: displayWeight, design: .rounded),
            titleLarge:     TextStyle(size: 28, weight: headingWeight, design: .rounded),
            titleMedium:    TextStyle(size: 22, weight: headingWeight, design: .rounded),
            titleSmall:     TextStyle(size: 20, weight: headingWeight, design: .default),
            headlineLarge:  TextStyle(size: 17, weight: headingWeight, design: .default),
            headlineMedium: TextStyle(size: 15, weight: headingWeight, design: .default),
            headlineSmall:  TextStyle(size: 13, weight: headingWeight, design: .default),
            bodyLarge:      TextStyle(size: 17, weight: .regular,      design: .default),
            bodyMedium:     TextStyle(size: 15, weight: .regular,      design: .default),
            bodySmall:      TextStyle(size: 13, weight: .regular,      design: .default),
            captionLarge:   TextStyle(size: 12, weight: .regular,      design: .default),
            captionSmall:   TextStyle(size: 11, weight: .regular,      design: .default),
            buttonLarge:    TextStyle(size: 17, weight: headingWeight,  design: .default),
            buttonMedium:   TextStyle(size: 15, weight: headingWeight,  design: .default),
            buttonSmall:    TextStyle(size: 13, weight: headingWeight,  design: .default)
        )

        let spacing: SpacingScale = switch preset.spacing {
        case .tight:
            SpacingScale(xs: 4, sm: 4, smd: 8, md: 12, mlg: 16, lg: 20, xl: 24, xxlg: 32, xxl: 40)
        case .balanced:
            ThemeFactory.spacing()
        case .airy:
            SpacingScale(xs: 8, sm: 12, smd: 16, md: 24, mlg: 28, lg: 32, xl: 40, xxlg: 52, xxl: 64)
        }

        let radii: RadiiScale = switch preset.corners {
        case .sharp:
            RadiiScale(xs: 4, sm: 8, md: 8, lg: 12, xl: 16, pill: 999)
        case .mixed:
            RadiiScale(xs: 8, sm: 12, md: 16, lg: 20, xl: 28, pill: 999)
        case .rounded:
            RadiiScale(xs: 12, sm: 16, md: 20, lg: 28, xl: 36, pill: 999)
        }

        // Shadows tinted with brand color for warmth
        let shadows: ShadowScale = switch preset.surface {
        case .flat:
            ShadowScale(
                soft:   ShadowToken(color: .clear, radius: 0, y: 0),
                card:   ShadowToken(color: .clear, radius: 0, y: 0),
                lifted: ShadowToken(color: .clear, radius: 0, y: 0)
            )
        case .elevated, .glass:
            ShadowScale(
                soft:   ShadowToken(color: colorStory.brand.opacity(0.06), radius: 8,  y: 3),
                card:   ShadowToken(color: colorStory.brand.opacity(0.08), radius: 10, y: 5),
                lifted: ShadowToken(color: colorStory.brand.opacity(0.14), radius: 20, y: 8)
            )
        }

        let glass = GlassTokens(
            tint:       Color.white.opacity(0.10),
            strongTint: Color.white.opacity(0.18),
            border:     Color.white.opacity(0.40),
            shadow:     ShadowToken(color: .black.opacity(0.08), radius: 10, y: 4)
        )

        self.tokens = DesignTokens(
            colors: colors,
            typography: typography,
            spacing: spacing,
            radii: radii,
            shadows: shadows,
            glass: glass,
            layout: ThemeFactory.layout()
        )
    }
}
```

- [ ] **Step 3: Do NOT commit yet**

The codebase won't compile until callsites are updated in Task 2. Task 1 and Task 2 share a single atomic commit at the end of Task 2 to avoid a broken intermediate state.

---

### Task 2: Update all callsites + tests

**Files:**
- Modify: `Forge/App/AppDelegate.swift:20-22`
- Modify: `Packages/core-packages/DesignSystem/Sources/DesignSystem/DesignSystem.swift:12,77,111`
- Modify: `Packages/core-packages/DesignSystem/Tests/DesignSystemTests/PresetConfigurationTests.swift`
- Modify: `Packages/core-packages/DesignSystem/Tests/DesignSystemTests/DesignSystemTests.swift:43`
- Modify: `skills/forge-workspace/SKILL.md:77,125,229`
- Modify: `README.md:120`

- [ ] **Step 1: Update AppDelegate.swift**

Replace lines 20-22:

```swift
        // Configure brand: AdaptiveTheme(colorStory: ColorStory(brand: .blue, surface: Color(hex: "F5F5F5")))
        // See ColorStory.swift for full palette options (contrast, surprise)
        DesignSystem.configure(theme: AdaptiveTheme())
```

- [ ] **Step 2: Update DesignSystem.swift defaults**

In `DesignSystem.swift`, replace all 3 occurrences of `AdaptiveTheme()` — these are default fallbacks that already use the default `colorStory` parameter, so the call stays `AdaptiveTheme()` but verify the parameter name changed. No code change needed if the default parameter works. Verify:

Run: `grep -n "AdaptiveTheme()" Packages/core-packages/DesignSystem/Sources/DesignSystem/DesignSystem.swift`

Expected: Lines 12, 77, 111 all show `AdaptiveTheme()` — these use the default `colorStory` parameter, no change needed.

- [ ] **Step 3: Update PresetConfigurationTests.swift**

Replace every `brandColor: .blue` with `colorStory: ColorStory(brand: .blue, surface: .gray)` and `AdaptiveTheme(brandColor: .blue)` with `AdaptiveTheme(colorStory: ColorStory(brand: .blue, surface: .gray))`:

```swift
import XCTest
@testable import DesignSystem
import SwiftUI

final class PresetConfigurationTests: XCTestCase {

    private let testStory = ColorStory(brand: .blue, surface: .gray)

    // MARK: - Default Preset

    func testDefaultPresetProducesStandardTokenValues() {
        let theme = AdaptiveTheme(colorStory: testStory, preset: .default)
        let tokens = theme.tokens

        XCTAssertEqual(tokens.spacing.xs, 4)
        XCTAssertEqual(tokens.spacing.sm, 8)
        XCTAssertEqual(tokens.spacing.md, 16)
        XCTAssertEqual(tokens.spacing.lg, 24)
        XCTAssertEqual(tokens.spacing.xl, 32)
        XCTAssertEqual(tokens.spacing.xxlg, 40)
        XCTAssertEqual(tokens.spacing.xxl, 52)

        XCTAssertEqual(tokens.radii.xs, 8)
        XCTAssertEqual(tokens.radii.sm, 12)
        XCTAssertEqual(tokens.radii.md, 16)
        XCTAssertEqual(tokens.radii.lg, 20)
        XCTAssertEqual(tokens.radii.xl, 28)
        XCTAssertEqual(tokens.radii.pill, 999)
    }

    // MARK: - Spacing Axis

    func testTightSpacingUsesSmallerScale() {
        let theme = AdaptiveTheme(
            colorStory: testStory,
            preset: PresetConfiguration(spacing: .tight)
        )

        XCTAssertEqual(theme.tokens.spacing.md, 12)
        XCTAssertEqual(theme.tokens.spacing.lg, 20)
        XCTAssertLessThan(theme.tokens.spacing.md, 16)
    }

    func testAirySpacingUsesLargerScale() {
        let theme = AdaptiveTheme(
            colorStory: testStory,
            preset: PresetConfiguration(spacing: .airy)
        )

        XCTAssertEqual(theme.tokens.spacing.md, 24)
        XCTAssertEqual(theme.tokens.spacing.lg, 32)
        XCTAssertGreaterThan(theme.tokens.spacing.md, 16)
    }

    // MARK: - Corner Radius Axis

    func testSharpCornersUseSmallerRadii() {
        let theme = AdaptiveTheme(
            colorStory: testStory,
            preset: PresetConfiguration(corners: .sharp)
        )

        XCTAssertEqual(theme.tokens.radii.md, 8)
        XCTAssertEqual(theme.tokens.radii.xl, 16)
    }

    func testRoundedCornersUseLargerRadii() {
        let theme = AdaptiveTheme(
            colorStory: testStory,
            preset: PresetConfiguration(corners: .rounded)
        )

        XCTAssertEqual(theme.tokens.radii.md, 20)
        XCTAssertEqual(theme.tokens.radii.xl, 36)
    }

    // MARK: - Surface Treatment Axis

    func testFlatSurfaceZeroesAllShadowRadii() {
        let theme = AdaptiveTheme(
            colorStory: testStory,
            preset: PresetConfiguration(surface: .flat)
        )

        XCTAssertEqual(theme.tokens.shadows.soft.radius, 0)
        XCTAssertEqual(theme.tokens.shadows.card.radius, 0)
        XCTAssertEqual(theme.tokens.shadows.lifted.radius, 0)
    }

    func testElevatedSurfaceHasNonZeroShadows() {
        let theme = AdaptiveTheme(
            colorStory: testStory,
            preset: PresetConfiguration(surface: .elevated)
        )

        XCTAssertGreaterThan(theme.tokens.shadows.soft.radius, 0)
        XCTAssertGreaterThan(theme.tokens.shadows.card.radius, 0)
        XCTAssertGreaterThan(theme.tokens.shadows.lifted.radius, 0)
    }

    // MARK: - Typography Weight Axis

    func testHeavyWeightUsesBolderHeadings() {
        let heavy = AdaptiveTheme(
            colorStory: testStory,
            preset: PresetConfiguration(weight: .heavy)
        )
        let light = AdaptiveTheme(
            colorStory: testStory,
            preset: PresetConfiguration(weight: .light)
        )

        XCTAssertEqual(heavy.tokens.typography.display.weight, .black)
        XCTAssertEqual(light.tokens.typography.display.weight, .bold)
        XCTAssertEqual(heavy.tokens.typography.titleLarge.weight, .bold)
        XCTAssertEqual(light.tokens.typography.titleLarge.weight, .semibold)
    }

    // MARK: - Named Presets

    func testNamedPresetsHaveExpectedAxisValues() {
        XCTAssertEqual(PresetConfiguration.linear.spacing, .tight)
        XCTAssertEqual(PresetConfiguration.linear.corners, .sharp)
        XCTAssertEqual(PresetConfiguration.linear.weight, .heavy)
        XCTAssertEqual(PresetConfiguration.linear.surface, .flat)

        XCTAssertEqual(PresetConfiguration.airbnb.spacing, .airy)
        XCTAssertEqual(PresetConfiguration.airbnb.corners, .rounded)

        XCTAssertEqual(PresetConfiguration.stripe.surface, .flat)
        XCTAssertEqual(PresetConfiguration.apple.surface, .glass)
    }

    // MARK: - ColorStory

    /// Helper: compare two Colors by resolving to RGBA components
    private func assertColorsEqual(_ a: Color, _ b: Color, file: StaticString = #file, line: UInt = #line) {
        let env = EnvironmentValues()
        let ra = a.resolve(in: env)
        let rb = b.resolve(in: env)
        XCTAssertEqual(ra.red, rb.red, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(ra.green, rb.green, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(ra.blue, rb.blue, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(ra.opacity, rb.opacity, accuracy: 0.01, file: file, line: line)
    }

    func testColorStoryDerivation() {
        let story = ColorStory(brand: .blue, contrast: .green, surprise: .orange, surface: .gray)
        let theme = AdaptiveTheme(colorStory: story, preset: .default)
        let colors = theme.tokens.colors

        // brand → primary
        assertColorsEqual(colors.primary, .blue)
        // contrast → secondary, info
        assertColorsEqual(colors.secondary, .green)
        assertColorsEqual(colors.info, .green)
        // surprise → accent
        assertColorsEqual(colors.accent, .orange)
        // surface → surfaceVariant, backgroundSecondary
        assertColorsEqual(colors.surfaceVariant, .gray)
        assertColorsEqual(colors.backgroundSecondary, .gray)
    }

    func testColorStoryWithoutOptionals() {
        let story = ColorStory(brand: .blue, surface: .gray)
        let theme = AdaptiveTheme(colorStory: story, preset: .default)
        let colors = theme.tokens.colors

        // surprise not provided → accent falls back to brand
        assertColorsEqual(colors.primary, .blue)
        assertColorsEqual(colors.accent, .blue)
        // contrast not provided → derived as brand.opacity(0.7)
        // Verify secondary is different from primary (derived, not identical)
        let env = EnvironmentValues()
        let primaryResolved = colors.primary.resolve(in: env)
        let secondaryResolved = colors.secondary.resolve(in: env)
        XCTAssertEqual(secondaryResolved.opacity, 0.7, accuracy: 0.05,
                       "Derived contrast should have ~0.7 opacity")
        XCTAssertNotEqual(primaryResolved.opacity, secondaryResolved.opacity,
                          "Derived contrast should differ from brand")
    }

    func testInitWithoutColorStoryMatchesDefault() {
        let withoutStory = AdaptiveTheme()
        let withDefault = AdaptiveTheme(preset: .default)

        XCTAssertEqual(withoutStory.tokens.spacing.md, withDefault.tokens.spacing.md)
        XCTAssertEqual(withoutStory.tokens.radii.md, withDefault.tokens.radii.md)
        XCTAssertEqual(withoutStory.tokens.shadows.card.radius, withDefault.tokens.shadows.card.radius)
    }
}
```

- [ ] **Step 4: Update DesignSystemTests.swift line 43**

Replace:
```swift
DesignSystem.reconfigureForDebug(theme: AdaptiveTheme(brandColor: .blue))
```
With:
```swift
DesignSystem.reconfigureForDebug(theme: AdaptiveTheme(colorStory: ColorStory(brand: .blue, surface: .gray)))
```

- [ ] **Step 5: Update forge-workspace/SKILL.md**

Replace all 3 occurrences of:
```
DesignSystem.configure(theme: AdaptiveTheme(brandColor: .{color}))
```
With:
```
DesignSystem.configure(theme: AdaptiveTheme(colorStory: ColorStory(brand: .{color}, surface: Color(hex: "{surface_hex}"))))
```

- [ ] **Step 6: Update README.md line 120**

Replace:
```
DesignSystem.configure(theme: AdaptiveTheme(brandColor: .indigo))
```
With:
```
DesignSystem.configure(theme: AdaptiveTheme(colorStory: ColorStory(brand: .indigo, contrast: .teal, surface: Color(hex: "F4F3F1"))))
```

- [ ] **Step 7: Run tests**

Run: `cd /Users/matvii/Developer/Personal/forge && swift test --package-path Packages/core-packages/DesignSystem 2>&1 | tail -20`

Expected: All tests pass.

- [ ] **Step 8: Commit (atomic — includes Task 1 + Task 2)**

```bash
cd /Users/matvii/Developer/Personal/forge
git add Packages/core-packages/DesignSystem/ Forge/App/AppDelegate.swift skills/forge-workspace/SKILL.md README.md
git commit -m "feat(ds): replace brandColor with ColorStory across entire DS

Create ColorStory struct (brand, contrast, surprise, surface). Rewrite
AdaptiveTheme to derive all tokens from ColorStory. Update all callsites
(AppDelegate, DesignSystem defaults, forge-workspace, README) and tests.
Add ColorStory derivation tests."
```

---

### Task 3: design-md-format.md — Section 1 (Mood → Design North Star)

**Files:**
- Modify: `skills/forge-app/references/design-md-format.md:37-65`

- [ ] **Step 1: Rewrite Section 1**

Replace the entire Section 1 block (from `## Section 1: Mood` through the `---` before Section 2) with:

```markdown
## Section 1: Design North Star

**Purpose:** Set the emotional target for the entire app. The North Star anchors every downstream decision — color warmth, typography weight, animation speed, surface depth. This section is the tiebreaker for every design decision.

**Format:**

~~~markdown
## Design North Star

**Mood:** [One sentence — a specific sensory/emotional description, not "clean" or "modern"]

**Visual Feel:**
[3-5 sentences describing the EXPERIENCE of using the app, not the anatomy. How does it feel to open? What's the emotional arc of a session? What does the user feel when they close it? This paragraph is included in every Codex build prompt — it's the prose target that gives builders a design north star beyond token compliance.]

**Reference:** [1-2 real apps] — take [specific aspect] from each.

**Anti-references:** This app is NOT [2-3 things it could be mistaken for]. [Why each would be wrong.]
~~~

**Rules:**
- The Mood sentence must name a concrete feeling, not an abstract quality ("a calm morning journal" not "minimalist")
- The Visual Feel paragraph describes experience, not anatomy. "Opening this app feels like checking the weather — one number, instant confidence, close" not "The dashboard has a chart and three stat cards."
- Anti-references prevent builders from drifting toward adjacent genres. A finance tracker is NOT a banking app, NOT a stock trading terminal.
- References must name 1-2 apps with WHAT to take from each (not "like Notion" but "like Notion — the density and typography confidence")
- The Visual Feel paragraph is injected into every Codex build prompt via the `{{VISUAL_FEEL}}` placeholder

**Example:**

~~~markdown
## Design North Star

**Mood:** This app feels like a confident coach's whiteboard — bold data, tight layout, zero decoration.

**Visual Feel:**
Opening Drift feels like checking the weather — you glance, see one number, and close. The trend line dominates your attention. Stats are whispered below, not shouted. You never scroll on the main screen. The whole experience is 3 seconds of calm confidence: "I'm on track" or "I need to adjust." There is no dashboard — there is one answer.

**Reference:** Mercury (flat numbers, monospaced confidence), Streaks (single-color discipline).

**Anti-references:** This is NOT a health dashboard (no grids of colored cards), NOT a banking app (no transaction lists), NOT an analytics tool (no multiple charts or date pickers).
~~~
```

- [ ] **Step 2: Verify**

Run: `grep -c "Design North Star" skills/forge-app/references/design-md-format.md`

Expected: At least 2 (section header + table reference)

- [ ] **Step 3: Update the Stitch-to-Forge translation table**

In the same file, update the Section 1 row in the mapping table (around line 21):

Replace:
```
| 1 | Mood | Visual Theme & Atmosphere | Condense to 2 lines max. Extract mood + reference apps. |
```
With:
```
| 1 | Design North Star | Visual Theme & Atmosphere | Extract mood sentence, write 3-5 sentence Visual Feel paragraph, add anti-references. |
```

- [ ] **Step 4: Update the Validation Checklist**

Replace the mood checklist items:
```
- [ ] **Mood** exists and is 2 lines or fewer
- [ ] **Mood** names 1-2 reference apps with specific aspects to take from each
```
With:
```
- [ ] **Design North Star** has a Mood sentence (one line, concrete feeling)
- [ ] **Design North Star** has a Visual Feel paragraph (3-5 sentences, experience not anatomy)
- [ ] **Design North Star** has Anti-references (2-3 things the app is NOT)
- [ ] **Design North Star** names 1-2 reference apps with specific aspects to take from each
```

- [ ] **Step 5: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-app/references/design-md-format.md
git commit -m "feat(design): expand Section 1 Mood to Design North Star

Add Visual Feel paragraph (3-5 sentences of experience, not anatomy)
and Anti-references. Visual Feel is injected into Codex prompts via
VISUAL_FEEL placeholder."
```

---

### Task 4: design-md-format.md — Section 2 (Color Palette → ColorStory)

**Files:**
- Modify: `skills/forge-app/references/design-md-format.md:67-106`

- [ ] **Step 1: Rewrite Section 2 format**

Replace the Section 2 Color Palette format block with:

~~~markdown
## Section 2: Color Palette

**Purpose:** Define the app's ColorStory — the intentional palette that drives AdaptiveTheme. Map every semantic color role to exact hex values (light + dark) and a usage rule.

**Format:**

```markdown
## Color Palette

### ColorStory

| Role | Light | Dark | Usage Rule |
|------|-------|------|------------|
| brand | #RRGGBB | #RRGGBB | Primary actions, active states, brand accent — buttons, tint, tab bar icons |
| contrast | #RRGGBB | #RRGGBB | Charts, badges, data viz highlights, secondary actions |
| surprise | #RRGGBB | #RRGGBB | Craft moment highlights only — one per screen, <1% of pixels. Use "None" if omitted. |
| surface | #RRGGBB | #RRGGBB | Card fills, secondary backgrounds, surface tint |

**Color Distribution:** Brand ~15% of pixels. Contrast ~5%. Surprise <1%. Surface fills the rest.

### Semantic Roles (derived from ColorStory)

| Role | Token | Derives From | Usage Rule |
|------|-------|-------------|------------|
| primary | Color.themePrimary | brand | Primary actions, active states |
| secondary | Color.secondary | contrast | Charts, badges, info states |
| accent | Color.accent | surprise (or brand if no surprise) | Craft moments only |
| ... | ... | ... | ... |
```

**Required ColorStory fields:**
- `brand` — required. The single most recognizable color of the app.
- `surface` — required. Background tint for cards and secondary surfaces.
- `contrast` — required for apps with data visualization or multi-color references. Use "Derived from brand" for minimal 2-color apps.
- `surprise` — optional. The craft detail color. Use "None" for single-accent apps.

**Rules:**
- Every field must have BOTH light and dark hex values
- Color Distribution is aspirational guidance — used by the judge's Vibe Check, not validated by pipeline
- The brand color must appear in fewer than 20% of on-screen pixels — it is an accent, not a wash
- Semantic roles derive from the ColorStory via AdaptiveTheme's derivation mapping. Only list overrides where the derivation doesn't match the reference.
- Apps with rich data viz (6+ colors) define additional chart colors as Color extensions beyond the story
~~~

- [ ] **Step 2: Update the Validation Checklist**

Replace the color palette checklist items with:

```markdown
- [ ] **Color Palette** has a ColorStory table with brand and surface (required), contrast and surprise (optional)
- [ ] **Color Palette** every ColorStory field has BOTH light and dark hex values
- [ ] **Color Palette** has a Color Distribution line
- [ ] **Color Palette** semantic roles table shows derivation from ColorStory fields
- [ ] **Color Palette** every override has a usage rule explaining why the derivation doesn't work
```

- [ ] **Step 3: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-app/references/design-md-format.md
git commit -m "feat(design): replace brandColor with ColorStory in Section 2

Color Palette now defines brand/contrast/surprise/surface with derivation
mapping to semantic roles. Adds Color Distribution guidance."
```

---

### Task 5: design-md-format.md — Section 8 (Blueprint additions)

**Files:**
- Modify: `skills/forge-app/references/design-md-format.md:329-397`

- [ ] **Step 1: Add Visual Feel, Hierarchy, and Density target to blueprint format**

In the Section 8 format block, add three new fields after Craft Moment:

```markdown
**Visual Feel:** [2-3 sentences describing how this specific screen FEELS to use. Not the layout — the experience. This is injected into the Codex build prompt alongside the Design North Star.]

**Hierarchy:**
- **Primary (60%+ visual weight):** [The ONE element that dominates — what the eye hits first, what takes most of the screen]
- **Secondary (supporting):** [Elements that support the primary — visible but subordinate]
- **Tertiary (discoverable):** [Elements below the fold or visually minimized — available but not competing]

**Density target:** [How much content appears above the fold. "1 dominant element" or "dense workspace with 3 data panels" or "single scrollable list"]
```

- [ ] **Step 2: Update the blueprint example**

Update the Dashboard example to include the new fields:

```markdown
### Dashboard

**Design Intent:** This is the app's confidence moment — the user opens and instantly knows their position. It should feel like a calm, authoritative summary, not a cluttered data dump.

**Craft Moment:** The hero number uses .contentTransition(.numericText()) so it animates smoothly when the period changes — the one detail that says "this app was made with care."

**Visual Feel:** Opening the Dashboard feels like checking your watch — one glance, one answer, done. The number fills your vision. The small text below is comfort, not information. You never need to scroll.

**Hierarchy:**
- **Primary (60%+ visual weight):** Today's completion count — standalone 48pt .display() .monospaced number
- **Secondary (supporting):** Caption subtitle below the number, weekly spark chart (80pt, no axes)
- **Tertiary (discoverable):** Today's habit list (scrolls into view below the fold)

**Density target:** 1 dominant element above the fold. Everything else scrolls.

**Visual Reference:** .forge/design-mockups/dashboard-approved.png

**Hero element:** Today's completion count — standalone 48pt .display() .monospaced number, left-aligned

**Sections (top to bottom):**
1. Hero stat — Raw number + .captionLarge() subtitle below, DSSpacing.xs (4) gap
2. Today's habits — Vertical list of DSListRow, each with checkbox toggle and habit name
3. Weekly spark — Inline 7-day bar chart (Swift Charts), 80pt tall, no axes, brand color fill

**Empty state:** "Your first habit starts here" + "Add Habit" button

**Entrance animation:** .opacity per section, 0.15s stagger delay

**Don't:**
- Don't wrap the hero number in any card or container
- Don't use a progress ring — this app uses raw numbers, not circular progress
```

- [ ] **Step 3: Update Visual Reference to conditional**

Find the rule about Visual Reference in the Section 8 rules and replace:

```
- Visual Reference path is required when mockups were generated (Phase 2b). If no mockup exists for this screen, use "None — derived from {closest screen} mockup"
```

This should remain as-is (it was already corrected during the adversarial review).

- [ ] **Step 4: Fix radii table in Section 5**

The existing Section 5 radii table has incorrect values that don't match the code. Find the "Available DS corner radii" table and replace it with values matching the actual `.mixed` preset defaults:

```markdown
| Token | Value |
|-------|-------|
| `DSRadii.xs` | 8pt |
| `DSRadii.sm` | 12pt |
| `DSRadii.md` | 16pt |
| `DSRadii.lg` | 20pt |
| `DSRadii.xl` | 28pt |
```

- [ ] **Step 5: Update the Validation Checklist**

Add after the existing blueprint checklist items:

```markdown
- [ ] **Screen Blueprints** every blueprint has a Visual Feel paragraph (2-3 sentences, experience not layout)
- [ ] **Screen Blueprints** every blueprint has a Hierarchy with Primary/Secondary/Tertiary elements
- [ ] **Screen Blueprints** every blueprint has a Density target
- [ ] **Screen Blueprints** Primary element in Hierarchy matches the Hero element field
```

- [ ] **Step 6: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-app/references/design-md-format.md
git commit -m "feat(design): add Visual Feel, Hierarchy, Density to blueprints; fix radii table

Each blueprint now encodes experience (Visual Feel), visual weight
distribution (Hierarchy: primary/secondary/tertiary), and content
density (Density target). Prevents flat section lists."
```

---

### Task 6: forge-design/SKILL.md — Complete rewrite

**Files:**
- Modify: `skills/forge-design/SKILL.md`

- [ ] **Step 1: Rewrite the entire file**

Replace `skills/forge-design/SKILL.md` with:

```markdown
---
name: forge-design
description: "Translates design references (awesome-design-md, user screenshots, preset axes) into an iOS-native DESIGN.md contract."
model: opus
---

# forge-design — Reference → DESIGN.md Translator

You translate design references into an iOS-native DESIGN.md contract for the Forge template.

No live browsing. No mockup generation. Pure translation from inputs already collected.

## Inputs

Read from `.forge/references/`:
- `index.md` — which references are selected, how they combine, any axis overrides
- `*.md` — awesome-design-md files (web-native DESIGN.md format, CSS values)
- `screenshots/*.png` / `*.jpg` — reference app screenshots (describe what you see, extract feel)

Read from `docs/design-reference/presets.md`:
- Preset axis values selected during Phase 1

Read from `.forge/spec.json`:
- Feature list, screen types, navigation structure, pitch

## Translation Rules

### ColorStory (web → iOS)

Analyze the reference apps' color DISTRIBUTION — don't just extract hex values:
1. Which color dominates? → `brand`
2. Which provides contrast/accent? → `contrast`
3. Which surprises or delights? → `surprise` (optional)
4. Which tints surfaces and backgrounds? → `surface`

Map to ColorStory:
- Reference primary/brand color → `brand` (buttons, active states, tint)
- Reference accent/CTA color → `contrast` (charts, badges, data viz)
- Reference highlight/special color → `surprise` (craft moments only — omit if reference uses ≤2 colors)
- Reference background tint → `surface` (cards, secondary backgrounds)

If reference uses only 2 colors (e.g., Things 3): set `contrast` to "Derived from brand" and `surprise` to "None".

Semantic roles (textPrimary, border, divider, error) derive automatically from the ColorStory via AdaptiveTheme. Only specify overrides where the reference demands a color the derivation can't produce.

### Typography (web → iOS)
- Map font families → DS design variants: `.default` (San Francisco), `.rounded`, `.monospaced`, `.serif`
- Map font weights → DS text styles: `.display()`, `.titleLarge()`, `.bodyMedium()`, etc.
- Map font sizes → closest DS text style (don't invent new sizes)
- Weight axis from presets: heavy = use `.semibold`/`.bold` for headings; light = use `.regular`/`.medium`

### Spacing (web → iOS)
- Map CSS spacing values to closest DS spacing token: `DSSpacing.xs` (4), `.sm` (8), `.smd` (12), `.md` (16), `.mlg` (20), `.lg` (24), `.xl` (32), `.xxlg` (40), `.xxl` (52)
- Rhythm axis from presets: tight = prefer xs/sm/md; airy = prefer md/lg/xl
- Never invent spacing values — always use DS tokens

### Components (web → iOS)
- Web buttons → DSButton (sizes: .small, .medium, .large; styles: .primary, .secondary, .ghost)
- Web cards → DSCard or DSListRow (depending on content type)
- Web inputs → DSTextField
- Web navigation → AppRoute/AppSheet/AppTab (never hamburger menus)
- Web modals → .sheet() presentations
- Surface axis from presets: flat = no shadows; elevated = DSShadows.soft/card/lifted; glass = .glassEffect()

**CREATE Verdict Guidance:** If 3+ reference components look fundamentally different from their DS counterpart, the default verdict is CREATE, not KEEP. The DS is a floor, not a ceiling. When references demand flat borderless surfaces but DSCard has borders and shadows, verdict is CREATE with explicit replacement pattern. Don't force reference aesthetics into template shapes.

### Radius (web → iOS)
- Map CSS border-radius to DS radii: `DSRadii.xs` (8), `.sm` (12), `.md` (16), `.lg` (20), `.xl` (28), `.pill` (999)
- Radius axis from presets: sharp = prefer xs/sm; rounded = prefer lg/xl; mixed = sharp for controls, rounded for cards

## Output: DESIGN.md (9 sections)

Write to `.forge/DESIGN.md`. Follow the format in `skills/forge-app/references/design-md-format.md`.
Use the Stitch-to-Forge translation mapping at the top of that file to convert web-native references into iOS-native output.

### Section 1: Design North Star
- Mood sentence: specific sensory/emotional description
- Visual Feel paragraph: 3-5 sentences describing the EXPERIENCE of using the app
- Reference apps with specific aspects to take from each
- Anti-references: what this app is NOT (2-3 adjacent genres to avoid)

### Section 2: Color Palette
- ColorStory table: brand, contrast (optional), surprise (optional), surface — with light+dark hex values
- Color Distribution: aspirational pixel percentages (brand ~15%, contrast ~5%, surprise <1%)
- Semantic roles table showing derivation from ColorStory fields
- Only override semantic roles where the reference demands non-derived colors

### Section 3: Typography
- DS text style assignments per heading level
- Design variant (.default, .rounded, .monospaced, .serif)
- Weight emphasis pattern from preset

### Section 4: Component Rules
- KEEP/COMPOSE/CREATE/SKIP table for every DS component
- Surface treatment details from preset
- Lean toward CREATE when references look fundamentally different from DS defaults

### Section 5: Layout Principles
- Spacing rules using DS token names
- Rhythm description from preset
- Preferred section patterns

### Section 6: Depth & Elevation
- Map reference shadow/depth system to DSShadows tokens
- Glass/blur treatment if applicable

### Section 7: Do's and Don'ts
- 4-6 DO patterns
- 6-10 DON'T patterns (GREPPABLE)

### Section 8: Screen Blueprints
- One blueprint per screen from spec.json
- Required fields: Design Intent, Craft Moment, Visual Feel, Hierarchy (primary/secondary/tertiary), Density target, Visual Reference, Hero element, Sections, Empty state, Entrance animation, Screen-specific Don'ts

### Section 9: Voice & Copy
- Tone derived from reference mood
- Exhaustive table of user-facing strings

## Post-Generation: Simplicity Audit

After generating all blueprints, run this check:

1. Count total sections across ALL screen blueprints
2. Read the pitch from `.forge/spec.json`
3. If the pitch implies simplicity ("one glance", "3 seconds", "single purpose", "under N seconds") but blueprints have 15+ total sections across all screens:
   - Flag the conflict to the orchestrator
   - Recommend specific sections to CUT or demote to tertiary
   - Do NOT proceed until the conflict is resolved

This is distinct from the Phase 1 feature count check. Phase 1 catches feature bloat. This catches section bloat within features.

## Post-Generation: UX Audit

Cross-reference Section 8 blueprints against the pitch:

1. Identify the core promise from the pitch (e.g., "the trend line IS the app")
2. Find that promise in the blueprints — is it the Primary element in the Hierarchy?
3. If the core promise is one of several equal-weight sections, FAIL the blueprint
4. Blueprints must encode hierarchy. If Primary/Secondary/Tertiary fields show equal distribution, flag it.

## Human Gate

After generating DESIGN.md, present it to the human for review. Do not proceed to Phase 3 until approved.
```

- [ ] **Step 2: Verify key patterns**

Run: `grep -c "ColorStory" skills/forge-design/SKILL.md && grep -c "CREATE" skills/forge-design/SKILL.md && grep -c "Simplicity Audit" skills/forge-design/SKILL.md`

Expected: ColorStory: 3+, CREATE: 3+, Simplicity Audit: 1+

- [ ] **Step 3: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-design/SKILL.md
git commit -m "feat(design): rewrite forge-design for ColorStory, CREATE verdicts, audits

Complete rewrite: ColorStory translation replaces brandColor mapping,
CREATE verdict guidance when references differ from DS, Simplicity Audit
catches section bloat, UX Audit ensures pitch promise is Primary element."
```

---

# Batch B: Quality Loop (Themes 3 + 4 + 5 + 6)

---

### Task 7: forge-judge — Consolidate + Craft Score + Vibe Check

**Files:**
- Modify: `skills/forge-judge/SKILL.md` (personal repo — full rewrite)

- [ ] **Step 1: Read the marketplace version and fix section numbers**

Read: `/Users/matvii/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-judge.md`

This 209-line version with 7 criteria is the base. **Before copying, fix these section number errors** in the marketplace content:
- "Section 6 Don'ts" → should be "Section 7 Don'ts" (Do's and Don'ts is Section 7 in design-md-format.md)
- "Section 7 blueprint" → should be "Section 8 blueprint" (Screen Blueprints is Section 8)
- "Section 8 copy" → should be "Section 9 copy" (Voice & Copy is Section 9)
- "Section 7 (Design Intent + Craft Moment)" → should be "Section 8 (Design Intent + Craft Moment)"

- [ ] **Step 2: Write the complete forge-judge/SKILL.md**

Replace the entire personal repo `skills/forge-judge/SKILL.md` with a single file that combines:
1. The marketplace agent content (with section numbers fixed per Step 1)
2. The Craft Score section (Step 4b below)
3. The Vibe Check section (Step 4c below)
4. The updated verdict format (Step 3 below)

**Important:** Provide the complete file content — do not leave a merge-it-yourself instruction. Read the marketplace file, apply fixes, insert the new sections after "Step 4: Grade on seven criteria" and before "Step 5: Return verdict", then write the result as a single complete file.

The new sections to insert between Step 4 and Step 5:

```markdown
### Step 4b: Craft Score (screenshot-only evaluation)

After compliance grading, evaluate 5 craft questions from the screenshot ONLY. These are visual judgments — do not reference code.

**C1. Dominance** (PASS/FAIL)
Does the screen have ONE element that commands attention? Describe what your eye hits first. If everything is the same visual weight (e.g., 4 equal-sized cards in a grid), FAIL. A screen needs a clear focal point.

**C2. Rhythm** (PASS/FAIL)
Does spacing VARY intentionally between sections? Check for uniform padding — if every gap between sections is the same DSSpacing value, FAIL. Good rhythm means some gaps are tight (related elements) and some breathe (section breaks). Uniform padding = template feel.

**C3. Breathing room** (PASS/FAIL)
Is there negative space letting the hero element stand out? Or is every pixel filled with content? If the hero element is crowded by surrounding elements with no whitespace buffer, FAIL. The primary element from the Hierarchy needs visual isolation.

**C4. Typography tension** (PASS/FAIL)
Do font sizes create visual interest? Check the range between the largest and smallest text on screen. If all text is within 4pt of each other (e.g., 15pt body + 17pt title), FAIL. Good typography has contrast — a 34pt display number next to 12pt caption creates tension and hierarchy.

**C5. Signature moment** (PASS/FAIL)
Does the screen have at least one visual detail that goes beyond functional correctness? Look for: the Craft Moment defined in the blueprint, a custom animation, an intentional color pop (using the `surprise` color from ColorStory), a typographic choice that creates visual interest. If the screen is "technically correct but has zero craft details beyond the spec minimum," FAIL.

**Craft Score verdict:**
- All 5 pass → CRAFT PASS
- Any fail → CRAFT FAIL with specific observations

Craft Score is a SEPARATE gate from compliance. A screen can pass all 7 compliance criteria and fail craft. Both must pass for the overall verdict.

### Step 4c: Vibe Check (reference comparison)

If reference app screenshots exist in `.forge/references/screenshots/`:
1. Read the reference screenshots
2. Compare the built screenshot against them for feel-matching:
   - Same visual density? (Amount of content, spacing tightness)
   - Same surface treatment? (Card depth, border usage, background treatment)
   - Same typography confidence? (Bold vs light, large vs small proportions)
   - Same emotional response? (Does it feel like the same family of apps?)
3. This is feel-matching, not pixel-matching. The built screen should EVOKE the reference, not copy it.

**If no reference screenshots exist:** Evaluate against the Visual Feel paragraph from the blueprint and the preset axes from DESIGN.md Section 1. Does the screenshot match the described experience?

**Vibe Check verdict:**
- Feels like the reference family → VIBE PASS
- Feels like a different app → VIBE FAIL with specific observations about what diverges

Vibe Check failure does not block on its own but is reported alongside the compliance and craft verdicts.
```

- [ ] **Step 3: Update the verdict format**

Replace the existing verdict format with:

```markdown
### Step 5: Return verdict

Output in this exact format:

~~~
JUDGE VERDICT: {PASS|FAIL}

## Compliance (7 criteria)
1. Design Quality: {PASS|FAIL} — {observations}
2. iOS-Native: {PASS|FAIL} — {observations}
3. Originality: {PASS|FAIL} — {observations}
4. Craft: {PASS|FAIL} — {observations}
5. Craft Intent: {PASS|FAIL} — {observations}
6. Visual Target Match: {PASS|FAIL|SKIPPED} — {observations}
7. Architecture: {PASS|FAIL} — {observations}

## Craft Score (5 criteria)
C1. Dominance: {PASS|FAIL} — {observations}
C2. Rhythm: {PASS|FAIL} — {observations}
C3. Breathing room: {PASS|FAIL} — {observations}
C4. Typography tension: {PASS|FAIL} — {observations}
C5. Signature moment: {PASS|FAIL} — {observations}

## Vibe Check
{PASS|FAIL|SKIPPED} — {observations}

FIXES REQUIRED:
1. {file_path:line — what to change, referencing DESIGN.md section}
2. ...
~~~

Overall verdict is PASS only if ALL compliance criteria pass AND ALL craft score criteria pass. Vibe Check is reported but does not block independently.
```

- [ ] **Step 4: Verify**

Run: `grep -c "Craft Score" skills/forge-judge/SKILL.md && grep -c "Vibe Check" skills/forge-judge/SKILL.md && grep -c "Signature moment" skills/forge-judge/SKILL.md`

Expected: Craft Score: 3+, Vibe Check: 3+, Signature moment: 1+

- [ ] **Step 5: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-judge/SKILL.md
git commit -m "feat(judge): add Craft Score and Vibe Check to forge-judge

Consolidate personal repo version with marketplace 7-criteria base.
Add 5-criterion Craft Score (dominance, rhythm, breathing room,
typography tension, signature moment) as separate hard gate.
Add Vibe Check comparing screenshots against reference app feel."
```

---

### Task 8: forge-build/PROMPT.md — New placeholders

**Files:**
- Modify: `skills/forge-build/PROMPT.md`

- [ ] **Step 1: Add new placeholder sections**

After the existing `</screen_type_guidance>` section (line 60) and before `<action_safety>` (line 62), add:

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

- [ ] **Step 2: Add visual feel guidance to the task section**

After `- Use DS radii tokens:` (line 23), add:

```
   - Read the <visual_feel> section — this describes how the screen should FEEL to use. Match the experience described, not just the tokens.
   - If a <mockup> is provided, build to match its layout and visual hierarchy. The mockup is the visual target.
   - If <visual_references> contains reference app screenshots, study them. Your output should evoke the same feeling — same density, surface treatment, and typography confidence.
   - If this is a retry after a judge FAIL, <visual_references> includes the failing screenshot. Compare your changes against it.
```

- [ ] **Step 3: Verify**

Run: `grep -c "VISUAL_FEEL\|VISUAL_REFERENCES\|MOCKUP_PATH\|SKILL_CONTEXT" skills/forge-build/PROMPT.md`

Expected: 8 (4 placeholders + 4 in XML tags)

- [ ] **Step 4: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-build/PROMPT.md
git commit -m "feat(build): add visual feel, references, mockup, skill context placeholders

Codex now receives: Visual Feel prose target, reference app screenshots,
approved mockup path, and pre-loaded skill patterns. On retry rounds,
failing screenshot is included in VISUAL_REFERENCES."
```

---

### Task 9: Screen-type fragments — Hierarchy-first rewrites

**Files:**
- Modify: `skills/forge-build/prompts/dashboard.md`
- Modify: `skills/forge-build/prompts/detail.md`
- Modify: `skills/forge-build/prompts/form.md`
- Modify: `skills/forge-build/prompts/list.md`
- Modify: `skills/forge-build/prompts/onboarding.md`
- Modify: `skills/forge-build/prompts/paywall.md`
- Modify: `skills/forge-build/prompts/settings.md`

- [ ] **Step 1: Rewrite dashboard.md**

```markdown
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
```

- [ ] **Step 2: Rewrite detail.md**

```markdown
# Detail Screen Guidance

## Hierarchy
- The title/header anchors the top — clear, bold, immediately readable.
- Primary content fills the middle — the data or content the user came to see.
- Actions (edit, delete, share) are secondary — toolbar or bottom, never competing with content.

## Visual Intent
- This screen is about ONE thing in depth. The user tapped to learn more — reward that intent with focused content.
- Use generous spacing between sections — the user is reading, not scanning.
- If there's a hero image or chart, let it breathe — don't crowd it with labels.

## DS Components
- `DSScreen` as root (required)
- `DSSection` for grouping related fields
- `DSListRow` for metadata pairs (label: value)
- `DSButton` for primary actions — one per screen, placed clearly

## Anti-Patterns
- Do NOT pack every detail above the fold — scrolling is expected and welcome
- Do NOT use multiple card styles on one detail screen — consistency within the screen
- Do NOT place destructive actions prominently — use `.confirmationDialog()` behind a secondary button
```

- [ ] **Step 3: Rewrite form.md**

```markdown
# Form Screen Guidance

## Hierarchy
- The form title tells the user what they're creating/editing — prominent but not overwhelming.
- Input fields are the primary interaction — each gets enough vertical space to feel comfortable.
- The submit button is the clear endpoint — fixed at the bottom or after the last field.

## Visual Intent
- This screen is about input, not display. Every element serves the user's task of entering data.
- Group related fields with `DSSection`. Keep groups to 3-4 fields max before a visual break.
- Placeholder text should be examples, not instructions ("e.g., Morning run" not "Enter habit name").

## DS Components
- `DSScreen` as root (required)
- `DSTextField` for text input with label and validation
- `DSSection` for field grouping
- `DSButton(.primary, size: .large)` for submit — full width

## Anti-Patterns
- Do NOT use a ScrollView of TextFields without section breaks — it feels like a government form
- Do NOT put validation errors only in a toast — show inline under the field
- Do NOT auto-advance focus to the next field — let the user control their pace
```

- [ ] **Step 4: Rewrite list.md**

```markdown
# List Screen Guidance

## Hierarchy
- Each row has ONE primary label. Secondary info (date, count, status) is visually subordinate.
- The list itself is the content — don't wrap it in cards or add unnecessary chrome.
- Search/filter controls (if any) are compact and above the list, not competing with content.

## Visual Intent
- This screen is about scanning and selecting. The user is looking for ONE item — make scanning fast.
- Row density should match the content: tight for settings-like lists, airy for content browsing.
- Use consistent row heights — visual rhythm matters in lists more than anywhere else.

## DS Components
- `DSScreen` as root (required)
- `DSListRow` for each item — use the same component consistently
- `DSSection` if the list has logical groups (but don't over-section)
- `ContentUnavailableView` for empty state

## Anti-Patterns
- Do NOT use DSCard for every list item — rows are for lists, cards are for featured content
- Do NOT mix row styles within the same list — consistency creates scannability
- Do NOT put action buttons on every row — use swipe actions or context menus
```

- [ ] **Step 5: Rewrite onboarding.md**

```markdown
# Onboarding Screen Guidance

## Hierarchy
- Each slide has ONE message — a headline and a supporting visual or brief description.
- The page indicator shows progress but doesn't compete with content.
- The CTA button is the clear next step — prominent at the bottom.

## Visual Intent
- Onboarding is about emotion, not information. Each slide should make the user FEEL something about the app.
- Use the `surprise` color from ColorStory for the key visual element on at least one slide.
- Keep text to 3-5 words per headline, 1 sentence per body. If you're writing paragraphs, you're over-explaining.

## DS Components
- `DSScreen` as root (required)
- TabView with `.tabViewStyle(.page)` for slide navigation
- `DSButton(.primary, size: .large)` for CTA — "Get Started" / "Continue"
- Use `.containerRelativeFrame([.horizontal, .vertical])` on TabView when inside DSScreen's ScrollView wrapper (prevents zero-height rendering)

## Anti-Patterns
- Do NOT use more than 3-4 slides — every extra slide increases drop-off
- Do NOT use feature lists or bullet points — this isn't a product page
- Do NOT skip the page indicator — users need to know where they are
- Do NOT auto-advance slides — let the user control their pace
```

- [ ] **Step 6: Rewrite paywall.md**

```markdown
# Paywall Screen Guidance

## Hierarchy
- The value proposition headline dominates — this is the ONE reason to upgrade.
- Feature list is secondary — supporting evidence, not the main argument.
- The CTA button is unmissable — large, brand-colored, fixed at the bottom.

## Visual Intent
- This screen sells a feeling, not a feature list. The headline should create desire.
- Use the `brand` color generously here — this is the one screen where brand saturation is welcome.
- Price should be clear but not the focal point — value first, price second.

## DS Components
- `DSScreen` as root (required)
- `DSButton(.primary, size: .large)` for CTA — full width, brand color
- `DSListRow` or checkmark list for feature comparison
- Use `.presentationDetents([.large])` if presented as a sheet

## Anti-Patterns
- Do NOT lead with the price — lead with what the user gets
- Do NOT list more than 5 features — pick the 3 that matter most
- Do NOT use "Premium" or "Pro" in the headline — use benefit-driven language
- Do NOT hide the close/dismiss button — that gets App Store rejections
```

- [ ] **Step 7: Rewrite settings.md**

```markdown
# Settings Screen Guidance

## Hierarchy
- Settings is a utility screen — no hero element needed. "Hero: None" is correct.
- Group related settings with clear section headers.
- Destructive actions (delete account, clear data) are at the very bottom, visually de-emphasized.

## Visual Intent
- This screen is about control, not display. Every row is a toggle, picker, or navigation link.
- Keep it flat and scannable — no cards, no elevation, no visual flourish.
- Use system controls (Toggle, Picker, DatePicker) — don't reinvent settings UI.

## DS Components
- `DSScreen` as root (required)
- `DSListRow` for each setting — consistent row treatment
- `DSSection` with headers for grouping (Account, Preferences, About, Danger Zone)
- System `Toggle`, `Picker`, `DatePicker` for controls

## Anti-Patterns
- Do NOT use DSCard for settings rows — flat rows are correct here
- Do NOT add visual flourish — settings should be invisible infrastructure
- Do NOT put destructive actions in prominent positions — bottom of the last section
- Do NOT use custom toggles or switches — system controls are expected
```

- [ ] **Step 8: Verify all 7 files have hierarchy section**

Run: `grep -l "## Hierarchy" skills/forge-build/prompts/*.md | wc -l`

Expected: 7

- [ ] **Step 9: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-build/prompts/
git commit -m "feat(build): rewrite all screen-type fragments with hierarchy-first guidance

Replace component shopping lists with design intent and visual hierarchy.
Each fragment now defines Primary/Secondary/Tertiary visual weight
distribution and anti-patterns specific to the screen type."
```

---

### Task 10: forge-app/SKILL.md — Phase 1 (auth gate stripping)

**Files:**
- Modify: `skills/forge-app/SKILL.md` (Phase 1 section)

- [ ] **Step 1: Add auth gate stripping after spec.json approval**

Insert after the section headed "Human gate" (where the user approves spec.json) and before "Simplicity Check" (added by Task 11). The auth gate check requires spec.json to exist, so it must run in Phase 1, not Phase 0:

```markdown
### Auth Gate Check

After the user approves spec.json:

```bash
# Check if spec.json has any auth-related features
if [ -f ".forge/spec.json" ]; then
  AUTH_FEATURES=$(grep -i '"id".*\(auth\|login\|signin\|sign-in\|signup\|sign-up\)' .forge/spec.json | wc -l)
  if [ "$AUTH_FEATURES" -eq 0 ]; then
    echo "NO_AUTH_NEEDED"
  else
    echo "AUTH_REQUIRED"
  fi
fi
```

If NO_AUTH_NEEDED:
1. Check if AppRootView.swift has an auth gate:
```bash
grep -l "signIn\|isAuthenticated\|authState\|SignInView\|LoginView" {AppName}/App/AppRootView.swift && echo "AUTH_GATE_FOUND"
```
2. If AUTH_GATE_FOUND, strip the auth gate — remove the sign-in conditional, route directly from onboarding to main app content. Dispatch to Codex:
```
Agent(subagent_type: "codex:codex-rescue", prompt: "
  Read {AppName}/App/AppRootView.swift.
  This app does not need authentication.
  Remove the auth gate (SignInView/LoginView conditional).
  Route directly from onboarding to the main app content (TabView/NavigationStack).
  Keep the onboarding flow intact.
")
```
```

- [ ] **Step 2: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-app/SKILL.md
git commit -m "feat(pipeline): add auth gate stripping to Phase 1

When spec.json has no auth features, strip the template's auth gate
from AppRootView to prevent no-auth apps from showing a login screen.
Runs after spec.json approval (Phase 1), not Phase 0."
```

---

### Task 11: forge-app/SKILL.md — Phase 1 (simplicity check)

**Files:**
- Modify: `skills/forge-app/SKILL.md` (Phase 1 section)

- [ ] **Step 1: Add simplicity check after spec.json approval**

Insert after the "Auth Gate Check" section (added by Task 10) and before "Create pipeline snapshot". Use content anchors — do not rely on line numbers as prior tasks shift them:

```markdown
### Simplicity Check

After the user approves the spec.json, check for feature bloat:

```bash
FEATURE_COUNT=$(grep -c '"id"' .forge/spec.json)
echo "FEATURE_COUNT: $FEATURE_COUNT"
```

Read the pitch from spec.json. If the pitch implies simplicity — contains phrases like "one glance", "under 3 seconds", "single purpose", "one question", "just one" — but FEATURE_COUNT is 6 or more:

```
"Your pitch says this is a simple, focused app, but the spec has {N} features.
Simple apps typically have 3-4 screens. Consider:
- Which features are essential to the core promise?
- Which could be cut or deferred to v2?
- Does every feature serve the '3-second' promise?

Let's trim before building."
```

Wait for the user to reduce scope before proceeding. This check runs on feature count (from spec.json), not section count (blueprints don't exist yet). The Phase 2 Simplicity Audit in forge-design checks section count within blueprints.
```

- [ ] **Step 2: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-app/SKILL.md
git commit -m "feat(pipeline): add Phase 1 simplicity check

Catches feature bloat before design phase: if pitch implies simplicity
but spec has 6+ features, force scope reduction conversation."
```

---

### Task 12: forge-app/SKILL.md — Phase 2 (screenshot acquisition, color gate, mockup mandate)

**Files:**
- Modify: `skills/forge-app/SKILL.md` (Phase 2 section)

- [ ] **Step 1: Add screenshot acquisition step before DESIGN.md generation**

Insert before the section headed "Step 1: Translate references → DESIGN.md". Use content anchors — do not rely on line numbers:

```markdown
### Step 0: Acquire reference screenshots

Before generating DESIGN.md, ensure visual references exist:

```bash
mkdir -p .forge/references/screenshots
ls .forge/references/screenshots/*.{png,jpg,jpeg} 2>/dev/null | wc -l
```

If no screenshots exist:
1. Check if the user provided screenshots during Phase 1 Q5 — save to `.forge/references/screenshots/`
2. If no user screenshots, attempt to capture reference app visuals:
   - For each reference in `.forge/references/index.md`, use WebFetch to capture the app's landing page or App Store preview screenshots
   - Save to `.forge/references/screenshots/{app-name}-{context}.png` (e.g., `notion-settings.png`, `stripe-dashboard.png`)
3. If WebFetch fails, log a warning: "No reference screenshots available. Vibe Check will evaluate against Visual Feel paragraph only."

These screenshots are used by:
- forge-design — visual translation input
- forge-build — `{{VISUAL_REFERENCES}}` in Codex prompt
- forge-judge — Vibe Check comparison
```

- [ ] **Step 2: Add color gate after DESIGN.md approval**

Insert after the section headed "Step 2: Human approval". Note: this is a rough sanity check ("does teal look medical?"), not a definitive validation — the real color validation happens at Gate 2 when the first real screen is built:

```markdown
### Step 2b: Color Gate — Verify ColorStory on a real screen

After the user approves DESIGN.md, validate colors in pixels before building:

1. Extract the ColorStory hex values from the approved DESIGN.md Section 2
2. Update AppDelegate.swift with the ColorStory:
```
Agent(subagent_type: "codex:codex-rescue", prompt: "
  Read .forge/DESIGN.md Section 2 (Color Palette).
  Extract the ColorStory hex values (brand, contrast, surprise, surface).
  Update {AppName}/App/AppDelegate.swift to configure AdaptiveTheme
  with the extracted ColorStory.
")
```
3. Build and screenshot the app's current state (even if it's just the template default screen):
```bash
xcodebuildmcp simulator build-and-run --scheme "{AppName} - Mock" --project-path ./{AppName}.xcodeproj --simulator-name "iPhone 17 Pro"
xcodebuildmcp ui-automation screenshot --simulator-id {SIMULATOR_UDID} --return-format path
```
4. Show the screenshot to the user:
```
"Here's your ColorStory on a real screen. Does this feel right?
Brand: {brand_hex} | Contrast: {contrast_hex} | Surface: {surface_hex}
If the colors feel wrong in pixels (too clinical, too cold, too loud), now is the time to adjust — before we build 7 screens with these colors."
```
5. If the user wants changes, update DESIGN.md Section 2, re-apply to AppDelegate, re-screenshot. Max 3 color iterations.
```

- [ ] **Step 3: Add mockup mandate for complex screens**

Insert after the existing section headed "Optional: Mockup generation":

```markdown
### Step 3: Mandatory mockups for complex screens

Check each feature in spec.json. If `screen_type` is `dashboard`, or the screen has charts, or the blueprint has 3+ sections:

1. Generate a Stitch mockup for the screen:
```
Agent(description: "Generate mockup for {feature_name}", prompt: "
  Use Stitch MCP to generate a mockup for {feature_name}.
  Read .forge/DESIGN.md Section 8 blueprint for {feature_name}.
  Read .forge/DESIGN.md Section 1 for the Design North Star and Visual Feel.
  Generate 2-3 visual variants. Save to .forge/design-mockups/{feature_name}-v1.png, v2.png, v3.png
")
```
2. Show mockup variants to the user:
```
"Here are 3 mockup options for {feature_name}. Which direction feels right?
Or describe what you'd change."
```
3. Save the approved mockup as `.forge/design-mockups/{feature_name}-approved.png`
4. Update the blueprint's Visual Reference field to point to the approved mockup

For simple screens (settings, forms) with <3 sections, mockups are optional. Use "None — derived from {closest screen} mockup" in the Visual Reference field.

Do NOT present this as a lettered choice. Complex screens get mockups automatically.
```

- [ ] **Step 4: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-app/SKILL.md
git commit -m "feat(pipeline): add screenshot acquisition, color gate, mockup mandate to Phase 2

Phase 2 now: acquires reference screenshots, validates ColorStory on
a real screen before building, and mandates Stitch mockups for complex
screens (dashboard, charts, 3+ sections)."
```

---

### Task 13: forge-app/SKILL.md — Phase 3 (taste gates, checkpoints, discipline)

**Files:**
- Modify: `skills/forge-app/SKILL.md` (Phase 3 section)

- [ ] **Step 0: Update all existing `codex:rescue` references**

Find and replace all occurrences of `"codex:rescue"` with `"codex:codex-rescue"` in `skills/forge-app/SKILL.md`. The correct subagent_type is `codex:codex-rescue`.

```bash
grep -n "codex:rescue" skills/forge-app/SKILL.md
```

Replace each occurrence. This ensures the checkpoint in Step 1 doesn't contradict existing dispatch calls.

- [ ] **Step 1: Add checkpoint before Phase 3**

Insert before the section headed "For each feature in spec.json":

```markdown
### CHECKPOINT: Before Phase 3

Re-read Phase 3 steps below before proceeding. Verify your approach:
- [ ] Codex dispatch uses `subagent_type: "codex:codex-rescue"` — NEVER `"general-purpose"` or Agent without subagent_type
- [ ] All build/run/screenshot uses xcodebuildmcp — NEVER raw `xcodebuild`, `xcrun simctl`, or `screencapture`. If xcodebuildmcp fails 4 consecutive times on the same operation, fall back to raw xcodebuild with a warning logged to `.forge/retrospective.md`.
- [ ] Judge is dispatched after EVERY screenshot — NEVER skipped, NEVER deferred to "after all screens"
- [ ] Human gate fires after EVERY feature — NEVER batch-committed without individual review
- [ ] Skill pre-load ran before each Codex dispatch
- [ ] Bundle ID is verified after every launch — must contain ".mock"

### Hard Rules

**Codex-Only:** ALL code generation and ALL code fixes go through Codex dispatch. The orchestrator NEVER writes or edits Swift code directly. The orchestrator's job is to identify problems and write fix prompts, not to fix code. This includes "quick fixes." There are no quick fixes.

**xcodebuildmcp-First:** Invoke the `xcodebuildmcp-cli` skill at the start of Phase 3 if not already invoked. All simulator discovery, building, running, UI automation, and screenshots go through xcodebuildmcp.
```

- [ ] **Step 2: Add skill pre-load step before Codex dispatch**

In Step 1 (Codex Code Generation), after "Replace placeholders" and before "Dispatch to Codex", add:

```markdown
#### Skill Pre-load

Before dispatching to Codex, invoke relevant skills and extract patterns:

1. Invoke `swiftui-expert` skill — extract patterns relevant to `{screen_type}`
2. If the screen uses charts: invoke `axiom-swiftui` for Swift Charts patterns
3. If the screen has navigation: invoke `axiom-swiftui` for NavigationStack patterns
4. Capture the skill output and embed the relevant guidance in `{{SKILL_CONTEXT}}`

This is necessary because Codex cannot invoke Claude Code skills. Pre-loading turns skill knowledge into prompt context.

Also populate:
- `{{VISUAL_FEEL}}` — Design North Star Visual Feel paragraph + this screen's blueprint Visual Feel
- `{{VISUAL_REFERENCES}}` — Reference screenshots from `.forge/references/screenshots/` (if available)
- `{{MOCKUP_PATH}}` — Approved mockup from `.forge/design-mockups/{feature_name}-approved.png` (if available)
```

- [ ] **Step 3: Add bundle ID assertion to Step 4**

In Step 4 (Build + Screenshot), after the build-and-run command, add:

```markdown
#### Bundle ID Assertion

After every build-and-run, verify the correct bundle launched:

```bash
# Check the launched bundle ID
xcodebuildmcp simulator list-running-apps --simulator-id {SIMULATOR_UDID} | grep -i "{AppName}"
```

If the bundle ID contains `.dev` or `.prod` instead of `.mock`:
1. Stop immediately — do NOT screenshot or proceed
2. Fix the scheme selection: the build must use `"{AppName} - Mock"` scheme
3. Retry the build-and-run with the correct scheme
```

- [ ] **Step 4: Add retry screenshot to Codex fix prompts**

In the judge FAIL → Codex retry flow (Step 5), update the retry dispatch:

```markdown
If FAIL: send fix instructions to Codex (Step 1), including:
- The judge's specific fix instructions (from FIXES REQUIRED)
- The failing screenshot path (so Codex can see what needs to change via `{{VISUAL_REFERENCES}}`)
- Cross-screen retrospective entries that share the same fix target (prevents repeating mistakes across screens)

Max 3 total judge rounds per feature.
```

- [ ] **Step 4b: Update judge dispatch prompt**

In the section headed "Step 5: Taste Judge", update the judge dispatch prompt from:
```
Grade on 5 criteria: Design Quality, Originality, Craft, Craft Intent, Visual Target Match.
```
To:
```
Grade on 7 compliance criteria (Design Quality, iOS-Native, Originality, Craft, Craft Intent, Visual Target Match, Architecture) + 5 craft score criteria (Dominance, Rhythm, Breathing room, Typography tension, Signature moment) + Vibe Check.
Return PASS or FAIL with specific fix instructions.
```

This matches the updated forge-judge from Task 7.

- [ ] **Step 5: Add Gate 2 (first screen review) after first feature**

After the existing Step 6 (Human Gate), add:

```markdown
### Gate 2: First Screen Review

After the FIRST feature passes both compliance and craft score, STOP the pipeline before building screen 2:

```
"This is the first screen built — it sets the visual tone for the entire app.
[screenshot]

Does this feel like YOUR app? Key questions:
- Does the hero element command attention?
- Does the color palette feel right in context?
- Does the spacing rhythm feel intentional, not uniform?

If yes → I'll build the remaining screens in this style.
If no → Tell me what feels off and I'll redesign this screen before continuing."
```

If no: redesign the blueprint for this screen, rebuild, re-judge. Do NOT proceed to screen 2 until the user explicitly approves screen 1's taste.

This gate fires ONCE — only for the first feature in the build loop.
```

- [ ] **Step 6: Update Step 6 (Human Gate) to approve-or-flag**

Replace the existing Step 6 content:

```markdown
### Step 6: Human Gate (Approve or Flag)

Show the screenshot to the user:
```
"Here's {feature_name}. The hero element is {hero_element_from_blueprint}.
[screenshot]

Does it command attention? Does the screen have one clear focal point?
- **Approve** — looks good, continue to next screen
- **Flag** — note what feels off (I'll continue building, but we'll fix flagged issues in a batch after all screens are done)"
```

If approved: commit files, update spec.json status to "done".
If flagged: record the concern in `.forge/flags.md`, update spec.json status to "done-flagged", continue to next feature.
If specific feedback that should be fixed now: send feedback to Codex (Step 1). Max 2 feedback rounds.

### Flagged Issues Round

After ALL features are built (or blocked), if any features have status "done-flagged":
1. Present all flags together:
```
"These screens were flagged during the build:
{list of flagged screens with concerns from .forge/flags.md}

Want to fix all flagged issues now? I'll dispatch Codex for each fix."
```
2. If yes: re-enter the build loop for each flagged screen with the flag concern as the fix prompt
3. Re-judge and re-screenshot each fixed screen
```

- [ ] **Step 7: Verify key patterns**

Run: `grep -c "CHECKPOINT" skills/forge-app/SKILL.md && grep -c "codex:codex-rescue" skills/forge-app/SKILL.md && grep -c "Skill Pre-load" skills/forge-app/SKILL.md && grep -c "Gate 2" skills/forge-app/SKILL.md`

Expected: CHECKPOINT: 1+, codex:codex-rescue: 2+, Skill Pre-load: 1+, Gate 2: 1+

- [ ] **Step 8: Commit**

```bash
cd /Users/matvii/Developer/Personal/forge
git add skills/forge-app/SKILL.md
git commit -m "feat(pipeline): add taste gates, checkpoints, discipline to Phase 3

Phase 3 now has: checkpoint checklist before start, skill pre-load
before Codex dispatch, bundle ID assertion after build, Gate 2 (first
screen blocking review), approve-or-flag per feature, flagged issues
batch round. Codex-only and xcodebuildmcp-first enforcement."
```

---

## Self-Review

**Spec coverage check:**
- Theme 1 (DS Flexibility): Tasks 1-2 ✓
- Theme 2 (Visual-First Design): Tasks 3-6 ✓
- Theme 3 (Taste Layer): Task 7 ✓
- Theme 4 (Builder Context): Tasks 8-9 ✓
- Theme 5 (Human Taste Gates): Tasks 10, 12, 13 ✓
- Theme 6 (Pipeline Discipline): Tasks 10-13 ✓
- Auth gate stripping: Task 10 ✓
- Simplicity check (Phase 1 features): Task 11 ✓
- Simplicity audit (Phase 2 sections): Task 6 ✓
- Screenshot acquisition: Task 12 ✓
- Color gate: Task 12 ✓
- Mockup mandate: Task 12 ✓
- Craft Score + Vibe Check: Task 7 ✓
- Visual references in build prompt: Task 8 ✓
- Skill pre-load: Task 13 ✓
- Codex-only enforcement: Task 13 ✓
- xcodebuildmcp with fallback: Task 13 ✓
- Bundle ID assertion: Task 13 ✓
- Gate 2 (first screen review): Task 13 ✓
- Gate 3 (approve-or-flag): Task 13 ✓
- Checkpoint system: Task 13 ✓
- Retry screenshot in Codex prompt: Task 13 ✓

**No gaps found.** All spec requirements have corresponding tasks.

**Type consistency:** `ColorStory` fields are consistently named `brand`, `contrast`, `surprise`, `surface` across all tasks. `AdaptiveTheme(colorStory:)` API is consistent across Tasks 1-2 and referenced skill files.
