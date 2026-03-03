# Forge Pipeline Quality Fix — Session Brief

## The Problem

The Forge pipeline consistently produces apps that are WORSE than the template it starts from. The template has polished onboarding (StaggeredVStack, AmbientBackground, lineByLineTransition, DSChoiceButton, smooth springs), good DS components, and proper architecture. When agents "build" screens, they throw away all of this and write raw SwiftUI from scratch — hardcoded font sizes, LinearGradient instead of AmbientBackground, custom Button instead of DSButton, no entrance animations. The output compiles but looks cheap and generic.

## Root Cause Chain (diagnosed in previous session)

The problem is upstream, not in screen building:

1. **AGENTS.md was stripped of guardrails.** The original AGENTS.md (commit d083ce9, 293 lines) had "How to Customize Onboarding/HomeView/Paywall" sections that told agents to MODIFY existing screens, not rebuild. It had Design Principles (borderless surfaces, warm neutrals, ambient gradients, shadow-only depth) and Craft Patterns (floating CTAs with safeAreaInset, StaggeredVStack entrances, hero stats patterns). We stripped all of this during a "lean refactor" (commit 49bd676: "AGENTS.md is agent-only, 423 → 158 lines"), calling them "human docs." They were actually the scaffolding guardrails.

2. **Feature specs describe dream apps, not template customizations.** forge-ux writes specs like "DNA helix animation transforming into archetype icon" and "Instagram Story format share card (1080x1920)" — features that would take a design team weeks. The specs never reference that a working onboarding ALREADY EXISTS in the template. The agent reads the spec and builds from scratch.

3. **design-system.md contradicts itself.** The Component Strategy table correctly says "MODIFY DSChoiceButton for quiz" and "use AmbientBackground for welcome." But the Screen Blueprint code sketches use raw SwiftUI (LinearGradient, Font.system(size:)). The agent copies the code sketch, not the strategy table.

4. **The pipeline says "build" not "customize."** The forge-app orchestrator dispatches agents with "Build and visually craft the {screen_name} screen." This implies from-scratch creation. The template screens (Onboarding, Home, Settings, Paywall) already exist and work.

## The User's Vision

The template is **a scaffolding with guardrails** — it defines the architectural constraints (MVVM, navigation patterns, DS token system, animation vocabulary) while allowing agents creative freedom within them.

**Structure (don't break):** Architecture, DS tokens, theme protocol, component patterns, animation springs (.smooth, .bouncy, .snappy), quality patterns (AmbientBackground, StaggeredVStack, safeAreaInset CTAs)

**Expression (create freely):** Visual personality, layout composition, new components (built WITH DS tokens), mood-specific customization, unique content and interactions

The template is the FLOOR, not the ceiling. Apps should look DIFFERENT from each other and BETTER than the template — but never WORSE. Agents currently can't tell the difference between structure (preserve) and expression (create freely). They either preserve everything (template-like) or replace everything (breaks the floor).

## What Needs Fixing

### 1. Restore guardrails to AGENTS.md
The original AGENTS.md at commit d083ce9 had these sections that need to come back (adapted, not copy-pasted):
- "How to Customize" sections per screen — tells agents to MODIFY existing files
- Design Principles — the floor rules (borderless, warm neutrals, ambient, shadow-only)
- Craft Patterns — HOW to use DS components correctly (floating CTAs, staggered entrances, hero stats)
- New component rules — create in /Components/Views/, use DS tokens, no business logic

Compare `git show d083ce9:AGENTS.md` (original with guardrails) vs current AGENTS.md to see exactly what was lost.

### 2. Fix the upstream spec problem
forge-ux feature specs should acknowledge the template. When the screen type exists in the template (Onboarding, Home, Settings, Paywall), the spec should describe WHAT TO CHANGE, not describe a new screen from scratch. For screens that don't exist in the template, the spec should reference the closest template screen's patterns.

The forge-craft design-system.md code sketches MUST use DS components and DS tokens — never raw SwiftUI in code examples. If the Component Strategy says "MODIFY DSChoiceButton," the code sketch should show DSChoiceButton with modifications, not a custom Button.

### 3. Code-level floor enforcement
After building, scan the code for floor violations — rules in prompts don't work, code checks do:
- Used `Font.system(size:)` → should use DS typography token
- Used raw `LinearGradient` for background → should use AmbientBackground
- Used raw `Button()` → should use DSButton/DSIconButton
- Missing DSScreen as root → flag
- No StaggeredVStack or entrance animation → flag

This could be a grep-based check in forge-verifier or a new verification step.

### 4. Change "build" to "customize" where template screens exist
The orchestrator dispatch prompt should distinguish:
- Template screens (Onboarding, Home, Settings, Paywall): "The template {screen} exists at {path}. Read the existing files. Modify them to match the feature spec. Keep DS components, transitions, and animation patterns. Add domain-specific content."
- New screens (Transactions, Monthly Wrap, Archetype Profile): "Create a new screen. Use the closest template screen as a reference for patterns and quality bar."

## Key Files

- Template AGENTS.md (original): `git show d083ce9:AGENTS.md` (293 lines, has guardrails)
- Current AGENTS.md: `/Users/matvii/Documents/Developer/Templates/forge/AGENTS.md`
- forge-app orchestrator: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-app/skills/forge-app/SKILL.md`
- forge-craft-agent (new, merged build+polish): `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/agents/forge-craft-agent.md`
- forge-craft research: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-craft/skills/forge-craft/SKILL.md`
- forge-ux (feature design): `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-ux/skills/forge-ux/SKILL.md`
- forge-feature pipeline: `~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins/forge-feature/skills/forge-feature/SKILL.md`
- Template onboarding (what "good" looks like): Forge/Features/Onboarding/ in the template repo (OnboardingView.swift, OnboardingStep.swift, OnboardingController.swift)
- Design doc: docs/plans/2026-03-02-artisan-model-design.md
- Memory: ~/.claude/projects/-Users-matvii-Documents-Developer-Templates-forge/memory/MEMORY.md

## Recent Pipeline Changes (Artisan Model, 2026-03-02)

- forge-builder and forge-polisher were MERGED into forge-craft-agent (one agent that builds and visually verifies)
- App Store browsing fixed with Playwright code snippet (browser_run_code)
- Human checkpoints added (first 2 screens approved individually, then batch)
- Output format simplified to 5 items (screenshot, evaluation, files, issues, build)
- These changes are correct but insufficient — they fix the build step but the upstream problems (AGENTS.md guardrails, feature spec ambition, design-system.md contradictions) still feed bad instructions to the agent

## What NOT to Do

- Don't add more prompt rules. Agents ignore rules. Use code-level enforcement.
- Don't add more complexity. The pipeline already has too many rules that aren't followed.
- Don't try to automate visual quality judgment. Human eyes are the final check.
- Don't make the template more rigid. The goal is creative freedom within structural constraints.
- Don't strip AGENTS.md "for agents only" again. The customization guides and design principles ARE for agents.

Use /forge-publish when done to sync marketplace, cache, commit, and push both repos.
