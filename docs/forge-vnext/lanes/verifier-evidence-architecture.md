# Forge vNext Lane C — Generic Verifier + Evidence Architecture

Date: 2026-05-25
Kanban: `t_48694186`
Scope: diagnosis/spec only. No second app generation. No DayRateLab polish.
Source artifacts:
- `docs/forge-vnext-charter.md`
- `docs/rfcs/2026-05-25-forge-vnext-agentic-product-studio.md`
- `docs/forge-vnext-pipeline-gap-audit.md`

## Objective

Replace the current DayRate-specific verifier with an app-agnostic verification contract. The reusable verifier must prove build/test/run/screenshot/video/audit evidence for any generated app by reading project-local `.forge` artifacts, especially `.forge/verification-plan.json`, without editing verifier source for each app domain.

## Current failure to remove

`scripts/forge-e2e-native-verify.mjs` currently mixes reusable verifier rules with DayRateLab app facts:

- direct file paths: `Features/Home/HomeView.swift`, `HomeViewModel.swift`, `Managers/DayRate/DayRateManager.swift`
- app literals: `Patterns`, `Pro`, `hasEnoughPatternData`, `DayRateManagerProtocol`, `MockDayRateManager()`
- fixed screenshots: `.forge/evidence/native-today-screen.jpg`, `.forge/evidence/native-patterns-screen.jpg`
- generic banned patterns mixed with DayRate/template-specific terms such as `budget`, `spending`, `financial`

vNext keeps the reusable mechanics but moves all app-specific assertions into generated config.

## Architecture stance

The verifier becomes a contract runner, not a DayRate judge.

```text
Generated app repo
└── .forge/
    ├── spec.json                         app model: screens/features/navigation
    ├── DESIGN.md                         design contract + screenshot criteria
    ├── gates/                            machine-readable product/design/launch gate receipts
    │   ├── activation.json
    │   ├── retention.json
    │   ├── monetization.json
    │   └── design.json
    ├── verification-plan.json            app-specific verification contract
    └── evidence/
        ├── build/build-receipt.json
        ├── test/test-receipt.json
        ├── run/run-receipt.json
        ├── screenshots/*.png
        ├── video/*.mp4
        ├── audit/audit-receipt.json
        ├── substitutions/*.json
        └── evidence-index.json

Forge repo / reusable tools
└── scripts/
    └── forge-e2e-verify.mjs              generic runner; no app-domain literals
```

The reusable verifier is allowed to know Forge pipeline concepts: generated app repo, `.xcodeproj`, scheme, Swift file scans, build/test/run receipts, screenshot slots, evidence status, substitutes, and audit verdicts.

The reusable verifier is not allowed to know app-domain names, app-specific copy, feature names, screenshots, manager names, Swift marker strings, or expected nav paths except through `.forge/verification-plan.json` and referenced gate artifacts.

## `.forge/verification-plan.json` shape

`verification-plan.json` is generated during product/design/native planning before verification begins. It is app-owned and committed/copied inside the generated app repo. It must be deterministic enough for a generic script to validate it with JSON schema before checking evidence.

### Required top-level shape

```json
{
  "schema_version": "forge.verification-plan.v1",
  "app": {
    "id": "meal-loop",
    "name": "MealLoop",
    "repo_root": ".",
    "project": "MealLoop.xcodeproj",
    "scheme": "MealLoop - Mock",
    "bundle_id": "com.local.mealloop.mock",
    "platform": "ios",
    "configuration": "Debug",
    "simulator": {
      "device": "iPhone 17 Pro",
      "os": "latest"
    }
  },
  "sources": {
    "spec": ".forge/spec.json",
    "design": ".forge/DESIGN.md",
    "gate_receipts": [
      ".forge/gates/product.json",
      ".forge/gates/activation.json",
      ".forge/gates/retention.json",
      ".forge/gates/monetization.json",
      ".forge/gates/design.json"
    ]
  },
  "policy": {
    "strictness": "proof-app",
    "allow_substitutes": true,
    "max_repair_loops_before_human": 2,
    "overclaiming_rule": "missing_required_evidence_blocks_success"
  },
  "checks": [],
  "evidence": {},
  "screenshot_slots": [],
  "video_slots": [],
  "audit": {},
  "success_criteria": {}
}
```

