# T001 Scout Receipt: Current Forge E2E Pipeline Map

Date: 2026-05-24
Task: T001 fresh scout
Mode: read-only evidence gathering plus this receipt/state update

## Scope

Mapped the current Forge template repo, local and remote marketplace repo, vault intent, old proof commits, superseded goal evidence, existing generated/proof app paths, and concrete pipeline gaps across the goal's required gates.

No template cleanup, reset, revert, push, publish, production credential use, or app implementation was performed.

## Current Repos And State

### Forge template repo

Path: `/Users/matvii/Developer/Personal/forge`
Remote: `git@github.com:sakhnenkoff/forge-ios.git`

Current local branch:

- `main` is at `0d70b5d Record Forge Complete final audit`.
- Remote `origin/main` is `7b77b3d docs: add retrospective fixes spec and implementation plan`.
- Local `main` is four commits ahead of remote.
- `forge-complete-proof-archive` points to the same local head.

The four ahead commits are archived evidence, not acceptable final architecture:

- `a6eadee feat: add Forge v4 product studio MVP`
- `55efa93 docs: record Forge v4 goal completion`
- `f9fb5e4 Prove Forge native app pipeline`
- `0d70b5d Record Forge Complete final audit`

Current untracked files in the Forge repo include this fresh goal board, the superseded goal board, `DESIGN.md`, `.claude/settings.json.bak`, `.playwright-mcp/`, `linear.app/`, and `docs/superpowers/plans/2026-04-13-skill-distribution.md`. These are unrelated or board artifacts and should be excluded from future commits unless explicitly selected by a later Judge.

### Marketplace repo

Path: `/Users/matvii/Developer/Personal/forge-marketplace`
Remote: `git@github.com:sakhnenkoff/forge-marketplace.git`

Local checkout before fetch was clean at `0b6d711 feat: pipeline v3 - visual design phase, code-only Generator, 7-criteria Judge`.

Fresh remote inspection/fetch found `origin/main` at `bf3c6ca fix(forge-plan): correct dependency ordering + enforce NotebookLM`. Remote v5 has a P0-P7 architecture:

- `forge-app`: thin orchestrator, never writes Swift directly.
- `forge-plan`: P0 spec building, competitive research, project setup.
- `forge-design`: P1 DESIGN.md and directional mockups.
- `forge-tailor`: P2 design-system tailoring and gold standard.
- `forge-arch`: P3 models, managers, ViewModels, navigation via Codex.
- `forge-craft`: P4 SwiftUI views through screenshot-driven development.
- `forge-judge`: P5 visual/scoring consistency review.
- `forge-verify`: P6 auditors.
- `forge-ship`: P7 backend, storefront, submission prep.

The remote marketplace manifest exposes only a thin `forge-app` plugin that reads project-local skills. That is aligned with this goal's pipeline-first requirement: the template/app repo should contain the reusable phase instructions and generated app artifacts.

## Existing Pipeline Map

### Current local Forge skill pipeline

The local `README.md` still describes a 6/8 skill pipeline around `/forge:app`, `spec.json`, `DESIGN.md`, per-feature generator/judge loop, and post-build wire/storefront/ship skills.

Important current local skill behavior:

- `skills/forge-app/SKILL.md` detects template vs app project and says template runs should create a new app via `scripts/new-app.sh` before continuing.
- `skills/forge-design/SKILL.md` can translate references to a 9-section `DESIGN.md` and includes useful audits for section bloat and UX hierarchy.
- `skills/forge-build/PROMPT.md` is code-only and enforces core AGENTS architecture, but it does not build/run/screenshot.
- `skills/forge-judge/SKILL.md` evaluates screenshot and code against DESIGN.md, including compliance, craft score, vibe check, and architecture.
- `skills/forge-storefront/SKILL.md` contains useful App Store handoff structure: competitor listings, subtitle, description, keyword and screenshot plan.
- `skills/forge-ship/SKILL.md` in remote v5 consolidates backend wiring, storefront, and submission readiness with explicit credential boundaries.

### Scripts and proof paths

`scripts/new-app.sh` is the existing reusable scaffold path. It copies the template and runs `rename_project.sh`. It is acceptable as a separate-app starting point, but it only produces a renamed template unless later phases generate product-specific `.forge` and SwiftUI output.

`scripts/forge-v4-product-studio.mjs` is deterministic and produces product/spec/journey/screen/visual/app-view artifacts. Its receipt explicitly skipped native build/simulator proof, so it is a supporting stage, not sufficient completion.

`scripts/forge-complete-pipeline.mjs` is useful evidence but unacceptable as the final proof path for this goal. It hardcodes:

