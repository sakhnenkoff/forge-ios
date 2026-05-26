# GitHub Stars Capability Mining for Forge

Date: 2026-05-26
Source: Matvii's authenticated GitHub starred repositories via `gh api /user/starred`
Scope: read-only mining of already-starred repositories for Forge capability reconnaissance.

## Summary

Matvii's GitHub stars are a high-signal personal prior for Forge. They contain exactly the kind of tools Forge should mine before another app iteration: iOS-native proof tooling, App Store launch helpers, agent orchestration systems, AI-agent skills, visual/design references, and research/capability infrastructure.

Access result:

- Fetched: `189` starred repositories.
- Access method: authenticated `gh api`, read-only.
- Local raw cache: `/tmp/matvii_github_stars.json` during this run only.
- No repositories cloned, forked, starred/unstarred, or modified.

Category counts from a first-pass keyword classifier:

- iOS/native: `128`
- AI agents/orchestration: `64`
- design/UI: `20`
- research/scraping/web: `11`
- testing/verification: `8`
- launch/growth/App Store: `7`
- data/knowledge tooling: `11`

## Why stars should become a Forge source

Public web research is broad, but Matvii's stars are curated by his taste and current interests. Forge should treat starred repos as a **personalized capability source** before searching the wider web.

Use stars for:

- candidate tools to evaluate;
- agent skill examples;
- native iOS implementation references;
- launch/App Store tooling;
- design/taste resources;
- proof/verifier ideas;
- substrate/template ideas.

Rules:

- Stars are discovery signals, not approval.
- Starred repos must still pass license, maintenance, risk, and fit checks.
- Do not copy code/assets without explicit license review and approval.
- Do not adopt dependencies just because they are starred.

## High-leverage candidates for Forge

### 1. Native iOS proof and simulator tooling

#### `getsentry/XcodeBuildMCP`

- URL: `https://github.com/getsentry/XcodeBuildMCP`
- Stars at fetch: `5746`
- Language: TypeScript
- Why it matters: MCP server/CLI specifically for agentic iOS/macOS development with Xcode.
- Forge use: candidate MCP/tooling layer for native build/test/simulator proof.
- Risk: foundation-level MCP dependency; must inspect tool surface and mutation risks.
- Recommendation: high-priority read-only/tooling spike.

#### `b-nnett/codex-plusplus-ios-simulator`

- URL: `https://github.com/b-nnett/codex-plusplus-ios-simulator`
- Stars at fetch: `524`
- Language: JavaScript
- Why it matters: iOS Simulator integration for Codex-style agent workflows.
- Forge use: inspiration for simulator visibility/control in agent loops.
- Risk: may be tied to Codex++ assumptions; inspect before adopting.
- Recommendation: research as part of native proof tooling spike.

#### `AvdLee/Xcode-Build-Optimization-Agent-Skill`

- URL: `https://github.com/AvdLee/Xcode-Build-Optimization-Agent-Skill`
- Stars at fetch: `1075`
- Language: Python
- Why it matters: agent skill for optimizing Xcode builds via benchmarks.
- Forge use: example of an iOS-specific agent skill with measurable build feedback.
- Risk: optimization is secondary to proof reliability; do not let it distract from fail-closed gates.
- Recommendation: inspect skill structure for Forge worker skill design.

#### `AvdLee/SwiftUI-Agent-Skill`

- URL: `https://github.com/AvdLee/SwiftUI-Agent-Skill`
- Stars at fetch: `2923`
- Language: Python
- Why it matters: AI coding skill focused on SwiftUI best practices.
- Forge use: candidate reference for generated app code-quality rules and SwiftUI lane prompts.
- Risk: must align with Forge's own architecture rules.
- Recommendation: compare to Forge `AGENTS.md` and consider a per-lane skill import/adaptation.

#### `twostraws/SwiftAgents`