### `checks[]`

Checks are app-specific assertions executed by generic check types. The verifier owns the interpreter for check types, while the plan owns paths, expected markers, and rationale.

```json
{
  "checks": [
    {
      "id": "swift.architecture.viewmodel-pattern",
      "type": "swift_contains_all",
      "severity": "blocker",
      "path": "MealLoop/Features/Planner/PlannerViewModel.swift",
      "markers": ["@Observable", "private var hasLoaded", "var toast: Toast?", "LoggableEvent"],
      "rationale": "Planner screen reads/writes generated meal-plan data and must follow Forge ViewModel rules."
    },
    {
      "id": "domain.manager.mock-data",
      "type": "swift_contains_all",
      "severity": "blocker",
      "path": "MealLoop/Managers/MealPlan/MealPlanManager.swift",
      "markers": ["protocol MealPlanManagerProtocol", "final class MockMealPlanManager", "static let placeholders", "static let mockList"],
      "rationale": "The core loop needs a manager and realistic mock states."
    },
    {
      "id": "no-template-copy",
      "type": "repo_forbid_regex",
      "severity": "blocker",
      "include": ["MealLoop/**/*.swift"],
      "patterns": ["DayRate", "Forecast your day", "Your money", "Template"],
      "rationale": "Generated app must not carry DayRate/template copy."
    },
    {
      "id": "design.tokens-used",
      "type": "repo_contains_any",
      "severity": "warning",
      "include": ["MealLoop/**/*.swift"],
      "markers_from": ".forge/gates/design.json#/required_native_markers",
      "rationale": "Design gate selected app-specific native markers; verifier checks their presence without knowing the domain."
    },
    {
      "id": "spec.features-implemented",
      "type": "spec_feature_statuses",
      "severity": "blocker",
      "spec": ".forge/spec.json",
      "required_status": "done",
      "feature_ids_from": ".forge/verification-plan.json#/success_criteria/required_features",
      "rationale": "Launch-candidate claims require required features to be implemented."
    }
  ]
}
```

Allowed generic check types for v1:

| Type | Generic behavior | App-specific inputs |
|---|---|---|
| `file_exists` | Assert path exists. | `path` |
| `json_schema_valid` | Validate JSON artifact against named schema. | `path`, `schema` |
| `markdown_contains_sections` | Assert headings/sections exist. | `path`, `sections` |
| `swift_contains_all` | Read one Swift file and require markers. | `path`, `markers` |
| `swift_contains_any` | Read one Swift file and require at least one marker. | `path`, `markers` |
| `repo_contains_any` | Search included files for at least one marker or regex. | `include`, `markers`/`patterns` |
| `repo_forbid_regex` | Fail if any regex matches included files. | `include`, `patterns` |
| `spec_feature_statuses` | Check required spec feature IDs/statuses. | `spec`, `feature_ids`, `required_status` |
| `gate_assertion` | Check machine-readable gate receipt fields. | `receipt`, `json_pointer`, `expected` |
| `evidence_slot_present` | Check an evidence slot has accepted artifact or approved substitute. | `slot_id` |

The first implementation should intentionally keep this type list small. New app needs should extend the generic type list, not sneak app literals into verifier source.

## App-specific checks outside reusable verifier source

App facts live in three places only:

1. `.forge/spec.json`
   - app name, feature IDs, screen types, nav paths, manager/model requirements, feature status
2. `.forge/gates/*.json`
   - product/design/activation/retention/monetization requirements, hard minimums, required screenshots, required native proof markers, launch bar
