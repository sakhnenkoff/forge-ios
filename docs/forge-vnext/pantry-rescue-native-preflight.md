# Pantry Rescue Queue native preflight

Generated: 2026-05-25 20:54:34 CEST
Task: `t_04353ae0`
Scope: local-only preflight. No generated app repo was created. No public/external/money/credentials/work-system/App Store/TestFlight/signing/account actions were performed.

## Verdict

Status: PASS for local preflight / generation can be queued after the remaining product/design/native gate says it is allowed.

Reason: the repo has a documented separate-app copy/rename path, local Xcode simulator tooling is available when `DEVELOPER_DIR` points at the installed full Xcode, and the proposed Pantry Rescue Queue path/name is isolated from this Forge control-plane repo and from DayRateLab.

Important boundary: `docs/forge-vnext/second-proof-app-direction-gate.md` still records `native_generation_allowed: false` for that gate. This preflight only proves the machine/repo path is ready; it is not itself approval to generate native Swift.

## 1. Current branch and status

Command run:

```bash
git status --short --branch
git branch --show-current
git rev-parse --show-toplevel
```

Observed:

```text
## forge-e2e-pipeline-great-apps-clean...origin/main [ahead 5]
branch: forge-e2e-pipeline-great-apps-clean
root: /Users/matvii/Developer/Personal/forge-e2e-clean
```

Dirty paths before this artifact: none shown by the initial `git status --short --branch`.

Dirty paths introduced by this task: `docs/forge-vnext/pantry-rescue-native-preflight.md`.

Current post-write status also shows `docs/forge-vnext/pantry-rescue-native-proof-spec.md` and `docs/forge-vnext/pantry-rescue-native-proof-spec.json` as untracked. Those files are separate artifacts for Kanban task `t_a048159e` and were not created or edited by this preflight task.

## 2. Local iOS/Xcode tooling preflight

Observed tooling:

```text
xcode-select -p -> /Library/Developer/CommandLineTools
installed full Xcode -> /Applications/Xcode-26.5.0.app
bare xcodebuild -> fails because active developer directory is CommandLineTools
bare xcrun simctl -> fails because simctl is not available under CommandLineTools
xcodebuildmcp -> /Users/matvii/.nvm/versions/node/v22.22.3/bin/xcodebuildmcp
xcodebuildmcp version -> 2.1.0
DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcodebuild -version -> Xcode 26.5 / Build version 17F42
available simulator -> iPhone 17 Pro on iOS 26.5, UDID D7D2DE96-156E-4AD0-B19C-7FF8149A7031
```

Required environment for later build/run/screenshot proof:

```bash
export DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer
```

Do not change global `xcode-select` from a worker. Prefix or export `DEVELOPER_DIR` for every XcodeBuildMCP, `xcodebuild`, or `xcrun` simulator command.

## 3. Safe separate generated-app repo path/name

Proposed app identity:

```text
Swift/project name: PantryRescueQueue
Display name: Pantry Rescue Queue
Bundle identifier for local proof candidate: com.matvii.pantryrescuequeue
Generated app path: /Users/matvii/Developer/Personal/PantryRescueQueue
```

Why this path:

- It is under Matvii's local `/Users/matvii/Developer/Personal` area.
- It is a sibling of the Forge control-plane/template repo, not inside `/Users/matvii/Developer/Personal/forge-e2e-clean`.
- It matches `scripts/new-app.sh` behavior when given a destination directory or when defaulting to the template parent.
- It avoids `DayRateLab`, previous-proof names, money/budget/day-rating terminology, and generic fixture names.

Existence check:

```text
available: /Users/matvii/Developer/Personal/PantryRescueQueue
available: /Users/matvii/Developer/Personal/pantry-rescue-queue
available: /Users/matvii/Developer/Personal/ForgeProofs/PantryRescueQueue
```

Recommended path to use first: `/Users/matvii/Developer/Personal/PantryRescueQueue`.

No directory was created during this preflight.

## 4. Existing Forge generation and verification commands

### Template copy / separate repo creation

Documented generator script:

```bash
./scripts/new-app.sh NewAppName [destination_dir] [bundle_id] [display_name]
```

Relevant implementation facts:

- `scripts/new-app.sh` copies the template with `rsync` and excludes `.git`, `.swiftpm`, `DerivedData`, `build`, `xcuserdata`, and `*.xcuserstate`.
- It then runs `./rename_project.sh` inside the copied target only.
- It fails if the target directory already exists.
- `rename_project.sh` requires a Swift-safe project name: must start with a letter and contain only letters, numbers, and underscores.

