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

### dep.research.appstore-public-harvester

- Status: `proposed`
- Scope: `foundation`
- Layer: `research`, `visual`, `launch`
- Candidate: Direct Apple public endpoints: iTunes Search/Lookup, Reviews RSS, Apple Marketing Tools charts, App Store web listings.
- Problem: Forge needs real competitor screenshots, metadata, ratings, reviews, release notes, chart context, and launch copy before synthesizing app ideas/designs.
- Expected leverage: strong safe baseline for product/taste/visual/launch research without paid services.
- Risks: endpoint brittleness, noisy reviews, App Store country bias, screenshot-copying risk.
- Approval needed: none for read-only public use; adoption as foundation script still requires code review.
- Evaluation plan: generate a JSON packet for 10-25 apps from one category/query; include screenshot URLs, reviews, release notes, source URLs, access date, and limitations.
- Rollback: remove harvester from required gates and keep manual App Store citations.

### dep.research.reddit-json-demand-harvester

- Status: `proposed`
- Scope: `foundation`
- Layer: `research`
- Candidate: Reddit public JSON endpoints with custom User-Agent.
- Problem: Forge needs real user pain, alternative requests, price/privacy/offline complaints, and product language beyond App Store listings.
- Expected leverage: qualitative demand evidence for app direction gates.
- Risks: spam, vocal minority bias, rate limits, public-user privacy/PII concerns.
- Approval needed: none for read-only public JSON; no login/posting/voting.
- Evaluation plan: run query families such as `looking for app`, `alternative to`, `wish there was an app`, `too expensive`, `privacy`, `offline`, `subscription` across relevant subreddits and output scored evidence clusters.
- Rollback: remove Reddit as required source and use App Store reviews/HN/GitHub issues.

### dep.research.github-ios-reference-index

- Status: `proposed`
- Scope: `foundation`
- Layer: `research`, `native`, `substrate`
- Candidate: GitHub public API plus curated repos such as `dkhamsing/open-source-ios-apps`.
- Problem: Forge needs real native implementation references, package health checks, and open-source pattern discovery without copying code/assets.
- Expected leverage: better SwiftUI/UIKit architecture references and dependency evaluation.
- Risks: unauthenticated GitHub rate limits, license ambiguity, star-count false confidence, copy/paste contamination.
- Approval needed: none for read-only public metadata; code/package adoption requires separate approval/review.
- Evaluation plan: produce a repo index with license, activity, stars, language/UI stack, domain, screen patterns, and issue/discussion signals.
- Rollback: remove as required source and use manually selected references.

### dep.research.pageflows-public-parser

- Status: `proposed`
- Scope: `foundation`
- Layer: `research`, `visual`
- Candidate: Page Flows public pages visible without login/payment.
- Problem: Forge needs flow sequencing and real journey structures, not isolated screenshot inspiration.
- Expected leverage: better onboarding/paywall/permission/account/core-loop flow contracts before visual synthesis.
- Risks: public subset only, ToS/bulk-download risk, old app versions, copying flow structure too literally.
- Approval needed: none for limited public-page citation; paid/account access requires explicit approval.
- Evaluation plan: parse curated public URLs into flow-step skeletons without downloading proprietary media/assets.
- Rollback: remove parser and use manual flow notes.

### dep.research.web-search-provider

- Status: `proposed`
- Scope: `foundation`
- Layer: `research`
- Candidate: DDGS/SearXNG-style local fallback or paid providers such as Exa, Firecrawl, Parallel, Tavily.
- Problem: Hermes web/search backend is currently empty, forcing ad-hoc direct URL research.
- Expected leverage: broader discovery of tools, references, and demand evidence.
- Risks: provider cost/account/API keys, search quality variance, scraping/ToS concerns.
- Approval needed: local free fallback can be proposed for spike; paid/API provider requires explicit approval.
- Evaluation plan: compare one low-risk local/public search fallback against manual known-source research on a fixed Forge query set.
- Rollback: remove provider and continue with direct public endpoints.

### dep.mcp.github-readonly

- Status: `proposed`
- Scope: `foundation`
- Layer: `research`, `native`, `operator_ux`
- Candidate: GitHub MCP with mutation tools excluded.
- Problem: Forge needs safer structured access to GitHub repositories/issues/files for research and dependency vetting.
- Expected leverage: faster repo inspection while keeping writes disabled.
- Risks: OAuth/token scope, accidental mutation tools, rate limits.
- Approval needed: MCP server configuration approval and strict tool include/exclude review.
- Evaluation plan: add in isolated profile with read-only tool filters, test repository search/file read only, surface in cockpit.
- Rollback: remove MCP server config and fall back to `gh`/public API.

### dep.mcp.codex-implementation-lane

