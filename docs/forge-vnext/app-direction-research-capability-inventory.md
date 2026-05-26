# Forge vNext app-direction research capability inventory

Generated: 2026-05-26 05:56:24 CEST
Task: t_35ebc6c0
Scope: local/non-destructive capability inventory for the next real app-direction research run.

Safety boundaries honored:
- No work-system content was read. Slack MCP configuration was inventoried locally, but Slack history/search tools were not used.
- No credentials, paid services, App Store Connect, TestFlight, signing, bundle IDs, account portals, posting, publishing, or public mutation actions were used.
- Browser verification used a local `data:` URL only. Public web/Reddit/X/App Store pages were not fetched in this run; they are listed as available paths or gaps, not verified evidence.

Source charters read:
- `docs/forge-vnext/persistent-orchestrator-charter.md`
- `docs/forge-vnext-charter.md`

Related prior artifact checked:
- `docs/forge-vnext/research-integration-access-audit.md` from 2026-05-25. This inventory refreshes it for the next app-direction run and tightens the no-work-system/no-external-action boundary.

## Executive answer

Forge can run the next app-direction research cycle safely with:
1. Hermes CLI `web` + `browser` capability for public read-only research, but this worker only verified browser automation locally, not live internet search.
2. Local repo/file/terminal/code execution for durable evidence capture and matrix generation.
3. Public App Store competitor research via browser/web or public Apple/iTunes search endpoints, but no dedicated App Store scraper/CLI is installed and no App Store account path should be touched.
4. X/Twitter as a weak/optional signal: X-related skills exist and `x_search` config exists, but the `x_search` toolset is disabled and `xurl` CLI is missing.
5. Reddit/public-community research only through generic web/browser substitutes; no Reddit-specific CLI/MCP/skill is installed.
6. Strong local iOS verification via full Xcode 26.5 with explicit `DEVELOPER_DIR` and `xcodebuildmcp`.
7. Actual Kanban lane profiles are present: `forgeproduct`, `forgedesign`, `forgeapp`, `forgeverifier`, `forgejudge`, `forgelaunch`, plus `default`.

Recommended next research stack: use generic web/browser for public sources, public App Store pages/API for competitor data, GitHub CLI for developer-market signals, repo-local Forge gates/skills for product/design/launch shape, and XcodeBuildMCP for later native proof. Treat Reddit/X as optional gap/substitute evidence unless a human explicitly approves/configures first-class access.

## Capability matrix