3. `.forge/verification-plan.json`
   - concrete checks compiled from spec + gates + implementation decisions

Reusable source may contain generic defaults, such as:

```json
{
  "default_forbidden_regex": ["TODO", "AsyncImage", "@StateObject", "Font\\.system\\(size:", "Color\\(red:"],
  "required_evidence_classes": ["build", "test", "run", "screenshots", "audit"]
}
```

But any app/domain terms must come from the plan:

```json
{
  "id": "no-foreign-domain-copy",
  "type": "repo_forbid_regex",
  "include": ["**/*.swift", ".forge/**/*.md"],
  "patterns": ["DayRate", "Patterns", "Pro forecast"],
  "rationale": "These are previous-run or rejected-domain words for this app."
}
```

Acceptance rule: if a second app requires changing a regex, filename, marker, screenshot name, manager name, or copy string in `scripts/forge-e2e-verify.mjs`, the architecture failed.

## Evidence matrix

Each evidence class is represented as a slot in the plan and as an artifact receipt under `.forge/evidence/`. The verifier evaluates status, not vibes.

| Evidence class | Required for success? | Primary artifact | Receipt path | What verifier checks | Substitute allowed? |
|---|---:|---|---|---|---:|
| Build | Yes | Xcode build log | `.forge/evidence/build/build-receipt.json` | command, project/scheme, exit code 0, warnings classified, timestamp | No for native proof; failure blocks |
| Tests | Yes when test target exists; otherwise substitute required | test log/result bundle | `.forge/evidence/test/test-receipt.json` | command, exit code, test counts, compile failures absent | Yes if no test target yet, but must include compile/build + static testability audit |
| Run | Yes | simulator launch receipt | `.forge/evidence/run/run-receipt.json` | installed app launched, bundle ID, simulator, smoke duration, crash absent | Rare; only if simulator unavailable and build succeeds with documented environment failure |
| Screenshots | Yes | PNG/JPG per slot | `.forge/evidence/screenshots/{slot-id}.png` | file exists, non-empty, slot metadata maps to gate, optional vision/judge receipt | Yes per slot if state is infeasible; substitute must be stronger than prose |
| Video / flow proof | Required for core flow when feasible | MP4 or ordered screenshots with actions | `.forge/evidence/video/{slot-id}.mp4` + receipt | flow starts/ends, actions listed, artifacts exist, app did not crash | Yes: ordered screenshot sequence + UI snapshot + action log |
| Audit | Yes | human/agent audit markdown + JSON verdict | `.forge/evidence/audit/audit-receipt.json` | verdict, app score, pipeline score, blockers, evidence links | No; if audit cannot run, success claim is blocked |
| Evidence index | Yes | machine-readable index | `.forge/evidence/evidence-index.json` | every required slot is `accepted` or `substituted_approved`; no stale links | No |

### Evidence slot shape

```json
{
  "evidence": {
    "build": {
      "id": "build.mock-debug",
      "required": true,
      "command": "xcodebuild -project MealLoop.xcodeproj -scheme 'MealLoop - Mock' -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build",
      "receipt": ".forge/evidence/build/build-receipt.json",
      "acceptance": {
        "exit_code": 0,
        "app_code_warnings": "none",
        "external_warnings": "allowed_with_classification"
      }
    },
    "tests": {
      "id": "tests.mock-debug",
      "required": true,
      "command": "xcodebuild test -project MealLoop.xcodeproj -scheme 'MealLoop - Mock' -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'",
      "receipt": ".forge/evidence/test/test-receipt.json",
      "acceptance": {
        "exit_code": 0,
        "minimum_tests": 1,
        "compile_errors": 0
      }
    },
    "run": {
      "id": "run.smoke",
      "required": true,
      "receipt": ".forge/evidence/run/run-receipt.json",
      "acceptance": {
        "launched": true,
        "crashed": false,
        "minimum_seconds_alive": 10
      }
    }
  }
}
```

## Screenshot slot derivation from app gates

