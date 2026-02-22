# Design: forge-app — Whole-App Orchestrator

**Date:** 2026-02-22
**Status:** Approved

---

## Problem

`forge-feature` builds individual features well, but there's no skill that takes a developer from "I have an app idea" to a fully built, polished, running iOS app. Today, building a whole app requires manually invoking forge-workspace, then forge-feature for each screen, tracking dependencies yourself, and hoping for consistency across screens.

## Solution

A top-level orchestrator skill (`/forge:app`) that:
1. Builds an app blueprint through conversation
2. Detects whether the template needs setup (forge-workspace)
3. Executes the blueprint by chaining `forge-feature` calls — adaptive mode per screen
4. Delivers a running, polished app on Mock scheme

Part of a larger pipeline with planned future skills for backend wiring and App Store submission.

---

## The Forge Ecosystem

```
forge-workspace → forge-app → forge-wire → forge-ship
   (setup)        (build)      (connect)    (submit)
```

Each skill is independent and invocable separately. They're designed to chain but don't require each other.

- **forge-workspace** — rename, brand, configure the template
- **forge-app** — build the whole app (screens, flows, polished UI) ← THIS DESIGN
- **forge-wire** — connect to backend services (planned future)
- **forge-ship** — prepare for App Store submission (planned future)

---

## forge-app Design

### Input: Conversational Spec-Building

The developer starts with a rough idea. The orchestrator asks ~5-10 adaptive questions to build a blueprint. Not a rigid questionnaire — it adapts based on answers.

**Structural questions (forge-app handles these directly):**
1. What does the app do? (one-sentence pitch)
2. Who is it for? (target user — informs design decisions)
3. What are the core screens? (orchestrator proposes based on pitch, user confirms/adjusts)
4. Data models — what entities exist? (habits, entries, categories, etc.)
5. Key user flows — what does the user do first? Daily loop?
6. Tab structure — which screens are tabs vs pushes vs sheets?
7. Monetization — free, freemium, subscription? (maps to paywall config)

**Creative direction (delegated to superpowers:brainstorming when available):**
- Visual direction — brand color, reference apps for feel
- What should make this app stand out?
- Design principles ("minimal like Things", "data-rich like Streaks")

When `superpowers:brainstorming` is not available, forge-app handles creative direction with simpler inline questions (brand color, 1-2 reference apps).

### Output: The Blueprint

After the conversation, the orchestrator produces a structured blueprint — the contract for what gets built:

```
App: HabitFlow
Pitch: Daily habit tracker with streaks, reminders, and weekly stats
Brand: Indigo
Reference: Things 3, Streaks

Screens:
1. [complex] Dashboard (Tab: Home) — grid of today's habits with completion toggles
2. [simple]  Habit Detail (Push from Dashboard) — streak calendar, stats, edit
3. [simple]  Add Habit (Sheet from Dashboard) — name, icon, color, frequency, reminder
4. [complex] Stats (Tab: Stats) — weekly/monthly completion charts, best streaks
5. [simple]  Onboarding — customize for habit tracking (3 slides)
6. [simple]  Paywall — customize for premium features
7. [skip]    Settings — already exists, minor config only

Data Models:
- Habit: name, icon, color, frequency, reminderTime, createdAt
- HabitEntry: habitId, date, completed

Navigation:
- Tabs: Dashboard, Stats, Settings
- Pushes: Dashboard → Habit Detail
- Sheets: Dashboard → Add Habit, Habit Detail → Edit Habit
```

Each screen gets a complexity tag: `[simple]`, `[complex]`, or `[skip]`. This determines whether forge-feature runs in quick or full mode.

The developer reviews and approves the blueprint before any code is written.

### Execution Engine

After blueprint approval:

**Step 1 — Smart workspace detection:**
- Check if the project has been set up (app name != "Forge", bundle ID configured)
- If not: invoke `forge-workspace` with app name, brand color, and domain from blueprint
- If already set up: skip to building

**Step 2 — Data model creation:**
- Create SwiftData models from the blueprint's data model section
- These are shared across screens, so they must exist before screen building starts

**Step 3 — Screen-by-screen execution:**
For each screen in the blueprint order:
- Pass the screen description, data models, and navigation context to `forge-feature`
- `[simple]` screens → `forge-feature` quick mode (scaffold → build → polish → verify)
- `[complex]` screens → `forge-feature` full mode (+ planning and review)
- `[skip]` screens → minor configuration only, no scaffold

**Step 4 — Final verification:**
- Full `xcodebuild` on Mock scheme
- Verify all navigation works (tabs, pushes, sheets)
- Report summary of what was built

### Autonomy + Checkpoints

