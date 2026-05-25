# Forge vNext Charter

Date: 2026-05-25
Source: Forge interview, Kanban board `forge`, card `t_e800422a`, answers through Q105.

## One-line mission

Forge vNext turns Forge from an app-shaped Swift generator into an agentic product studio that can research, design, build, verify, package, and learn from launchable iOS apps.

## Core stance

Forge is the product.

Generated apps are:
- customer-facing deliverables when good enough
- proof artifacts for the pipeline
- learning material for Forge

Generated apps must not mutate or contaminate the Forge template. Each generated proof app should live in its own local repo first, then eventually its own remote repo after approval/tests.

## What Forge must produce

For each app run, Forge should move through:

1. Market/product research
2. Three app directions + one recommendation
3. Early product/design proof for the recommended direction
4. Human approval gate
5. App-specific design system
6. HTML/clickable prototype
7. Modular SwiftUI native implementation
8. Build/test/run/screenshot/video/audit evidence when feasible
9. App-specific launch package
10. Structured postmortem + learning patch proposal

## Non-bullshit app bar

A generated app is not good enough unless it has:

- real painful user problem
- sharp target user and use case
- repeat-use loop
- distinctive app-specific look and feel
- believable money path
- native implementation that builds/runs
- screenshots and evidence proving the core experience
- app-specific launch path

Weaknesses must be diagnosed and repaired. Forge may recommend killing an idea, but Matvii decides every kill.

## Quality model

Forge must score the app and the Forge pipeline separately.

The scorecard should use:
- overall score
- hard minimums for critical dimensions
- app-specific pass/repair/kill/launch thresholds

A high average cannot hide a failed critical dimension.

Suggested scorecard groups:

### App score
- Pain/problem clarity
- Target user sharpness
- Repeat-use/retention loop
- Visual/product distinctiveness
- Monetization believability
- Native UX quality
- Launch readiness

### Pipeline score
- Research evidence quality
- Gate clarity and enforcement
- Design artifact quality
- Native architecture/modularity
- Verification reliability
- Launch package completeness
- Reusability/generalization
- Learning quality

## Success proof for Forge vNext

Forge vNext succeeds only if all are true:

- The pipeline is generalized beyond DayRateLab.
- A second app is generated from scratch through the pipeline.
- The second app passes skeptical audit.
- The second app reaches TestFlight-ready local package quality.
- Forge produces a full app-specific launch package.
- Evidence proves the app is not just a prototype or static build.

## Safety and autonomy

Allowed without asking:
- all local non-destructive actions
- local code/artifact edits in approved worktrees
- local generated app repos
- local builds/tests/screenshots/video artifacts
- broad web/browser research
- cleanup of temporary/generated junk

Always ask before:
- public/external actions
- spending money or activating paid services
- credentials/secrets/accounts/signing/bundle IDs/entitlements
- work-system access, every time
- TestFlight/App Store actions
- live monetization setup
- deleting repos/apps
- merge/publish operations

Git rule:
- pushing is allowed after local tests pass
- merging/publishing still needs appropriate approval

Early vNext trial rule:
- stop and ask at every major gate
- if a gate fails, try two repair loops, then ask

## Research rules

Research depth is app-specific.

Forge should triangulate demand across multiple evidence types, such as:
- existing paid apps
- App Store and search demand
- competitor reviews
- forums/social pain signals
- pricing/paywall patterns
- niche context

Research output must include:
- sources
- confidence levels
- evidence matrix
- judge critique of research quality
- explicit evidence gaps

If evidence is weak but the idea feels promising, Forge asks Matvii with confidence level and gaps instead of pretending the research is strong.

If revenue potential conflicts with personal taste/usefulness, Forge makes the tradeoff explicit and Matvii decides.

## Design rules

Design is a gate, not polish.

Each app needs an app-specific design system. Forge must not reuse the scaffold design system with cosmetic tweaks.

Design should balance per app:
- Apple-native elegance
- distinctive brand/personality
- utility/workflow clarity

