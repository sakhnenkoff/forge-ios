# Forge vNext Persistent Orchestrator Charter

Status: active operating charter for Forge vNext autonomous improvement loop.

## North star

Forge must become an agentic product studio that can repeatedly produce launch-candidate iOS apps, not demos, scaffolds, or app-shaped bullshit.

A successful pipeline can:

1. research real user pain using broad sources where available;
2. synthesize multiple app directions and recommend one;
3. produce app-specific product/design artifacts before native code;
4. generate a separate native iOS app repo without contaminating Forge;
5. verify build/run/tests/screenshots/evidence with generic, app-agnostic tooling;
6. produce local launch, privacy, pricing, copy, screenshot, postmortem, and learning artifacts;
7. fail weak ideas/apps honestly;
8. iterate the Forge pipeline based on trial evidence;
9. stop at real human gates, not fake option lists.

## Absolute DayRateLab rule

DayRateLab is not inspiration, not a baseline, not a product direction, and not a design reference.

It may be referenced only as a negative failure example when auditing prior mistakes. It should not influence product direction, design language, architecture, app naming, fixtures, screenshots, launch copy, or verifier assumptions.

Goal: delete/quarantine DayRateLab artifacts after scoped review, using recoverable deletion where possible, and preserve only a tiny negative-audit note if needed.

## Persistent loop

The orchestrator should keep working through Kanban, not through one stale Telegram `/goal`.

Each cycle:

1. Inspect Forge board and current repo state.
2. If workers are running, monitor and recover stuck work.
3. If no workers are running, choose the highest-leverage safe local next step.
4. Prefer pipeline improvement, trial generation, verification, and learning loops over conversation-only planning.
5. Use Kanban comments/artifacts as durable state.
6. Keep Telegram updates compact and only user-relevant.
7. Stop/ask only at real gates:
   - public/external/money/credentials/work-system/App Store/TestFlight/signing/account actions;
   - repo/app deletion after exact scoped path review;
   - native generation for a specific app direction if the gate requires Matvii taste/product approval;
   - ambiguous tradeoffs where multiple options are genuinely viable.

## Access and capability principle

The pipeline should explicitly check and use available research/integration access where appropriate:

- web search / browser research;
- App Store and competitor data;
- Reddit and public communities if available through browser/web;
- X/Twitter if a working tool or configured credential exists;
- custom Hermes skills/plugins/MCPs that are installed and relevant;
- local iOS/Xcode tooling;
- GitHub only for local repo inspection unless pushing/PRs are explicitly approved.

If a tool/integration is missing, record the gap and continue with substitutes rather than pretending coverage exists.

## Current proof level

Current status before persistent loop begins:

- interview/charter exists;
- DayRateLab gap audit exists;
- lane specs exist;
- local fixture validators/scripts exist;
- final dry-run fixture audit passes;
- no real second generated app proof exists yet;
- pipeline changes are local/uncommitted and need review/commit hygiene.

## Next durable phase

Phase objective: turn the local dry-run pipeline into an evidence-producing iterative app factory.

Immediate priorities:

1. Review and clean uncommitted pipeline diff.
2. Commit local Forge vNext pipeline repair if clean.
3. Scope and quarantine/delete DayRateLab artifacts without using them as inspiration.
4. Validate capability access: web/browser, Reddit, X/Twitter, custom skills/plugins, Xcode, Kanban profiles.
5. Run app-direction research under repaired gates.
6. Generate one real second proof app only after direction gate is strong enough.
7. Run skeptical audit and patch Forge based on failures.
8. Repeat until the pipeline meets the interview bar.

## Definition of done

Do not declare Forge vNext done because scripts exist or one fixture passes.

Done requires:

- at least one non-DayRate generated app in its own repo;
- product/design/native/verification/launch/learning artifacts produced by the pipeline;
- Mock build/run/screenshot evidence;
- generic verifier passes without source edits;
- skeptical audit says the app is not generic/scaffold bullshit;
- pipeline learning patches are applied or explicitly rejected;
- Matvii agrees the result matches the interview-level bar.
