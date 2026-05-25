# Forge vNext Blocker Taxonomy and Routing

Status: active operating rule for persistent orchestrator/watchdog loops.

This document turns blocked Kanban cards into pipeline-improvement work. The default response to a blocker is no longer "unblock and continue". The orchestrator/watchdog must classify the blocker, record the route, and create a prevention/repair task unless the card is a real human gate.

## Taxonomy

### `real_human_gate`

Use only when Matvii is genuinely required.

Signals:
- taste/product direction or final acceptance;
- safety, deletion/quarantine, public/external actions;
- credentials/accounts/work-system access;
- money, pricing changes with live consequences, signing, App Store Connect, TestFlight.

Route:
- ask Matvii for the exact decision;
- do not create substitute worker churn;
- keep the blocked card blocked until the decision is recorded.

### `mechanical_repair`

Use when a concrete artifact is broken and a worker can repair it.

Signals:
- xcodebuild/compile/test/verifier/gate failure;
- missing screenshot/video/evidence file for an already-approved local proof;
- invalid schema or malformed local artifact.

Route:
- create/dispatch a repair task to the lane that owns the artifact;
- unblock/retry the original card only after the repair task exists or finishes.

### `pipeline_bug`

Use when the blocker represents a repeatable Forge failure class.

Signals:
- generated app contains forbidden template/control-plane residue;
- generated cleanup repeats across trials;
- visual/design state is invisible to Matvii before final acceptance;
- watchdog says "blocked" without exact action commands;
- a gate that should be automated requires Matvii;
- any issue whose prevention belongs in generator, substrate, verifier, watchdog, or orchestrator docs/scripts.

Route:
- create a pipeline-hardening task, usually for `forgejudge` unless a more specific lane owns the prevention;
- acceptance must name the durable guard: verifier/test/gate, generator/substrate patch, watchdog/orchestrator routing update, or doc/skill rule;
- then unblock/retry the original only after prevention has been recorded or dispatched.

### `worker_error`

Use when the worker blocked incorrectly or produced an unusable handoff.

Signals:
- block reason is only "stuck", "unclear", or "needs help";
- worker ignored available instructions;
- wrong assignee/profile, spawn/profile config issue, missing prompt fragment, Codex ceiling misuse;
- fallback classification when there is not enough evidence for a real human gate.

Route:
- reclaim/reassign/retry with corrected instructions;
- add a prompt/doc fix if the same mistake can recur.

### `dependency_shape_bug`

Use when Kanban topology/status is wrong.

Signals:
- implementation card blocks for generic review while verifier/judge child cards already exist;
- missing parent/child edge, wrong fan-in/fan-out, verifier waiting on a child it should depend on;
- review/verification ownership is encoded in the wrong card.

Route:
- fix dependency edges/status convention;
- implementation cards complete with handoff when verifier/judge children own review;
- Matvii is not needed unless the verifier/judge reaches a real human gate.

## Routing convention

For every blocked card, write a compact blocker notice with:

- What blocked?
- Why?
- Classification.
- Is Matvii needed? yes/no.
- If no: prevention/repair/routing task created or exact task to create.
- If yes: exact decision needed.
- Exact inspect command.
- Exact resume/unblock command.

Kanban shape:

1. The prevention/repair task should be a child of the blocked card or of the orchestrator/watchdog card that discovered it.
2. The child task title should start with one of:
   - `Prevent recurring blocker:` for `pipeline_bug`;
   - `Repair blocker:` for `mechanical_repair`;
   - `Fix Kanban routing for blocker:` for `dependency_shape_bug`;
   - `Retry/reassign blocked worker:` for `worker_error`.
3. The child task body must include:
   - source blocker id;
   - classification;
   - signals;
   - acceptance criteria for durable prevention.
4. Do not unblock the original card merely because it is inconvenient. Unblock only after the route is recorded, the repair/prevention child exists, or the human decision is answered.

## Local classifier probe

Run the local classifier on the observed Forge blocker classes:

```bash
node scripts/forge-vnext-blocker-classifier.mjs --probe --json
```

Expected proof points:
- generic implementation review with verifier/judge children -> `dependency_shape_bug`;
- generated app template/control-plane residue -> `pipeline_bug`;
- invisible visual state before acceptance -> `pipeline_bug`;
- watchdog blocked notice without exact commands -> `pipeline_bug`;
- repeated app-specific cleanup -> `pipeline_bug`;
- real taste/product direction gate -> `real_human_gate`;
- xcodebuild failure -> `mechanical_repair`;
- vague worker stuck block -> `worker_error`.

To classify a saved board export or hand-built blocker list:

```bash
node scripts/forge-vnext-blocker-classifier.mjs --input blockers.json --json
```

The script is intentionally local-only. It reads JSON, prints routing/prevention recommendations, and does not mutate Kanban or call external services.
