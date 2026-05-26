# Forge Operator Control Loop

Status: proposed operating contract for human-facing Forge updates.
Scope: Telegram updates, visual proof packets, Kanban lifecycle, dashboard/report needs, and ask-vs-continue rules. This document is control-plane UX only; it does not generate or modify an app.

## 1. Goal

Matvii should see Forge as a product-studio control loop, not as raw Kanban noise.

The human-facing loop is:

```text
state -> proof -> decision/next action -> autonomous continuation
```

Every operator surface must answer three questions quickly:

1. What is true now?
2. What proof backs it?
3. What, if anything, must Matvii decide?

Kanban remains the durable machine ledger. Telegram and dashboards should expose only the decision-relevant layer.

## 2. Non-goals

- Do not stream every card transition to Matvii.
- Do not ask for vague "review" when a verifier, judge, or repair route exists.
- Do not merge app quality and pipeline quality into one hidden grade.
- Do not report blocked cards as status-only; classify and route them.
- Do not use this document to authorize native app generation, public launch actions, signing, App Store Connect, TestFlight, IAP, paid tools, deletion, or account actions.

## 3. Operator surfaces

### Cockpit control plane

The cockpit must expose tools/dependencies/services as first-class state, not hidden implementation detail.

Every phase should show:

- currently active local tools;
- external read-only sources actually used;
- proposed experiments not yet adopted;
- dependency proposal registry split into foundation-level vs per-app proposals;
- services/dependencies requiring Matvii approval;
- blocked or unavailable capabilities;
- new tooling/service deltas since last preserved commit.

Detailed registries:

- `docs/forge-vnext/forge-tooling-service-control-plane.md`
- `docs/forge-vnext/dependency-proposal-registry.md`

New worker handoffs should include `dependency_proposals` and `tooling_service_delta` whenever they add or propose a package, API, account, paid service, public/external action, runtime dependency, or foundation-layer tool.

### Telegram

Use Telegram only for human-relevant moments:

- real human gates;
- compact proof packets after important gates;
- blocker notices that genuinely require Matvii;
- daily/phase digest when autonomous work continued without interruption;
- high-risk anomaly: repeated worker failure, evidence contradiction, or hard fail.

Telegram should be short mobile bubbles, not board dumps. Prefer 2-3 bubbles:

1. State.
2. Proof.
3. Next / decision.

### Kanban

Kanban is the durable execution log:

- exact task spec;
- parent/child dependencies;
- comments with structured handoffs;
- blocker classification;
- worker run history;
- artifact paths.

Kanban should optimize for worker continuity, not human readability. Human dashboards can summarize it.

### Visual proof packet

The proof packet is the bridge between worker evidence and human trust. It is required before real approval gates and final quality claims.

It can be a markdown file, dashboard section, or Telegram-linked artifact, but it must have stable paths and evidence references.

### Dashboard/report

The dashboard should show current decisions, proof, blockers, and next autonomous work. It should not force Matvii to inspect every task unless he chooses to drill down.

## 4. Telegram update shapes

All Telegram updates should use these shapes. If sent through a platform that supports separate messages, split each numbered block into its own bubble.

### 4.1 Gate decision request

Use only for a real human gate.

```text
State
Forge is at Gate <A/B/C/D>: <short gate name>.
Default if unanswered: <safe default>.
```

```text
Proof
App score: <x>/10 or n/a.
Pipeline score: <x>/10 or n/a.
Hard fail: <yes/no/unknown>.
Evidence: <1-3 artifact names or paths>.
```

```text
Decision
Choose one: <option A>, <option B>, <option C>.
I will <continue/stop/repair> based on that answer.
```

Rules:

- Use the clarify/options tool where available for the final decision.
- Max 4 options.
- Name the safe default.
- Never ask "thoughts?" or "review?".

### 4.2 Autonomous progress digest

Use when useful work continued and no decision is needed.

```text
State
Forge continued locally. No Matvii decision needed.
```

```text
Proof
Done: <1-3 concrete outputs>.
Verified: <test/build/script/evidence check>.
```

```text
Next
Now running/queued: <one next card or phase>.
I will ask only if a real gate appears.
```

### 4.3 Visual proof packet ready

Use when a reviewable artifact exists.

```text
Proof packet ready
<app/direction/pipeline phase> has a review packet.
Verdict: <pass/repair/kill/needs human gate>.
```

```text
What to inspect
1. <artifact path or title>
2. <artifact path or title>
3. <artifact path or title>
```

```text
Next
<exact decision or autonomous route>.
```

### 4.4 Blocker notice