- URL: `https://github.com/twostraws/SwiftAgents`
- Stars at fetch: `1318`
- Why it matters: AGENTS.md-style instructions for Swift/SwiftUI projects.
- Forge use: benchmark Forge-generated app instructions against a known Swift community reference.
- Recommendation: use as prompt/instruction reference, not dependency.

#### `yonaskolb/XcodeGen`

- URL: `https://github.com/yonaskolb/XcodeGen`
- Stars at fetch: `8459`
- Language: Swift
- Why it matters: declarative Xcode project generation.
- Forge use: possible future substrate/project-generation alternative if `.xcodeproj` drift becomes painful.
- Risk: substantial foundation change.
- Recommendation: park unless project-file generation becomes a blocker.

#### `Wooder/ios_17_required_reason_api_scanner`

- URL: `https://github.com/Wooder/ios_17_required_reason_api_scanner`
- Stars at fetch: `650`
- Language: Shell
- Why it matters: scans for Apple's Required Reason API usage.
- Forge use: launch/privacy readiness checker.
- Recommendation: candidate launch/privacy local spike.

### 2. App Store / launch / screenshot tooling

#### `ParthJadhav/app-store-screenshots`

- URL: `https://github.com/ParthJadhav/app-store-screenshots`
- Stars at fetch: `5149`
- Language: TypeScript
- Why it matters: end-to-end App Store screenshot creation using AI.
- Forge use: strong candidate for launch screenshot package inspiration.
- Risk: likely too launch-focused before native evidence is stable; may involve generative screenshot composition that must not outrun actual app proof.
- Recommendation: inspect now, adopt only after verifier evidence is real.

#### `froessell/app-store-opportunity-research`

- URL: `https://github.com/froessell/app-store-opportunity-research`
- Stars at fetch: `20`
- Why it matters: Claude Code skill for App Store opportunity research.
- Forge use: directly overlaps with Forge app-direction research.
- Risk: small repo; quality must be inspected.
- Recommendation: high-priority skill/prompt reference for `appstore-reference-harvester` and opportunity-scoring gates.

#### `rorkai/App-Store-Connect-CLI`

- URL: `https://github.com/rorkai/App-Store-Connect-CLI`
- Stars at fetch: `4505`
- Language: Go
- Why it matters: scriptable App Store Connect CLI.
- Forge use: future ASC/TestFlight/local draft integration.
- Risk: external mutation surface: TestFlight, submissions, signing, ASC writes.
- Recommendation: keep approval-gated; no live use without explicit action approval.

#### `rorkai/app-store-connect-cli-skills`

- URL: `https://github.com/rorkai/app-store-connect-cli-skills`
- Stars at fetch: `817`
- Why it matters: agent skills for App Store deployment flows.
- Forge use: reference for future launch lane skill design.
- Risk: can normalize dangerous live actions; must keep local-draft boundary.
- Recommendation: read-only study only for now.

### 3. Agent orchestration and Forge operating system

#### `steipete/agent-scripts`

- URL: `https://github.com/steipete/agent-scripts`
- Stars at fetch: `3568`
- Language: JavaScript
- Why it matters: practical scripts for agents across repositories.
- Forge use: candidate patterns for reusable agent scripts, worker helpers, report generation, and cross-repo agent operations.
- Recommendation: inspect for small reusable script patterns; do not bulk import.

#### `raindrop-ai/workshop`

- URL: `https://github.com/raindrop-ai/workshop`
- Stars at fetch: `744`
- Language: TypeScript
- Why it matters: gives coding agents the power to write and run agent evals.
- Forge use: strong inspiration for evaluating Forge workers/pipelines, not just app outputs.
- Recommendation: high-priority research for Forge worker/pipeline eval layer.

#### `tolibear/goalbuddy`

- URL: `https://github.com/tolibear/goalbuddy`
- Stars at fetch: `601`
- Language: JavaScript
- Why it matters: better `/goal` for Codex and Claude Code.
- Forge use: compare with Hermes GoalBuddy/Kanban loops for persistent factory goals.
- Recommendation: inspect for goal-loop UX and worker control ideas.

