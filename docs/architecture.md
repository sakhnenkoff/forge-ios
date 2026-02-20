# Architecture Guide

Forge uses layered MVVM (Model-View-ViewModel) with a feature-based folder structure and a single dependency container (`AppServices`).

## Layer Overview

```
ForgeApp.swift              ← App entry point
    └── AppRootView.swift      ← Root navigation (driven by AppSession.rootState)
        └── AppTabsView.swift  ← Tab-based navigation
            └── Features/      ← Feature screens (one folder per feature)
                ├── View.swift         ← UI only, reads from ViewModel
                └── ViewModel.swift    ← Business logic, calls Managers
                    └── Managers/      ← Domain logic (Auth, User, Purchases, etc.)
                        └── Services/  ← External SDK adapters (Firebase, RevenueCat)
                            └── SPM Packages  ← Core, DesignSystem
```

## 1. Application Layer (`Forge/App/`)

Bootstraps the app, initializes services, and manages global routing state.

- **`ForgeApp.swift`** — `@main` entry point, applies DesignSystem theme, creates `AppServices` and `AppSession`, injects them into the SwiftUI environment
- **`AppDelegate.swift`** — UIApplication lifecycle, Firebase initialization, push notification handling
- **`AppRootView.swift`** — Root conditional navigation: reads `AppSession.rootState` to decide which top-level view to show (loading → onboarding → auth → paywall → app)
- **`AppSession.swift`** — Global observable state: auth status, premium status, onboarding completion, paywall dismissal. Single source of truth for top-level routing.
- **`AppServices.swift`** — Dependency container: creates all managers based on build configuration. Inject via `@Environment(AppServices.self)`.

### Post-Onboarding Routing

`AppSession.rootState` routes through this priority order after onboarding completes:

1. **Auth screen** — if `FeatureFlags.enableAuth` && not signed in && not dismissed
2. **Paywall screen** — if `FeatureFlags.enablePurchases` && not premium && not dismissed
3. **Main app** — `AppTabsView`

To change routing behavior, modify the `shouldShowAuth` / `shouldShowPaywall` computed properties in `AppSession.swift`. The `// MARK: - Post-Onboarding Routing` comment marks the configuration point.

## 2. Feature Layer (`Forge/Features/`)

One folder per user-facing feature, each with a View + ViewModel pair.

```
Features/
├── Auth/
│   ├── AuthView.swift          ← Renders sign-in UI, reads viewModel state
│   └── AuthViewModel.swift     ← Calls services.authManager, updates AppSession
├── Home/
│   ├── HomeView.swift
│   └── HomeViewModel.swift
├── Onboarding/
│   ├── OnboardingView.swift
│   ├── OnboardingController.swift
│   └── OnboardingStep.swift
├── Paywall/
│   ├── PaywallView.swift
│   ├── PaywallViewModel.swift
│   ├── CustomPaywallView.swift
│   └── PremiumUnlockedView.swift
└── Shared/
    └── Templates/              ← Example screens showing common patterns
```

**Pattern:**
- Views are `struct` — UI only, no business logic
- ViewModels are `@MainActor @Observable final class` — all business logic
- Views read from ViewModels via `@State private var viewModel = SomeViewModel()`
- ViewModels receive `AppServices` and `AppSession` as function arguments (not stored properties)

## 3. Manager Layer (`Forge/Managers/`)

Domain-specific business logic. Each manager encapsulates one concern.

| Manager | Responsibility |
|---------|---------------|
| `AuthManager` | Sign-in, sign-out, session restoration |
| `UserManager` | Fetching and saving user profiles (Firestore) |
| `PurchaseManager` | Product fetching, purchasing, entitlement checking |
| `LogManager` | Analytics event tracking (routes to Mixpanel, Firebase, Crashlytics) |
| `ABTestManager` | A/B test variant assignment via Firebase Remote Config |
| `PushManager` | Push notification authorization and routing |

