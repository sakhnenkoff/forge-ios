# AGENTS.md

Agent-only reference for building in this project. Human docs are in README.md.

---

## Build

```bash
xcodebuild -project Forge.xcodeproj -scheme "Forge - Mock" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build
```

- Warnings from app code are blockers — fix before finishing.
- Warnings from external packages (SPM) are acceptable.
- Use Mock scheme for development (no Firebase required).

---

## Architecture

```
View → ViewModel → Services/Managers
```

- **ViewModel**: `@MainActor @Observable` (never `ObservableObject`)
- **View**: `@State private var viewModel` (never `@StateObject`)
- **Services**: Injected via `@Environment(AppServices.self)`, `@Environment(AppSession.self)`
- **Navigation**: `@Environment(Router<AppTab, AppRoute, AppSheet>.self)`

### Concurrency

- App target: strict concurrency (`complete`), defaults to `MainActor`
- Upcoming features enabled: `NonisolatedNonsendingByDefault`, `InferIsolatedConformances`
- Package targets (`Packages/core-packages`): do NOT default to `MainActor` — use explicit annotations
- No `@unchecked Sendable` / `nonisolated(unsafe)` without `SAFETY:` comment + TODO

### File Creation

- Xcode 15+ File System Synchronization — files created in the app folder auto-appear in Xcode
- Always use Write/Edit tools for .swift files

---

## View Rules

- `DSScreen(title:)` as root container
- `.toast($viewModel.toast)` modifier on every screen
- `.onAppear { viewModel.onAppear(services:session:) }` — include `session` when the screen uses user/auth data, `onAppear(services:)` otherwise
- `@State` ONLY for UI animation flags (`isAnimating`, `showSheet`) — all data in ViewModel
- No business logic in `body` — all logic in ViewModel
- All component data injected via `init`, all actions are closures
- `.frame(maxWidth: .infinity, alignment: .leading)` over `Spacer()`
- `ImageLoaderView` for URL images (never `AsyncImage`)
- `DSButton` / `DSIconButton` for all interactive elements

### ViewModel Rules

- `var toast: Toast?` property
- `private var hasLoaded = false` guard pattern in `onAppear`
- `Event` enum conforming to `LoggableEvent` — track `onAppear` + key actions
- Track events via `services.logManager.trackEvent(event:)`

### Loading & States

**Skeleton loading** for screens with loadable data. ViewModels initialize with placeholder items.
The View renders the same layout in both states — `.redacted(reason: .placeholder)` toggles skeleton.
No full-screen spinners.

```swift
// ViewModel
@Observable class HabitListViewModel {
    var habits: [Habit] = Habit.placeholders  // placeholder data for skeleton
    var isLoading = true
    var isEmpty: Bool { !isLoading && habits.isEmpty }

    func load(services: AppServices) async {
        do {
            habits = try await services.habitManager.fetchAll()
        } catch {
            toast = .error(error.localizedDescription)
        }
        isLoading = false
    }
}

// View
List(viewModel.habits) { habit in
    HabitRow(habit: habit)
}
.redacted(reason: viewModel.isLoading ? .placeholder : [])
.overlay { if viewModel.isEmpty { ContentUnavailableView("No habits", systemImage: "tray") } }
.refreshable { await viewModel.load(services: services) }
.task { await viewModel.load(services: services) }
```

**When to use:**
- Screens that load data from a manager → skeleton loading + empty state + error toast
- Static screens (Settings, About, Onboarding, Paywall) → no loading, no states
- Detail views receiving data from parent → no loading (data already available)

**Empty states:** `ContentUnavailableView` with copy from `.forge/DESIGN.md` (Section 8 — Voice & Copy).
**Errors:** `Toast.error()` — never replace content with an error screen.
**Refresh:** `.refreshable { }` — existing content stays visible during refresh.

### Error Handling

Standardized error handling in ViewModels — errors show as toasts, never replace content:

```swift
func load(services: AppServices) async {
    do {
        habits = try await services.habitManager.fetchAll()
    } catch {
        toast = .error(error.localizedDescription)
    }
    isLoading = false
}

func delete(_ habit: Habit) async {
    do {
        try await services.habitManager.delete(habit.id)
        habits.removeAll { $0.id == habit.id }
    } catch {
        toast = .error("Couldn't delete. Try again.")
    }
}
```

**Rules:**
- Network/persistence errors → `Toast.error()` with user-friendly message
- Validation errors → inline field errors (not toast)
- Save failures → toast with retry guidance
- Never show raw error messages (`error.localizedDescription` only for debug)
- Use DESIGN.md Section 8 (Voice & Copy) error copy when available

### Mock Data on Models