Use only when Matvii is needed or when the blocker is important enough to explain. Otherwise record it in Kanban and continue.

```text
Blocked
<task title/id> is blocked because <one concrete reason>.
Classification: <real_human_gate|mechanical_repair|pipeline_bug|worker_error|dependency_shape_bug>.
```

```text
Route
Matvii needed: <yes/no>.
Repair/prevention: <task id/title or n/a>.
```

```text
Decision
<exact decision needed, or "none — I am routing it through Kanban">.
```

### 4.5 Final phase verdict

Use when a phase ends.

```text
Verdict
<phase> is <passed/repaired/failed/blocked>.
```

```text
Scores
App: <x>/10 or n/a.
Pipeline: <x>/10.
Hard fail: <yes/no + reason if yes>.
```

```text
Next
<one recommended next action>.
```

## 5. Visual proof packet contract

Every proof packet should have this structure.

```text
# <Phase/App/Direction> Proof Packet

Status: <pass|repair|kill|human_gate|failed>
Gate: <A/B/C/D or local gate name>
Generated app: <none|path>
External actions: none unless explicitly approved

## Verdict
- App score: <x>/10 or n/a
- Pipeline score: <x>/10 or n/a
- Hard fail: <true/false>
- Recommendation: <continue|repair|kill|ask Matvii>

## What changed
- <artifact/task/result>

## Evidence
- Build/test/run: <paths or n/a>
- Screenshots/video: <paths or n/a>
- Evidence index: <path or n/a>
- Research sources: <paths or n/a>
- Scorecards: <paths or n/a>

## Visual review
- Screenshot set: <path or n/a>
- Prototype: <path or n/a>
- Native screen notes: <path or n/a>
- Taste risks: <1-3 bullets>

## Open gaps
- <gap + owner + route>

## Human decision, if any
Question: <exact question or n/a>
Options: <max 4 options or n/a>
Default if unanswered: <safe default>

## Resume route
- If approved: <next card/action>
- If rejected: <repair/kill route>
```

Minimum proof rules:

- A visual/taste gate needs screenshots, prototype, or explicit visual substitute evidence.
- A native implementation gate needs build/run/test/screenshot evidence or an indexed reason why a substitute is accepted.
- A launch/external gate needs exact action, account/surface, reversibility, cost/risk, and local evidence already produced.
- A greatness claim needs separate app and pipeline scorecards plus hard-fail checklist.

Visual excellence hard-gate rules:

- Native generation may not start unless the proof packet links a passing `visual_judge_pre_native` artifact and that artifact explicitly allows native expansion.
- Human review may not be requested unless the proof packet links a passing `visual_judge_post_native` artifact and that artifact explicitly allows human review.
- A visual proof packet must name the state of each required lane: `visual_reference_research`, `original_visual_synthesis`, `prototype_before_native`, `visual_judge_pre_native`, `native_screenshot_sequence`, `visual_judge_post_native`, and `visual_repair_loop`.
- `visual_repair_loop` is the default route for repairable visual failures. Ask Matvii only for explicit taste/product/kill decisions, not for missing screenshots, stale evidence, generic-card slop, or prototype/native mismatch that a lane worker can fix.

## 6. Kanban card lifecycle

Forge cards should move through this lifecycle.

```text
triage -> shaped -> ready -> running -> handoff/review/blocked -> done/archived
```

Hermes Kanban statuses may remain `triage`, `todo`, `ready`, `running`, `blocked`, and `done`; the lifecycle below defines the meaning Forge workers should encode in titles, bodies, comments, and handoffs.

### Triage

Meaning: raw idea, not safe to dispatch.

Required before leaving triage:

- outcome;
- non-goals;
- known context/artifacts;
- acceptance criteria;
- assignee lane;
- parent dependencies;
- ask-vs-continue boundary.

### Shaped todo

Meaning: specified card exists but a parent/gate is not done yet.

Template title:

```text
Forge vNext: <verb> <artifact/gate> after <parent condition>
```

Template body:

```text
Outcome: <one sentence>.

Context:
- Parent: <task id/title>
- Required docs/artifacts: <paths>

Do:
- <specific work>

Do not:
- <non-goals, external action bans, app generation ban if relevant>

Acceptance:
- <artifact path>
- <verification command or review rule>
- <handoff fields required>

Ask Matvii only if:
- <real human gate conditions>
```

### Ready

Meaning: all parents are done and the assigned profile can start without new human input.

Ready cards must not contain unresolved human choices. If a choice exists, the card should be blocked as a gate or kept in triage.

### Running

Meaning: a worker has claimed the card.

Worker obligations:

