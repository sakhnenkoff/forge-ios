# Forge screenshot sequence verifier contract

Generated: 2026-05-26
Task: `t_584a6091`
Scope: verifier-layer contract only. No native app generation, account actions, paid actions, or external mutations.

## Purpose

The screenshot sequence verifier is an integrity gate before post-native visual judgment and human review. It proves that the generated app has current evidence for the required product states. It does not decide whether the UI has taste, and it must not reduce visual quality to pixel-diff pass/fail.

Taste remains the job of the visual judge rubric in `docs/forge-vnext/visual-excellence-research-and-judge-layer.md`. This verifier only answers: are the right screenshots, accessibility snapshots, and evidence-index records present, current, and connected to the verification plan?

## Required states

A post-native visual evidence packet must cover all five states:

1. `activation` — the first useful value / first screen that proves the product promise.
2. `core-loop-after-action` — the core action after the user has taken it, showing changed state.
3. `returning-progress` — a returning or progress state that proves repeat-use continuity.
4. `empty-error` — empty and/or recoverable error state, with useful copy and no dead shell.
5. `money-boundary` — a deferred upgrade/export/money boundary after free value; no paid action or account setup required.

## Verification-plan contract

Add a check to `.forge/verification-plan.json`:

```json
{
  "id": "visual-sequence-required",
  "type": "visual_evidence_sequence",
  "severity": "blocker",
  "states": [
    "activation",
    "core-loop-after-action",
    "returning-progress",
    "empty-error",
    "money-boundary"
  ],
  "rationale": "Post-native visual review needs current screenshots plus accessibility snapshots for every required loop state; pixel diffs alone are not a taste judge."
}
```

For each state, define one screenshot slot and one accessibility snapshot slot. The canonical slot IDs are:

```text
visual.screenshot.<state>
visual.accessibility.<state>
```

Example:

```json
{
  "screenshot_slots": [
    {
      "id": "visual.screenshot.activation",
      "class": "screenshot",
      "required": true,
      "artifact": ".forge/evidence/screenshots/native/activation.png",
      "visual_state": "activation",
      "accessibility_snapshot_slot": "visual.accessibility.activation"
    }
  ],
  "evidence_slots": [
    {
      "id": "visual.accessibility.activation",
      "class": "accessibility_snapshot",
      "required": true,
      "artifact": ".forge/evidence/screenshots/native/accessibility-snapshots/activation.json",
      "visual_state": "activation"
    }
  ]
}
```

## Evidence-index contract

Every required visual screenshot and accessibility snapshot must have an accepted evidence-index entry:

```json
{
  "id": "visual.screenshot.activation",
  "class": "screenshot",
  "required": true,
  "status": "accepted",
  "artifact": ".forge/evidence/screenshots/native/activation.png",
  "artifact_sha256": "<sha256 of the current screenshot file>"
}
```

Accessibility snapshot entries use `class: "accessibility_snapshot"` and must also include `artifact_sha256`.

The verifier rejects:

- missing plan slots;
- missing evidence-index entries;
- non-`accepted` visual entries;
- artifact path mismatches between plan and index;
- missing screenshot/accessibility files;
- missing or malformed `artifact_sha256`;
- stale screenshots or snapshots whose current SHA-256 no longer matches the index;
- invalid accessibility JSON;
- accessibility snapshots whose `state` does not match the required visual state;
- accessibility snapshots with no visible elements.

## Accessibility snapshot minimum

The current minimum JSON shape is intentionally simple so it can be produced by simulator tooling or a browser/native bridge:

```json
{
  "schema_version": "forge.accessibility-snapshot.v1",
  "state": "activation",
  "elements": [
    { "label": "Milo's Morning Relay" },
    { "label": "Mark care done" }
  ]
}
```

Future versions can add frame data, traits, hierarchy, or source tool metadata without changing the core gate.

## Pixel-diff boundary

Pixel/snapshot diffs are allowed as regression evidence after a design has been approved, but they are advisory only. They can say "this screenshot changed" or "this no longer matches the approved baseline." They cannot say "this app has taste."

The verifier therefore does not accept a pixel-diff result as a substitute for the five screenshots and five accessibility snapshots. Visual taste must be judged by the separate visual judge output, reference comparison, and repair rubric.

## Implemented verifier behavior

`scripts/forge-vnext-verifier.mjs` now supports the `visual_evidence_sequence` check type. The focused test in `tests/forge-vnext-verifier.test.mjs` proves that the verifier:

- accepts a complete five-state visual sequence with current screenshot/accessibility hashes;
- rejects stale screenshots after artifact mutation;
- rejects missing accessibility snapshots;
- reports `visual_evidence_sequence_policy` as an integrity-only policy, not a pixel taste judgment.
