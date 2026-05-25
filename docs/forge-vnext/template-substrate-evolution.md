# Forge vNext Template/Substrate Evolution Strategy

Status: durable pipeline direction.

## Core decision

The current Forge template is not a golden path.

Treat it as a legacy starting substrate that must be continuously refactored into app-factory building blocks. Each generated app trial should teach Forge which parts of the substrate are reusable factory machinery and which parts are stale product residue that must be stripped, modularized, or gated.

## Why this matters

If every generated app requires a long cleanup job to remove auth, paywall, settings, sync, localization, docs, skills, scripts, StoreKit, Firebase, or prior-app assumptions, then Forge is not yet an app factory. It is copying a big old app and hoping validators catch the mess.

The goal is to make the next generated app cheaper, cleaner, and more app-specific than the previous one.

## Substrate taxonomy

### Keep as factory machinery

Reusable infrastructure is good when it is app-agnostic and only activated by app-specific plans:

- project/scaffold creation;
- build schemes and Xcode settings;
- dependency injection shell;
- routing primitives;
- design-system primitives;
- toast/error patterns;
- local/mock service pattern;
- test helpers;
- `.forge` artifact contracts;
- verifier/evidence/launch/learning scripts.

### Make optional modules

These must not appear by default in every generated app. They should be selected by `.forge/spec.json` / product gates and added only when justified:

- auth/account;
- paywall/purchases/StoreKit/RevenueCat;
- settings/profile;
- push notifications;
- sync/backend/Firebase/Firestore;
- onboarding;
- analytics/AB testing;
- localization;
- App Store/TestFlight/launch package wiring.

### Strip / forbid by default

These should not be copied into generated proof app repos unless explicitly needed:

- Forge control-plane docs/goals/plans;
- skills directories;
- forge-cli/internal scripts;
- stale proof-app artifacts;
- DayRateLab or previous app references;
- public launch/App Store/TestFlight/signing instructions;
- copied examples that are not part of the app.

## Desired generator model

Forge generation should become:

1. Product plan decides required capabilities.
2. Capability planner chooses modules.
3. App generator creates minimal app shell.
4. Module assembler adds only selected modules.
5. Sanitizer strips forbidden residue.
6. Verifier enforces both presence and absence gates.
7. Trial audit patches the substrate so the same mistake is not repeated.

## Required pipeline changes

1. Add a module manifest for the template/substrate.
   - Each feature/module declares: purpose, product prerequisites, files, dependencies, routes, forbidden-by-default state.

2. Make `new-app.sh` or its successor selective.
   - It should not copy the whole old template blindly.
   - If full copy remains temporarily, sanitizer must remove non-selected modules and residue.

3. Add app-specific module selection artifact.
   - Example: `.forge/module-plan.json`
   - Contains selected modules, explicitly rejected modules, and rationale.

4. Strengthen absence gates.
   - Verifier must fail if non-selected modules leave visible/routable/compiled surfaces.
   - Absence gates should check paths, Swift symbols, packages, routes, visible labels, docs, and launch instructions.
   - Local-boundary negative copy is allowed only when it explicitly forbids a module (for example, "no account creation" or "no payment setup"). Positive setup/configuration/wiring instructions for account, auth, payment, paywall, subscription, or purchase surfaces are blockers.

5. Write a module plan for generated proof apps.
   - Current transitional artifact: `.forge/module-plan.json` with `schema_version: forge.module-plan.v1`.
   - Default selected module: `local-proof-shell` only.
   - Default rejected modules: `auth-account`, `paywall-purchases`, `sync-backend`, `settings-profile`, `onboarding`, and `public-launch` until an app-specific plan opts in.
   - Schema: `docs/forge-vnext/schemas/forge.module-plan.v1.schema.json`.

6. Convert cleanup learnings into substrate patches.
   - Every app trial must output pipeline-learning patches, not just app fixes.
   - If Pantry needed auth/paywall removal, the next app should not need the same removal job.

## Proof that this is working

The next generated app after Pantry should show:

- fewer forbidden residue hits before manual cleanup;
- module plan exists before app creation;
- absent modules are actually absent, not merely hidden by feature flags;
- generated app repo contains app artifacts, not Forge control-plane baggage;
- verifier catches forbidden residues automatically;
- design/product differences are driven by app-specific artifacts, not template defaults.

## Current Pantry implication

Pantry Rescue is not just an app repair task. It is evidence that the Forge substrate must evolve.

Current observed failure mode:

- app could build/run;
- but copied template surfaces and generic infrastructure leaked into the proof app;
- visual/design review also needed stronger app-specific proof.

Therefore, Pantry repairs must produce both:

1. local app cleanup;
2. Forge generator/substrate changes so future generated apps avoid the same class of failure.