Screenshot slots must not be fixed names like `native-today-screen.jpg`. They are derived from gate contracts.

### Source gates

The planner/design phase must emit machine-readable gate receipts containing visual proof obligations:

```json
{
  "schema_version": "forge.gate.activation.v1",
  "gate": "activation",
  "status": "approved",
  "required_native_proof": [
    {
      "id": "activation.first-value",
      "state": "first useful result after minimum input",
      "feature_id": "planner",
      "nav_path": "launch > complete:onboarding-minimal > tap:generate-plan",
      "acceptance": [
        "first useful plan visible",
        "minimum input count <= 3",
        "no long explanatory wall before value"
      ],
      "required": true
    }
  ]
}
```

The verification planner then compiles required screenshot slots by reading these gate proof obligations.

### Derivation algorithm

1. Load `.forge/spec.json` features and navigation.
2. Load gate receipts for activation, core loop/product, retention, monetization, design, and launch if present.
3. For each approved gate, read `required_native_proof[]`.
4. Convert each proof obligation into a screenshot slot:
   - `slot_id = {gate}.{proof.id}` normalized to kebab-case
   - `feature_id` from proof obligation or matching spec feature
   - `screen_type` from spec feature
   - `nav_path` from proof obligation, falling back to spec feature `nav_path`
   - `required` inherited from proof obligation
   - `acceptance` copied from proof obligation/design blueprint
5. Deduplicate slots by `feature_id + state`; preserve every gate reference in `derived_from`.
6. Add baseline design slots from `.forge/DESIGN.md` screen blueprints only if not already covered by product gates.
7. Fail plan generation if any required slot lacks `feature_id`, `nav_path`, or acceptance criteria.

### Required slot categories

Every app must explicitly decide each category. `required: false` must include a rationale.

| Category | Gate source | Default proof rule |
|---|---|---|
| Activation / first value | activation gate | Required if app has onboarding or first-run setup; otherwise primary first screen must prove immediate value |
| Core loop | product/spec gate | Always required |
| Retention / progress / insight | retention gate | Required when repeat-use, history, progress, insights, or compounding value are part of thesis |
| Monetization / Pro boundary | monetization gate | Required when monetization is in scope; if not monetized yet, require “not monetized yet” rationale artifact |
| Design distinctiveness | design gate | Required for at least the primary surface; additional slots for signature/craft moments |
| Error/empty/loading state | UX/state gate | Required for screens that load or mutate data |

Example compiled screenshot slots:

```json
{
  "screenshot_slots": [
    {
      "id": "activation.first-value",
      "required": true,
      "derived_from": [".forge/gates/activation.json#/required_native_proof/0"],
      "feature_id": "planner",
      "screen_type": "primary_surface",
      "nav_path": "launch > complete:onboarding-minimal > tap:generate-plan",
      "artifact": ".forge/evidence/screenshots/activation.first-value.png",
      "receipt": ".forge/evidence/screenshots/activation.first-value.json",
      "acceptance": [
        "first useful plan/result is visible",
        "empty/loading state is not mistaken for success",
        "screen matches DESIGN.md Planner blueprint craft moment"
      ]
    },
    {
      "id": "retention.day7-progress",
      "required": true,
      "derived_from": [".forge/gates/retention.json#/required_native_proof/1"],
      "feature_id": "progress",
      "screen_type": "primary_surface",
      "nav_path": "tab:progress > seed:day7",
      "artifact": ".forge/evidence/screenshots/retention.day7-progress.png",
      "receipt": ".forge/evidence/screenshots/retention.day7-progress.json",
      "acceptance": ["day 7 state visible", "compounding value is shown", "no fake confident insight without enough data"]
    },
    {
      "id": "monetization.pro-boundary",
      "required": true,
      "derived_from": [".forge/gates/monetization.json#/required_native_proof/0"],
      "feature_id": "paywall",
      "screen_type": "paywall",
      "nav_path": "tab:settings > tap:upgrade",
      "artifact": ".forge/evidence/screenshots/monetization.pro-boundary.png",
      "receipt": ".forge/evidence/screenshots/monetization.pro-boundary.json",
      "acceptance": ["free value not blocked", "paid value clear", "placeholder product IDs only"]
    }
  ]
}
```

