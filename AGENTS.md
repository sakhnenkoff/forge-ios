# AGENTS.md

Agent-only reference for building in this project. Human docs are in README.md.

---

## Build

```bash
xcodebuild -project Forge.xcodeproj -scheme "Forge - Mock" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
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
- `.onAppear { viewModel.onAppear(services:session:) }` on every screen
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

**Empty states:** `ContentUnavailableView` with voice-guide copy from `.forge/voice-guide.md`.
**Errors:** `Toast.error()` — never replace content with an error screen.
**Refresh:** `.refreshable { }` — existing content stays visible during refresh.

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
        Habit(id: "2", name: "Read for 30 minutes before bed", streak: 5, ...),
        // 5-8 items, varied content, realistic data
        // Include: one long name, one with nil optional fields, varied dates
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
7. Read `.forge/design-system.md` for Component Strategy and Screen Blueprints before choosing components

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

These are the TEMPLATE defaults. When `.forge/design-system.md` Component Strategy says MODIFY or REPLACE a component, that decision overrides what's listed here.

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

Available patterns — use what serves the app's mood (from `.forge/design-system.md`):

- **Floating CTAs**: `safeAreaInset(edge: .bottom)` + `.bottomFade()`
- **Staggered entrances**: `StaggeredVStack` with `.staggeredAppearance(index:)`
- **Layout stability**: Opacity control to hide views (reserve frame space), not conditional rendering
- **Toolbar (iOS 26)**: `DSIconButton(showsBackground: false)` for system Liquid Glass
- **Glass + animation**: `.compositingGroup()` before `.glassEffect()` to prevent flicker
- **Concentric corners**: Inner radius = outer radius - padding

---

## Design System Override Priority

When building screens, `.forge/design-system.md` is the design authority:

1. **Component Strategy** (KEEP/MODIFY/REPLACE) overrides the component table above
2. **Screen Blueprints** override generic layout patterns
3. **Design Synthesis** overrides default token values
4. **Template Departures** list what NOT to do from the defaults above

This file provides architecture. `.forge/design-system.md` provides design. When they conflict, design-system.md wins.