Safe generation command candidate, not run:

```bash
cd /Users/matvii/Developer/Personal/forge-e2e-clean
./scripts/new-app.sh PantryRescueQueue /Users/matvii/Developer/Personal com.matvii.pantryrescuequeue "Pantry Rescue Queue"
```

This should create `/Users/matvii/Developer/Personal/PantryRescueQueue` if it still does not exist.

Local `skills/forge-app/SKILL.md` also documents this convention for template repos: use `new-app.sh`, then verify the new project exists, then do all subsequent work in the new project so the template/control-plane repo is untouched.

### Foundation artifact bridge

Existing script:

```bash
node scripts/forge-e2e-foundation.mjs --idea <idea.json> --app-path <generated-app-path> [--clean] [--generated-at <iso>]
```

Scope from script help/source: writes Forge E2E foundation artifacts into `<generated-app-path>/.forge`; creates planning/product/design artifacts only; does not edit Swift files.

Candidate after app repo creation and after a Pantry Rescue idea JSON exists:

```bash
cd /Users/matvii/Developer/Personal/forge-e2e-clean
node scripts/forge-e2e-foundation.mjs \
  --idea /path/to/pantry-rescue-queue.idea.json \
  --app-path /Users/matvii/Developer/Personal/PantryRescueQueue
```

Caution: existing `forge-e2e-foundation.mjs` contains DayRate-oriented domain inference branches and old monetization defaults. Do not treat its generated foundation text as sufficient for Pantry Rescue without review/repair; the newer generic vNext verification path is safer for app-specific evidence.

### Generic vNext verification

Existing generic verifier:

```bash
node scripts/forge-vnext-verifier.mjs --app-path <app-or-fixture-path> [--plan .forge/verification-plan.json] [--write-index]
```

Scope from script help/source: runs the generic Forge vNext verification/evidence contract. App-specific paths, markers, screenshots, and substitutions must live in the app-local `.forge` plan and evidence index.

Candidate after generated app has app-local `.forge/verification-plan.json` and evidence index:

```bash
cd /Users/matvii/Developer/Personal/forge-e2e-clean
node scripts/forge-vnext-verifier.mjs --app-path /Users/matvii/Developer/Personal/PantryRescueQueue
```

### Legacy/native proof verifier

Existing script:

```bash
node scripts/forge-e2e-native-verify.mjs --app-path <generated-app-path>
```

Scope from script help/source: verifies reusable Forge P6/P7 native proof expectations for a generated iOS app.

Caution: this verifier is not yet app-agnostic enough for Pantry Rescue. Its source still expects old `DayRateManager`/`DayRateManagerProtocol` markers and fixed screenshot names (`native-today-screen.jpg`, `native-patterns-screen.jpg`). It should not be used as the acceptance gate for Pantry Rescue until repaired or superseded by `forge-vnext-verifier.mjs` with Pantry-specific plan data.

### Build/run/screenshot proof via XcodeBuildMCP

Installed XcodeBuildMCP command names verified from `xcodebuildmcp --help` on this machine:

```bash
export DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer
cd /Users/matvii/Developer/Personal/PantryRescueQueue

xcodebuildmcp simulator discover-projects --workspace-root .
xcodebuildmcp simulator list-schemes --project-path ./PantryRescueQueue.xcodeproj
xcodebuildmcp simulator build-and-run \
  --scheme "Pantry Rescue Queue - Mock" \
  --project-path ./PantryRescueQueue.xcodeproj \
  --simulator-name "iPhone 17 Pro" \
  --use-latest-os
xcodebuildmcp simulator snapshot-ui --simulator-id D7D2DE96-156E-4AD0-B19C-7FF8149A7031
xcodebuildmcp simulator screenshot --simulator-id D7D2DE96-156E-4AD0-B19C-7FF8149A7031 --return-format path
```

Possible scheme-name caveat: `rename_project.sh` updates occurrences of `Forge` to `PantryRescueQueue`, but display-name update may make bundle display names human-readable. If `list-schemes` shows `PantryRescueQueue - Mock` instead of `Pantry Rescue Queue - Mock`, use the exact listed mock scheme. The build must use a Mock scheme and the launched bundle must be the mock bundle.

Alternative XcodeBuildMCP scaffolding command exists but is not the preferred Forge path because it bypasses the Forge template/skills:

