# Forge

## About

Forge is a production-ready iOS 26+ SwiftUI template that ships with MVVM, AppRouter navigation, and clean integrations for Firebase, Mixpanel, RevenueCat, and Google Sign-In. It’s designed to stay simple at the surface while scaling to real-world product complexity.


## Features

- AppRouter-powered navigation (tabs + deep links + sheets)
- MVVM views with `@Observable` view models
- Three build configurations (Mock, Dev, Production)
- Firebase integration (Auth, Firestore, Analytics, Crashlytics)
- RevenueCat for in-app purchases
- Mixpanel analytics
- Consent + ATT settings
- Push notification routing hooks
- Gamification system (Streaks, XP, Progress)

## Requirements

- Xcode 16+ (iOS 26 SDK)
- Swift 5.9+

## Getting Started

See [docs/getting-started.md](docs/getting-started.md) for the full guide, including build configurations, Firebase setup, and RevenueCat configuration.

**Quick start (zero credentials):**
1. Clone this repository
2. Open in Xcode, select **Forge - Mock** scheme
3. Run on simulator — no credentials needed, no API keys

**For production setup:**
- [Getting Started](docs/getting-started.md) — prerequisites, build configs, Firebase and RevenueCat setup
- [Architecture Guide](docs/architecture.md) — MVVM layers, data flow, conventions
- [Adding a Feature](docs/adding-a-feature.md) — step-by-step guide with a complete worked example

## Build

Use direct `xcodebuild`:

```bash
xcodebuild -project Forge.xcodeproj -scheme "Forge - Mock" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
```

Resolve all app warnings before shipping. External package warnings are acceptable.

## Scripts

- `rename_project.sh` - Rename the project (optional `--bundle-id` and `--display-name`)
- `scripts/new-app.sh` - Copy the template to a new folder and rename in one step
- `scripts/setup-secrets.sh` - Create `Secrets.xcconfig.local` from the example file

## Navigation

- Tabs and routes are defined in `Forge/App/Navigation/`
- Use `AppRoute` for push navigation and `AppSheet` for modal flows
- Deep links are handled via `.onOpenURL` in `AppTabsView`

## Internal Packages (SPM)

The shared modules live in `forge-core-packages` and are consumed as a single SPM dependency (Core + DesignSystem).

- Remote dependency: `https://github.com/sakhnenkoff/forge-core-packages.git`
- Local override: in Xcode, use `File > Packages > Add Local...` to point to a local clone when iterating

## SDKs Used

- Firebase (Auth, Firestore, Analytics, Crashlytics, Messaging, RemoteConfig, Storage)
- Mixpanel
- RevenueCat
- GoogleSignIn

## Documentation

- [Getting Started](docs/getting-started.md) — prerequisites, build configs, Firebase and RevenueCat setup
- [Architecture Guide](docs/architecture.md) — MVVM layers, data flow, conventions
- [Adding a Feature](docs/adding-a-feature.md) — step-by-step guide with a complete worked example

## License

MIT License - See [LICENSE.txt](LICENSE.txt) for details.
