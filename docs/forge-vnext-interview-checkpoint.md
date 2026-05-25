# Forge vNext Interview Checkpoint

Purpose: durable checkpoint so Telegram/Hermes turn limits or context resets do not lose the Forge vNext interview.

Kanban source of truth:
- Board: `forge`
- Card: `t_e800422a` — `Forge vNext charter: pipeline, not proof app`
- Interview answers saved as Kanban comments through Q105.

Next requested action:
- Synthesize Forge vNext charter now.
- Output should include: rewritten Kanban card, markdown charter, and Forge repo RFC/spec.

## Core Forge vision

Forge should become an agentic product studio for launchable iOS apps:
research → product strategy → design → modular native app → verification → app-specific launch package → learning loop.

Forge is the product. Generated apps are proof + deliverables, not mutations of the Forge template.

## Non-bullshit app bar

A generated app needs:
- real painful user problem
- sharp target user/use case and repeat-use loop
- distinctive app-specific design/look/feel
- believable money path
- verified native build/run/screenshots/tests/evidence

Weak dimensions should be diagnosed and repaired. Forge recommends kill/repair, but Matvii decides every kill.

## Safety/autonomy

Allowed without asking:
- all local non-destructive actions
- local builds/tests/screenshots/artifacts
- local generated app repos
- broad web/browser research
- temp/generated junk cleanup

Approval required:
- public/external/money/credentials/work-system actions
- repo/app deletion
- TestFlight/App Store actions
- signing/account/bundle/credential changes
- work-system access, every time

Git remote:
- push allowed after local tests pass
- merge/publish still requires appropriate approval

First Forge vNext trial:
- stop and ask at every major gate
- two repair loops after failed gate, then ask

## Success proof for Forge vNext

Forge vNext succeeds when all are true:
- generalized pipeline + second app passes audit
- second app reaches TestFlight-ready local package
- Forge produces full app-specific launch package
- not just a prototype/build

## Architecture direction

- SwiftUI-first
- modern iOS patterns
- strict modularity even if slower
- separate Swift packages / mini buildable apps for features/user flows
- readable file structure, small components, tests/previews/mock data
- generated apps each get their own repo eventually; local first, remote later after approval/tests

## Design direction

Design is not polish. It is a gate.

Rules:
- custom design system per app
- no scaffold reskin bullshit
- balance Apple-native elegance, distinctive brand/personality, and workflow clarity per app
- use references + original synthesis
- app-specific emotional tone
- distinctiveness can include typography/colors/icons, interaction/workflow shape, empty states, copy, microinteractions
- require HTML/clickable prototype + native screenshot gates
- motion/haptics should be tasteful, app-specific, useful

## Research and product strategy

- Forge proposes 3 app directions, recommends 1
- approval should include early product/design evidence, not just text ideas
- research depth is app-specific
- demand evidence should be triangulated across multiple sources
- cite sources + confidence levels
- save evidence matrix
- judge agent critiques research quality
- weak evidence but promising idea → ask Matvii with confidence/evidence gaps
- revenue vs personal taste conflict → make tradeoff explicit; Matvii decides

## Launch package

Launch package is app-specific and proposed by Forge.

May include:
- App Store Connect-ready local drafts
- positioning/copy variants
- competitor-informed copy
- native proof screenshots
- polished App Store marketing screenshots
- privacy/data collection draft, human-approved before live use
- pricing/paywall research and local prototype

Helpful external refs to investigate/vet:
- `ParthJadhav/app-store-screenshots`
- `coreyhaines31/marketingskills`

No live App Store/TestFlight/monetization/account actions without approval.

## Learning loop

After each generated app:
- structured scorecard + postmortem
- app score and pipeline score separately
- app-specific thresholds for pass/repair/kill/candidate
- propose reviewable learning patches
- Forge is source of truth for durable learning
- orchestrators/tools/vault/Kanban may read/summarize Forge artifacts
- external tools/skills should be curated/vendored after vetting, not used ad hoc

## Operator UX

- decision-rich taste/control gates
- Telegram compact cards, Kanban, and local HTML reports depending on moment
- major gate approval should present 3 options with tradeoffs
- message after every agent/gate finishes
- final run report should be timeline: decisions, evidence, scores, next actions
- meaningful agent disagreements escalate to Matvii with summary/tradeoffs/recommendation

## Post-launch

- actively create iteration backlog after launch
- use user feedback/reviews, analytics/retention/monetization, crash/performance/quality signals
- after approval, Forge can run a full iteration cycle
- portfolio strategy: opportunistic apps; reuse infra when useful
