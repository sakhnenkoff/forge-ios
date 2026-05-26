# Forge Capability Reconnaissance

Date: 2026-05-26
Status: research synthesis for the next Forge phase
Scope: tools, agent skills, plugins, MCP servers, external sources, public research surfaces, design references, native proof tooling, launch tooling, and approval boundaries before the next app-factory iteration.

## Executive verdict

Forge should add a dedicated upstream phase before any new app generation:

> **Capability reconnaissance → capability registry → approved spikes → pipeline repair → app direction research → app production.**

This research confirms Matvii's concern: many Forge quality issues are not only prompt/pipeline issues. They depend on which sources, tools, skills, plugins, MCP servers, and local/external capabilities the factory uses.

The most important strategic shift:

> Forge should learn from the outside world before it tries to generate again, but it must separate safe read-only source use from dependency adoption and external/account/paid actions.

## Access and blocker summary

### Available now without extra approval

These were probed as read-only public/local sources and are usable for Forge capability research:

- Apple App Store / iTunes Search API
- Apple App Store Lookup API
- Apple App Store customer reviews RSS
- Apple Marketing Tools app charts RSS
- Apple App Store public web listings
- Apple HIG and Apple Design Resources
- Reddit public JSON endpoints with custom User-Agent
- Hacker News Algolia API
- Product Hunt public pages
- GitHub public API and public repository pages
- Page Flows public pages where exposed without login
- Refero public pages and public GitHub skill repo
- Local Hermes skills/profiles/Kanban state
- Local Codex CLI and Codex MCP server
- Full Xcode **when explicitly invoked with** `DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer`

### Blocked or needs approval/auth

- X/Twitter search:
  - `XAI_API_KEY` missing.
  - `TWITTER_BEARER_TOKEN` missing.
  - Browser X search redirects to login.
  - Nitter-style mirrors were empty or 503-blocked.
- Mobbin browse/app pages redirected to account-oriented landing surface.
- Refero MCP requires Refero Pro subscription.
- Paid Page Flows / Mobbin / Refero / Nicelydone / ASO tools require approval before account/payment/login/API use.
- AlternativeTo automation returned Cloudflare 403.
- Current global `xcode-select` points to CommandLineTools, so `xcrun simctl` fails unless `DEVELOPER_DIR` is set explicitly.
- Claude Code CLI is installed but not logged in.
- OpenCode, fastlane, Maestro, Appium, swift-format, ddgs/SearXNG-style fallback tools are missing locally.

## Source strategy

### Tier 1 — Use now as safe read-only foundation sources

#### Apple App Store public surfaces

Use for:

- competitor discovery;
- real screenshots;
- ratings and review counts;
- release notes;
- customer review pain mining;
- chart snapshots;
- public launch copy and positioning.

Important endpoints:

- `https://itunes.apple.com/search?term=<query>&entity=software&country=us&limit=<n>`
- `https://itunes.apple.com/lookup?id=<app-id>&country=us&entity=software`
- `https://itunes.apple.com/us/rss/customerreviews/id=<app-id>/sortBy=mostRecent/json`
- `https://rss.applemarketingtools.com/api/v2/us/apps/top-free/10/apps.json`
- `https://apps.apple.com/us/app/<slug>/id<app-id>`

Risks:

- endpoints can be inconsistent;
- reviews are noisy and biased;
- screenshots are references only, never assets to copy.

Recommended spike:

- `spike.appstore-reference-harvester`

#### Reddit public JSON

Use for:

- demand/pain mining;
- alternative/replacement requests;
- price/privacy/offline/subscription complaints;
- real user language for product copy;
- category/domain exploration.

Useful query families:

- `looking for app`
- `alternative to`
- `replacement for`
- `wish there was an app`
- `too expensive`
- `privacy`
- `offline`
- `Apple Health sync`
- `subscription`

Candidate subreddits:

- `r/iosapps`
- `r/iphone`
- `r/AppHookup`
- app-domain-specific subreddits per direction

Risks:

- vocal minority bias;
- spam/self-promotion;
- rate limits;
- avoid storing unnecessary usernames/PII.

Recommended spike:

- `spike.reddit-demand-harvester`

#### GitHub public API and public repos

Use for:

- native implementation references;
- open-source iOS app patterns;
- package health and maintenance signals;
- issue/discussion pain signals;
- agent/tool/MCP candidate discovery.

Key references:

