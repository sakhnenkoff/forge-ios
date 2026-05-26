# Forge vNext Pipeline Readiness Red Team

Date: 2026-05-26
Scope: pipeline readiness only. App idea quality is intentionally out of scope.

## Verdict

Forge vNext is **not ready** to generate the next proof app as evidence of factory quality.

The current state is useful and much better than the previous pipeline, but it is still mostly **contract/fixture-ready**, not **generation-ready**. Passing tests prove that several validators and fixture failures work; they do not yet prove that a freshly generated native app can build, run, capture real evidence, pass the visual/taste gates, and produce a launch/learning package without false positives.

## Key evidence

- Local tests pass: `32/32` via `node --test tests/*.test.mjs`.
- Final dry run reports `ready_for_human_decision`, but explicitly says no second app was generated and lists unresolved evidence gaps.
- A freshly generated temp app can self-verify with empty `checks` and empty `evidence_slots`, producing a false-positive verifier pass.
- Current machine Xcode tooling is incomplete for native proof:
  - `xcodebuild` points to CommandLineTools, not full Xcode.
  - `simctl` is unavailable.

## Blocking findings

### 1. Final audit is fixture-ready, not generation-ready

The final audit validates the fixture matrix. It does not generate a new app, build it, run it, capture screenshots, or run a full post-native visual proof.

**Required repair:** introduce a single generation smoke command that runs:

1. `new-app.sh`
2. generic verifier
3. native build check
4. simulator/screenshot/accessibility capture when Xcode is available
5. post-native visual judge
6. launch/learning package
7. final audit receipt with generated app path and evidence hashes

### 2. Generated apps can pass verifier with zero real evidence

`new-app.sh` currently emits a `.forge/verification-plan.json` with empty `checks` and empty `evidence_slots`. The generic verifier accepts that.

**Required repair:** generated proof apps must start as `not_ready` until they define required evidence slots for at least activation, core loop, returning/progress, empty/error, and money boundary or an approved deferral.

### 3. Visual judge is not fully wired into the final audit fan-in

Visual judge schema and fixtures exist, but the final audit happy path does not require integrated pre/post-native visual judge artifacts.

**Required repair:** final audit must fail unless:

- pre-native visual judge passes before native generation;
- post-native visual judge passes before human review;
- visual judge artifacts are linked from the evidence index.

### 4. Screenshot sequence contract is stronger than executable enforcement

Docs require five native states, screenshots, accessibility snapshots, and hashes. The default pass fixture does not enforce that full sequence in the happy path.

**Required repair:** make visual sequence evidence mandatory in the default final audit path, not only in isolated tests.

### 5. Minimal pass fixture has cross-artifact contradictions

The app spec and design fixture disagree about app identity/product surface. The design validator does not read the app spec, so it misses product/design mismatch.

**Required repair:** design gate validation must cross-check spec identity, target user/problem, core workflow, and required states.

### 6. Launch evidence is disconnected from verifier evidence

Launch validation can read a separate claims-shaped evidence file instead of the verifier's accepted evidence index. This risks launch paperwork passing from parallel evidence rather than the source of truth.

**Required repair:** launch validation must consume the same accepted evidence index used by the verifier, or explicitly map from it with hash-backed links.

### 7. Native proof cannot currently run on this machine

The active developer directory is CommandLineTools and `simctl` is not available.

**Required repair:** either configure full Xcode locally before native proof, or make the pipeline report `native_tooling_unavailable` and stop before claiming generation readiness.

## Revised decision framing

The next choice is not primarily app idea accept/repair/reject.

The correct next gate is:

- **Repair pipeline first**: fix the false-positive paths above before any new proof app.
- **Then choose app direction**: once the pipeline can honestly fail/verify a generated app.

## Next repair sequence

1. Add `scripts/forge-vnext-generation-smoke.mjs` or equivalent local command.
2. Make generated app verification plans fail closed by default.
3. Wire visual judge + five-state screenshot sequence into final audit.
4. Add product/design cross-artifact consistency checks.
5. Unify launch evidence with verifier evidence index.
6. Add environment preflight for Xcode/simctl and surface it in final audit.
7. Only then revisit the next proof app direction.
