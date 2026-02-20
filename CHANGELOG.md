# Changelog

All notable changes to Forge are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)

## [Unreleased]

## [1.0.0] - 2026-02-19

### Added

**CLI (`forge`)**
- Interactive wizard for project generation with feature selection, back-navigation, and presets
- Feature registry: 8 JSON manifests (Firebase Analytics, Mixpanel, Crashlytics, RevenueCat, Push Notifications, A/B Testing, Onboarding, Image Upload)
- Dependency resolver: automatic inclusion of required features with user confirmation
- Three built-in presets: `minimal`, `standard`, `full`
- Non-interactive mode: all flags provided skips wizard to review step
- `--programmatic` mode: stdin/stdout JSON API for AI agent compatibility (CLI-13)
- Structured error responses with 13 machine-readable error codes in programmatic mode (CLI-14)
- `files_written` list in programmatic success output for agent context
- Template versioning: generated projects include `.template-version` file

**Template (iOS app)**
- Auth flow: Sign in with Apple, Google Sign-In, Email/Password, Anonymous — with error handling and loading states
- Onboarding: multi-step flow with permission requests and value proposition screens
- Paywall: monthly/annual subscription toggle, one-time lifetime purchase option, restore purchases
- Settings: account management, privacy policy, support links, debug menu (hidden in production)
- DesignSystem: CleanTheme with SF Pro and system colors — comment-guided customization point
- MVVM architecture: `@Observable` ViewModels, `AppServices` dependency container, `AppSession` routing
- Security: Keychain-backed sensitive state (premium status, dismissal flags), typed error enums with Crashlytics-compatible error codes
- Testing: Swift Testing unit tests for core managers (AuthManager, UserManager, PurchaseManager, LogManager)
- Mock scheme: builds without backend dependencies for UI development

**Documentation**
- `docs/getting-started.md` — setup, build configurations, first run
- `docs/architecture.md` — MVVM pattern, layer responsibilities, data flow
- `docs/adding-a-feature.md` — how to add feature modules and services to the template
- `docs/cli-usage.md` — CLI interactive, hybrid, non-interactive, and programmatic modes (DOCS-05)
- `docs/cli-flags.md` — complete flag reference with validation rules and interactions (DOCS-06)
- `docs/ai-agent-integration.md` — Claude Code CLAUDE.md snippets and programmatic usage patterns (DOCS-07)
- `docs/features.md` — feature toggle reference and registry manifest schema for extending the registry (DOCS-08)

[1.0.0]: https://github.com/yourorg/forge/releases/tag/v1.0.0