Forge should use visual references plus original synthesis. References inform the direction; they are not copied.

Each app should define its own emotional tone.

Distinctiveness may come from:
- typography
- colors
- iconography
- interaction model
- workflow shape
- empty states
- copy
- microinteractions
- motion/haptics

Motion/haptics should be tasteful, app-specific, and useful. No generic flourish.

Required design gates:
- references/moodboard before implementation
- HTML/clickable prototype before Swift expansion
- native screenshot review before feature expansion
- final App Store screenshot/metadata review before launch use

## Native architecture rules

Forge should prioritize strict modularity and agent-friendly architecture even if it slows the first build.

Direction:
- SwiftUI-first
- latest iOS patterns
- minimal abstraction
- simple but scalable
- readable file structure
- small editable components
- tests, previews, and mock data around features
- separate Swift packages / mini buildable apps for feature/user-flow isolation

A generated app should be buildable/testable in useful slices, not only as one monolith.

## Verification rules

Minimum before success claim, when feasible:
- tests
- build
- run
- native screenshots
- simulator video or equivalent flow evidence
- audit receipt

If any evidence is not feasible, Forge must explain why and provide substitute evidence.

Forge must not overclaim success from weak evidence.

## Launch package rules

Launch package is app-specific and proposed by Forge.

It may include:
- App Store Connect-ready local drafts
- app name/subtitle/description/keywords/promotional text
- positioning variants
- competitor-informed copy
- privacy/data collection declaration draft
- pricing/paywall recommendation
- local paywall prototype if approved
- native proof screenshots
- polished App Store marketing screenshots
- TestFlight-ready local package checklist
- developer handoff and/or launch handoff

Human approval is required before using real App Store Connect resources, TestFlight, App Store submission, privacy declarations, signing/accounts, or live monetization.

Tools/references to investigate and possibly curate:
- `ParthJadhav/app-store-screenshots`
- `coreyhaines31/marketingskills`

## Learning loop

Forge is the source of truth for durable product/pipeline learning.

Orchestrators such as Kanban, GoalBuddy, vault notes, or dashboards may read and summarize Forge artifacts, but durable learning should live in Forge-owned artifacts.

After every generated app, Forge should produce:
- structured app scorecard
- structured pipeline scorecard
- postmortem
- evidence index
- proposed learning patches

Learning patches may touch:
- prompts
- gates
- verifier rules
- architecture templates
- optional modules
- design references
- docs
- scripts
- curated external tools/skills

Learning patches require human review before becoming durable pipeline changes, especially if they increase complexity.

## Operator UX

Forge should be decision-rich while proving itself.

Control surfaces:
- Telegram compact cards for decisions and updates
- Kanban for workflow state
- local HTML dashboard/report for rich review

Major gate approval messages should present:
- three options
- tradeoffs
- recommendation
- evidence links/artifacts
- clear next action

Forge should message after every agent/gate finishes.

Final run report should be a timeline of:
- decisions
- evidence
- scores
- next actions

Meaningful agent disagreements should be escalated to Matvii with summary, evidence, tradeoffs, and recommendation.

## Post-launch loop

After TestFlight/App Store launch, Forge should actively create an iteration backlog.

Signals:
- user feedback/reviews
- analytics/retention/monetization
- crash/performance/quality

After approval, Forge may run a full iteration cycle through the appropriate gates.

Portfolio strategy:
- build opportunistic apps
- reuse infrastructure and patterns when useful
- do not force a rigid portfolio theme

## Immediate vNext execution target

Do not polish DayRateLab.

The next Forge work should:

1. Convert this charter into executable gates/specs.
2. Audit DayRateLab and previous Forge runs only for pipeline lessons.
3. Generalize verifiers and evidence requirements.
4. Add/repair product, design, research, launch, and learning gates.
5. Generate a second proof app in its own repo.
6. Produce full evidence + launch package.
7. Run skeptical final audit.
8. Propose reviewed learning patches.
