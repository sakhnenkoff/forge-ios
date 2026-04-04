# Forge

**Build unique iOS apps from an idea — not from a template that looks like a template.**

Forge is an iOS app template with a Claude Code skill pipeline that takes you from "I have an app idea" to a running, polished app with its own visual identity and design. 6 skills handle everything: spec conversation, design contract, screen building with quality evaluation, backend connection, App Store listing, and submission prep.

The template provides Swift architecture (MVVM, navigation, design system tokens, component structure). The pipeline produces a spec (`spec.json`) and design contract (`DESIGN.md`), then builds each feature through a Generator + Judge loop — so the result looks like YOUR app, not like every other Forge project.

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

     Spec Conversation (6 adaptive questions)
     ├── Pitch + target
     ├── Monetization + CRO (paywall/onboarding optimization)
     ├── Reference apps
     ├── Core screens + flows
     ├── Color + mood direction
     └── Brand confirmation

     Visual Design (3 paths)
     ├── Full: references + mockups + direction review
     ├── References-only: gather refs, write DESIGN.md from conversation (recommended)
     └── Conversation-only: no external tools, fastest

     Contract Generation
     ├── spec.json (features, models, navigation)
     └── DESIGN.md (design contract — colors, typography, components, copy)

     Sprint Loop (per feature)
     ├── Generator builds screen from DESIGN.md
     ├── Judge evaluates (Design Quality, Originality, Craft, Architecture)
     ├── Fix loop (if Judge fails, max 2 rounds)
     └── Human approves screenshot

     Finalization
     ├── Cross-screen consistency check
     ├── Navigation wiring verification
     └── Completion report

     Post-build:
     ├── forge-wire ──── Connect to backend
     ├── forge-storefront ── App Store listing
     └── forge-ship ──── Submission prep
```

## Skills (6 plugins)

All installable from the [Forge Marketplace](https://github.com/sakhnenkoff/forge-marketplace):

```bash
claude plugin marketplace add https://github.com/sakhnenkoff/forge-marketplace
```

| Skill | Install | Purpose |
|-------|---------|---------|
| `forge-app` | `claude plugin install forge-app@forge-marketplace` | Planner — idea → spec.json + DESIGN.md → sprint orchestration |
| `forge-feature` | `claude plugin install forge-feature@forge-marketplace` | Feature pipeline with forge-build (Generator) + forge-judge (Evaluator) |
| `forge-workspace` | `claude plugin install forge-workspace@forge-marketplace` | Project setup — rename, brand, configure |
| `forge-wire` | `claude plugin install forge-wire@forge-marketplace` | Backend — Firebase, Supabase, REST, GraphQL, CloudKit |
| `forge-ship` | `claude plugin install forge-ship@forge-marketplace` | Submission prep — privacy, accessibility, metadata |
| `forge-storefront` | `claude plugin install forge-storefront@forge-marketplace` | App Store listing — screenshots, description, keywords |

## Optional Enhancements

Auto-detected and integrated when installed. Not required — the pipeline has inline fallbacks.

| Plugin | Install | What It Adds |
|--------|---------|-------------|
| **Superpowers** | `claude plugin install superpowers@claude-plugins-official` | Brainstorming, planning, code review |
| **Axiom** | Available via Claude Code | Deep iOS auditing (accessibility, security, memory, energy) |
| **Playwright** | `claude plugin install playwright@claude-plugins-official` | Visual design research (Mobbin, Dribbble, Behance) |
| **Impeccable** | `claude plugin install impeccable@claude-plugins-official` | Automated design critique + polish — auto-fixes spacing, hierarchy, consistency |
| **Marketing Skills** | [Install guide](https://github.com/coreyhaines31/marketingskills) | 29 marketing skills — pricing, CRO, copywriting, launch strategy, SEO |

Marketing Skills are auto-detected by forge-app (pricing), forge-feature (paywall/onboarding CRO), and forge-storefront (launch strategy).

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
├── .forge/
│   ├── spec.json             # What to build (features, models, navigation, status)
│   └── DESIGN.md             # How it should look (design contract — colors, typography, components, do's/don'ts, copy)
└── Forge.xcodeproj           # 3 schemes: Mock, Development, Production
```

The `.forge/` directory is created during the build and preserves all decisions across sessions.

### Design System

The DS provides code architecture — token system, component APIs, modifier patterns. The visual output is customized per app based on the design contract in `.forge/DESIGN.md`.

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