## Video / flow proof

Video is used for flows that screenshots can misrepresent: onboarding-to-first-value, create/edit/delete loops, paywall boundary, or permission flows.

```json
{
  "video_slots": [
    {
      "id": "flow.activation-to-first-value",
      "required": true,
      "derived_from": [".forge/gates/activation.json"],
      "start_state": "fresh install",
      "end_state": "first useful result visible",
      "artifact": ".forge/evidence/video/flow.activation-to-first-value.mp4",
      "fallback_artifacts": [
        ".forge/evidence/screenshots/activation.step-01.png",
        ".forge/evidence/screenshots/activation.step-02.png",
        ".forge/evidence/run/activation-action-log.json"
      ],
      "acceptance": ["no crash", "flow reaches first value", "actions match activation gate"]
    }
  ]
}
```

The verifier only checks existence/metadata for video v1. A later judge can inspect pixels. If video capture is infeasible, the fallback must include ordered screenshots plus an action log; a single screenshot is not an equivalent substitute for flow proof.

## Substitute evidence policy

Forge must never silently downgrade required evidence. Missing evidence can be accepted only through an explicit substitute record.

### Substitute record shape

```json
{
  "schema_version": "forge.evidence-substitution.v1",
  "slot_id": "video.flow.activation-to-first-value",
  "original_requirement": {
    "class": "video",
    "artifact": ".forge/evidence/video/flow.activation-to-first-value.mp4",
    "reason_required": "Activation flow cannot be proven by one static screenshot."
  },
  "status": "approved",
  "reason_infeasible": "Simulator video capture failed because xcodebuildmcp returned device recording unavailable after 4 retries; app build/run/screenshot evidence succeeded.",
  "attempts": [
    {
      "timestamp": "2026-05-25T12:00:00Z",
      "command": "xcodebuildmcp ui-automation record ...",
      "result": "failed: recording unavailable"
    }
  ],
  "substitute_artifacts": [
    ".forge/evidence/screenshots/activation.step-01.png",
    ".forge/evidence/screenshots/activation.step-02.png",
    ".forge/evidence/run/activation-action-log.json",
    ".forge/evidence/screenshots/activation.first-value.json"
  ],
  "why_substitute_is_sufficient": "The ordered screenshots and action log show the same start/end states and actions required by the activation gate; run receipt proves no crash during the flow.",
  "limits": "Does not prove animation smoothness or timing.",
  "approved_by": "verification-agent",
  "approved_at": "2026-05-25T12:05:00Z"
}
```

### Policy rules

1. Build evidence cannot be substituted for native proof. If build fails, verification fails.
2. Audit receipt cannot be substituted. If no skeptical audit runs, no success claim.
3. Run evidence can be substituted only for environment/tooling failure, not app crash.
4. Screenshot substitutes must be stronger than prose: UI snapshot, accessibility tree, generated preview image, or ordered flow screenshots.
5. Test evidence may be substituted only when no test target exists yet; substitute must include successful build plus explicit testability/static-coverage audit and an implementation task to add tests.
6. Every substitute must name limits. The final evidence index must preserve those limits so downstream audit cannot overclaim.
7. `allow_substitutes: false` in policy means any missing required slot blocks success.

## Evidence index and statuses

The final verifier output should be `.forge/evidence/evidence-index.json`:

```json
{
  "schema_version": "forge.evidence-index.v1",
  "app_id": "meal-loop",
  "generated_at": "2026-05-25T12:10:00Z",
  "verification_plan": ".forge/verification-plan.json",
  "overall_status": "pass_with_substitutions",
  "slots": [
    {
      "id": "build.mock-debug",
      "class": "build",
      "required": true,
      "status": "accepted",
      "artifact": ".forge/evidence/build/build-receipt.json"
    },
    {
      "id": "video.flow.activation-to-first-value",
      "class": "video",
      "required": true,
      "status": "substituted_approved",
      "artifact": ".forge/evidence/substitutions/video.flow.activation-to-first-value.json",
      "limits": "Does not prove animation smoothness or timing."
    }
  ],
  "blockers": [],
  "warnings": ["video substitute accepted; final audit must mention limits"]
}
```

Allowed slot statuses:

- `accepted`
- `missing`
- `failed`
- `substitution_requested`
- `substituted_approved`
- `substituted_rejected`
- `not_applicable_with_rationale`

Success mapping:

| Overall status | Meaning |
|---|---|
| `pass` | All required slots accepted with no substitutes. |
| `pass_with_substitutions` | Required slots accepted or substituted; limits must be surfaced in audit. |
| `fail` | Any required slot missing/failed/rejected. |
| `blocked_human_decision` | Evidence cannot be produced or substituted without human choice. |

## Generic verifier implementation outline

The implementation worker should replace or supersede `scripts/forge-e2e-native-verify.mjs` with a runner shaped like this:

1. Parse args:
   - `--app-path <path>`
   - optional `--plan .forge/verification-plan.json`
   - optional `--write-index`
2. Resolve app path and plan path.
3. Validate `verification-plan.json` against `forge.verification-plan.v1` schema.
4. Validate referenced source artifacts exist: spec, design, gate receipts.
5. Discover project/scheme from plan; optionally verify `.xcodeproj` exists.
6. Execute generic `checks[]` by type.
7. Evaluate evidence slots:
   - build/test/run receipts
   - screenshot slots
   - video slots
   - audit receipt
   - approved substitutes
8. Write `.forge/evidence/evidence-index.json`.
9. Exit non-zero when any blocker remains.
10. Print JSON summary with `status`, `app_path`, `plan_path`, `evidence_index`, `blockers`, `warnings`.

Pseudocode:

```js
const plan = readJson(planPath);
validateSchema("forge.verification-plan.v1", plan);
const errors = [];
const warnings = [];

for (const source of plan.sources.gate_receipts.concat([plan.sources.spec, plan.sources.design])) {
  requireExists(source, errors);
}

for (const check of plan.checks) {
  runGenericCheck(check, { appPath, plan, errors, warnings });
}

for (const slot of allEvidenceSlots(plan)) {
  evaluateSlot(slot, { appPath, plan, errors, warnings, evidenceIndex });
}

writeEvidenceIndex(evidenceIndex);
exit(errors.length === 0 ? 0 : 1);
```

## Criteria proving the second app can verify without editing verifier source

Before generating the second app, add these acceptance tests/tasks to the implementation lane:

1. Static source guard
   - Run a repo scan proving `scripts/forge-e2e-verify.mjs` contains no DayRateLab literals and no second-app literals.
   - Blocked terms include generated app name, feature names, manager names, screenshot slot IDs, and domain copy.
2. Fixture test: unrelated fake plans
   - Create at least two tiny fixture repos or fixture trees:
     - one DayRate-like plan
     - one unrelated app plan, e.g. learning/journal/meal app
   - Both use the same verifier source and different `verification-plan.json` files.
3. Negative fixture test
   - Remove one required screenshot from the unrelated app fixture.
   - Verifier must fail because the plan slot is missing, not because of app-specific code.
4. Substitute fixture test
   - Replace a video slot with an approved substitute record.
   - Verifier must return `pass_with_substitutions` and include limits in `evidence-index.json`.
5. Real second app proof
   - After vNext gates are approved, generate a second proof app in its own repo.
   - Generate `.forge/verification-plan.json` from its spec/gates.
   - Run the same verifier command without changing reusable verifier source.
   - Commit or archive evidence index showing app-specific screenshot slots and checks came from the plan.

