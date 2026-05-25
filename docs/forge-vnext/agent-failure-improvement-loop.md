# Forge vNext Agent Failure → Pipeline Improvement Loop

Status: required operating rule for long-running Forge work.

## Rule

When an agent gets stuck, blocks for a silly reason, repeats cleanup, or requires Matvii for a gate that should be automated, treat it as a pipeline bug.

Do not only unblock and continue. Capture the failure mode and add a durable prevention mechanism.

## Failure classes observed

1. Implementation worker blocks for generic human review while verifier/judge children already exist.
   - Prevention: implementation cards should complete with handoff; verifier/judge cards own review.
   - Human gets involved only after judge or at real taste/safety gates.

2. Generated app contains forbidden template residue.
   - Prevention: generator sanitizer, module-plan, absence gates, proof-app verifier checks.

3. Visual/design state is invisible to Matvii.
   - Prevention: every native proof produces screenshot/visual packet before final acceptance.

4. Watchdog says blocked without action points.
   - Prevention: watchdog brief includes exact inspect/unblock/dispatch/log commands.

5. App-specific cleanup repeats across trials.
   - Prevention: convert trial cleanup into Forge substrate/generator/verifier patches.

## Required response to any new blocker

For every new blocked card, the orchestrator/watchdog should classify using `docs/forge-vnext/blocker-taxonomy-and-routing.md`:

- `real_human_gate`: needs Matvii because of taste, safety, deletion, external/account/money/signing/App Store/TestFlight/work-system, or final acceptance.
- `mechanical_repair`: create/dispatch repair task.
- `pipeline_bug`: create/dispatch pipeline-hardening task so it does not repeat.
- `worker_error`: reclaim/reassign/retry with corrected instructions.
- `dependency_shape_bug`: fix Kanban dependencies, do not ask Matvii.

Local probe proving the observed Forge blockers route through the taxonomy:

```bash
node scripts/forge-vnext-blocker-classifier.mjs --probe --json
```

Watchdog/operator brief with exact commands: `docs/forge-vnext/watchdog-blocker-brief.md`.

## Output format for blocker notices

- What blocked?
- Why?
- Is Matvii needed? yes/no.
- If no: what task was launched to fix/prevent it?
- If yes: exact decision needed.
- Exact command to inspect/resume.

## Definition of improvement

A blocker is not resolved until at least one is true:

- verifier/test/gate prevents the same failure class;
- generator/substrate changed so the bad state is not produced;
- watchdog/orchestrator routing changed so the same stuck pattern is auto-handled;
- documentation/skill updated with the new rule.
