# T012 Judge Receipt: Pre-Commit Audit

Date: 2026-05-24 23:30 CEST

## Verdict

`ready_to_commit: false`

The generated-app proof and reusable pipeline artifacts are materially valid, but the current Forge repository branch is not commit-ready because tracked template files still contain benchmark DayRate content from earlier local proof work.

## What Passed

- `forge-marketplace` working tree is clean.
- Native verifier passes:
  - `node scripts/forge-e2e-native-verify.mjs --app-path /Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab`
  - Result: `NATIVE_VERIFY_OK`.
- Handoff bridge passes:
  - `node scripts/forge-e2e-handoff.mjs --app-path /Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab`
  - Result: `HANDOFF_OK`.
- DayRateLab evidence exists:
  - `.forge/evidence/native-today-screen.jpg`
  - `.forge/evidence/native-patterns-screen.jpg`
  - `.forge/app-store-handoff.md`
  - `.forge/evidence/handoff-receipt.json`
- T010/T011 reusable pipeline additions are good candidates for a clean Forge commit once branch contamination is handled.

## Blocking Findings

1. Template contamination exists in tracked Forge app files.

   `rg -n "DayRate|dayrate|DayRateLab|dayratelab" Forge ForgeUnitTests Packages` returned:

   - `Forge/Features/Onboarding/OnboardingStep.swift`
   - `Forge/Features/Home/HomeView.swift`
   - `Forge/Managers/Purchases/EntitlementOption.swift`

   This violates the goal rule that benchmark app content must not live in the Forge template. These edits predate this repair pass, so they should not be silently reverted in the current worktree.

2. The Forge working tree has unrelated untracked files.

   Exclude from any proof commit unless separately reviewed:

   - `.claude/settings.json.bak`
   - `.playwright-mcp/`
   - `DESIGN.md`
   - `docs/goals/forge-app-factory-real-app-proof/`
   - `docs/superpowers/plans/2026-04-13-skill-distribution.md`
   - `linear.app/`

3. The generated proof app is not a git repository.

   `/Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab` has no `.git` directory. If local commit hashes are required for final proof, the generated app needs its own local repo or an explicit decision to exclude it from commit requirements.

## Eligible Forge Files After Clean Branch Repair

These are the Forge repo files eligible for a clean proof commit:

- `docs/forge-e2e-pipeline-gates.md`
- `scripts/forge-e2e-foundation.mjs`
- `scripts/forge-e2e-native-verify.mjs`
- `scripts/forge-e2e-handoff.mjs`
- `docs/goals/forge-e2e-pipeline-great-apps/**`

Do not include the old superseded goal folder unless the final commit intentionally archives it as historical evidence.

## Generated App Commit Candidate

If the proof app is initialized as its own local git repo, the first commit should include the generated app as a self-contained proof artifact:

- `.forge/**`
- `DayRateLab/**`
- `DayRateLab.xcodeproj/**`
- `DayRateLabUnitTests/**`
- `Packages/core-packages/**`
- project docs/scripts required to build the generated app

Exclude DerivedData, `.swiftpm/`, user secrets, local credential files, and simulator logs outside `.forge/evidence`.

## Recommended Commit Messages After Repair

- Forge repo: `Add E2E proof pipeline gates and bridges`
- Generated app repo: `Add DayRateLab generated proof app`

## Required Next Step

Use a non-destructive clean-worktree strategy instead of rewriting the current contaminated branch:

1. Create a clean Forge worktree or branch from `origin/main`.
2. Copy only the eligible Forge pipeline/goal files into that clean workspace.
3. Verify the clean workspace template has no DayRate content in `Forge`, `ForgeUnitTests`, or `Packages`.
4. Decide whether to initialize the generated DayRateLab app as its own local repo.
5. Rerun this pre-commit audit before allowing T013 commits.
