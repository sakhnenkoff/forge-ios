# Forge

**Build unique iOS apps from an idea — not from a template that looks like a template.**

Forge is an iOS app template with a Claude Code skill pipeline that takes you from "I have an app idea" to a running, polished app with its own visual identity, voice, and feature design. 10 skills handle everything: feature UX, design system customization, content strategy, screen building, backend connection, App Store listing, and submission.

The template provides Swift architecture (MVVM, navigation, design system tokens, component structure). The pipeline researches what your specific app needs and customizes everything — tokens, components, backgrounds, copy, interactions — so the result looks like YOUR app, not like every other Forge project.

## Quick Start

### With Claude Code (recommended)

```bash
# Add the Forge skill marketplace
claude plugin marketplace add https://github.com/sakhnenkoff/forge-marketplace

# Install the orchestrator
claude plugin install forge-app@forge-marketplace
```

Then say `/forge:app` — describe your app and the pipeline handles the rest.

### Manual setup

```bash
./scripts/new-app.sh MyAppName ~/Documents/Developer/Apps com.mycompany.myapp "My App"
cd ~/Documents/Developer/Apps/MyAppName
open *.xcodeproj
```

Select the **Mock** scheme and run. See AGENTS.md for architecture conventions.

> **Never manually copy the template** with `cp -R`. The script handles renaming the project, bundle ID, imports, and directory structure.

## The Pipeline

```
/forge:app → Describe your idea

     Spec Conversation
     ├── What does it do?
     ├── Who is it for?
     ├── What should it feel like?
     └── Visual references?

     Blueprint → Approved

     Step 1: Project Setup ─────── forge-workspace
     Step 2: Feature Design ────── forge-ux
     Step 3: Design System ─────── forge-craft + forge-eye
     Step 4: Voice & Content ───── forge-voice
     Step 5: Data Models
     Step 6: Screen Execution ──── forge-feature (per screen)
     Step 7: Navigation Wiring
     Step 8: Final Verification

     Post-build:
     ├── forge-wire ──── Connect to backend
     ├── forge-storefront ── App Store listing
     └── forge-ship ──── Submission prep
```

## Skills (10 plugins)

All installable from the [Forge Marketplace](https://github.com/sakhnenkoff/forge-marketplace):

```bash
claude plugin marketplace add https://github.com/sakhnenkoff/forge-marketplace
```

| Skill | Install | Purpose |
|-------|---------|---------|
| `forge-app` | `claude plugin install forge-app@forge-marketplace` | Orchestrator: idea → running app |
| `forge-ux` | `claude plugin install forge-ux@forge-marketplace` | Feature experience design — user journeys, states, aha moment |
| `forge-craft` | `claude plugin install forge-craft@forge-marketplace` | Mood-driven visual design — 7 craft dimensions, Playwright research |
| `forge-voice` | `claude plugin install forge-voice@forge-marketplace` | Content strategy — app voice, all copy, tonal consistency |
| `forge-feature` | `claude plugin install forge-feature@forge-marketplace` | Per-screen pipeline — scaffold, build, polish, verify |
| `forge-screens` | `claude plugin install forge-screens@forge-marketplace` | Scaffold View + ViewModel pairs |
| `forge-workspace` | `claude plugin install forge-workspace@forge-marketplace` | Project setup — rename, brand, configure |
| `forge-storefront` | `claude plugin install forge-storefront@forge-marketplace` | App Store listing — screenshots, description, keywords |
| `forge-wire` | `claude plugin install forge-wire@forge-marketplace` | Backend — Firebase, Supabase, REST, GraphQL, CloudKit |
| `forge-ship` | `claude plugin install forge-ship@forge-marketplace` | Submission prep — privacy, accessibility, metadata |

## Optional Enhancements

Auto-detected and integrated when installed. Not required — the pipeline has inline fallbacks.

| Plugin | Install | What It Adds |
|--------|---------|-------------|
| **Superpowers** | `claude plugin install superpowers@claude-plugins-official` | Brainstorming, planning, code review |
| **Ralph Loop** | `claude plugin install ralph-loop@claude-plugins-official` | Continuous build-test-fix iteration |
| **Axiom** | Available via Claude Code | Deep iOS auditing (accessibility, security, memory, energy) |
| **Playwright** | `claude plugin install playwright@claude-plugins-official` | Visual design research (Mobbin, Dribbble, Behance) |
| **Marketing Skills** | [Install guide](https://github.com/coreyhaines31/marketingskills) | 29 marketing skills — pricing, CRO, copywriting, launch strategy, SEO |

Marketing Skills are auto-detected by forge-app (pricing), forge-feature (paywall/onboarding CRO), forge-voice (copywriting), and forge-storefront (launch strategy).

## Architecture

```
forge/
├── Forge/                    # iOS app (SwiftUI, MVVM)
│   ├── App/                  # Entry point, navigation, dependencies
│   ├── Features/             # Screen pairs (View + ViewModel)
│   ├── Managers/             # Auth, Purchases, Push, Logs, User, Data
│   ├── Components/           # Reusable UI components
│   └── Configurations/       # Mock/Dev/Prod xcconfig, feature flags
├── Packages/core-packages/
│   └── DesignSystem/         # Tokens, components, theme
├── scripts/
│   └── new-app.sh            # Create new project from template
├── AGENTS.md                 # All architecture conventions
└── Forge.xcodeproj           # 3 schemes: Mock, Development, Production
```

### Design System

The DS provides code architecture — token system, component APIs, modifier patterns. The visual output is customized per app in Step 3 (Design System) based on mood and research.

```swift
// Brand color drives the entire token system
DesignSystem.configure(theme: AdaptiveTheme(brandColor: .indigo))
```

Token groups: `ColorPalette`, `TypographyScale`, `SpacingScale`, `RadiiScale`, `ShadowScale`, `GlassTokens`. All customizable in `AdaptiveTheme.swift`. Components (`DSButton`, `DSCard`, `DSScreen`, etc.) read from tokens — change the tokens, change everything.

### Build Configurations

| Config | Use Case |
|--------|----------|
| **Mock** | Development — no Firebase, mock services |
| **Development** | Real Firebase with dev credentials |
| **Production** | Real Firebase with production credentials |

## Tech Stack

- **UI**: SwiftUI (iOS 18+), Swift 6.0+
- **Auth**: Firebase Auth, Sign in with Apple, Google Sign-In
- **Payments**: RevenueCat
- **Analytics**: Firebase Analytics, Mixpanel, Crashlytics
- **Navigation**: AppRouter
- **Design**: Adaptive theme system with Liquid Glass support (iOS 26+)
- **Data**: SwiftData, Firestore

## License

Proprietary. See LICENSE for details.