- `https://github.com/dkhamsing/open-source-ios-apps`
- `https://github.com/facundoolano/app-store-scraper`
- `https://github.com/referodesign/refero_skill`
- `https://github.com/pointfreeco/swift-snapshot-testing`
- `https://github.com/ChargePoint/xcparse`
- `https://github.com/mobile-dev-inc/Maestro`

Risks:

- license must be checked per repo;
- stars are not taste;
- do not copy code/assets unless explicitly allowed and approved.

Recommended spike:

- `spike.github-real-ios-pattern-index`

#### Apple HIG and Design Resources

Use for:

- native platform correctness;
- visual judge rubric baseline;
- accessibility/control/navigation constraints;
- avoiding web/SaaS UI patterns masquerading as iOS.

References:

- `https://developer.apple.com/design/human-interface-guidelines/`
- `https://developer.apple.com/design/resources/`

Recommendation:

- Make Apple HIG citation mandatory in every Forge visual synthesis packet.

#### Hacker News Algolia API

Use for:

- technical-user pain;
- Show HN launches;
- startup/product discussion;
- early-adopter feedback.

Reference:

- `https://hn.algolia.com/api`

Risk:

- strongly developer/startup biased.

Recommendation:

- Use only as a secondary demand source.

### Tier 2 — Public pages useful but not enough alone

#### Page Flows public pages

Use for:

- real onboarding/paywall/permissions/account setup flow sequencing;
- timeline labels and screen-step structures;
- anti-slop flow grounding.

Reference:

- `https://pageflows.com/`
- example structure tested at public iOS onboarding flow pages.

Constraints:

- public subset only;
- full access likely account/paid;
- do not bulk-download proprietary video/assets.

Recommended spike:

- `spike.pageflows-public-flow-parser`

#### Product Hunt public pages

Use for:

- trend/context scans;
- launch copy examples;
- competitor clustering.

Risk:

- launch hype does not prove durable demand.

Recommendation:

- Use lightly, not as primary proof.

#### Refero public pages + public skill repo

Use for:

- evaluating agentic design reference workflows;
- understanding what structured design references for AI agents could look like.

References:

- `https://refero.design/`
- `https://github.com/referodesign/refero_skill`

Constraint:

- MCP access requires Refero Pro subscription.

Recommendation:

- Top approval-needed design-source spike candidate.

### Tier 3 — Approval required before use

#### X/Twitter

Use case:

- current discourse;
- indie-app launch reactions;
- taste/tool conversations;
- market/pain signals from builders and users.

Current blocker:

- no local `XAI_API_KEY`;
- no Twitter/X bearer token;
- logged-out browser search redirects to login;
- Nitter mirrors unreliable.

Approval options:

1. configure xAI `XAI_API_KEY` for the `search-x` skill / Hermes `x_search`;
2. provide official X API bearer token;
3. approve manual browser login for read-only research;
4. approve a third-party X search provider.

Recommendation:

- Mark `dep.research.x-twitter-readonly-provider` as `needs_approval`.
- Do not block all Forge research on X; Reddit/App Store/GitHub/HN are enough for first public-source layer.

#### Paid design-reference services

Candidates:

- Mobbin
- Page Flows paid access
- Refero Pro/MCP
- Nicelydone
- DesignArena
- ScreensDesign if public access is insufficient

Use case:

- high-quality visual references;
- real app flow grounding;
- stronger anti-slop visual judge baseline.

Risk:

- account/payment/ToS;
- copying/overfitting;
- paid dependency in factory.

Recommendation:

- Keep as proposal only until Matvii approves a specific spike.

#### Paid ASO/market intelligence

Candidates:

- Appfigures
- Sensor Tower
- AppTweak
- data.ai
- AppFollow

Use case:

- download/revenue estimates;
- keyword difficulty;
- competitor ranks;
- review analytics.

Recommendation:

- Park. Public App Store + Reddit + GitHub should be exhausted first.

## Native proof and verifier strategy

### Key discovery

Native proof is not fundamentally blocked by missing Xcode install. Full Xcode exists locally, but global selection points to CommandLineTools.

Current global state:

```text
xcode-select -p -> /Library/Developer/CommandLineTools
```

Working explicit path:

```bash
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcodebuild -version
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcrun simctl list devices available
```

Implication:

- Forge should not mutate global `xcode-select` automatically.
- Forge should support a configurable `DEVELOPER_DIR` in its native preflight.
- Final audit should report `native_tooling_unavailable` only if both global and configured Xcode paths fail.

### Foundation capabilities to adopt now

