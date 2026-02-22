# AGENTS.md

This file provides guidance to AI coding agents when working with this repository.

---

## Getting Started

If a user is new to Forge or asks "how does this project work", "what can I do", "help me get started", or similar — walk them through this section interactively.

### What is Forge?

Forge is a production-ready iOS app template built with SwiftUI, MVVM architecture, and AppRouter navigation. It ships with authentication, in-app purchases, analytics, onboarding, a paywall, and a full design system — so you skip boilerplate and start building features immediately.

### First-Time Setup

1. **Rename the template** for your app. Install the `forge-workspace` skill:
   ```bash
   claude plugin marketplace add https://github.com/sakhnenkoff/forge-marketplace
   claude plugin install forge-workspace@forge-marketplace
   ```
   Then say: "Set up Forge for [my app name]" — it walks you through renaming, branding, feature flags, and content customization.

2. **Build** using the Mock scheme (no Firebase needed):
   ```bash
   xcodebuild -project Forge.xcodeproj -scheme "Forge - Mock" -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build
   ```

### What's Included

| Area | What You Get |
|------|-------------|
| **Architecture** | MVVM + AppRouter (TabView + NavigationStack + sheets) |
| **Design System** | Full token system (spacing, colors, typography, shadows) + 20+ reusable components (`DSButton`, `DSCard`, `DSHeroCard`, `DSTextField`, etc.) |
| **Auth** | Sign-in flow with Google Sign-In, Apple Sign-In (toggle via feature flags) |
| **Purchases** | RevenueCat integration with paywall, entitlements, subscription management |
| **Analytics** | Mixpanel + Firebase Analytics with `LoggableEvent` pattern |
| **Onboarding** | Multi-step onboarding with goals, permissions, name input |
| **Build Configs** | Mock (no Firebase), Dev, Prod — switch schemes in Xcode |

### How to Build

**Build an entire app:** `/forge:app` — describe your idea, get a running polished app
```bash
claude plugin install forge-app@forge-marketplace
```

**Build individual features:** `/forge:feature` or `/forge:quick`
- **Most features:** `/forge:quick` — scaffold, build, polish, verify (default)
- **Major features:** `/forge:feature` — full pipeline with brainstorming, planning, and review
- **Multi-session work:** Automatically escalates to GSD when complexity warrants it

**Connect to backend:** `/forge:wire` — wire up Firebase, Supabase, REST, GraphQL, CloudKit, or local SwiftData

**Prepare for App Store:** `/forge:ship` — pre-flight audit, Axiom deep scan, auto-fixes, submission checklist

Or build features manually with individual skills:

1. **Scaffold**: `forge-screens` generates View + ViewModel with correct architecture. Say: "Create a screen for [feature]".
2. **Polish**: `swiftui-craft` makes UI feel premium. Say: "Polish this screen".
3. **Or manually**: Create `{App}/Features/{Feature}/{Feature}View.swift` and `{Feature}ViewModel.swift` following the patterns in the Quick Start Guide below.

### Key Concepts

- **AppServices** — injected via `@Environment`, provides access to all managers (auth, purchases, logging)
- **AppSession** — user state (signed in, current user, display name)
- **Router** — navigation via `router.navigate(to:)` (push), `router.presentSheet(_:)` (modal), `router.selectedTab` (tab)
- **DS components** — never build raw UI — use `DSButton`, `DSCard`, `DSSection`, `DSListCard`, `DSListRow`, `DSTextField`, etc.
- **Feature flags** — toggle Firebase, analytics, purchases, auth in `FeatureFlags.swift`
- **Mock scheme** — develop without any backend services configured

### Available Skills

All installable from the forge marketplace:

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `forge-app` | Build a complete app from an idea — blueprint + execution | `/forge:app` |
| `forge-feature` | Quality pipeline — scaffold, build, polish, verify | `/forge:feature` or `/forge:quick` |
| `forge-wire` | Connect to backend services (Firebase, Supabase, REST, etc.) | `/forge:wire` |
| `forge-ship` | App Store pre-flight audit, Axiom scan, auto-fixes | `/forge:ship` |
| `forge-workspace` | Rename, brand, and configure the template for your app | "Set up Forge for [app]" |
| `forge-screens` | Scaffold architecture-correct feature screens | "Create a screen for [feature]" |
| `swiftui-craft` | Premium design polish + soul (personality, warmth, human touch) | "Polish this UI" |

---

## Building the Project

Use direct `xcodebuild` (do not use MCP).

### Build Workflow

