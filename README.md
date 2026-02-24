# Forge

**Generate polished, domain-specific iOS apps in minutes.**

Forge is a monorepo scaffolding product that generates production-ready iOS apps with SwiftUI, Firebase, RevenueCat, and a clean design system. Choose an archetype, configure your features, and get a $50K-looking app from the CLI.

---

## Quick Start

### Create a new app from the template

```bash
./scripts/new-app.sh MyAppName ~/Documents/Developer/Apps com.mycompany.myapp "My App"
cd ~/Documents/Developer/Apps/MyAppName
open *.xcodeproj
```

This creates a fully renamed, ready-to-build project. Select the **Mock** scheme and run.

> **Never manually copy the template** with `cp -R` or `rsync`. The CLI tool handles renaming the project, bundle ID, imports, and directory structure correctly.

### Or use Claude Code to build the entire app

```bash
claude plugin marketplace add https://github.com/sakhnenkoff/forge-marketplace
claude plugin install forge-app@forge-marketplace
```

Then say `/forge:app` — describe your idea and get a running polished app.

### Or use the interactive CLI wizard

```bash
cd forge-cli
swift build
.build/debug/forge
```

The wizard walks you through archetype, project name, bundle ID, auth, monetization, analytics, and features.

---

## Archetypes

| Archetype | Screens | Description |
|-----------|---------|-------------|
| **Blank** | Home, Settings | Clean shell with auth, onboarding, paywall |
| **Finance Tracker** | Dashboard, Transactions, Budgets, Reports | SwiftData + Swift Charts finance app |

### Creating Your Own Archetype

1. Create `Archetypes/{id}/manifest.json` with tabs, routes, screens, models
2. Add Swift files under `Archetypes/{id}/files/` mirroring the app structure
3. Run `forge --archetype {id}` to test

See `Archetypes/finance/manifest.json` for a complete example.

---

## Architecture

```
forge/
├── Forge/                    # iOS app template (SwiftUI, MVVM)
│   ├── App/                  # Entry point, navigation, dependencies
│   ├── Features/             # Home, Auth, Onboarding, Paywall, Settings
│   ├── Managers/             # Auth, Purchases, Push, Logs, User, Data
│   ├── Components/           # Reusable UI components
│   ├── Extensions/           # Swift extensions
│   └── Utilities/            # Config, feature flags, constants
├── ForgeUnitTests/           # Unit tests
├── Packages/core-packages/   # SPM: DesignSystem, Core, CoreMock
├── Archetypes/               # Domain-specific app archetypes
│   ├── blank/                # Default clean shell
│   └── finance/              # Finance Tracker archetype
├── forge-cli/                # CLI tool for project generation
│   └── Sources/ForgeCLI/
│       ├── Commands/         # GenerateCommand, ProgrammaticMode
│       ├── Generator/        # ProjectGenerator, TemplateEngine
│       ├── Archetypes/       # ArchetypeManifest, Injector, Registry
│       ├── Wizard/           # Interactive wizard flow
│       ├── Registry/         # Feature manifests, dependency resolver
│       └── Output/           # Console formatting, next steps
└── Forge.xcodeproj           # Xcode project (3 schemes)
```

### Build Configurations

| Config | Use Case |
|--------|----------|
| **Mock** | Fast development, no Firebase, mock services |
| **Development** | Real Firebase with dev credentials |
| **Production** | Real Firebase with production credentials |

---

## Design System (v2)

15 core components, one adaptive theme, no gimmicks.

### Components

| Component | Purpose |
|-----------|---------|
| `DSButton` | Primary, secondary, tertiary, destructive styles |
| `DSIconButton` | Icon-only buttons with optional background |
| `DSTextField` | Styled text input |
| `DSScreen` | Scrollable screen container with navigation title |
| `DSCard` | Clean card container |
| `DSListCard` | Card optimized for list rows |
| `DSListRow` | Compact list row with icon and trailing control |
| `DSSection` | Section with title header |
| `DSSectionHeader` | Standalone section header |
| `DSChoiceButton` | Selectable choice for surveys/onboarding |
| `DSSegmentedControl` | Animated segment picker |
| `DSPillToggle` | Custom boolean toggle |
| `EmptyStateView` | Empty state with icon, title, action |
| `ErrorStateView` | Error state with retry |
| `LoadingView` | Loading indicator |
| `ToastView` | Success/error/warning/info toasts |

### Theme

```swift
// In your app's init:
DesignSystem.configure(theme: AdaptiveTheme(brandColor: .indigo))
```

All colors derive from the single `brandColor`. Token system: `ColorPalette`, `TypographyScale`, `SpacingScale`, `RadiiScale`, `ShadowScale`, `LayoutScale`.

---

## CLI Usage

### Interactive Mode
```bash
forge
```

### Flag Mode (partial or full)
```bash
forge --projectName MyApp --preset standard --archetype finance
```

### Programmatic Mode (for AI agents)
```bash
echo '{"projectName":"MyApp","bundleId":"com.me.myapp","authProviders":["apple"],"monetizationModel":"subscription","analyticsServices":["firebase"],"features":["onboarding"],"archetype":"finance"}' | forge --programmatic
```

---

## Claude Code Skills

Seven AI-powered skills for working with Forge projects, available from a single marketplace:

```bash
claude plugin marketplace add https://github.com/sakhnenkoff/forge-marketplace
```

| Skill | Install | Purpose |
|-------|---------|---------|
| `forge-app` | `claude plugin install forge-app@forge-marketplace` | Build an entire app from an idea |
| `forge-feature` | `claude plugin install forge-feature@forge-marketplace` | Quality pipeline — scaffold, build, polish, verify |
| `forge-wire` | `claude plugin install forge-wire@forge-marketplace` | Connect to backend (Firebase, Supabase, REST, etc.) |
| `forge-ship` | `claude plugin install forge-ship@forge-marketplace` | App Store pre-flight audit + submission prep |
| `forge-workspace` | `claude plugin install forge-workspace@forge-marketplace` | Set up the template — rename, brand, configure features |
| `forge-screens` | `claude plugin install forge-screens@forge-marketplace` | Scaffold architecture-correct feature screens |
| `forge-craft` | `claude plugin install forge-craft@forge-marketplace` | Mood-driven design polish — 7 craft dimensions with visual iteration |

**Full pipeline**: `forge-workspace` (setup) → `forge-app` (build) → `forge-wire` (connect backend) → `forge-ship` (submit)

### Optional Enhancements

These free plugins improve the pipeline but are NOT required:

| Plugin | Install | What it adds |
|--------|---------|-------------|
| Superpowers | `claude plugin install superpowers@claude-plugins-official` | Structured brainstorming, planning, and code review |
| Ralph Loop | `claude plugin install ralph-loop@claude-plugins-official` | Continuous build-test-fix iteration |

---

## Tech Stack

- **UI**: SwiftUI (iOS 18+), Swift 6.0+
- **Auth**: Firebase Auth, Sign in with Apple, Google Sign-In
- **Payments**: RevenueCat
- **Analytics**: Firebase Analytics, Mixpanel, Crashlytics
- **Navigation**: [AppRouter](https://github.com/Dimillian/AppRouter)
- **Design**: Custom design system with adaptive theming
- **Data**: SwiftData (archetypes), Firestore (sync)

---

## License

Proprietary. See LICENSE for details.
