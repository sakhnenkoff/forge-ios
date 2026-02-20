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

## Documentation Structure

All detailed documentation is in `.claude/docs/`:

| File | Purpose |
|------|---------|
| `rule-loading.md` | Which docs to load for each task (progressive disclosure) |
| `project-structure.md` | Architecture overview, folder structure |
| `mvvm-architecture.md` | MVVM rules, UI guidelines |
| `commit-guidelines.md` | Commit message format |
| `package-dependencies.md` | Direct SDK + package integration |
| `package-quick-reference.md` | Quick snippets and common patterns |
| `design-system-usage.md` | DSButton, EmptyStateView, colors, typography |
| `design-system-recipes.md` | Design system examples and patterns |
| `testing-guide.md` | ViewModel testing, accessibility identifiers |
| `concurrency-guide.md` | Concurrency defaults, isolation rules, migration guardrails |
| `localization-guide.md` | String Catalog workflow |
| `action-create-screen.md` | How to create new MVVM features |
| `action-create-component.md` | How to create reusable components |
| `action-create-manager.md` | How to create new managers |
| `action-create-model.md` | How to create data models |

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

### Rule Loading (Progressive Disclosure)
- Always load `.claude/docs/rule-loading.md` first.
- Then load only the documents relevant to the task; avoid loading all docs by default.
- When switching task type (for example: feature work → testing), refresh loaded docs using `rule-loading.md`.
- If new patterns are introduced, update the relevant rule/doc file in the same change.

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

## Additional Resources

- AppRouter: https://github.com/Dimillian/AppRouter