**Default: high autonomy.** The orchestrator builds screen after screen without stopping.

The developer controls checkpoints:
- **Before execution:** "Checkpoint after dashboard and stats"
- **During execution:** "Stop" or "let me review" — interrupts current screen
- **Implicit:** After each screen, the orchestrator briefly reports progress. Developer can say "keep going" (or say nothing — it continues) or "wait, change X"

If no checkpoints requested, the orchestrator runs the entire blueprint end-to-end, then presents the final result.

### Superpowers Integration

| Phase | Superpowers skill | Role | Fallback |
|-------|-------------------|------|----------|
| Spec conversation | `superpowers:brainstorming` | Creative direction questions | Inline: brand color + reference app questions |
| Blueprint | `superpowers:writing-plans` | Structure the blueprint as a formal plan | Inline: generate blueprint directly |
| Per-screen | (via forge-feature) | Planning/review for complex screens | forge-feature inline fallbacks |
| Final review | `superpowers:requesting-code-review` | Whole-app architecture review | Inline: AGENTS.md checklist across all files |
| Completion | `superpowers:verification-before-completion` | Verify the app actually runs | Inline: xcodebuild + run check |

### Ralph Loop Integration

Ralph Loop is handled entirely within `forge-feature` at the per-screen level. forge-app does not activate Ralph separately. When forge-feature detects iterative UI work on a complex screen, it offers Ralph to the developer.

### GSD Integration

For apps with 8+ screens, the blueprint will trigger GSD auto-escalation within `forge-feature` calls. This provides:
- Persistent state across sessions (if context overflows)
- Atomic commits per logical boundary
- Goal-backward verification

forge-app itself doesn't invoke GSD directly — it lets forge-feature handle escalation per its existing rules.

---

## Token Cost Estimates

| App Size | Screens | Estimated Tokens | Approximate Cost |
|----------|---------|-----------------|-----------------|
| Small (3-4 screens) | 3-4 | 600K-900K | ~$2.50-3.50 |
| Medium (5-7 screens) | 5-7 | 1.0M-1.7M | ~$4-7 |
| Large (8-12 screens) | 8-12 | 1.8M-3.0M | ~$7-12 (multi-session via GSD) |

Medium apps fit within a single 1M-context session. Large apps will span multiple sessions with GSD managing continuity.

---

## Planned Future Skills

### forge-wire (backend connection)

**Purpose:** Connect the polished app to real backend services.

**Backend-agnostic.** The Forge template abstracts services behind managers (AuthManager, DataManager, LogManager). forge-wire plugs in the right implementation for the developer's chosen stack.

**Supported backends:**
- Firebase / Firestore
- Supabase
- REST API (POST/GET with custom endpoints)
- GraphQL (with schema)
- CloudKit
- Local only (SwiftData, no sync)

**Supported auth:**
- Firebase Auth
- Supabase Auth
- Custom JWT
- Apple-only (AuthenticationServices)

**Supported analytics:**
- Firebase Analytics
- Mixpanel
- PostHog
- Custom endpoint
- None

**How it works:** Conversational — asks which services the developer wants, then generates/modifies the manager implementations to connect to real endpoints. Guides Firebase/Supabase setup if the developer hasn't done it yet.

### forge-ship (App Store submission)

**Purpose:** Prepare the app for App Store submission.

**Scope:**
- Unit test scaffolding for ViewModels and Managers
- Privacy manifest generation (PrivacyInfo.xcprivacy)
- App Store metadata prep (description, keywords, screenshots guidance)
- Build configuration for Production scheme
- Code signing guidance
- Pre-submission checklist (accessibility, age rating, export compliance)

**How it works:** Audits the current app state, identifies gaps, and fills them. Can invoke Axiom skills (accessibility auditor, security scanner) for compliance checks.

---

## File Structure

New plugin in forge-marketplace:

```
forge-app/
├── claude-code.json
└── skills/
    └── forge-app/
        ├── SKILL.md              # Main orchestrator logic
        └── references/
            ├── blueprint.md      # Blueprint structure and examples
            └── execution.md      # Execution engine rules, mode selection, checkpoints
```

---

## Success Criteria

1. Developer goes from "I want a habit tracker" to running app in one session (for medium apps)
2. Every screen uses DS components and follows AGENTS.md rules
3. Navigation works end-to-end (tabs, pushes, sheets)
4. App compiles on Mock scheme with zero errors
5. UI looks polished — not generic or template-like
6. Blueprint accurately captures what gets built (no surprises)
7. Works with zero third-party plugins (superpowers/GSD/Ralph optional)
8. Commercially distributable (MIT license, no proprietary dependencies)