| Area | Status | Evidence checked | Safe use in next app-direction research | Gaps / constraints | Safe substitute |
| --- | --- | --- | --- | --- | --- |
| Local shell/file/code execution | Available and verified | `pwd`, `git status --short --branch`, file reads/writes in `/Users/matvii/Developer/Personal/forge-e2e-clean`; terminal backend config is `local`. | Create `.forge/research` notes, evidence matrices, scorecards, repo docs, validators. | Repo branch is `forge-e2e-pipeline-great-apps-clean...origin/main [ahead 7]`; code/doc changes need review hygiene. | Keep research artifacts in `docs/forge-vnext/` or generated app `.forge/` directories. |
| Hermes web/search toolset | Available in profile, not live-verified in this worker | `hermes tools list` shows `web` enabled; `config.yaml` has `web.backend`, `search_backend`, `extract_backend` empty/auto. | Use in normal Forge/Hermes runs for broad public search and extraction. | This worker schema did not expose a separate `web_search` call; no live public search was run due local/non-destructive boundary. | Use browser/local notes now; run a dedicated read-only web research task if internet evidence is required. |
| Browser automation | Available and locally verified | `browser_navigate` loaded a local `data:` URL titled `Forge capability probe`; snapshot returned `Browser tool works`; warning: local browser without residential proxies. Config: `browser.engine: auto`, `allow_private_urls: false`, `record_sessions: false`. | Read-only public pages, competitor pages, App Store public pages, forum pages, screenshots when needed. | Bot detection may block some sites; external pages not tested here. | Use browser snapshots as qualitative evidence; pair with generic web extracts and explicit source limitations. |
| Agent-browser CLI | Installed and verified help text | `agent-browser --help` works; installed at `/Users/matvii/.hermes/hermes-agent/node_modules/.bin/agent-browser`. | Alternative browser automation for repeatable snapshots/PDFs/accessibility trees in research/design lanes. | Not tested against external sites in this run. | Use built-in browser tool first; use `agent-browser` for scripted browser sessions if needed. |
| Reddit/public communities | Missing first-class access; generic path only | Commands `reddit`, `rdt`, `praw`, `hn`, `hackernews`, `firecrawl`, `tavily` absent; no Reddit-specific skill found. | Browser/web search can inspect public Reddit/HN/Product Hunt pages if accessible. | No Reddit API/CLI/MCP. Reddit often blocks/rate-limits automated access. | Use generic web queries, browser spot-checks, GitHub/community substitutes, and mark `access_method=browser/web_substitute`. |
| X/Twitter tools | Installed/unverified at skill layer; missing/disabled at runtime | Skills present: `xurl`, `x-twitter`, `twitter-reader`, `search-x`; config has `x_search.model: grok-4.20-reasoning`; `hermes tools list` shows `x_search` disabled; `xurl` command not found. Env names relevant to X/Twitter credentials were not present except generic browser vars. | Specific public X URLs may be opened through browser if needed; no posting/search automation. | No verified X search; no `xurl`; `x_search` disabled and credential/provider availability not confirmed. | Treat X as optional weak signal; use web search snippets, public pages, or skip with explicit gap. Configure `xurl`/enable `x_search` only after human approval. |
| App Store / competitor data | Public browser/web path available; dedicated tools missing | Commands `mas`, `fastlane`, `deliver`, `pilot`, `appstoreconnect`, `app-store-scraper` absent. Repo skills include `forge-ship` and `forge-storefront`; charters mention App Store competitor/review/pricing evidence and local launch drafts. | Public App Store pages, public Apple/iTunes search endpoints, competitor websites, screenshots/copy notes. | No App Store Connect/TestFlight/signing/account checks; no first-class scraper installed. | Capture public URLs and manual notes; if repeated ingestion is needed, add a local read-only scraper later, without ASC credentials. |
| Work-system / Slack MCP | Configured but intentionally not used for this research run | `hermes mcp list` shows `slack` enabled with 9 selected tools; `mcp_servers.slack` configured in profile config. No Slack data tool was called. | Not recommended for this public app-direction run unless the task explicitly asks for internal/private signal. | Work-system access is excluded by this task. Slack data is private and cannot stand in for public market evidence. | Use public web/App Store/GitHub/community sources; mention Slack as unavailable-by-boundary. |
| Hermes skills relevant to research/design/launch | Available and verified by listing | Profile has 149 skills. Relevant profile skills include `hermes-agent`, `kanban-worker`, `native-mcp`, `agent-browser`, `marketing-skills`, `competitor-alternatives`, `launch-strategy`, `pricing-strategy`, `social-content`, `xurl`, `x-twitter`, `twitter-reader`, `xcodebuildmcp-cli`, GitHub skills, Slack MCP skills. Repo-local Forge skills: `forge-workspace`, `forge-app`, `forge-design`, `forge-judge`, `forge-ship`, `forge-storefront`, `forge-wire`. | Use skills as procedural checklists for design gates, launch drafts, competitor comparison, pricing, and native verification. | Some skills wrap missing commands or credentialed systems; verify prerequisites before relying on them. | Prefer repo-local Forge skills for pipeline-owned artifacts; use marketing/openclaw skills as ideation/checklists, not as evidence. |
| Hermes plugins | Installed list verified; research plugins mostly disabled | `hermes plugins list` shows bundled plugins including `browser/browser_use`, `browser/browserbase`, `browser/firecrawl`, image generation, model providers; listed ones are `not enabled`. | None needed for safe local research inventory. | Firecrawl/Browserbase/browser-use require enablement and often paid/API keys; not approved here. | Use built-in `web`/`browser` and local artifacts; enable plugins only after a concrete bottleneck and human approval. |
| MCP framework | Available, one configured server | `hermes mcp list` shows Slack enabled; `config.yaml` has `mcp_servers.slack` command/tools. | MCP is available as a mechanism for future structured data sources. | Only Slack MCP is configured for this profile; no Reddit/App Store/X MCP configured. | Add new MCPs only for stable repeated public read-only sources and only with reviewed credential handling. |
| Local Xcode CLI | Available with explicit full Xcode path | `xcode-select -p` is `/Library/Developer/CommandLineTools`; bare `xcodebuild -version` fails because active developer dir is CLT. `DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcodebuild -version` returns Xcode 26.5 build 17F42. | Build/test/run generated proof apps with explicit `DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer`. | Do not change global `xcode-select` without approval. Bare sim/build commands may fail. | Standardize `DEVELOPER_DIR=...` in Forge verifier/runner docs/scripts. |
| iOS simulators | Available and verified with full Xcode path | `DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcrun simctl list devices available` shows iOS 18.2 and iOS 26.5 devices including iPhone 17 Pro. | Later app proof can target iPhone 17 Pro / iOS 26.5 for screenshots/build/run evidence. | Some older runtimes unavailable; no app launched in this inventory task. | Use iPhone 17 Pro/iOS 26.5 as default simulator evidence target. |
| XcodeBuildMCP | Available and verified | `xcodebuildmcp tools --flat` reports 67 canonical / 91 total tools; command installed under nvm Node. `xcodebuildmcp version` is not a valid subcommand, but CLI help works and global npm list shows `xcodebuildmcp@2.1.0`. | Preferred interface for build/run/test/log/screenshot/UI hierarchy evidence in verifier lane. | Still depends on `DEVELOPER_DIR`; no project in this repo root. | Use `xcodebuildmcp simulator build/test/build-and-run/screenshot/snapshot-ui` against generated app workspaces. |
| Current clean repo app project | Missing by design | Searches for `*.xcodeproj` and `*.xcworkspace` in repo returned 0. | Treat this repo as Forge pipeline/control-plane, not a generated app workspace. | No direct build target for app-direction research. | Generate/attach separate proof app repos later after human direction gate. |
| Kanban profiles | Available and verified | `hermes profile list` shows `default` plus `forgeapp`, `forgedesign`, `forgejudge`, `forgelaunch`, `forgeproduct`, `forgeverifier`; each Forge profile has config/env and 149 skills. | Route lanes by capability: product/research to `forgeproduct`, design to `forgedesign`, native app to `forgeapp`, launch to `forgelaunch`, verification to `forgeverifier`, skeptical audit to `forgejudge`. | Gateways for Forge profiles show stopped, but this worker was spawned successfully by the active dispatcher. | Use `kanban_*` tools inside workers as source of truth; do not shell out to Kanban CLI from workers. |
| GitHub/developer-market data | Available as CLI/skills, not auth-verified | `gh` installed at `/opt/homebrew/bin/gh`; GitHub skills installed. No `gh auth status` run to avoid credential/account probing. | Public repo/search inspection if needed for developer-market app directions. | Credential state unknown; private/work GitHub excluded unless explicitly authorized. | Use unauthenticated public GitHub pages/search where possible; mark credentialed GitHub as unavailable by boundary. |
| Image/design generation | Installed but not needed for direction research | `hermes tools list` shows `image_gen` enabled; design skills installed. | Use only after direction/design gate to create local visual concepts if needed. | May use paid provider/API; not part of research evidence. | Prefer text moodboards/reference notes first; use generated images only as design exploration, not demand evidence. |