1. **Build**: `xcodebuild -project Forge.xcodeproj -scheme "Forge - Mock" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build`
2. **If fails**: Fix compile errors, then re-run the same command.
3. **Warnings are blockers**: Resolve all build warnings from app code before finishing work. Warnings originating from external packages are acceptable.

### When to Build

- **Do NOT** auto-build after UI-only changes (colors, layout tweaks, theme updates, copy changes).
- **Do** build after large features or structural changes to ensure everything compiles.
- **Otherwise**, ask the user whether they want a build before running one.

---

## Quick Summary

- **Architecture**: MVVM + AppRouter (TabView + NavigationStack + sheets)
- **Tech Stack**: SwiftUI (iOS 26+), Swift 6.0+, Firebase, RevenueCat, Mixpanel
- **Build Configs**: Mock (no Firebase), Dev, Prod
- **Packages**: Direct SDKs (Firebase, Mixpanel, RevenueCat, GoogleSignIn) + Packages/core-packages (monorepo)

---

## Quick Start Guide

### For New Screens
1. Create a SwiftUI View + ViewModel under `/Features/[FeatureName]/`
2. Wire navigation in `AppRoute`/`AppSheet` if needed
3. Follow the steps in ACTION 1 documentation
4. **Screen scaffolding**: Use the `forge-screens` skill to generate architecture-correct View + ViewModel pairs wired into the AppRouter navigation pattern (`claude plugin marketplace add https://github.com/sakhnenkoff/forge-marketplace && claude plugin install forge-screens@forge-marketplace`).
5. **Design craft**: Use the `swiftui-craft` skill for premium, Apple-native design — researching real award-winning apps for inspiration, applying six craft dimensions (typography, color, composition, motion, material, micro-interactions), and detecting the project's design system to use its tokens (`claude plugin install swiftui-craft@forge-marketplace`).

### For New Components
- Always create in `/Components/Views/` (or `/Components/Modals/` for modals)
- Make all data properties optional for flexibility
- Never include business logic - components are dumb UI
- Follow the rules in ACTION 2 documentation

### For New Managers
- Decide: Service Manager (most common) or Data Sync Manager (for Firestore sync)
- Service Managers use protocol-based pattern with Mock/Prod implementations
- Data Sync Managers use `DocumentManagerSync` + services in `Managers/DataManagers/`
- Follow the steps in ACTION 3 documentation

### For New Models
- Models live in `/Managers/[ManagerName]/Models/`
- Must conform to: `StringIdentifiable, Codable, Sendable`
- Use snake_case for CodingKeys raw values
- Follow the steps in ACTION 4 documentation

---

## Critical Rules

### File Creation (ALWAYS use Write/Edit tools)
- This project uses Xcode 15+ File System Synchronization
- Files created in `Forge/` folder automatically appear in Xcode
- ALWAYS use Write/Edit tools to create .swift files (unless documentation)
- Files automatically included in build - no manual Xcode steps needed

### MVVM Data Flow
```
View → ViewModel → Services/Managers
```

### Concurrency Baseline
- App target uses strict concurrency (`complete`) and defaults to `MainActor` isolation.
- Upcoming features are enabled: `NonisolatedNonsendingByDefault` and `InferIsolatedConformances`.
- Package targets (`Packages/core-packages`) do NOT default to `MainActor`; use explicit actor annotations.
- Avoid adding `@unchecked Sendable` / `nonisolated(unsafe)` unless absolutely required.
- If unsafe annotations are required, include a short `SAFETY:` invariant comment plus a TODO follow-up ticket.
- Prefer structured concurrency and explicit isolation boundaries over blanket `@MainActor` fixes.

### Component Rules
- NO @State for data (only for UI animations)
- NO business logic
- ALL data is injected via init
- Make properties optional when possible
- ALL actions are closures

### Layout Best Practices
- PREFER `.frame(maxWidth: .infinity, alignment: .leading)` over `Spacer()`
- ALWAYS use `ImageLoaderView` for URL images (never AsyncImage)
- ALWAYS use `DSButton` or `DSIconButton` for interactive elements in feature screens

### Analytics
- Key ViewModel actions MUST track events
- Manager methods MUST track events with logger

---

## Build Configurations

- **Mock**: Fast development, no Firebase, mock data
- **Development**: Real Firebase with dev credentials
- **Production**: Real Firebase with production credentials

Use Mock for 90% of development.

---

## File Locations