Every model used by a manager must have static placeholder and mock data:

```swift
extension Habit {
    /// Placeholder items for skeleton loading — same shape, dummy content
    static let placeholders: [Habit] = (0..<4).map {
        Habit(id: "\($0)", name: "Placeholder", streak: 0, createdAt: .now)
    }
    /// Realistic mock data for MockManagers
    static let mockList: [Habit] = [
        Habit(id: "1", name: "Morning Run", streak: 12, createdAt: ...),
        Habit(id: "2", name: "Read for 30 minutes before bed with a very long name that tests truncation", streak: 5, ...),
        // 5-8 items with edge cases:
        // - One very long name (tests text truncation)
        // - One with nil optional fields (tests optional handling)
        // - Dates spanning past/today/future
        // - Zero and high numeric values
        // - Empty string fields where applicable
    ]
    static let mockSingle: Habit = mockList[0]
}
```

---

## Patterns

### Adding a Feature

1. Create `{App}/Features/{Feature}/{Feature}View.swift` + `{Feature}ViewModel.swift`
2. If this screen reads/writes domain data → create a Feature Manager first (see below)
3. ViewModel: `@MainActor @Observable`, `toast`, `hasLoaded`, `Event` enum (see View/ViewModel Rules)
4. If manager exists → wire ViewModel to `services.{feature}Manager`, use skeleton loading pattern
5. View: `DSScreen` root, environment injections, `.toast()`, `.onAppear()`
6. Wire navigation: add case to `AppTab`/`AppRoute`/`AppSheet`, wire destination view
7. Read `.forge/DESIGN.md` for Component Strategy and Screen Blueprints before choosing components

### Adding a Feature Manager

When a feature reads/writes domain data, create a manager BEFORE the ViewModel:

1. Create protocol: `{App}/Managers/{Feature}/{Feature}Manager.swift`
2. Create mock implementation in the same file
3. Register in `AppServices` — add protocol property and mock initializer
4. ViewModel accesses via `services.{feature}Manager`

```swift
// Protocol — backend-agnostic contract
// No Sendable needed: app target defaults to @MainActor, so protocol
// inherits MainActor isolation. When forge-wire adds a real backend
// that runs off MainActor, the protocol may need @Sendable or become
// an actor — but for mock builds, MainActor isolation is correct.
protocol HabitManagerProtocol {
    func fetchAll() async throws -> [Habit]
    func create(_ habit: Habit) async throws
    func update(_ habit: Habit) async throws
    func delete(_ id: String) async throws
}

// Mock — in-memory, implicitly @MainActor (app target default)
final class MockHabitManager: HabitManagerProtocol {
    private var habits: [Habit] = Habit.mockList
    func fetchAll() async throws -> [Habit] { habits }
    func create(_ habit: Habit) async throws { habits.append(habit) }
    func update(_ habit: Habit) async throws {
        if let i = habits.firstIndex(where: { $0.id == habit.id }) { habits[i] = habit }
    }
    func delete(_ id: String) async throws {
        habits.removeAll { $0.id == id }
    }
}
```

**Which screens get managers:**
- Screens that list/create/edit/delete domain objects → YES
- Settings, About, Onboarding, Paywall → NO (static content)
- Dashboard aggregating from existing managers → uses existing managers, no new one
- Detail view receiving data from parent → NO (data already loaded)

Register in `AppServices` — the active implementation is selected by build configuration.
Access in ViewModel via `services.{feature}Manager`.

### Component Creation

When creating reusable components in `{App}/Components/Views/`:
- All data properties optional for flexibility
- No business logic — components are pure UI
- All actions are closures (`onTap: () -> Void`)
- Follow existing DS component naming and structure patterns

### AppServices Dependency Injection

```swift
// In View — inject from environment
@Environment(AppServices.self) private var services
@Environment(AppSession.self) private var session

// In onAppear — pass to ViewModel
viewModel.onAppear(services: services, session: session)

// In ViewModel — use services
func onAppear(services: AppServices, session: AppSession) {
    services.logManager.trackEvent(event: Event.onAppear)
    // Access any manager: services.authManager, services.purchaseManager, etc.
}
```

---

## File Locations

```
{App}/App/                    — App shell, AppDelegate, navigation
{App}/Features/{Feature}/     — View + ViewModel per feature
{App}/Managers/{Manager}/     — Service managers (protocol + Mock/Prod)
{App}/Models/                 — Data models
{App}/Components/Views/       — Reusable UI components
{App}/Extensions/             — Swift extensions
{App}/Configurations/         — xcconfig files (Mock, Dev, Prod)
{App}/Theme/                  — Custom Theme struct
Packages/core-packages/       — DesignSystem, Core, CoreMock
```

