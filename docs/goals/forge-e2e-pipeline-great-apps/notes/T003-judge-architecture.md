# T003 Judge Receipt: Pipeline Architecture And First Worker Scope

Date: 2026-05-24
Task: T003 judge
Mode: read-only decision based on T001/T002 receipts and current repo state

## Inputs Reviewed

- `docs/goals/forge-e2e-pipeline-great-apps/notes/T001-fresh-scout.md`
- `docs/goals/forge-e2e-pipeline-great-apps/notes/T002-external-product-scout.md`
- Current Forge git status: `main...origin/main [ahead 4]` with untracked goal/board and unrelated local files.
- Current marketplace git status: local `main...origin/main [behind 22]` after fetching remote v5.

## Decision

Proceed with a pipeline-first local bridge that aligns with remote marketplace v5, but do not update the marketplace repo in this goal slice.

The target source of truth for this proof run is:

1. Remote `forge-marketplace` v5 phase architecture as the north star.
2. Local Forge repo docs/scripts as the executable bridge for this goal.
3. Generated app `.forge/` artifacts as proof that the pipeline stages are exercised outside the template.

This is not a license to hand-build DayRate Lab. Every proof artifact and app change must either be produced by the reusable bridge or record how it maps back to a reusable Forge phase.

## Marketplace v5 Reconciliation

Remote marketplace v5 is understood and accepted as the better architecture:

- thin `forge-app` launcher;
- app-agnostic project detection;
- P0-P7 staged phases;
- project-local skills/artifacts;
- no direct Swift writes by orchestrator;
- generated app work happens after scaffold;
- xcodebuildmcp/simulator evidence is part of the loop.

Do not merge or edit `/Users/matvii/Developer/Personal/forge-marketplace` now. It is 22 commits behind remote and would distract from the proof. For this goal, reconciliation means the Forge repo bridge and receipts must explicitly align with v5 phases and explain what is deferred.

Deferred marketplace work:

- syncing local marketplace to remote v5;
- porting any bridge script into the marketplace plugin;
- cleaning version naming mismatch (`version: 3.0.0` vs README v5);
- resolving NotebookLM as a hard dependency.

## Benchmark App Decision

Use DayRate Lab.

Rationale:

- It is small enough for a vertical proof.
- It has a strong first-session activation moment: first prediction.
- It has a daily loop: morning prediction -> evening rating.
- It has retention mechanics: Day Twins, Micro-Patterns, Time Capsules.
- It has monetization surfaces: deeper history, exports, reminders, pattern reports, Pro insights.
- It has a clear design challenge: dark, minimal, data-color, not generic mood-grid cards.
- It has prior failure evidence that can become reusable Forge guardrails.

Do not use `/Users/matvii/Developer/Personal/Apps/DayRate` as an implementation target. It remains research evidence only.

## Repo And Cleanup Policy

Approved for now:

- Keep local Forge `main` at old proof head.
- Keep `forge-complete-proof-archive` untouched.
- Do not reset, revert, delete, or rewrite old commits.
- Do not push.
- Do not mutate `Forge/Features/**` with DayRate proof content.
- Use `/Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab` for the proof app.
- Treat current untracked unrelated files as excluded unless a later Judge explicitly includes them.

Required later:

- Pre-commit audit must decide which Forge repo changes are related.
- Final audit must explicitly address template preservation and old proof contamination.

## Architecture Decision For First Worker

The first Worker should create a reusable foundation/gate bridge and exercise it on the generated DayRateLab app. This is larger than docs-only but still safe because it avoids native screens and template mutation.

The Worker should produce:

1. A reusable Forge E2E gate contract in the Forge repo.
2. A no-credential local foundation generator script or equivalent reusable instruction artifact.
3. DayRateLab `.forge/` artifacts written into the generated app by exercising that bridge.
4. Evidence receipts proving the generated app path and Xcode project/scheme discovery.

This advances both sides of the goal:

- reusable Forge pipeline capability;
- proof app foundation outside the template.

Native SwiftUI screen implementation remains out of scope for this Worker.

## T004 Worker Scope

Objective:

Implement the reusable planning/product/quality gate foundation selected by this Judge and exercise it against `/Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab`. Create the generated app `.forge` foundation artifacts, but do not implement native DayRate SwiftUI screens yet.

Allowed files:

- `/Users/matvii/Developer/Personal/forge/docs/forge-e2e-pipeline-gates.md`
- `/Users/matvii/Developer/Personal/forge/scripts/forge-e2e-foundation.mjs`
- `/Users/matvii/Developer/Personal/forge/docs/goals/forge-e2e-pipeline-great-apps/notes/T004-worker-pipeline-foundation.md`
- `/Users/matvii/Developer/Personal/forge/docs/goals/forge-e2e-pipeline-great-apps/state.yaml`
- `/Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab/.forge/**`

Required generated app artifacts:

- `.forge/spec.json`
- `.forge/product-thesis.md`
- `.forge/competitive-notes.md`
- `.forge/activation-onboarding.md`
- `.forge/retention-loop.md`
- `.forge/monetization.md`
- `.forge/user-journeys.md`
- `.forge/DESIGN.md`
- `.forge/progress.md`
- `.forge/evidence/`

The bridge must record that:

- the generated app path is outside the template;
- native implementation is pending;
- remote marketplace v5 is the aligned architecture;
- old template-mutating proof is archived evidence only;
- DayRateLab artifacts are generated foundation artifacts, not final app proof.

Verification commands:

```bash
ruby -e 'require "yaml"; YAML.load_file("docs/goals/forge-e2e-pipeline-great-apps/state.yaml"); puts "YAML_OK"'
node --check scripts/forge-e2e-foundation.mjs
node scripts/forge-e2e-foundation.mjs --idea docs/forge-v4/sample-ideas/dayrate-lab.json --app-path /Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab --clean
test -f /Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab/.forge/spec.json
test -f /Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab/.forge/DESIGN.md
test -f /Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab/.forge/evidence/foundation-receipt.json
rg -n "DayRate Lab|prediction|rating|Micro-Pattern|dayratelab.pro" /Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab/.forge
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcodebuild -project /Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab/DayRateLab.xcodeproj -list
```

Build is allowed but optional in T004. If used:

```bash
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcodebuild -project /Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab/DayRateLab.xcodeproj -scheme "DayRateLab - Mock" -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build
```

Stop if:

- the generated app path contains unrelated user work beyond template scaffold and empty/generated `.forge`;
- the script would hardcode DayRate into `Forge/Features/**` or any template app file;
- the bridge cannot be reused for a second idea without rewriting the script;
- implementation needs marketplace repo writes;
- implementation needs destructive cleanup/reset/revert;
- commands would push, publish, deploy, use production credentials, or spend money.

## Judge Verdict

T003 complete. Activate T004.