## Commands and probes run

Read artifacts:
- `read_file docs/forge-vnext/persistent-orchestrator-charter.md`
- `read_file docs/forge-vnext-charter.md`
- `read_file docs/forge-vnext/research-integration-access-audit.md`
- `search_files docs/forge-vnext '*'`
- `search_files skills/SKILL.md`
- `search_files '*.xcodeproj'`, `search_files '*.xcworkspace'`

Local CLI/config probes:
- `pwd`
- `git status --short --branch`
- `hermes --version`
- `hermes profile list`
- `hermes tools list`
- `hermes mcp list`
- `hermes plugins list`
- `python3` YAML parse of `/Users/matvii/.hermes/profiles/forgeproduct/config.yaml` with secret-like values omitted
- `command -v xcodebuild xcrun xcodebuildmcp xurl gh reddit rdt praw hn hackernews firecrawl tavily mas fastlane deliver pilot appstoreconnect app-store-scraper node npm agent-browser clawdhub`
- `npm list -g --depth=0`
- `agent-browser --help`
- `clawdhub --version` / help output
- `xcode-select -p`
- `xcodebuild -version`
- `DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcodebuild -version`
- `DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcrun simctl list devices available`
- `xcodebuildmcp tools --flat`
- environment variable name scan for social/public-tool names only; values were not printed

Hermes/skill probes:
- `skills_list(category='social-media')`
- `skills_list(category='productivity')`
- `skills_list(category='openclaw-imports')`
- `skills_list(category='github')`
- `skill_view('hermes-agent')`

Browser probe:
- `browser_navigate(data:text/html,...)` local data URL only.

Explicitly not run:
- No Slack history/search/saved/user tools.
- No X.com, Reddit, App Store public page/API fetch.
- No App Store Connect, TestFlight, signing, fastlane, `gh auth status`, or paid/browser cloud plugin calls.

## Gaps to carry into the app-direction research card

1. Reddit/public-community evidence is substitute-only unless a human configures a read-only collector or approves public browsing for that lane.
2. X/Twitter evidence is substitute-only unless `x_search` is enabled for a fresh session or `xurl` is installed/authenticated by the human.
3. App Store competitor data should use public pages/API manually; no local scraper exists and App Store Connect is out of scope.
4. Browser/web live internet access still needs verification inside the actual research lane if it needs public evidence; this inventory only proved tool/config availability and local browser operation.
5. Slack MCP exists but is unavailable-by-boundary for this run; do not use work-system/private data as public market evidence.
6. Xcode commands must set `DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer`.
7. The clean Forge repo has no app project in root; generated app verification must target a separate app workspace.

## Safe substitute policy for the next app-direction run

When a first-class source is missing, the research artifact should record:
- `source_type`: `public_web`, `app_store_public`, `github_public`, `browser_snapshot`, `manual_substitute`, or `missing_by_boundary`.
- `access_method`: exact tool/command used.
- `confidence`: high/medium/low.
- `limitation`: e.g. `no Reddit API`, `X search disabled`, `logged-out/browser-only`, `not fetched due boundary`.
- `owner`: lane/profile responsible for future repair if the gap matters.

Minimum evidence mix for the next 3-direction research run:
- For each direction: at least 2 public web/App Store/competitor sources, 1 pricing/money-path note, 1 repeat-use/retention hypothesis, and explicit gaps.
- For recommendation: separate evidence quality score from taste/product score; do not let weak research hide behind a strong-sounding idea.
- If all three directions rely mostly on substitute evidence, the research card should block for a human decision before native generation.