#### `garrytan/gbrain`

- URL: `https://github.com/garrytan/gbrain`
- Stars at fetch: `19084`
- Language: TypeScript
- Why it matters: opinionated OpenClaw/Hermes agent brain.
- Forge use: reference for personal-agent OS patterns and memory/skill organization.
- Recommendation: read for operating-model ideas; do not merge wholesale.

#### `openai/codex-plugin-cc`

- URL: `https://github.com/openai/codex-plugin-cc`
- Stars at fetch: `19698`
- Language: JavaScript
- Why it matters: Codex from Claude Code for review/delegation.
- Forge use: reference for cross-agent review/delegation patterns.
- Recommendation: useful for implementation/review lane design, but Hermes remains orchestrator.

#### `safishamsi/graphify`

- URL: `https://github.com/safishamsi/graphify`
- Stars at fetch: `54081`
- Language: Python
- Why it matters: turns folders into dynamic knowledge graphs for AI coding assistants.
- Forge use: possible inspiration for mapping Forge docs/artifacts/dependencies/capabilities as a graph.
- Recommendation: research for cockpit/capability graph ideas; likely not immediate dependency.

#### `getzep/graphiti`

- URL: `https://github.com/getzep/graphiti`
- Stars at fetch: `26578`
- Language: Python
- Why it matters: real-time knowledge graphs for AI agents.
- Forge use: future learning loop/capability memory graph.
- Risk: heavy dependency; likely overkill before first factory proof.
- Recommendation: park as future learning-loop candidate.

#### `rowboatlabs/rowboat`

- URL: `https://github.com/rowboatlabs/rowboat`
- Stars at fetch: `14417`
- Language: TypeScript
- Why it matters: open-source AI coworker with memory.
- Forge use: reference for autonomous coworker UX/control loops.
- Recommendation: study for cockpit/operator UX patterns.

#### `superset-sh/superset`

- URL: `https://github.com/superset-sh/superset`
- Stars at fetch: `11272`
- Language: TypeScript
- Why it matters: code editor for running an army of Claude Code/Codex agents.
- Forge use: reference for multi-agent cockpit/worker fleet UX.
- Recommendation: study, but keep Forge cockpit lightweight first.

### 4. Skills and agent capability libraries

#### `mattpocock/skills`

- URL: `https://github.com/mattpocock/skills`
- Stars at fetch: `106409`
- Language: Shell
- Why it matters: curated engineering skills.
- Forge use: benchmark skill quality, structure, and scope.
- Recommendation: mine selectively for skill-authoring patterns.

#### `ComposioHQ/awesome-claude-skills`

- URL: `https://github.com/ComposioHQ/awesome-claude-skills`
- Stars at fetch: `61898`
- Language: Python
- Why it matters: broad Claude skill catalog.
- Forge use: discovery source for app factory skills.
- Recommendation: include in capability reconnaissance source list.

#### `skills-directory/skill-codex`

- URL: `https://github.com/skills-directory/skill-codex`
- Stars at fetch: `1269`
- Why it matters: Claude Code skill to delegate prompts to Codex.
- Forge use: cross-harness delegation patterns.
- Recommendation: compare to Hermes `delegate_task` and Kanban profile dispatch.

#### `plugin87/ux-ui-agent-skills`

- URL: `https://github.com/plugin87/ux-ui-agent-skills`
- Stars at fetch: `196`
- Why it matters: UX/UI skills for agents.
- Forge use: candidate anti-slop/taste prompt material.
- Recommendation: inspect during visual-taste lab.

#### `jakubkrehel/make-interfaces-feel-better`

- URL: `https://github.com/jakubkrehel/make-interfaces-feel-better`
- Stars at fetch: `880`
- Why it matters: agent skill based on interface detail craft.
- Forge use: great candidate for visual judge rubrics and repair prompts.
- Recommendation: high-priority visual/taste reference.

