# Forge App Factory Operating Model

Status: draft structure for the broader Forge goal.
Date: 2026-05-26
Scope: app-factory strategy, research lanes, tool/plugin/dependency discovery, and iteration gates before the next pipeline run.

## 1. Core thesis

Forge should not begin another app-generation iteration until it has an explicit map of the tools, agent skills, plugins, external sources, and dependency options that can improve the factory.

The product is not a single generated app. The product is a repeatable app factory that can:

1. discover worthwhile app directions;
2. borrow safely from the world without copying;
3. synthesize taste and product strategy;
4. generate native proof apps;
5. verify with real local evidence;
6. package launch materials;
7. learn without overfitting to one app.

## 2. Broader factory loop

```text
Factory intelligence research
  -> capability registry
  -> tool/dependency approval/spike
  -> pipeline integrity gates
  -> app direction research
  -> product/taste gate
  -> visual inspiration + synthesis
  -> prototype judge
  -> native proof
  -> evidence verifier
  -> launch package
  -> postmortem + learning patches
```

Important ordering rule:

> Tooling/capability research is a first-class upstream goal, not a side effect during app generation.

## 3. Factory layers

### Layer A — Intelligence sources

Goal: find what the world already knows.

Potential sources:

- public App Store listings/screenshots/reviews;
- Apple HIG and platform docs;
- public GitHub repos and templates;
- public design/product blogs;
- Hacker News / Reddit / forums where relevant;
- X/Twitter discourse if safe read-only access is configured or approved;
- design reference services if approved: Mobbin, Page Flows, Nicelydone, Refero, DesignArena;
- open-source iOS libraries, Swift packages, screenshot tooling, UI examples;
- agent-framework / coding-agent patterns relevant to orchestration.

Outputs:

- source inventory;
- access constraints;
- trust/confidence score;
- reusable research queries;
- ethical/safety constraints: borrow patterns, not assets/brands.

### Layer B — Capability/tool registry

Goal: know what Forge can use before it tries to build.

Categories:

- Hermes skills and profiles;
- Hermes plugins / MCP servers;
- local CLI tools;
- Node scripts and validators;
- Xcode/simulator tooling;
- design/prototype tools;
- visual regression tools;
- screenshot/accessibility tools;
- LLM/vision judge providers;
- launch/package helpers;
- external APIs and services.

Every capability should have:

- status: available / missing / proposed / approved-for-spike / adopted / rejected / parked;
- scope: foundation / per-app / both;
- approval class: autonomous local / read-only public / ask-before-use / blocked unless approved;
- cost/account risk;
- maintenance risk;
- rollback plan;
- concrete pipeline layer it improves.

### Layer C — Safe borrowing and synthesis

Goal: use the web/GitHub/Twitter/design references without producing clones or slop.

Rules:

- collect references from multiple categories;
- separate `borrow`, `avoid`, and `transform` notes;
- never copy assets, brand, exact layout, distinctive identity, or proprietary flows;
- require original synthesis before prototype;
- cite every source with access date and limitation;
- visual judge compares against the quality bar, not against one copied reference.

Outputs:

- visual/product reference packet;
- original synthesis doc;
- pattern inventory;
- rejected-patterns list;
- risk notes for copying/overfitting.

### Layer D — Pipeline integrity

Goal: Forge cannot claim success unless the evidence is real.

Mandatory gates:

- generated apps fail verifier by default until required checks/evidence exist;
- final audit cannot pass from fixtures only;
- Xcode/simctl preflight blocks native proof if unavailable;
- visual judge is part of final audit fan-in;
- five-state screenshot sequence is mandatory for native proof;
- launch package consumes verifier evidence index;
- app score and pipeline score remain separate;
- all tool/dependency changes emit `tooling_service_delta`.

### Layer E — App direction/product taste

Goal: app ideas are chosen after the factory knows its tools and proof bar.

Outputs:

- multiple app directions;
- evidence matrix;
- target user/problem/job;
- activation/core loop/retention/money boundary;
- explicit kill/repair/proceed decision;
- app-specific dependency proposals, if needed.

### Layer F — Prototype and native proof

Goal: prove product and design before full native expansion.

Sequence:

1. reference research;
2. original visual/product synthesis;
3. local HTML/clickable prototype or equivalent;
4. pre-native visual judge;
5. native SwiftUI proof app in separate repo;
6. build/run/screenshot/accessibility evidence;
7. post-native visual judge;
8. verifier/final audit.

### Layer G — Launch and learning

Goal: produce local launch materials and improve Forge without silently mutating the factory.

Outputs:

- local launch package;
- privacy/pricing/copy/screenshot/testflight drafts;
- app scorecard;
- pipeline scorecard;
- postmortem;
- proposed learning patches;
- dependency/tooling decisions preserved in registry.

## 4. Research-first goal structure

### Goal 0 — Factory capability reconnaissance

Question:

> What tools, agents, plugins, external sources, and open-source projects should Forge consider before the next app iteration?

Workstreams:

1. **Design/reference intelligence** — sources for high-quality visual/product patterns.
2. **Native iOS proof tooling** — build, screenshot, accessibility, snapshot, simulator automation.
3. **Visual/taste judging** — LLM/vision judges, local diffs, rubric design, human proof packets.
4. **Product/demand research** — App Store, reviews, public discourse, GitHub trends, pain signals.
5. **Agent orchestration** — skills/profiles/plugins/MCP/Kanban patterns that make workers more reliable.
6. **Launch/package tooling** — privacy, pricing, copy, screenshot plans, local ASC drafts without live mutation.
7. **Substrate/template strategy** — what should be in Forge default substrate vs per-app only.

Required output:

- `docs/forge-vnext/factory-capability-research.md`
- updated dependency proposal registry;
- cockpit capability summary;
- recommended spikes with approval class.

### Goal 1 — Approve or reject capability spikes

Matvii chooses from a short menu:

- local no-account spikes approved automatically if low risk;
- account/paid/API/browser-login tools require explicit approval;
- foundation adoption requires a separate accept step after a spike.

### Goal 2 — Pipeline fail-closed repair

Use the selected capabilities only if they help close known false-positive gaps.

Priority repairs:

1. generated-app verifier fail-closed;
2. generation smoke command;
3. visual judge/five-state screenshot integration;
4. Xcode/simctl preflight;
5. launch evidence unification.

### Goal 3 — App direction research

Only after Goals 0-2 create enough confidence.

Choose an app direction based on:

- real user pain;
- product loop;
- visual opportunity;
- buildability with approved capabilities;
- low external/service risk for proof.

### Goal 4 — One tiny brutal proof run

Run the smallest real app through the repaired pipeline, with traps and hard-fail paths preserved.

Success is not necessarily a great app. Success is Forge honestly proving or rejecting its own output.

## 5. Decision model

When a new tool/dependency/source appears, classify it as:

```text
1. Useful source only — safe read-only research.
2. Useful local tool — spike locally, no adoption yet.
3. Foundation candidate — needs proposal + spike + review before adoption.
4. Per-app candidate — allowed only for one app direction if approved.
5. External/account/paid/mutating — ask Matvii before use.
6. Reject/park — too risky, noisy, expensive, or low leverage.
```

## 6. Suggested next move

Create a dedicated research goal before more pipeline iteration:

> Forge Capability Reconnaissance: map tools, skills, plugins, public sources, design references, GitHub projects, and external services that could improve the app factory; produce a registry of safe-to-use sources, proposed spikes, approval needs, and recommended pipeline upgrades.

Do not build the next app during this goal.

Do not adopt new dependencies during this goal unless explicitly approved.

Do update the cockpit and dependency registry with the findings.