- **App Shell**: `/Forge/App/`
- **Features**: `/Forge/Features/[FeatureName]/`
- **Managers**: `/Forge/Managers/[ManagerName]/`
- **Components**: `/Forge/Components/Views/`
- **Extensions**: `/Forge/Extensions/`
- **SPM Packages**: `Packages/core-packages/` (Core, CoreMock, DesignSystem)

---

## How to Add a New Feature

1. **Create files**: Add `FeatureView.swift` and `FeatureViewModel.swift` in `Forge/Features/YourFeature/`.
2. **ViewModel**: Mark with `@MainActor @Observable`. Add analytics events following the `Event: LoggableEvent` pattern (see `HomeViewModel` for example).
3. **View**: Use `DSScreen(title:)` as the root. Inject `@Environment(AppServices.self)` and `@Environment(AppSession.self)` as needed. Use `@State private var viewModel = FeatureViewModel()`.
4. **Wire navigation**: Add a case to the appropriate navigation enum:
   - **New tab**: Add case to `AppTab` in `Forge/App/Navigation/AppTab.swift`, implement `icon`, `title`, and `makeContentView()`.
   - **Push destination**: Add case to `AppRoute` in `Forge/App/Navigation/AppRoute.swift`. Navigate with `router.navigate(to: .yourRoute)`.
   - **Sheet/modal**: Add case to `AppSheet` in `Forge/App/Navigation/AppSheet.swift`. Present with `router.presentSheet(.yourSheet)`.
5. **Use DS components**: `DSButton`, `DSCard`, `DSSection`, `DSListCard`, `DSListRow`, `DSTextField`, `EmptyStateView`, `ErrorStateView`.

---

## How to Customize HomeView

The home screen (`Forge/Features/Home/HomeView.swift`) ships as a personal finance dashboard with demo data. To replace with real content:

1. **Update `HomeViewModel`**: Replace `stats`, `recentItems` (transactions), and `budgetCategories` arrays with real data from your managers/services. The `BudgetCategory` model includes `name`, `icon`, `spent`, `limit`, computed `progress`, and formatted strings.
2. **Update view sections**: The view has five sections — `welcomeSection`, `statsRow`, `budgetProgressSection`, `recentActivitySection` (transactions), `quickActionsSection`. Replace or remove sections to match your domain.
3. **Connect actions**: The "Add Transaction" and "View Budget" buttons in `quickActionsSection` have TODO placeholders. Wire them to `router.navigate(to:)` or `router.presentSheet(_:)`.
4. **Keep analytics**: The `onAppear` event tracking is already wired. Add domain-specific events to the `Event` enum.

---

## How to Customize the Paywall

Files: `Forge/Features/Paywall/PaywallView.swift`, `CustomPaywallView.swift`, `PaywallViewModel.swift`.

- **Value props**: Edit the `heroCard` in `PaywallView.swift` — change the `featureBullet` entries to match your app's premium features.
- **Pricing copy**: Product titles/subtitles come from your StoreKit configuration or App Store Connect. The template reads them from `AnyProduct`.
- **Plan toggle**: Uses `DSSegmentedControl` for Monthly/Annual. Modify `intervals` array in `CustomPaywallView` to change options.
- **Product IDs**: Defined in `EntitlementOption`. Update product IDs to match your App Store Connect configuration.
- **Post-purchase**: On successful purchase, a toast is shown and the paywall dismisses. Customize the toast message in `PaywallViewModel.purchase()`.

---

## How to Customize Onboarding

File: `Forge/Features/Onboarding/OnboardingStep.swift`

- **Add/remove steps**: Add or remove cases from the `OnboardingStep` enum. Each case defines `title`, `icon`, `introHeadline` (for text-intro screens), `headlineLeading/Highlight/Trailing` (for data-gathering screens), `subtitle`, and `ctaTitle`.
- **Text-intro screens** (`isTextIntro == true`): Full-screen centered text with icon. Good for value prop screens.
- **Data-gathering screens**: Have a headline with highlighted word, subtitle, and interactive content (goals selection, permission request, name input).
- **Reorder**: Cases are displayed in declaration order. Simply reorder the enum cases.
- **Controller**: `OnboardingController.swift` handles state, validation, and analytics. The `userName` property is persisted and available via `session.currentUser?.displayNameCalculated`.

---

## DS Component Reference