#### `VoltAgent/awesome-design-md`

- URL: `https://github.com/VoltAgent/awesome-design-md`
- Stars at fetch: `84363`
- Why it matters: collection/analysis of DESIGN.md files from popular brand design systems.
- Forge use: direct foundation source for app-specific design-system generation.
- Recommendation: add to design-reference source list; no code dependency needed.

### 5. Native app architecture/UI references

These are not immediate dependencies, but useful as pattern references for generated app craft:

- `pointfreeco/swift-composable-architecture` — strong architecture/testing reference, but likely too heavy for proof apps.
- `nalexn/clean-architecture-swiftui` — reference architecture sample.
- `Dimillian/IceCubesApp` — real SwiftUI app quality reference.
- `Dimillian/MovieSwiftUI` — SwiftUI app architecture/reference implementation.
- `hmlongco/Factory` — DI candidate/reference; Forge already has service injection rules.
- `Swinject/Swinject` — DI reference, probably not needed for proof apps.
- `SDWebImage/SDWebImageSwiftUI` — image loading reference; Forge currently prefers `ImageLoaderView`.
- `amosgyamfi/open-swiftui-animations`, `Shubham0812/SwiftUI-Animations`, `EmergeTools/Pow`, `roberthein/Kinetics` — motion/taste references; adopt only per-app if justified.
- `Dimillian/AppRouter`, `rundfunk47/stinsen`, `joeldev/JLRoutes` — navigation/routing references; probably not foundation unless router pain appears.

Recommendation:

- Add a `starred-ios-pattern-index` source that maps these to specific app-factory questions instead of randomly adopting libraries.

## Proposed additions to Forge capability plan

### New source: `source.github.personal-stars`

- Status: available.
- Scope: foundation research source.
- Access: authenticated read-only `gh api /user/starred`.
- Use: personalized capability discovery and source prioritization.
- Risk: personal bias and stale stars; verify freshness/maintenance/license before adoption.

### New spike: `spike.github-stars-capability-miner`

Goal:

- turn Matvii's starred repos into a structured Forge capability registry input.

Inputs:

- all starred repos with name, URL, description, topics, language, stars, license, updated date, starred date.

Outputs:

- categorized candidates by Forge layer:
  - research;
  - visual/taste;
  - native proof;
  - verifier/evidence;
  - launch/package;
  - agent orchestration;
  - substrate/template;
  - learning/cockpit.
- recommended action per repo:
  - inspect;
  - spike;
  - park;
  - reject;
  - approval-needed.

Success criteria:

- no dependency adopted automatically;
- top 20 candidates have specific Forge use case and risk class;
- cockpit shows stars as a capability source.

### New approval-gated candidates found from stars

- `getsentry/XcodeBuildMCP` — inspect for MCP native proof tooling.
- `ParthJadhav/app-store-screenshots` — inspect for launch screenshot tooling.
- `froessell/app-store-opportunity-research` — inspect for App Store opportunity research skill design.
- `rorkai/App-Store-Connect-CLI` and `rorkai/app-store-connect-cli-skills` — keep approval-gated for future launch lane.
- `raindrop-ai/workshop` — inspect for agent evals.
- `b-nnett/codex-plusplus-ios-simulator` — inspect for simulator-in-agent-loop ideas.
- `AvdLee/SwiftUI-Agent-Skill` and `twostraws/SwiftAgents` — inspect for SwiftUI/iOS agent instruction quality.
- `jakubkrehel/make-interfaces-feel-better` and `plugin87/ux-ui-agent-skills` — inspect for visual/taste skill material.
- `VoltAgent/awesome-design-md` — inspect for design-system source material.

## Updated immediate action recommendation

Add one more autonomous read-only spike before broad web expansion:

1. capability registry scanner;
2. **GitHub stars capability miner**;
3. App Store reference harvester;
4. Reddit demand harvester;
5. GitHub iOS pattern index.

This makes Forge's research more personalized and likely more useful than generic web search.