No extra dependency needed:

- `xcodebuild`
- `xcrun simctl`
- `XCTest` / `XCUITest`
- `XCTAttachment(screenshot:)`
- `.keepAlways` screenshot attachments
- `xcresulttool`
- SwiftUI `accessibilityIdentifier(_:)`

Apple references:

- `https://developer.apple.com/library/archive/technotes/tn2339/_index.html`
- `https://developer.apple.com/documentation/xctest/xctattachment/init(screenshot:)`
- `https://developer.apple.com/documentation/xctest/xctattachment/lifetime/keepalways`
- `https://developer.apple.com/documentation/xctest/xcuiapplication`
- `https://developer.apple.com/documentation/swiftui/view/accessibilityidentifier(_:)`

### Native proof requirements

Generated app proof must include five app-specific states:

1. activation;
2. core loop after action;
3. returning/progress;
4. empty/error;
5. money boundary or approved deferral.

Each state should emit:

- PNG screenshot;
- accessibility JSON/assertion record;
- evidence-index slot;
- hash;
- simulator/device metadata;
- app version/commit/source reference;
- route/deep-link/launch-arg used to reach the state.

### High-value dependency candidates

#### `swift-snapshot-testing`

- Scope: foundation candidate, visual/native verification.
- Use: component/screen regression after baseline approval.
- Risk: SPM dependency, baseline maintenance, false confidence if treated as taste judge.
- Recommendation: isolated spike first.

Reference:

- `https://github.com/pointfreeco/swift-snapshot-testing`

#### `xcparse`

- Scope: foundation candidate, native evidence extraction.
- Use: easier extraction from `.xcresult` bundles.
- Risk: third-party dependency.
- Recommendation: use built-in `xcresulttool` first; spike `xcparse` only if extraction friction is high.

Reference:

- `https://github.com/ChargePoint/xcparse`

#### `pixelmatch` / `odiff`

- Scope: foundation candidate, visual regression.
- Use: compare approved prototype/native baselines to later artifacts.
- Risk: catches drift, not taste.
- Recommendation: optional local spike after screenshot evidence is real.

References:

- `https://github.com/mapbox/pixelmatch`
- `https://github.com/dmtrKovalenko/odiff`

#### BackstopJS / Playwright snapshots

- Scope: prototype/web visual regression only.
- Use: HTML prototype gates.
- Risk: not native iOS proof.
- Recommendation: only if HTML prototypes remain first-class.

References:

- `https://github.com/garris/BackstopJS`
- `https://playwright.dev/docs/test-snapshots`

#### fastlane snapshot

- Scope: launch-package candidate.
- Use: App Store screenshot production, localization, multi-device screenshot lanes.
- Risk: Ruby/tooling dependency, can creep toward live App Store actions.
- Recommendation: later, after local native evidence is stable.

Reference:

- `https://docs.fastlane.tools/actions/snapshot/`

## Agent/orchestration capability strategy

### Hermes profiles and Kanban

Keep Kanban as durable Forge execution ledger.

Current profile fleet exists:

- `forgeorchestrator`
- `forgeproduct`
- `forgedesign`
- `forgeapp`
- `forgejudge`
- `forgeverifier`
- `forgelaunch`

Recommended improvements:

- specialize each profile's skill diet instead of enabling broad overlapping skills everywhere;
- add profile/existence validation before creating Kanban cards;
- require worker handoffs to include:
  - `metadata.verification`;
  - `residual_risk`;
  - `tooling_service_delta`;
  - `dependency_proposals`;
  - evidence paths;
  - app_score vs pipeline_score where applicable.

### Codex / Claude / OpenCode

#### Codex

- Installed locally.
- `codex mcp-server` available.
- Best immediate candidate for bounded implementation lanes.
- Treat outputs as untrusted patches.
- Hermes must inspect diff and run tests before accepting.

#### Claude Code

- Installed but not authenticated.
- Candidate for structured review/design/spec critique once login is approved.

#### OpenCode

- Skill exists but CLI missing.
- Park until there is a clear reason.

### MCP strategy

MCP is the cleanest way to integrate external capabilities into Hermes while keeping tool filtering visible.

Candidate read-only MCP pack:

- GitHub MCP with mutation tools excluded;
- Codex MCP for bounded coding lane;
- Context7/docs MCP for current docs;
- Reddit MCP read-only;
- Playwright/browser MCP for public pages only;
- Refero MCP only after paid/account approval.

Rules:

