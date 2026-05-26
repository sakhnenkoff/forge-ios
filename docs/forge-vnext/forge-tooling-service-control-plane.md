# Forge Tooling and Service Control Plane

Status: draft control map for Matvii visibility and approval.
Generated: 2026-05-26

## Purpose

Forge needs a visible inventory of what it is using, what it may use, and what requires Matvii approval.

This document exists so the cockpit can answer:

- what tools are currently in the pipeline;
- what external services are being called;
- what dependencies are proposed but not yet adopted;
- which proposed dependencies are **foundation-level** vs **per-app**;
- what experiments are safe to try;
- what needs explicit approval.

Dependency proposal registry: `docs/forge-vnext/dependency-proposal-registry.md`.

## Control classes

### Class A — autonomous local tools

Allowed without asking, if scoped to the Forge repo or generated local app repo:

- Git local status/diff/log/commit when the task explicitly says preserve local work.
- Node scripts/tests under Forge.
- JSON schema validation.
- Swift/Xcode/xcodebuild local mock builds/tests.
- iOS Simulator screenshots and accessibility snapshots.
- Hermes Kanban task creation/routing/comments.
- Obsidian cockpit refresh writes.
- Local static HTML/prototype generation.

### Class B — autonomous read-only public research

Allowed without asking, if no login/payment/mutation is involved:

- Public App Store / iTunes Search API.
- Public web pages and blogs.
- Public GitHub repositories and docs.
- Hacker News/public forum pages.
- Public design/reference pages that are readable without account/payment.

All outputs must cite source URLs, access date, and confidence/limitations.

### Class C — propose first, ask before use

May be useful, but require Matvii approval before signup/payment/account/API use:

- Mobbin, Page Flows, Refero, Nicelydone, DesignArena, or any design-reference service requiring account/payment.
- X/Twitter API/search providers if not already configured safely.
- Browser automation against logged-in services.
- Paid LLM/vision/image-generation service beyond already configured Hermes provider usage.
- App Store Connect, TestFlight, signing, bundle IDs, certificates, IAP/StoreKit setup.
- Analytics/crash/telemetry SDKs.
- Any third-party API that writes, posts, uploads, or creates external state.

### Class D — blocked unless explicitly approved per action

- Public posting or marketing publication.
- Live app submission/TestFlight distribution.
- Payment/subscription/IAP actions.
- Account/credential changes.
- Work-system access.
- Irreversible deletion of repos/apps/artifacts.

## Current active tooling

### Hermes-native execution

- Kanban board: `forge`.
- Worker profiles: `forgeproduct`, `forgedesign`, `forgejudge`, `forgeverifier`, `forgeapp`, `forgelaunch`, `forgeorchestrator`.
- Telegram: decision/proof layer only.
- Obsidian: human cockpit at `/Users/matvii/vault/projects/forge-cockpit.md`.

### Forge local repo tooling

- Node test runner: `node --test`.
- Forge verifier: `scripts/forge-vnext-verifier.mjs`.
- Generated app sanitizer tests.
- Visual judge contract tests.
- JSON schemas under `docs/forge-vnext/schemas/`.
- Fixtures under `docs/forge-vnext/fixtures/`.

### Native app proof tooling

- Xcode / `xcodebuild` with Mock schemes.
- iOS Simulator.
- Screenshot evidence files.
- Accessibility snapshot JSON.
- `.forge/evidence/*` indexes in generated app repos.

## Current external calls actually used in this Forge run

Read-only public calls only:

- App Store / iTunes Search API for app-direction and category research.
- Public GitHub repository metadata/pages for visual tooling research.
- Public blogs / Hacker News / product pages for visual excellence research.

Not used:

- No paid design-reference service.
- No logged-in X/Twitter.
- No App Store Connect.
- No TestFlight.
- No signing/cert/bundle mutation.
- No IAP/payment setup.
- No public posting.
- No work-system access.

## Proposed optional dependency experiments

These are candidates to evaluate, not adopted dependencies.

Forge may propose dependencies for both:

- **foundation layers** — visual judging, screenshot verification, research tooling, launch packaging, operator UX, substrate/template improvements;
- **per-app layers** — a dependency needed only by one generated app and not promoted into the default factory.

Proposals must stay visible in the dependency registry until accepted, rejected, or parked.

### Visual regression / screenshot tooling

- `pointfreeco/swift-snapshot-testing` — Swift snapshot tests for native screens.
- `uber/ios-snapshot-test-case` — alternative iOS snapshot-testing reference.
- `pixelmatch` — image diff for screenshot/prototype regression.
- `BackstopJS` — HTML prototype visual regression.
- `reg-suit` / `odiff` style tools — CI-like screenshot diff reports.

Control rule: safe to research publicly; adding to repo/package/toolchain needs a scoped task and approval if it adds heavy complexity.

### Design inspiration sources

- App Store public screenshots and listings.
- Apple HIG.
- Mobbin / Page Flows / Nicelydone / Refero / DesignArena if accessible without paid/account friction, otherwise ask.

Control rule: references inform original synthesis; do not copy competitor assets into generated apps.

### Research sources

- Public App Store/iTunes API.
- Public web/blog/HN/GitHub.
- X/Twitter only through a configured safe tool/API or explicit approval.

## Cockpit requirements

The cockpit should expose this as:

1. **Currently used** — tools/services active in the latest run.
2. **Proposed experiments** — things Forge wants to try.
3. **Dependency proposals** — foundation vs per-app, status, and owner.
4. **Needs approval** — anything with account/payment/public/external mutation or foundation adoption.
5. **Blocked** — tools unavailable due missing API/key/access.
6. **Recent changes** — new dependencies or service calls introduced since last preserved commit.

## Rule for future tasks

Every Forge task that introduces a new dependency, external service, package, API, account, or tool must include a `tooling_service_delta` section in its handoff:

```json
{
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

If this section is missing, the task cannot be accepted as fully reviewed.

If the task is only proposing a dependency and not adopting it, it must still update `docs/forge-vnext/dependency-proposal-registry.md` so Matvii can see what Forge wants to try.