Hard pass criterion:

```bash
git diff -- scripts/forge-e2e-verify.mjs
# Expected: no changes after adapting plan/config for the second app
```

If the second app needs verifier changes, classify them:

- generic new check type needed: allowed only with fixture tests and no app literals
- app-specific path/marker/screenshot change: architecture failure; move data into plan
- product/design judgment issue: verifier should link audit/gate receipt, not encode subjective app rules in source

## Suggested implementation tasks

### Task 1: Add schema docs and fixtures

Files:
- Create `schemas/forge.verification-plan.v1.schema.json`
- Create `schemas/forge.evidence-index.v1.schema.json`
- Create `tests/fixtures/verification/dayrate-like/.forge/verification-plan.json`
- Create `tests/fixtures/verification/unrelated-app/.forge/verification-plan.json`

Acceptance:
- JSON schemas validate the examples in this document.
- Fixture plans contain different app names, features, screenshot slots, and Swift markers.

### Task 2: Introduce generic verifier runner

Files:
- Create `scripts/forge-e2e-verify.mjs`
- Keep `scripts/forge-e2e-native-verify.mjs` temporarily as legacy or wrapper.

Acceptance:
- Runner accepts `--app-path` and reads `.forge/verification-plan.json` by default.
- Runner executes only generic check types.
- No DayRate/domain literals in source.

### Task 3: Add evidence index writer

Files:
- Modify `scripts/forge-e2e-verify.mjs`
- Add fixture expected output under `tests/fixtures/verification/**/expected-evidence-index.json`

Acceptance:
- Pass, fail, and pass-with-substitutions statuses are deterministic.
- Missing required evidence returns non-zero.

### Task 4: Compile screenshot slots from gates

Files:
- Create or modify planner/generator logic that emits `.forge/verification-plan.json`.

Acceptance:
- Screenshot slots derive from gate `required_native_proof[]`.
- Plan generation fails if a required slot lacks `nav_path` or acceptance criteria.

### Task 5: Prove second-app readiness before generation

Files:
- Add tests for two fixture app plans using one verifier source.

Acceptance:
- Same verifier command passes/fails according to each plan.
- Changing fixture app-specific markers requires editing only fixture plan files, not verifier source.

## Open risks

1. Gate JSON contracts do not exist yet. This architecture assumes `.forge/gates/*.json`; implementation may need a lane A schema before screenshot derivation can be automated.
2. Visual quality still needs a judge. The generic verifier can prove screenshot files and receipts exist, but cannot by itself prove taste or design quality unless connected to a screenshot judge/audit receipt.
3. UI automation `nav_path` grammar must be standardized. Without a stable grammar, screenshot slots may be valid on paper but hard to capture automatically.
4. Test targets may not exist in early generated apps. The substitute policy avoids overclaiming but risks normalizing test absence unless follow-up tasks make tests mandatory.
5. Schema complexity can grow quickly. v1 should keep generic check types small and force app-specific requirements into config.

## Key decisions

- `.forge/verification-plan.json` is the single app-specific verifier contract.
- Reusable verifier source may contain generic check interpreters only; app/domain literals are forbidden.
- Screenshot slots are derived from app gate proof obligations, not hardcoded names.
- Missing required evidence blocks success unless an explicit substitute record is approved and indexed.
- Final proof is `evidence-index.json` plus audit receipt, not console output alone.

## Suggested next Kanban task

Title: `Implement generic Forge verifier schema + fixture runner`

Assignee: implementation/coding profile

Body:
- Add JSON schemas for `.forge/verification-plan.json` and `.forge/evidence/evidence-index.json`.
- Add two fixture app trees with different verification plans.
- Implement `scripts/forge-e2e-verify.mjs` as a generic runner for v1 check types.
- Add tests proving fixture app-specific changes require only plan edits, not verifier source edits.
- Do not generate the second app yet.