- write artifacts only in the allowed workspace/path;
- add heartbeats for long work;
- comment before blocking if context is non-trivial;
- complete with structured metadata for terminal research/docs work;
- for code changes needing human review, comment structured handoff then block with `review-required:`.

### Handoff / review

Meaning: output exists, but a verifier/judge/human decision owns acceptance.

Use child verifier/judge cards when review is mechanical or expert-agent-owned. Do not block implementation cards for generic review if a downstream verifier card exists.

Review handoff comment template:

```text
review handoff:
- artifact: <path>
- changed_files: <paths>
- verification: <commands/results>
- known_gaps: <bullets or none>
- next_owner: <profile/human>
```

### Blocked

Meaning: work cannot continue on this card.

Every blocked card must be classified:

- `real_human_gate` — Matvii must decide.
- `mechanical_repair` — concrete local artifact/build/test/evidence failure.
- `pipeline_bug` — repeatable Forge system failure.
- `worker_error` — unusable handoff, wrong profile, vague stuck state, ignored instructions.
- `dependency_shape_bug` — wrong parent/child/status/review topology.

Blocked cards must include the blocker notice from `watchdog-blocker-brief.md` or equivalent fields:

```text
What blocked: <task title/id>
Why: <one concrete sentence>
Classification: <class>
Matvii needed: <yes/no>
Task launched: <task id/title or n/a>
Decision needed: <exact decision or n/a>
Inspect: hermes kanban show <task-id>
Resume: hermes kanban unblock <task-id>
```

### Done

Meaning: acceptance criteria are satisfied and no reviewer is required for the card's scope.

Done handoff metadata should include:

```json
{
  "artifact_path": "docs/forge-vnext/<file>.md",
  "changed_files": ["docs/forge-vnext/<file>.md"],
  "tests_run": 0,
  "verification": ["read_file confirmed artifact content"],
  "decisions": ["<key design/routing decision>"]
}
```

### Archived

Meaning: card is old, superseded, killed, or folded into a newer artifact. Archive only after the durable artifact or successor card is clear.

## 7. Proposed card templates

### 7.1 Gate card

```text
Title: Forge Gate <A/B/C/D>: <decision name>
Assignee: forgeproduct or human-facing operator profile
Parents: <all required evidence cards>

Outcome: obtain or record the exact human/pipeline decision for <gate>.

Decision packet:
- Question: <exact question>
- Options: <max 4>
- Default if unanswered: <safe default>
- Proof packet: <path>

Acceptance:
- Kanban comment records selected option and timestamp/source.
- Child cards are created/routed for the selected option.
- No native/external/deletion action happens unless explicitly approved.
```

### 7.2 Proof packet card

```text
Title: Forge proof packet: <phase/app/gate>
Assignee: forgejudge or forgeproduct
Parents: <producer cards>

Outcome: create a human-readable proof packet that summarizes evidence, scores, hard fails, and next route.

Inputs:
- <artifact paths>

Acceptance:
- `docs/forge-vnext/<name>-proof-packet.md` exists.
- Packet includes separate app/pipeline scores or explains n/a.
- Packet links visual/build/test/evidence artifacts.
- Packet names exact human decision or autonomous next route.
```

### 7.3 Mechanical repair card

```text
Title: Repair blocker: <broken artifact/check>
Assignee: <owning lane>
Parents: <blocked task id>

Outcome: repair the concrete local failure so the blocked parent can resume.

Source blocker:
- Task: <id/title>
- Classification: mechanical_repair
- Failure: <command/artifact/error>

Acceptance:
- Broken check passes or is replaced by an approved indexed substitute.
- Parent card receives a comment with exact resume instructions.
```

### 7.4 Pipeline hardening card

```text
Title: Prevent recurring blocker: <failure class>
Assignee: forgejudge or owning pipeline lane
Parents: <source blocker or watchdog task>

Outcome: add durable prevention for a repeatable Forge failure class.

Source blocker:
- Task: <id/title>
- Classification: pipeline_bug
- Signals: <bullets>

Acceptance:
- Prevention is encoded as one of: verifier/test/gate, generator/substrate patch, watchdog/orchestrator routing update, doc/skill rule.
- A fixture/probe/doc example proves the failure class is now caught or routed.
```

### 7.5 Judge/verifier card

```text
Title: Judge Forge output: <artifact/app/gate>
Assignee: forgejudge or forgeverifier
Parents: <producer cards>

Outcome: independently assess the output against the relevant contract.

Acceptance:
- Verdict: pass/repair/kill/human_gate.
- Evidence checked: <paths/commands>.
- Findings are structured by severity.
- Follow-up repair cards are created for non-human failures.
- Human gate is requested only for taste/product/final/external decisions.
```