- `PROJECT_PATH = "Forge.xcodeproj"`
- `SCHEME = "Forge - Mock"`
- `BUNDLE_ID = "com.organization.Forge.mock"`

It mutates the template app and writes DayRate Lab proof data under the Forge repo. The goal forbids continuing that architecture.

### Current generated proof app path

`/Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab` exists and appears to be a renamed app copy from a clean/template source. It contains:

- `DayRateLab.xcodeproj`
- `DayRateLab/`
- copied template features (`Home`, `Onboarding`, `Paywall`, `Settings`, etc.)
- `.forge/evidence/` directory

However, current inspection found no files under `DayRateLab/.forge` yet. This means the generated app exists as a scaffold, but does not yet satisfy the expected proof artifacts from this fresh goal.

## Vault Intent

Vault evidence is consistent and should guide all later work:

- `vault/business/app-ideas-brainstorm.md`: Forge is Matvii's personal app factory, not a product for non-developers; the products are the apps Forge builds.
- `vault/projects/forge.md`: current failures are template-looking apps, broken SwiftUI/build loops, shallow features, weak use of agent infra, and expensive mediocre work.
- `vault/projects/forge-v4-prompt.md`: desired architecture is Opus/Claude orchestration, Codex building, Opus judging, Superpowers/GSD planning, hardened build, xcodebuildmcp screenshot/UI evidence, adversarial review, and ship/storefront handoff.
- `vault/content/seeds/monetization-patterns.md`: monetization/growth should be intentional; "Unlock Forever" framing and organic app growth are relevant inputs, not proof by themselves.

## Old Proof And Template Contamination

The old local proof commits are not acceptable as final architecture because they mutated the Forge template with DayRate Lab-specific content.

Observed contamination from archived proof evidence:

- `f9fb5e4` modified `Forge/Features/Home/HomeView.swift`, `Forge/Features/Onboarding/OnboardingStep.swift`, `Forge/Features/Onboarding/OnboardingController.swift`, and `Forge/Managers/Purchases/EntitlementOption.swift`.
- It added DayRate Lab native proof files under `.forge/generated/dayrate-lab`.
- It added native proof screenshots and receipts under `docs/goals/forge-complete/runs/dayrate-lab`.
- `docs/goals/forge-complete/runs/dayrate-lab/native-pipeline-receipt.json` proves the prior app path was `/Users/matvii/Developer/Personal/forge/Forge.xcodeproj`, not a generated app outside the template.

The superseded goal already judged the right direction: keep and bypass old commits for now, use `origin/main` as a clean template source, create the generated proof app outside the template, and defer destructive cleanup until after separate-app proof exists.

## DayRate Evidence

DayRate Lab remains the best default benchmark app.

Useful sources:

- `docs/forge-v4/sample-ideas/dayrate-lab.json`: compact sample idea and v4 static pipeline fixture.
- `docs/forge-v4/runs/dayrate-lab/**`: static product-studio artifacts and app-view output.
- `docs/goals/forge-complete/runs/dayrate-lab/**`: native evidence from the bad template-mutating proof, useful only as anti-pattern/supporting evidence.
- `/Users/matvii/Developer/Personal/Apps/DayRate/.forge/blueprint.md`: stronger product definition with morning prediction, evening rating, Day Twins, Micro-Patterns, Time Capsules, freemium gates, and no tab bar.
- `/Users/matvii/Developer/Personal/Apps/DayRate/.forge/feature-specs/daily-loop-research.md`: strong retention rationale. It explains why a plain mood grid churns and why DayRate should deliver Day 1 value, Day 7 Micro-Patterns, prediction loops, anonymous Day Twins, and Time Capsules.
- `/Users/matvii/Developer/Personal/Apps/DayRate/.forge/issues.md`: high-value failure log for Forge itself: generic circles, weak grids, cheap traffic-light palette, raw buttons, guessed Router APIs, missing morning/evening mode, design skill not consulted, and user-as-QA loops.

Do not touch `/Users/matvii/Developer/Personal/Apps/DayRate` in this goal unless a later Judge explicitly approves it. It is dirty and should remain evidence.

## Gate Gap Matrix