---

## Navigation

Uses [AppRouter](https://github.com/Dimillian/AppRouter).

**Tab**: Add case to `AppTab` — implement `icon`, `title`, `makeContentView()`.
**Push**: Add case to `AppRoute` — wire in `AppRouterViewModifiers.swift`. Navigate: `router.navigate(to:)`
**Sheet**: Add case to `AppSheet` — wire in `AppTabsView.swift`. Present: `router.presentSheet(_:)`

---

## Data Models

- Location: `{App}/Models/` or `{App}/Managers/{Manager}/Models/`
- Conform to: `StringIdentifiable, Codable, Sendable`
- `snake_case` for CodingKeys raw values
- `id: String` first field, `createdAt: Date` last

---

## DS Component Reference

These are the TEMPLATE defaults. When `.forge/DESIGN.md` Component Strategy says COMPOSE or CREATE a component, that decision overrides what's listed here.

### Tokens

- **Spacing**: `DSSpacing.xs` (4), `.sm` (8), `.smd` (12), `.md` (16), `.mlg` (20), `.lg` (24), `.xl` (32), `.xxl` (40), `.xxlg` (48)
- **Radii**: `DSRadii.xs` (8), `.sm` (12), `.md` (12), `.lg` (16), `.xl` (20)
- **Layout**: `DSLayout.iconXS` (16), `.iconSmall` (20), `.iconMedium` (22), `.iconLarge` (28), `.avatarSmall` (44), `.avatarLarge` (68), `.cardMaxWidth` (360)
- **Colors**: `Color.themePrimary`, `.textPrimary`, `.textSecondary`, `.textTertiary`, `.textOnPrimary`, `.border`, `.error`, `.divider`, `.backgroundPrimary`, `.backgroundSecondary`, `.surface`, `.surfaceVariant`
- **Typography**: `.display()`, `.titleLarge()`, `.titleMedium()`, `.titleSmall()`, `.headlineMedium()`, `.headlineSmall()`, `.bodyLarge()`, `.bodyMedium()`, `.bodySmall()`, `.captionLarge()`, `.buttonSmall()`, `.buttonMedium()`, `.buttonLarge()`
- **Shadows**: `DSShadows.soft`, `.card`, `.lifted` — brand-tinted by default

### Components

| Component | Usage |
|-----------|-------|
| `DSButton` | `.primary`, `.secondary`, `.tertiary`, `.destructive`. Use `.cta()` for full-width. |
| `DSIconButton` | Icon-only with optional circle background. `showsBackground: false` for toolbar (iOS 26 glass). |
| `DSCard` | Surface container. Depth: `.flat`, `.raised`, `.elevated`. Configurable tint and glass. |
| `DSHeroCard` | Hero surface with glass support. Wraps `GlassCard`. |
| `GlassCard` | Card with glass support. Configurable radius, tint, tilt. |
| `DSSection` | Title + optional trailing action + content. |
| `DSSegmentedControl` | Animated pill toggle. Uses `.compositingGroup()` before glass. |
| `DSChoiceButton` | Selectable button with icon, checkmark, tinted selected state. |
| `DSTextField` | `.bordered` or `.underline`. Convenience: `.email()`, `.password()`, `.name()`. |
| `DSInfoCard` | Center-aligned icon + text with semantic tint. |
| `DSScreen` | Scrollable screen wrapper with title and padding. |
| `AmbientBackground` | Brand-tinted radial gradient. Color-scheme-aware intensity. |
| `StaggeredVStack` | Cascading fade-in entrance. Use `.staggeredAppearance(index:)`. |
| `EmptyStateView` | Icon + title + message + optional action. |
| `ErrorStateView` | Error icon + title + message + retry. |
| `ToastView` | Auto-dismissing. `Toast.success()`, `.error()`, `.warning()`, `.info()`. |
| `DSListCard` | Card container for list rows with dividers. |
| `DSListRow` | Compact row: leading icon, title, subtitle, trailing view. |

### Craft Patterns

Available patterns — use what serves the app's mood (from `.forge/DESIGN.md`):

- **Floating CTAs**: `safeAreaInset(edge: .bottom)` + `.bottomFade()`
- **Staggered entrances**: `StaggeredVStack` with `.staggeredAppearance(index:)`
- **Layout stability**: Opacity control to hide views (reserve frame space), not conditional rendering
- **Toolbar (iOS 26)**: `DSIconButton(showsBackground: false)` for system Liquid Glass
- **Glass + animation**: `.compositingGroup()` before `.glassEffect()` to prevent flicker
- **Concentric corners**: Inner radius = outer radius - padding

---

## Post-Build Checks

After building a screen, code is scanned for these patterns. Violations require fixes before the screen is accepted.

**Architecture (hard gate — every screen):**
- View MUST contain: `DSScreen`, `.toast(`, `.onAppear`, `AppServices.self`
- View MUST NOT contain: `AsyncImage`, `@StateObject`
- ViewModel MUST contain: `@Observable`, `hasLoaded`, `LoggableEvent`, `var toast: Toast?`

**Data patterns (screens with a feature manager):**
- Manager file MUST contain: protocol definition, `Mock` implementation
- Model MUST contain: `static let placeholders`, `static let mockList`, `StringIdentifiable`
- View MUST contain: `.redacted(reason:`, `ContentUnavailableView`
- ViewModel MUST contain: `toast = .error` or `Toast.error`

**Component quality (warnings):**
- No `Font.system(size:` — use DS typography (`.display()`, `.titleLarge()`, `.bodyMedium()`, etc.)
- No `Color(red:` / `Color(#` / `Color(.sRGB` — use semantic colors (`.themePrimary`, `.textPrimary`, etc.)

---

## Quality Floor vs Style Freedom

### Quality Floor (Non-Negotiable — ensures professional quality)
- DS typography tokens — `.display()`, `.titleLarge()`, etc., never `Font.system(size:)`
- Semantic colors — `Color.themePrimary`, `.textPrimary`, etc., never `Color.green`/`Color.black`
- DS components — `DSButton`, `DSCard`, `DSScreen`, etc., never raw `Button()`/`TextField()`
- Entrance animation — some intentional entrance (`StaggeredVStack`, matched geometry, custom transitions — whatever the blueprint specifies)
- Visual hierarchy — one dominant element per screen, at least 3 text sizes
- Spacing rhythm — spacing varies between sections, not uniform padding everywhere
- Depth variation — multiple surface levels, not everything flat
- Error handling — `Toast` for errors, `ContentUnavailableView` for empty states

### Style Freedom (Comes from the Blueprint — differs per app)
These are NOT enforced as rules. They come from the human-approved `DESIGN.md`:
- Background treatment (AmbientBackground, solid, gradient, image — blueprint decides)
- Surface style (borderless, bordered, glass, shadow — blueprint decides)
- Color temperature (warm, cool, neutral — blueprint decides)
- Animation personality (bouncy, smooth, snappy — blueprint decides)
- CTA placement (floating, inline, bottom bar — blueprint decides)
- Component emphasis (which components to use where — blueprint decides)

---

## Template Screens as Quality Reference

The template has polished screens (Onboarding, Home, Settings, Paywall).
READ them to understand the QUALITY BAR (animation timing, component usage,
state management, transitions). Then REPLACE the template's style choices
with your blueprint's style choices. The template shows HOW WELL to build.
The blueprint shows WHAT to build.

### How to Customize Onboarding
The template onboarding at `{App}/Features/Onboarding/` demonstrates the quality bar:
- `OnboardingView.swift` — flow container with entrance animation
- `OnboardingStep.swift` — individual step rendering with DS components
- `OnboardingController.swift` — flow state machine with proper state management
Read these files to understand the QUALITY of implementation. Then implement your
blueprint's specific design (different animations, components, layout are fine).
Key patterns to preserve: flow state machine, DS component usage, toast support.

### How to Customize Home/Dashboard
The template home at `{App}/Features/Home/` demonstrates:
- `HomeView.swift` — section-based layout with hero element
- `HomeViewModel.swift` — skeleton loading, mock data wiring, analytics events
Key patterns to preserve: section rhythm, skeleton loading, DS component usage.

### How to Customize Settings
The template settings at `{App}/Features/Settings/` demonstrates:
- `SettingsView.swift` — grouped list with `DSListCard` + `DSListRow`
- Destructive actions with confirmation, version display
Key patterns to preserve: grouped row structure, destructive action handling.

### How to Customize Paywall
The template paywall at `{App}/Features/Paywall/` demonstrates:
- `PaywallView.swift` — value props, plan selection, CTA placement
- `PaywallViewModel.swift` — purchase flow state management
Key patterns to preserve: value hierarchy, plan selection pattern, purchase flow.

---

## Design System Override Priority

When building screens, `.forge/DESIGN.md` is the design authority:

1. **Component Strategy** (KEEP/COMPOSE/CREATE/SKIP) overrides the component table above
2. **Screen Blueprints** override generic layout patterns
3. **Design Synthesis** overrides default token values
4. **Template Departures** list what NOT to do from the defaults above

This file provides architecture. `.forge/DESIGN.md` provides design. When they conflict, DESIGN.md wins.