- every MCP server must have an approval class;
- include/exclude tool list must be visible in cockpit;
- mutation tools start disabled;
- OAuth/token presence must be redacted;
- MCP adoption is foundation-level, not per-app, unless scoped otherwise.

### Web/search backend

Current Hermes web backend appears empty.

Options:

- low-risk fallback: DDGS or SearXNG-style public search tool;
- paid/high-leverage: Exa, Firecrawl, Parallel, Tavily.

Recommendation:

- add a web/search capability proposal rather than silently adding provider dependencies.

## Launch/package capability strategy

Forge should keep launch outputs local-only until explicit approval.

### Improve now

- competitor listing extractor from App Store public pages/API;
- subtitle/keyword length validators;
- screenshot-caption validator;
- claims-to-evidence checker;
- privacy draft from actual local permissions/SDK/dependency evidence;
- pricing evidence matrix from public competitor information;
- launch evidence tied to verifier evidence index.

### Approval required

- App Store Connect API;
- TestFlight;
- signing/cert/bundle mutations;
- IAP/StoreKit setup;
- RevenueCat/Superwall SDKs or dashboards;
- fastlane deliver/upload;
- public marketing posts.

## Recommended next spikes

### Spike 1 — capability registry scanner

Purpose:

- produce a repeatable local inventory before each Forge run.

Should report:

- profiles and worker readiness;
- enabled skills/toolsets;
- MCP servers and filtered tools;
- web/search/browser providers;
- X/Reddit/GitHub/App Store source access;
- coding agent CLIs/auth state;
- Xcode/simctl state and configured `DEVELOPER_DIR`;
- dependency proposals and approval classes;
- cockpit summary.

Approval class:

- autonomous local/read-only.

### Spike 2 — App Store reference harvester

Purpose:

- feed product/taste/visual research with real app metadata, screenshots, reviews, release notes, and chart context.

Approval class:

- autonomous read-only public.

### Spike 3 — Reddit demand harvester

Purpose:

- mine user pain, alternative requests, price/privacy/offline complaints, and real language.

Approval class:

- autonomous read-only public.

### Spike 4 — GitHub iOS pattern index

Purpose:

- identify implementation references and open-source patterns without copying code/assets.

Approval class:

- autonomous read-only public.

### Spike 5 — native preflight and fail-closed verifier

Purpose:

- repair current false confidence before app generation.

Must prove:

- empty generated verification plans fail;
- configured Xcode path works;
- visual evidence sequence is required;
- final audit cannot pass from fixtures only.

Approval class:

- local repo work; safe if scoped to Forge tests/scripts and committed after review.

### Spike 6 — Refero/Mobbin/Page Flows paid/reference spike

Purpose:

- determine whether account-gated design references materially improve visual synthesis.

Approval class:

- needs Matvii approval before login/payment/account/API use.

### Spike 7 — X/Twitter read-only provider

Purpose:

- add real-time discourse as a product/taste signal.

Approval class:

- needs Matvii approval/auth.

Possible auth paths:

- configure `XAI_API_KEY` for `search-x`;
- configure official X API bearer token;
- approve browser login;
- approve third-party provider.

## New pipeline ordering

Recommended Forge sequence from here:

```text
0. Capability reconnaissance
1. Capability registry + approval menu
2. Safe public-source harvesters
3. Pipeline fail-closed repairs
4. Optional approved paid/account/tool spikes
5. App direction research
6. Product/taste gate
7. Visual reference + original synthesis
8. Prototype and pre-native visual judge
9. Native proof and evidence capture
10. Post-native visual judge
11. Launch package
12. Learning loop
```

## Cockpit additions needed

The cockpit should show a capability panel with:

- available sources;
- blocked sources;
- approval-needed sources;
- installed/missing local tools;
- Xcode/simctl status;
- MCP servers and included tools;
- proposed spikes;
- adopted/rejected/parked dependencies;
- last access check time;
- whether each capability is foundation-level or per-app.

## Immediate action recommendation

Do not build the next app yet.

Start with three autonomous read-only/local work items:

1. `capability-registry-scanner`
2. `appstore-reference-harvester`
3. `reddit-demand-harvester`

Then repair pipeline fail-closed behavior using those findings.

Ask Matvii separately for:

- X/Twitter auth/provider approval;
- Refero/Mobbin/Page Flows paid/account access approval;
- adding third-party dependencies such as `swift-snapshot-testing`, `xcparse`, `pixelmatch`, `odiff`, `fastlane`, or MCP servers.