```bash
xcodebuildmcp project-scaffolding scaffold-ios \
  --project-name PantryRescueQueue \
  --output-path /Users/matvii/Developer/Personal \
  --bundle-identifier com.matvii.pantryrescuequeue \
  --display-name "Pantry Rescue Queue"
```

Use this only if the Forge template copy path is explicitly rejected.

## 5. DayRateLab / failed-proof isolation check

Planned Pantry Rescue names/paths/fixtures in this preflight:

```text
PantryRescueQueue
Pantry Rescue Queue
pantry-rescue-queue
com.matvii.pantryrescuequeue
/Users/matvii/Developer/Personal/PantryRescueQueue
```

None contain `DayRateLab`, `DayRate`, prior proof naming, finance/budget terms, or day-rating concepts.

Guardrail findings:

- The current charter states DayRateLab is only a negative failure example and must not influence product direction, design language, architecture, app naming, fixtures, screenshots, launch copy, or verifier assumptions.
- The repaired direction gate repeats that no DayRateLab or prior proof app may be used as product/design/naming/market/fixture/screenshot/implementation/verifier inspiration.
- `scripts/forge-vnext-verifier.mjs` is generic and its tests include a source-free-of-DayRateLab assertion.
- `scripts/forge-e2e-native-verify.mjs` still contains old DayRate-specific checks, so Pantry Rescue should avoid using it as a source of acceptance criteria.

## 6. Preflight result matrix

| Check | Status | Finding |
|---|---|---|
| Branch/status | PASS | On `forge-e2e-pipeline-great-apps-clean`, ahead 5, no pre-existing dirty paths. |
| Full Xcode | PASS with env requirement | Full Xcode exists at `/Applications/Xcode-26.5.0.app`; bare global tools fail under CommandLineTools. |
| Simulator availability | PASS with env requirement | iPhone 17 Pro on iOS 26.5 is available when `DEVELOPER_DIR` is set. |
| XcodeBuildMCP | PASS | `xcodebuildmcp` 2.1.0 installed; simulator build/run/screenshot commands discoverable. |
| Separate repo isolation | PASS | `/Users/matvii/Developer/Personal/PantryRescueQueue` is available and outside Forge control-plane repo. |
| Forge generation path | PASS | `scripts/new-app.sh` safely copies template then renames copy; local `skills/forge-app` documents this convention. |
| Generic verifier path | PASS | `scripts/forge-vnext-verifier.mjs` is app-plan driven and suitable for Pantry-specific verification once plan/evidence exists. |
| Legacy native verifier | FAIL for Pantry acceptance | `scripts/forge-e2e-native-verify.mjs` still has DayRate-specific expectations; do not use as Pantry gate without repair. |
| DayRateLab isolation | PASS | Proposed path/name/commands do not use DayRateLab or prior failed proof as inspiration. |

## 7. Next safe queue candidates

Only queue these after the relevant judge/human/product gate allows native generation.

1. Create separate local app repo from the Forge template:

```bash
cd /Users/matvii/Developer/Personal/forge-e2e-clean
./scripts/new-app.sh PantryRescueQueue /Users/matvii/Developer/Personal com.matvii.pantryrescuequeue "Pantry Rescue Queue"
```

2. Verify creation and discover project/schemes:

```bash
export DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer
cd /Users/matvii/Developer/Personal/PantryRescueQueue
xcodebuildmcp simulator discover-projects --workspace-root .
xcodebuildmcp simulator list-schemes --project-path ./PantryRescueQueue.xcodeproj
```

3. Build/run with the exact mock scheme returned by `list-schemes`:

```bash
export DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer
cd /Users/matvii/Developer/Personal/PantryRescueQueue
xcodebuildmcp simulator build-and-run \
  --scheme "<exact Mock scheme from list-schemes>" \
  --project-path ./PantryRescueQueue.xcodeproj \
  --simulator-name "iPhone 17 Pro" \
  --use-latest-os
```

4. Capture native proof evidence after launch:

```bash
xcodebuildmcp simulator snapshot-ui --simulator-id D7D2DE96-156E-4AD0-B19C-7FF8149A7031
xcodebuildmcp simulator screenshot --simulator-id D7D2DE96-156E-4AD0-B19C-7FF8149A7031 --return-format path
```

5. Run the generic app-local verification plan once Pantry-specific `.forge/verification-plan.json` and `.forge/evidence/evidence-index.json` exist:

```bash
cd /Users/matvii/Developer/Personal/forge-e2e-clean
node scripts/forge-vnext-verifier.mjs --app-path /Users/matvii/Developer/Personal/PantryRescueQueue
```