**Example — loading user data:**
```swift
// HomeViewModel.swift
func loadUser(services: AppServices) async {
    do {
        user = try await services.userManager.getUser()
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

## 4. Service Layer (`Forge/Managers/*/`)

Thin adapters over external SDKs. Each manager has a protocol-based service interface, enabling Mock substitution.

```swift
// Protocol
protocol AuthService {
    func signInWithApple() async throws -> UserAuthInfo
}

// Real implementation
class FirebaseAuthService: AuthService { ... }  // Dev/Prod builds

// Mock implementation
class MockAuthService: AuthService { ... }       // Mock build
```

The build configuration (`Mock.xcconfig` vs `Development.xcconfig`) determines which service implementations `AppServices` creates via `BuildConfiguration.current`.

## 5. Package Layer (`forge-core-packages`)

Shared modules consumed as a local SPM dependency:

- **Core** — shared models (`UserModel`, `UserAuthInfo`), protocols, and utilities
- **DesignSystem** — tokens (`DSSpacing`, `DSRadii`, `DSShadows`), components (`DSButton`, `DSListRow`, `GlassCard`), and themes (`CleanTheme`, `CloudPetalTheme`, etc.)

## Full Data Flow Example: Sign In With Apple

Here's what happens when a user taps "Sign in with Apple":

```
1. AuthView
   └── User taps "Sign in with Apple"
       └── viewModel.signInApple(services: services, session: session)

2. AuthViewModel.signInApple()
   └── isLoading = true
       └── try await services.authManager.signIn(with: .apple)

3. AuthManager.signIn(with: .apple)
   └── authService.signInWithApple()
       └── Presents ASAuthorizationController (Apple's native UI)
           └── User authenticates with Face ID / Touch ID

4. Apple returns credential
   └── Firebase Auth: signIn(with: credential)
       └── Firebase returns FirebaseUser
           └── AuthManager returns UserAuthInfo

5. AuthViewModel receives UserAuthInfo
   └── currentUser = try await services.userManager.getUser()
       └── session.updateAuth(user: userInfo, currentUser: currentUser)

6. AppSession.updateAuth()
   └── self.auth = user           ← triggers @Observable reactivity
       └── markAuthDismissed()    ← prevents auth screen from showing again

7. AppRootView sees rootState change
   └── rootState recomputes:
       ├── isOnboardingComplete? YES
       ├── shouldShowAuth? NO (just signed in)
       ├── shouldShowPaywall? depends on FeatureFlags.enablePurchases
       └── → .paywall or .app
```

## Conventions

### @Observable ViewModels

All ViewModels use `@Observable` (not `ObservableObject`). Properties are automatically tracked — no `@Published` needed.

```swift
@MainActor
@Observable
final class HomeViewModel {
    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?
    var toast: Toast?
}
```

### @Environment Injection

Services and session are injected via the SwiftUI environment. Never pass them as init parameters.

```swift
struct HomeView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @State private var viewModel = HomeViewModel()
    // ...
}
```

### AppServices as Dependency Container

`AppServices` holds all managers. Pass it to ViewModel methods rather than storing it in the ViewModel.

```swift
// Correct: pass AppServices to methods
func loadData(services: AppServices) async { ... }

// Wrong: store AppServices in ViewModel init
init(services: AppServices) { self.services = services }
```

### Analytics in ViewModels

Track analytics events from ViewModels, not Views. Use `services.logManager.trackEvent()`.

```swift
// Correct
func onAppear(services: AppServices) {
    services.logManager.trackEvent(eventName: "Home_Appear", type: .analytic)
}
```

### Error Handling

Managers throw typed errors (`AuthError`, `PurchaseError`). ViewModels catch them and set `errorMessage` or `toast` for display. Use `toast = .error(...)` for transient failures that shouldn't block the UI, and `errorMessage` for persistent failures that prevent the screen from functioning.

```swift
do {
    try await services.authManager.signIn(with: provider)
} catch {
    errorMessage = error.localizedDescription
}
```

### Navigation

- **Push navigation**: Use `router.navigateTo(.routeCase, for: .tabCase)` — routes are defined in `AppRoute.swift` and registered in `AppRouterViewModifiers.swift`
- **Modal sheets**: Use `router.presentSheet(.sheetCase)` — sheets are defined in `AppSheet.swift`
- **Deep links**: Handled via `.onOpenURL` in `AppTabsView.swift`, parsed by `AppRoute.from(path:fullPath:parameters:)`