### Tokens
- **Spacing**: `DSSpacing.xs` (4), `.sm` (8), `.smd` (12), `.md` (16), `.mlg` (20), `.lg` (24), `.xl` (32), `.xxl` (40), `.xxlg` (48)
- **Radii**: `DSRadii.xs` (8), `.sm` (12), `.md` (12), `.lg` (16), `.xl` (20)
- **Layout**: `DSLayout.iconXS` (16), `.iconSmall` (20), `.iconMedium` (22), `.iconLarge` (28), `.avatarSmall` (44), `.avatarLarge` (68), `.cardMaxWidth` (360), `.cardCompactWidth` (340)
- **Colors**: Warm-tinted neutrals. Light: `backgroundPrimary` (#FAFAFA), `backgroundSecondary` (#F4F3F1), `surface` (#FFFFFF), `surfaceVariant` (#F0EFF2). Dark: `backgroundPrimary` (#0A0A0C), `surface` (#1A1A1E), `surfaceVariant` (#242428). Semantic: `Color.themePrimary`, `.textPrimary`, `.textSecondary`, `.textTertiary`, `.textOnPrimary`, `.border`, `.error`, `.divider`
- **Typography**: `.display()` (34pt bold rounded), `.titleLarge()` (28pt semibold rounded), `.titleMedium()`, `.titleSmall()`, `.headlineMedium()`, `.headlineSmall()`, `.bodyLarge()`, `.bodyMedium()`, `.bodySmall()`, `.captionLarge()`, `.buttonSmall()`, `.buttonMedium()`, `.buttonLarge()`
- **Shadows**: Three tiers — `DSShadows.soft` (subtle), `.card` (default cards), `.lifted` (elevated/hero content). Brand-tinted purple shadows, not neutral black.

### Design Principles

- **Borderless surfaces**: Cards and surfaces use shadow-only depth — no border strokes. Borders create a template feel. Premium apps (Flighty, Things 3) use shadow differentiation.
- **Warm neutrals**: Backgrounds use warm-tinted off-whites/off-blacks, not sterile pure white/black.
- **Ambient gradient**: `AmbientBackground` provides a subtle plum warmth tint. Color-scheme-aware — light mode gets stronger intensity.
- **Shadow-only depth**: Three tiers — `.flat` (no shadow), `.raised` (card shadow), `.elevated` (lifted shadow). No borders on any tier.
- **Glass by default**: `DSHeroCard` uses Liquid Glass on iOS 26+ by default. Hero content is the Floating layer.
- **Concentric corners**: Inner pill radius = outer radius - padding. For segmented controls and nested rounded rects.

### Components

| Component | Location | Usage |
|-----------|----------|-------|
| `DSButton` | DesignSystem | `.primary`, `.secondary`, `.tertiary`, `.destructive` styles. Use `.cta()` for full-width primary. Primary/destructive have colored shadows. |
| `DSIconButton` | DesignSystem | Icon-only button with optional circle background. On iOS 26 with `showsBackground: false`, renders native `Button { Image }` for proper toolbar Liquid Glass. |
| `DSCard` | DesignSystem | Borderless surface container with shadow depth: `.flat` (no shadow), `.raised` (card shadow, default), `.elevated` (lifted shadow). |
| `DSHeroCard` | DesignSystem | Glass-by-default hero surface. Uses Liquid Glass on iOS 26+, `.ultraThinMaterial` fallback. |
| `GlassCard` | DesignSystem | Glass card with `.lifted` depth. Good for stat pills and featured content. |
| `DSSection` | DesignSystem | Title + optional trailing action + content. |
| `DSSegmentedControl` | DesignSystem | Animated pill toggle with concentric inner radius. Uses `.compositingGroup()` before glass to prevent flicker. |
| `DSChoiceButton` | DesignSystem | Selectable button with icon badge, checkmark indicator, tinted selected state. Shadow on selection. Supports disabled state (40% opacity). |
| `DSTextField` | DesignSystem | Filled background text field (no border). Focus state shows plum tint + purple shadow glow. Icon color transitions between states. Convenience: `.email()`, `.password()`, `.name()`. Styles: `.bordered` (filled, default), `.underline`. |
| `DSInfoCard` | DesignSystem | Center-aligned icon + text compact card with semantic tint background. |
| `DSScreen` | DesignSystem | Scrollable screen wrapper with optional title and consistent padding. |
| `AmbientBackground` | DesignSystem | Radial plum gradient background. Color-scheme-aware intensity (light 2.8x, dark 2.0x multiplier). |
| `BottomFadeModifier` | DesignSystem | `.bottomFade()` modifier for pinned bottom bars. Gradient dissolve + solid fill through safe area. |
| `HeroIcon` | DesignSystem | Icon with rounded-square background. Corner radius scales proportionally (25% of tile size). |
| `IconTileSurface` | DesignSystem | Uses `Circle()` for circular shapes (not squircle). Borderless on non-glass path. |
| `StaggeredVStack` | DesignSystem | Container with cascading fade-in entrance animation. Use `.staggeredAppearance(index:)` on children. |
| `EmptyStateView` | DesignSystem | Tinted circle icon bg + title + message + optional action. |
| `ErrorStateView` | DesignSystem | Error circle icon bg + title + message + retry. |
| `ToastView` | DesignSystem | Auto-dismissing notification. Create via `Toast.success()`, `.error()`, `.warning()`, `.info()`. |
| `DSListCard` | Components | Card container for list rows with dividers. Borderless, shadow-only. |
| `DSListRow` | Components | Compact row with leading icon, title, subtitle, trailing view. |

### Craft Patterns

- **Floating CTAs**: Use `safeAreaInset(edge: .bottom)` + `.bottomFade()` for pinned action buttons. Content dissolves cleanly beneath.
- **Staggered entrances**: Wrap dashboard sections in `StaggeredVStack` with `.staggeredAppearance(index:)` for cascading reveal.
- **Hero stats**: Oversized numbers (48-52pt bold rounded) for primary metrics. "Flighty energy" — bold, confident.
- **Stat pills**: Centered vertical layout (icon → number → label) with tinted `GlassCard` backgrounds.
- **Layout stability**: Use opacity control to hide optional elements (like back buttons) instead of conditional rendering. Reserve space with invisible spacers for symmetric padding.
- **Toolbar buttons (iOS 26)**: Don't fight the system. `DSIconButton` with `showsBackground: false` renders a native button that gets perfect circular Liquid Glass automatically.
- **Glass containers with animation**: Use `.compositingGroup()` before `.glassEffect()` when animated content lives inside glass. Prevents flicker.

---

## Navigation Patterns

The app uses [AppRouter](https://github.com/Dimillian/AppRouter) for navigation.

### AppTab (TabView)
Each tab is a case in `AppTab` enum. To add a tab:
```swift
// In AppTab.swift
case myTab

var icon: String { "star" }
var title: String { "My Tab" }

@MainActor @ViewBuilder
func makeContentView() -> some View {
    MyTabView()
}
```

### AppRoute (NavigationStack push)
Push destinations within a tab's NavigationStack:
```swift
// In AppRoute.swift — add a case
case myDetail

// Navigate from any view with router access
router.navigate(to: .myDetail)
```

### AppSheet (Modal presentation)
Bottom sheets and full-screen covers:
```swift
// In AppSheet.swift — add a case
case myModal

// Present from any view with router access
router.presentSheet(.myModal)
```

---

## Adding a Data Model

1. **Create model**: In `Forge/Managers/[ManagerName]/Models/YourModel.swift`.
2. **Required conformances**: `StringIdentifiable, Codable, Sendable`.
3. **CodingKeys**: Use `snake_case` raw values.
4. **Example**:
```swift
struct Item: StringIdentifiable, Codable, Sendable {
    let id: String
    let title: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case createdAt = "created_at"
    }
}
```
5. **Create a manager**: Service managers use protocol + Mock/Prod pattern. See `Forge/Managers/` for examples.

---

## Setting Up a New Project from This Template

To transform this Forge template into your own app, install skills from the Forge marketplace:

```bash
claude plugin marketplace add https://github.com/sakhnenkoff/forge-marketplace
claude plugin install forge-workspace@forge-marketplace
```

Then say "set up Forge for [my app name]" and the skill will walk you through renaming, branding, feature configuration, and content customization.

Or build an entire app at once: `/forge:app` — describe your idea, get a running polished app (`claude plugin install forge-app@forge-marketplace`)

Other available skills from the same marketplace:
- `forge-app` — build a complete app from an idea (`claude plugin install forge-app@forge-marketplace`)
- `forge-feature` — quality pipeline: scaffold, build, polish, verify (`claude plugin install forge-feature@forge-marketplace`)
- `forge-wire` — connect to backend services (`claude plugin install forge-wire@forge-marketplace`)
- `forge-ship` — App Store pre-flight audit and submission prep (`claude plugin install forge-ship@forge-marketplace`)
- `forge-screens` — scaffold architecture-correct feature screens (`claude plugin install forge-screens@forge-marketplace`)
- `swiftui-craft` — premium design polish + soul (`claude plugin install swiftui-craft@forge-marketplace`)

---

## Additional Resources

- AppRouter: https://github.com/Dimillian/AppRouter