| Gate | Current reusable capability | Gap |
|---|---|---|
| Product | Local and remote `forge-plan` ask pitch/audience and usefulness questions; v4 product-studio can emit product specs. | Needs stronger reusable product thesis artifact for "why this deserves to exist", must-have/non-goals, and anti-generic differentiation before screens. |
| Competitive/reference | Remote v5 `forge-plan` requires competitive analysis and references; local design skill can translate references. | Local proof path has not yet exercised current competitive/reference gate for the generated app; NotebookLM requirement may be too tool-specific for Codex proof and needs explicit fallback/deferral. |
| Activation/onboarding | Local template has onboarding; local skills mention onboarding/paywall CRO. | Need a concrete DayRate first-session activation artifact and native flow where the user makes one prediction quickly. |
| Retention | DayRate research has strong retention concepts; remote v5 has staged planning. | Need reusable retention-loop gate output with day 1/day 3/day 7 states, reminders, insight cadence, and trigger logic. |
| Monetization | Storefront/ship skills have App Store and subscription prep; DayRate has freemium idea. | Need reusable monetization gate that separates free value, paid value, paywall timing, placeholder product IDs, claim safety, and "do not monetize yet" criteria. |
| UX/state | AGENTS.md has loading/empty/error patterns; v5 phases separate arch/craft. | Need generated app `.forge/user-journeys.md` covering first-use, returning, bad-network/local-only, empty, loading, and edge cases before native implementation. |
| Design | `forge-design` can write DESIGN.md; remote v5 adds mockups and DS tailoring. | Need DayRate-specific DESIGN.md with anti-template criteria and component/token strategy in the generated app, not only template-level docs. |
| Native build | Template and `new-app.sh` exist; v5 architecture separates `forge-arch` and `forge-craft`. | The current generated app is still mostly renamed template; native DayRate implementation has not been built outside the template. |
| Verification | AGENTS and previous proof establish Xcode 26.5, iPhone 17 Pro, xcodebuildmcp, screenshots, UI snapshots. | Verification must run against `DayRateLab.xcodeproj`, capture screenshots/UI snapshots, and scan app-code warnings there. |
| Judge/repair | Local judge skill and old receipts exist; remote v5 has advisory and cross-screen review. | Need a fresh judge receipt for generated app quality, plus at least one repair loop that feeds lessons back into reusable Forge instructions. |
| Handoff | `forge-storefront` and `forge-ship` contain useful listing/submission structure. | Need reusable handoff stage plus DayRate app positioning, subtitle/description, screenshot plan, production TODOs, monetization notes, and Matvii polish checklist. |

## Reuse Vs Ignore

Reuse:

- Remote marketplace v5 as architectural north star.
- `scripts/new-app.sh`/`rename_project.sh` as scaffold only.
- `scripts/forge-v4-product-studio.mjs` as artifact-stage source material, if adapted so output belongs to the generated app.
- Local `forge-design`, `forge-judge`, `forge-storefront`, and remote `forge-plan`/`forge-ship` phase instructions.
- DayRate `.forge` product/retention/design failure evidence as input.
- Xcode 26.5 + iPhone 17 Pro + xcodebuildmcp verification pattern.

Ignore or treat as anti-pattern:

- `scripts/forge-complete-pipeline.mjs` as a final proof path.
- Any proof that mutates `Forge/Features/**` in the template.
- Static `app-view` as completion proof.
- `/Users/matvii/Developer/Personal/Apps/DayRate` as an implementation target.
- Old local proof commits as architecture.

## Safe Repo Strategy Options

Recommended default for the next Judge:

1. Continue from fresh board, not the superseded board.
2. Keep old local proof commits untouched for now.
3. Treat remote marketplace v5 as the phase architecture to align with.
4. Use generated app path `/Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab`.
5. Populate and validate `.forge` artifacts inside that generated app before native implementation.
6. Do not edit template app screens with DayRate content.
7. Defer any destructive template cleanup/reset/revert until a later audit and explicit Matvii-approved strategy.

If the existing `forge-proof-apps/DayRateLab` scaffold is reused, the next Worker must first verify it was created from clean `origin/main` and contains no unrelated user work. If evidence is weak, recreate it from a clean temporary `origin/main` archive in a new path or ask Judge to approve replacement.

## Benchmark App Decision Inputs

Keep DayRate Lab unless T002 finds a better benchmark. It has the right proof properties:

- small enough for vertical proof;
- real activation moment: first prediction;
- daily loop: morning prediction and evening rating;
- retention loop: Day Twins, Micro-Patterns, Time Capsules;
- monetization: Pro insights/history/export/reminders/reporting;
- design direction: dark, minimal, data-color, no generic cards;
- strong failure evidence from prior Forge attempts.

The risk is that DayRate has too much old baggage. The mitigation is to use old DayRate only as research evidence and build the actual proof inside the clean generated `DayRateLab` app.

## Scout Verdict

T001 is complete.

Recommended next task: T002 external/product scout, focused on concrete reusable quality gates and rubrics for product, retention, monetization, design, screenshot-driven development, and App Store handoff. T002 should not implement app files.
