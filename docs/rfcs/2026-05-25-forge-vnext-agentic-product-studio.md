# RFC: Forge vNext — Agentic Product Studio Pipeline

Status: Draft for Matvii review
Date: 2026-05-25
Related charter: `docs/forge-vnext-charter.md`
Checkpoint: `docs/forge-vnext-interview-checkpoint.md`
Kanban: board `forge`, card `t_e800422a`

## Summary

Forge vNext upgrades Forge into an agentic product studio for iOS apps. The system should not merely generate Swift code. It should research an opportunity, choose a direction, design an app-specific experience, build a modular native app, verify it with real evidence, prepare an app-specific launch package, and then learn from the run.

## Motivation

Previous Forge work proved parts of the pipeline but also exposed failure modes:

- app-shaped outputs can look plausible while being weak products
- DayRateLab should not be polished as a product
- verifier logic became too app-specific
- scaffold UI/design-system reuse creates generic results
- template contamination is dangerous
- overclaiming success from weak evidence damages trust

The next work must improve Forge itself, not hand-polish a generated app.

## Goals

- Generalize the pipeline beyond DayRateLab.
- Add hard product/taste/design/research/launch gates.
- Enforce app-specific design systems and visual proof.
- Prioritize strict modular native architecture, even if slower.
- Generate a second proof app from scratch in its own repo.
- Produce a TestFlight-ready local package and app-specific launch package.
- Score app quality and pipeline quality separately.
- Produce reviewed learning patches after the run.

## Non-goals

- Do not turn DayRateLab into a polished product.
- Do not mutate the Forge template into a sample app.
- Do not ship/TestFlight/App Store-submit without approval.
- Do not create live monetization/signing/account changes without approval.
- Do not optimize for speed by sacrificing modularity and inspectability.

## Proposed pipeline

### Phase 1: Research

Inputs:
- broad web/browser research
- App Store/competitor scans
- forums/social/user-pain evidence
- pricing/paywall examples

Outputs:
- evidence matrix
- confidence levels
- cited sources
- research judge critique
- three app directions
- one recommendation
- explicit evidence gaps

Gate:
- Matvii approves direction after seeing recommendation plus early product/design evidence.

### Phase 2: Product strategy

Outputs:
- target user
- painful problem
- core workflow
- repeat-use loop
- monetization thesis
- app-specific launch bar
- app-specific score thresholds
- kill/repair recommendation if needed

Gate:
- weak dimensions are diagnosed and repair options are proposed.
- Matvii decides kills.

### Phase 3: Design

Outputs:
- visual references/moodboard
- original app-specific design synthesis
- design-system tokens/components/copy principles
- HTML/clickable prototype
- first-screen visual proof

Gate:
- no generic scaffold reskin
- design must balance Apple-native elegance, distinctive identity, and workflow clarity
- Matvii reviews 3 options with tradeoffs where appropriate

### Phase 4: Native implementation

Architecture:
- SwiftUI-first
- strict modularity
- separate Swift packages / mini buildable feature apps where useful
- small components
- mock data/tests/previews
- app repo separate from Forge repo

Gate:
- feature slices should build/test independently when practical
- native screenshot review before expanding scope

### Phase 5: Verification

Evidence when feasible:
- tests
- build
- run
- native screenshots
- simulator video/core-flow proof
- accessibility/UI snapshots where available
- audit receipt

Gate:
- two repair loops after failure, then ask
- do not overclaim success if evidence is missing

### Phase 6: Launch package

App-specific output may include:
- App Store Connect-ready local drafts
- name/subtitle/description/keywords/promotional copy
- positioning variants
- privacy declaration draft
- pricing/paywall recommendation
- local paywall prototype if approved
- native proof screenshots
- polished App Store marketing screenshots
- TestFlight-ready local checklist
- developer/launch handoff

Approval:
- real App Store Connect, TestFlight, App Store, signing, bundle/account, privacy declaration, or monetization activation requires explicit approval.

### Phase 7: Learning

Outputs:
- app scorecard
- pipeline scorecard
- postmortem
- evidence index
- reviewed learning patch proposals

Learning patch targets:
- gates
- prompts
- verifier rules
- architecture templates
- optional modules
- design references
- docs/scripts
- curated/vendored external tools/skills

Forge owns durable learning artifacts. External orchestrators may summarize them.

## Safety model

Allowed without asking:
- local non-destructive actions
- local code/artifact creation
- local generated app repos
- local builds/tests/screenshots/videos
- web/browser research
- temp/generated junk cleanup

Ask before:
- repo/app deletion
- public/external actions
- money/paid activation
- credentials/secrets/accounts/signing/bundle IDs/entitlements
- work-system access
- TestFlight/App Store/live monetization
- merges/publishing

Git push:
- allowed after local tests pass
- remote creation/publish still follows repo/app approval expectations

## Operator UX

During early vNext proving runs:
- ask at every major gate
- message after every agent/gate finishes
- present major decisions as 3 options with tradeoffs
- escalate meaningful agent disagreements
- final report is timeline: decisions, evidence, scores, next actions

## Acceptance criteria for this RFC

This RFC is implemented when:

- `docs/forge-vnext-charter.md` exists and is treated as the owner charter.
- Pipeline gates are converted into executable/checkable artifacts.
- Verifier is generalized beyond DayRate-specific literals.
- A second proof app is generated in its own repo.
- The app has app-specific design artifacts and native evidence.
- The app has a proposed launch package.
- Final skeptical audit returns a clear verdict with app score and pipeline score.
- Learning patch proposals are produced for Forge.

## Open implementation choices

These should be decided during execution, not guessed in this RFC:

- exact file paths/formats for gate artifacts
- whether launch-package tooling is vendored or called externally
- exact native modular package structure
- exact score thresholds for the selected second proof app
- which app idea becomes the second proof app