## 8. Proposed status templates

### Compact phase report

```text
phase: <name>
status: <running|passed|repairing|blocked|failed>
matvii_needed: <yes/no>
current_card: <id/title>
proof_packet: <path or n/a>
next_action: <one sentence>
```

### Blocker status

```text
blocked_task: <id/title>
classification: <real_human_gate|mechanical_repair|pipeline_bug|worker_error|dependency_shape_bug>
matvii_needed: <yes/no>
route: <repair task/prevention task/retry/human decision>
resume_condition: <exact condition>
```

### Gate status

```text
gate: <A/B/C/D/local>
question: <exact question>
options: [<option1>, <option2>, <option3>]
default_if_unanswered: <safe default>
proof_packet: <path>
blocked_until_answer: <true/false>
```

### Proof status

```text
artifact: <path>
app_score: <number or n/a>
pipeline_score: <number or n/a>
hard_fail: <true/false/unknown>
evidence_index: <path or n/a>
visual_evidence: <path(s) or n/a>
recommendation: <continue|repair|kill|ask>
```

## 9. Dashboard/report needs

The Forge dashboard should show these sections in this order.

### 9.1 Decision inbox

Only real human gates.

Fields:

- gate name;
- exact question;
- options;
- safe default;
- proof packet path;
- risk of approving;
- cost of waiting.

Empty state: `No Matvii decision needed. Forge can continue locally.`

### 9.2 Current proof

One row per active phase/app/gate.

Fields:

- verdict;
- app score;
- pipeline score;
- hard fail;
- proof packet path;
- most important visual artifact;
- latest verifier/judge status.

### 9.3 Active work

Summarized lane view, not raw Kanban spam.

Fields:

- card id/title;
- lane/assignee;
- why it matters;
- expected output artifact;
- started/last heartbeat;
- whether Matvii is needed.

### 9.4 Blockers and routes

Grouped by classification.

Fields:

- blocker class;
- task id/title;
- route task id/title;
- Matvii needed yes/no;
- resume condition;
- recurrence count if available.

### 9.5 Recent artifacts

Most recent durable outputs only.

Fields:

- artifact path;
- phase;
- verdict;
- verification;
- downstream owner.

### 9.6 Daily/phase report

A compact generated report should include:

```text
Forge report: <date/phase>

Decision inbox:
- <none or gate summaries>

Proof:
- <latest proof packet + verdict>

Autonomous progress:
- <3-5 important outputs>

Blockers routed:
- <class + route, only material blockers>

Next:
- <one recommended next action or "continue locally">
```

## 10. Ask vs continue rules

### Ask Matvii

Ask only when the answer changes risk or direction and cannot be inferred safely:

- Gate A/B/C/D from the Forge greatness charter;
- product/taste direction approval before native generation when required by the gate;
- public/external/account/money/App Store/TestFlight/signing/IAP/paid-tool/credential action;
- deletion or irreversible movement of repos/apps/artifacts;
- final acceptance that Forge is "super great" or interview-level;
- overriding a judge on product taste, strategy, launch readiness, or hard-fail acceptance;
- ambiguous strategic tradeoff where multiple options are genuinely viable.

### Continue autonomously

Continue without asking when the work is local, reversible, and already inside the charter:

- reading local artifacts and public/read-only sources;
- creating docs/proof packets under `docs/forge-vnext/`;
- running local validators/builds/tests/simulator/screenshot capture;
- creating mechanical repair, judge, verifier, or pipeline-hardening cards;
- classifying blocked cards and routing non-human blockers;
- killing/repair-routing weak directions before native generation;
- recording postmortems and proposed learning patches without applying material behavior changes unless scoped.

### Block but do not ask broadly

If a worker lacks context, it should block with an exact question or create a shaping task. It should not send Matvii a broad dump.

Bad:

```text
Need review / unclear what to do next.
```

Good:

```text
real-human-gate: approve, revise, or kill the Pet Care Relay direction before native generation; default is no generation.
```

Good non-human route:

```text
pipeline_bug: visual state is invisible before acceptance; created Prevent recurring blocker: require visual proof packet before Gate B.
```

## 11. Operator success criteria

This control loop is working when:

- Matvii sees at most one clear decision at a time.
- Every decision has a proof packet.
- Every blocker has a classification and route.
- Telegram never reads like raw Kanban event logs.
- Dashboard empty states say whether Forge can continue locally.
- App score and pipeline score remain separate.
- Workers ask less often but stop harder at real gates.
- The next action is always obvious: approve, repair, kill, inspect proof, or let Forge continue.
