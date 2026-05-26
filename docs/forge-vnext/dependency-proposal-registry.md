# Forge Dependency Proposal Registry

Status: control-plane registry for proposed dependencies, tools, services, and foundational capabilities.
Generated: 2026-05-26

## Purpose

Forge should be able to propose dependencies and tooling improvements without silently adopting them.

This registry covers both:

1. **Foundation-level dependencies** — improve Forge itself: visual judging, screenshots, verification, orchestration, research, launch packaging, analytics scaffolding, template/substrate.
2. **Per-app dependencies** — belong only to a generated app: domain SDKs, app-specific UI libraries, storage, export, notifications, etc.

Nothing in this registry is adopted just because it is listed here. Adoption requires the approval path below.

## Proposal lifecycle

```text
idea → proposal → evaluation spike → approve/adopt/reject → rollback plan → cockpit update
```

Statuses:

- `proposed` — candidate exists; no work beyond research.
- `researching` — read-only research/spike allowed.
- `needs_approval` — useful, but requires Matvii approval before adoption.
- `approved_for_spike` — allowed for local isolated spike only.
- `approved_for_foundation` — allowed into Forge foundation after tests/review.
- `approved_for_app` — allowed in one generated app only.
- `rejected` — do not use.
- `parked` — promising, not needed now.

## Approval classes

### Foundation-level changes

Require explicit review before merge/preserve if they add:

- new package manager dependencies;
- new runtime dependencies;
- new external service dependency;
- new paid/account-gated tool;
- new persistent process/watcher;
- new required human workflow/tool;
- new generated-app template/substrate behavior.

### Per-app changes

Can be approved for one app without becoming Forge default.

A per-app dependency must state:

- which app/direction it belongs to;
- why app-specific native capability requires it;
- why a local/no-dependency alternative is insufficient;
- whether it affects App Store/privacy/review/size/build complexity;
- how to remove it if the app direction is killed.

## Required proposal format

```json
{
  "id": "dep.<area>.<slug>",
  "status": "proposed",
  "scope": "foundation|per_app|both",
  "layer": "research|visual|verification|native|launch|operator_ux|substrate|app_runtime",
  "candidate": "tool/package/service name",
  "source_url": "https://...",
  "problem": "What weakness this solves",
  "expected_leverage": "Why this improves Forge or the app",
  "alternatives": ["no dependency", "local script", "manual review"],
  "risks": {
    "cost": "none|low|medium|high",
    "account_required": false,
    "external_mutation": false,
    "license_risk": "unknown|low|medium|high",
    "maintenance_risk": "low|medium|high",
    "privacy_or_app_review_risk": "none|low|medium|high"
  },
  "approval_needed": "none|spike|foundation_adoption|per_app_adoption|external_action",
  "evaluation_plan": "How to test it safely",
  "rollback_plan": "How to remove it",
  "decision": "pending|approved|rejected|parked",
  "owner": "profile or Matvii"
}
```

## Current foundation-level proposals

### dep.visual.swift-snapshot-testing

- Status: `proposed`
- Scope: `foundation`
- Layer: `visual`, `verification`
- Candidate: `pointfreeco/swift-snapshot-testing`
- Problem: Forge needs native screen regression checks after a design has passed; screenshots should not silently drift.
- Expected leverage: repeatable native visual regression for generated apps.
- Risks: adds Swift package dependency and snapshot maintenance burden.
- Approval needed: `approved_for_spike` before local isolated spike; `approved_for_foundation` before becoming default.
- Evaluation plan: spike in a tiny generated-app fixture, not in the template first.
- Rollback: remove package, test target, snapshots, and verifier hook.

### dep.visual.pixelmatch-or-odiff

- Status: `proposed`
- Scope: `foundation`
- Layer: `visual`, `verification`
- Candidate: `pixelmatch`, `odiff`, or equivalent local image diff.
- Problem: Forge needs artifact-level diffs between approved prototype/native screenshot iterations.
- Expected leverage: catches unexpected visual drift; does **not** judge taste.
- Risks: false confidence if treated as taste judge.
- Approval needed: spike before adoption.
- Evaluation plan: compare generated screenshots against approved local artifacts.
- Rollback: remove npm dependency/script and verifier hook.

### dep.visual.backstopjs

- Status: `proposed`
- Scope: `foundation`
- Layer: `visual`, `prototype`
- Candidate: `BackstopJS`
- Problem: HTML/clickable prototypes need visual regression if Forge uses web prototypes as design gates.
- Expected leverage: catches prototype drift before Swift implementation.
- Risks: node/browser tooling complexity.
- Approval needed: spike before adoption.
- Evaluation plan: run against one local prototype fixture.
- Rollback: remove config/scripts/dependency.

### dep.research.design-reference-services

- Status: `needs_approval`
- Scope: `foundation`
- Layer: `research`, `visual`
- Candidate: Mobbin / Page Flows / Nicelydone / Refero / DesignArena.
- Problem: Forge needs high-quality visual references and flow patterns, not generic generated UI.
- Expected leverage: stronger inspiration packets and visual judge baselines.
- Risks: accounts/payments, terms of use, reference-copying risk.
- Approval needed: explicit Matvii approval before login/signup/payment/API use.
- Evaluation plan: use public/free pages first; document access limits.
- Rollback: remove source from required pipeline if inaccessible.

### dep.research.x-twitter-search

- Status: `needs_approval`
- Scope: `foundation`
- Layer: `research`
- Candidate: configured X/Twitter search provider or safe API/tool.
- Problem: Forge may benefit from discourse about app taste, markets, AI slop, and niche pains.
- Expected leverage: better demand/taste research beyond App Store listing proxies.
- Risks: API key/account/cost/rate limits; noisy data.
- Approval needed: explicit approval unless a safe configured read-only tool already exists.
- Evaluation plan: read-only query set + source capture; no posting/DM/follow/login mutation.
- Rollback: mark unavailable and use public web/HN/blog substitutes.

## Current per-app proposals

None adopted.

Potential future per-app dependencies must be proposed under the app's own `.forge/dependencies/proposals.json` and summarized here only if accepted for that app.

## Cockpit requirements

The Forge cockpit should show:

- active foundation proposals;
- active per-app proposals;
- proposals needing Matvii approval;
- rejected/parked proposals;
- any newly adopted dependencies since last preserved commit;
- whether a proposal is foundation-wide or app-only.

## Worker handoff rule

Every worker that proposes or introduces a dependency must include both sections:

```json
{
  "dependency_proposals": ["dep.visual.swift-snapshot-testing"],
  "tooling_service_delta": {
    "new_local_dependencies": [],
    "new_external_readonly_sources": [],
    "new_external_mutating_services": [],
    "requires_matvii_approval": [],
    "cost_or_account_risk": "none|low|medium|high",
    "foundation_or_per_app": "foundation|per_app|both",
    "rollback_plan": "..."
  }
}
```

If a dependency is implemented without this, the worker handoff is incomplete.
