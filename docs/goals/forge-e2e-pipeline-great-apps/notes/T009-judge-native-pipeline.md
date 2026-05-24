# T009 Judge Receipt: Native App + Pipeline

Date: 2026-05-24 23:12 CEST

## Verdict

`80_percent_ready: false`

`pipeline_quality_ready: false`

T008 is a meaningful native proof slice, not final proof. The generated app now has a credible DayRateLab surface, warning-clean build, simulator launch, and screenshot/UI hierarchy evidence. It is materially better than the old template-mutating proof because the work stayed in `/Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab` and used `.forge` artifacts as source material.

It still falls short of the final goal because the native implementation was hand-coded from the artifacts rather than produced by a reusable native Forge stage, and the app has product/evidence gaps that would be unacceptable for an 80%-ship-ready app.

## What Passed

- Native work happened in the generated app, not the Forge template.
- Main architecture follows `View -> ViewModel -> Manager` with `@Observable`, `@State private var viewModel`, `AppServices`, skeleton loading, empty state, refresh, and toast error handling.
- Product loop is visible in the simulator: prediction, rating, daily question, recent history, Patterns and Pro controls.
- App-code build passed warning-clean through XcodeBuildMCP and raw `xcodebuild`.
- Template finance copy was cleaned from the touched/reachable app surfaces.
- Paywall/pro positioning now preserves the free daily loop and charges for depth.

## App Failures

1. Pattern truthfulness is still weak.
   The app shows `MicroPattern.mockList` cards even when readiness is `4/14`. The design/product contract says the app must refuse fake insights until enough real days exist. This needs a lock/teaser state or gated card treatment.

2. Screenshot evidence is incomplete.
   The receipt has a Today screenshot and UI hierarchy, but T008 expected onboarding/activation and Today/progress state screenshots. Patterns and Pro are implemented but not captured as image evidence. Onboarding activation was tailored but not proven visually.

3. State depth is still demo-thin.
   The manager is in-memory mock only, no local persistence, and no recovery/empty-history proof beyond static empty overlay. That is acceptable for a proof slice, but not 80%-ship-ready.

4. Interaction smoke evidence is shallow.
   The app launched and rendered, but no recorded smoke flow confirms saving prediction/rating changes state and emits the expected toast.

## Pipeline Failures

1. No reusable native generation or repair mechanism exists yet.
   T004 produced reusable P0-P5 foundation generation. T008 produced native app code, but not a reusable P6/P7 implementation stage. This is the largest remaining pipeline gap.

2. Verification knowledge is not encoded.
   The `UI-TESTING SKIP_ALL_GATES` requirement, generated project name mismatch, screenshot matrix, copy sweep, and data-sufficiency gate are in the receipt, not in a reusable script/gate.

3. Screenshot matrix is underspecified.
   P7 says screenshots/UI snapshots are required for key flows, but the pipeline does not yet enforce which states must be captured for a generated app.

## Required Repair Scope

Activate T010 as a combined reusable-pipeline plus app-output repair:

- Add a reusable native verification helper or gate update that can be reused for the next generated app. It must encode:
  - generated app project/scheme discovery rather than assuming `Forge.xcodeproj`;
  - mock launch args/env guidance such as `UI-TESTING SKIP_ALL_GATES`;
  - screenshot matrix expectations: onboarding activation, Today, progress/insufficient-data Patterns, Pro/paywall;
  - static app-code sweep for template copy and hard-gate patterns;
  - data-sufficiency rule: no confident insights before readiness threshold.
- Repair DayRateLab so Patterns respects readiness:
  - show readiness/progress and a non-fake teaser before 14 completed days;
  - only show confident Micro-Pattern cards when enough real completed days exist;
  - keep Today and Pro behavior intact.
- Capture fresh evidence after repair:
  - warning-clean Mock build;
  - simulator launch;
  - screenshots for Today and Patterns readiness at minimum;
  - UI snapshot for primary state;
  - receipt under `.forge/evidence/` or GoalBuddy notes.

## T010 Worker Selection

Proceed to T010. This is not app-only repair: the worker must update reusable Forge pipeline guidance or a script and then update the generated DayRateLab app/evidence.
