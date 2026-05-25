# Forge vNext Watchdog Blocker Brief

Status: active brief for watchdog/orchestrator checks of blocked Forge cards.

The watchdog must not report only "blocked". A blocked card is an input to the failure-improvement loop.

## Required blocker sweep

When blocked cards exist:

1. Inspect the card, comments, parent handoffs, and children.
2. Classify it using `docs/forge-vnext/blocker-taxonomy-and-routing.md`.
3. If the card is not `real_human_gate`, create or name the prevention/repair/routing task before asking Matvii.
4. Emit a compact notice with exact commands.

## Exact local commands for human/operator shells

Inspect one card:

```bash
hermes kanban show <task-id>
```

Inspect a saved JSON blocker sample with the local classifier:

```bash
node scripts/forge-vnext-blocker-classifier.mjs --input blockers.json --json
```

Run the built-in Forge blocker probe:

```bash
node scripts/forge-vnext-blocker-classifier.mjs --probe --json
```

Unblock only after the route is recorded or the human decision is answered:

```bash
hermes kanban unblock <task-id>
```

Create the prevention task from the classifier output:

```bash
hermes kanban create "Prevent recurring blocker: <short blocker title>" --assignee forgejudge --parent <blocked-task-id>
```

Use a more specific assignee when the route is mechanical and lane-owned, for example `forgeverifier` for verifier/evidence repairs or `forgedesign` for design packet repairs.

## Worker-tool equivalent

Inside a Hermes worker, use tools instead of shelling out:

- `kanban_show(task_id="<task-id>")` to inspect;
- `kanban_comment(...)` to record the blocker notice and classifier result;
- `kanban_create(..., parents=["<blocked-task-id>"])` to create repair/prevention/routing work;
- `kanban_block(reason="real-human-gate: ...")` only for real human gates;
- `kanban_complete(...)` only when the watchdog task itself has recorded or dispatched the route.

## Notice template

```text
What blocked: <task title/id>
Why: <one concrete sentence>
Classification: <real_human_gate|mechanical_repair|pipeline_bug|worker_error|dependency_shape_bug>
Matvii needed: <yes/no>
Task launched: <task id/title or n/a>
Decision needed: <exact Matvii decision or n/a>
Inspect: hermes kanban show <task-id>
Resume: hermes kanban unblock <task-id>
```

If the notice cannot name a classification and a route, the watchdog has not finished its job.
