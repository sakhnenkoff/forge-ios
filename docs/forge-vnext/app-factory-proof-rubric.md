# Forge vNext App-Factory Proof Rubric

Status: operating rubric for deciding whether Forge is getting closer to the interview-level app-factory goal.

## Key distinction

A Kanban card being `done` does **not** mean Forge vNext is done.

`done` means: the assigned worker completed that card's local scope and produced a handoff.

App-factory proof is a higher-level verdict that requires multiple independent cards to pass and a skeptical judge to approve the evidence.

## Status semantics

### Card-level statuses

- `todo`: shaped work exists but dependencies are not done yet.
- `ready`: work can be dispatched.
- `running`: a worker is currently acting.
- `blocked`: worker stopped because it needs a gate, repair, missing capability, or operator action.
- `done`: worker completed its scoped task; this is not global approval.

### Proof-level states

- `not_started`: no trial app direction or implementation exists.
- `direction_candidate`: research found a candidate, but it is not approved for native proof yet.
- `direction_approved_for_trial`: product/design/research judge says it is worth a local proof attempt.
- `native_implemented_unverified`: a native app exists but independent verification/judging has not passed.
- `verified_but_unaudited`: tests/build/run/verifier pass, but skeptical audit has not judged credibility.
- `credible_app_factory_proof`: independent verifier and judge approve, artifacts are preserved, and known gaps are either repaired or explicitly accepted.
- `failed_trial_learning_needed`: the trial failed but produced useful pipeline patches/learning.

## Who reviews what

### Agents should handle by default

- mechanical tests/build/run checks;
- verifier/evidence-index validation;
- screenshot/UI evidence collection;
- product/design rubric scoring;
- skeptical audit against the Forge interview bar;
- deciding whether to create repair cards;
- preserving artifacts after approved automated gates;
- keeping Kanban moving when no real human gate exists.

### Matvii should handle only real gates

- approving a product direction before native generation when taste/market judgment matters;
- approving public/external/money/credential/work-system/App Store/TestFlight/signing/account actions;
- approving repo/app deletion or irreversible cleanup;
- accepting/rejecting the final claim that Forge reached the interview-level bar;
- overriding a judge when taste/strategy matters.

Implementation workers should not block for generic human review if downstream verifier/judge cards exist. They should complete with evidence and let verifier/judge cards run. Human review comes after the judge, not before every child gate.

## App-factory proof checklist

Forge may claim one credible app-factory proof only if all are true:

1. Product direction
   - non-DayRate direction;
   - clear painful job;
   - sharp target user;
   - repeat-use loop;
   - believable money path or explicit accepted deferral;
   - product/taste receipt exists.

2. Design
   - app-specific design pressure;
   - not token-only scaffold reskin;
   - not generic card dashboard;
   - screen blueprint/prototype exists;
   - design gate receipt exists.

3. Native implementation
   - generated app lives in its own repo/path outside Forge template;
   - scoped MVP is implemented;
   - no DayRateLab inspiration/reuse;
   - no forbidden external/account/money/public actions;
   - local persistence/returning-state behavior exists when required.

4. Verification
   - relevant tests pass;
   - Mock build succeeds;
   - simulator run succeeds;
   - screenshot/UI evidence exists;
   - `.forge/verification-plan.json` and evidence index exist;
   - generic verifier passes without app-specific source edits.

5. Skeptical audit
   - independent judge says the proof is credible;
   - evidence is not circular or only self-reported;
   - known gaps are listed;
   - repairs are either completed or intentionally deferred;
   - result is not scaffold bullshit.

6. Learning loop
   - pipeline learning/postmortem exists;
   - Forge pipeline patches are proposed/applied/rejected explicitly;
   - next iteration is clearer because of this trial.

## Current Pantry Rescue interpretation

Current state after native implementation handoff:

- Product/design/native-prep gates: passed enough to attempt local native proof.
- Native app exists at `/Users/matvii/Developer/Personal/PantryRescueQueue`.
- Implementation worker reported tests/build/run/verifier pass.
- Independent verifier/judge chain still must run before this can count as credible proof.

Therefore current state is approximately:

`native_implemented_unverified`

It is not yet `credible_app_factory_proof`.
