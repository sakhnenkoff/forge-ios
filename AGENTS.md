# AGENTS.md

This file provides guidance to AI coding agents when working with this repository.

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
4. **Design craft**: When building or refining UI, use the `swiftui-craft` skill (`claude plugin marketplace add sakhnenkoff/swiftui-craft && claude plugin install swiftui-craft@swiftui-craft-marketplace`). It guides premium, Apple-native design — researching real award-winning apps for inspiration, applying six craft dimensions (typography, color, composition, motion, material, micro-interactions), and detecting the project's design system to use its tokens.

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
- **Radii**: `DSRadii.sm` (8), `.md` (12), `.lg` (16), `.xl` (20)
- **Colors**: `Color.themePrimary`, `.textPrimary`, `.textSecondary`, `.textTertiary`, `.textOnPrimary`, `.surface`, `.surfaceVariant`, `.backgroundPrimary`, `.border`, `.error`, `.divider`
- **Typography**: `.display()`, `.titleLarge()`, `.titleMedium()`, `.titleSmall()`, `.headlineMedium()`, `.headlineSmall()`, `.bodyMedium()`, `.bodySmall()`, `.captionLarge()`, `.buttonSmall()`, `.buttonMedium()`, `.buttonLarge()`

### Components

| Component | Location | Usage |
|-----------|----------|-------|
| `DSButton` | DesignSystem | `.primary`, `.secondary`, `.tertiary`, `.destructive` styles. Use `.cta()` for full-width primary. Primary/destructive have colored shadows. |
| `DSIconButton` | DesignSystem | Icon-only button with optional circle background. |
| `DSCard` | DesignSystem | Surface container with depth: `.flat` (subtle shadow + border), `.raised` (default), `.elevated`. All depths show border. |
| `DSSection` | DesignSystem | Title + optional trailing action + content. |
| `DSSegmentedControl` | DesignSystem | Animated pill toggle with primary-tinted shadow on selected pill. |
| `DSTextField` | DesignSystem | Styled text field with focus tint. Convenience: `.email()`, `.password()`, `.name()`. Styles: `.bordered` (default), `.underline`. |
| `DSScreen` | DesignSystem | Scrollable screen wrapper with optional title and consistent padding. |
| `EmptyStateView` | DesignSystem | Tinted circle icon bg + title + message + optional action. Convenience: `.noSearchResults()`, `.emptyList()`. |
| `ErrorStateView` | DesignSystem | Error circle icon bg + title + message + retry. Convenience: `.networkError()`, `.serverError()`. |
| `ToastView` | DesignSystem | Auto-dismissing notification with leading color accent bar. Create via `Toast.success()`, `.error()`, `.warning()`, `.info()`. |
| `DSListCard` | Components | Card container for list rows with dividers. |
| `DSListRow` | Components | Compact row with leading icon, title, subtitle, trailing view. |

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

## Additional Resources

- AppRouter: https://github.com/Dimillian/AppRouter