- Status: `proposed`
- Scope: `foundation`
- Layer: `operator_ux`, `native`, `verification`
- Candidate: local `codex mcp-server` / Codex CLI for bounded coding lanes.
- Problem: Forge can use specialized coding agents, but outputs must be treated as untrusted patches and verified by Hermes.
- Expected leverage: better implementation throughput for scoped repair cards.
- Risks: agent overreach, tool drift, unreviewed file mutation, hidden assumptions.
- Approval needed: approved-for-spike before adopting as standard worker lane.
- Evaluation plan: run on a small isolated repair task/worktree; Hermes reviews diff and reruns canonical tests before acceptance.
- Rollback: disable Codex lane and use normal Hermes workers.

### dep.mcp.context-docs

- Status: `proposed`
- Scope: `foundation`
- Layer: `research`, `native`, `verification`
- Candidate: Context7/docs MCP or equivalent current-docs provider.
- Problem: Forge needs up-to-date framework/tool docs for Swift/Xcode/testing/MCP/tooling decisions.
- Expected leverage: less stale API usage and fewer hallucinated commands.
- Risks: external service dependency, account/API/cost depending on provider.
- Approval needed: depends on provider; require proposal before adoption.
- Evaluation plan: test against fixed docs queries for XCTest, simctl, SwiftUI accessibility, and selected dependencies.
- Rollback: use direct official docs URLs/manual citations.

### dep.native.xcode-developer-dir-preflight

- Status: `proposed`
- Scope: `foundation`
- Layer: `native`, `verification`
- Candidate: Configurable `DEVELOPER_DIR` native preflight using `/Applications/Xcode-26.5.0.app/Contents/Developer` when available.
- Problem: global `xcode-select` points to CommandLineTools, but full Xcode is available if invoked explicitly; Forge should not falsely report native proof impossible or mutate global selection.
- Expected leverage: reliable native build/simulator readiness checks.
- Risks: local path/version drift.
- Approval needed: none for local preflight; do not mutate global `xcode-select` without approval.
- Evaluation plan: add preflight command that checks `xcodebuild -version`, `simctl list`, selected simulator, and Mock scheme availability using configured `DEVELOPER_DIR`.
- Rollback: remove configured path and fail with `native_tooling_unavailable`.

### dep.native.xcresulttool-first

- Status: `proposed`
- Scope: `foundation`
- Layer: `native`, `verification`
- Candidate: Built-in `xcresulttool` before adopting third-party `xcparse`.
- Problem: Forge needs durable extraction from Xcode result bundles for screenshots, logs, tests, and attachments.
- Expected leverage: native evidence collection without new dependency.
- Risks: Apple CLI format churn, extraction complexity.
- Approval needed: none for built-in local use.
- Evaluation plan: run a minimal UI test result bundle and extract attachment metadata/screenshots using `xcresulttool`.
- Rollback: spike `xcparse` if built-in extraction is insufficient.

### dep.native.xcparse

- Status: `proposed`
- Scope: `foundation`
- Layer: `native`, `verification`
- Candidate: `ChargePoint/xcparse`.
- Problem: extracting screenshots and coverage from `.xcresult` may be easier with a dedicated tool.
- Expected leverage: lower friction evidence extraction.
- Risks: third-party dependency, install/maintenance risk.
- Approval needed: spike before adoption.
- Evaluation plan: compare against `xcresulttool` on the same result bundle.
- Rollback: remove tool and return to built-in extraction.

### dep.native.fastlane-snapshot

- Status: `parked`
- Scope: `foundation`
- Layer: `launch`, `native`
- Candidate: `fastlane snapshot`.
- Problem: multi-device/localized App Store screenshot production may become useful later.
- Expected leverage: strong launch screenshot automation after local proof is stable.
- Risks: Ruby/tooling complexity, can creep toward live App Store Connect actions.
- Approval needed: explicit approval before install/adoption; live upload/deliver always requires separate approval.
- Evaluation plan: only after local native evidence works; dry-run screenshot generation without ASC upload.
- Rollback: remove fastlane files/dependency.

### dep.research.refero-mcp

- Status: `needs_approval`
- Scope: `foundation`
- Layer: `research`, `visual`
- Candidate: Refero MCP / Refero Pro.
- Problem: Forge needs structured, agent-friendly design references to fight AI slop.
- Expected leverage: potentially highest-leverage paid/account design intelligence source.
- Risks: paid subscription, external service dependency, prompt/data sent to service, copying/overfitting risk.
- Approval needed: explicit Matvii approval before account/payment/MCP use.
- Evaluation plan: isolated profile spike; measure structured metadata quality, source citation, and originality safeguards.
- Rollback: remove MCP and fall back to App Store/Page Flows/public references.

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
