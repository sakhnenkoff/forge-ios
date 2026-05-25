# Forge vNext Fixture Matrix

These fixtures prove the local vNext gate package before any second app is generated. They are contract fixtures only: placeholder screenshots/videos are allowed here so validators can prove pass/fail behavior without touching a simulator, App Store Connect, TestFlight, signing, IAP, or public channels.

Run the aggregate dry run:

```sh
node scripts/forge-vnext-final-audit.mjs
node scripts/forge-vnext-final-audit.mjs --json
```

## Expected outcomes

| Fixture | Expected aggregate status | Gates exercised | Purpose |
|---|---:|---|---|
| `minimal-app-specific-pass` | pass | product, design-final, verifier, launch-learning | Minimal app-specific Focus Pantry fixture that passes every local validator. It includes product/taste contracts, design contracts, verifier plan/evidence index, launch package, and learning artifacts. |
| `shallow-dashboard-fail` | expected fail | product, design-pre-native | Proves shallow dashboard/card-shell output cannot pass product/taste or design gates. |
| `token-reskin-fail` | expected fail | design-pre-native | Proves token-only scaffold reskins fail the design/look-feel gate before native expansion. |
| `missing-evidence-fail` | expected fail | verifier | Proves required evidence slots block when the evidence index marks them missing. |
| `substitute-evidence-missing-owner-fail` | expected fail | verifier | Proves substitute evidence is rejected when rationale/owner and referenced artifacts are incomplete. |
| `substitute-evidence-pass` | pass | verifier | Proves the generic verifier can accept approved substitute evidence when it is indexed with owner, rationale, approval, limits, and artifacts. |

## Minimal pass fixture notes

`minimal-app-specific-pass` is the fan-in fixture shared by the repaired lanes. It must stay app-specific and must not become a second generated app.

Required local pass artifacts:

- `.forge/gates/product-taste-gate.json`
- `.forge/gates/product-coverage-matrix.json`
- `.forge/scorecards/app-scorecard.json`
- `design/design-gate-receipt.json`
- `design/design-system.json`
- `.forge/verification-plan.json`
- `.forge/evidence/evidence-index.json`
- `.forge/launch/launch-package.json`
- `.forge/learning/app-scorecard.json`
- `.forge/learning/pipeline-scorecard.json`
- `.forge/learning/learning-patches.json`

Known evidence gap: fixture screenshots/video are placeholders. The approved second-app run must replace them with real native simulator evidence and fail if required artifacts are missing or only substituted without human-approved rationale.

## Safety rules

- Do not generate a second app from this fixture matrix.
- Do not polish DayRateLab here.
- Do not mutate the reusable Forge template with fixture/sample-app state.
- Keep live external actions out of these fixtures: no ASC login, TestFlight upload, signing/capability changes, IAP creation, or public posting.
