# Forge E2E Pipeline Gates

This is the local bridge contract for proving Forge can generate genuinely good iOS apps end to end without mutating the template app.

Remote `forge-marketplace` v5 is the architectural north star: a thin orchestrator runs app-agnostic phases, writes project-local `.forge` artifacts, then builds and verifies a generated app. This document is the Forge repo bridge until the behavior is folded into the marketplace/plugin pipeline.

## Hard Boundaries

- Generated app work happens outside the template repo.
- The orchestrator or bridge must never write benchmark app content into `Forge/Features/**`.
- Static app-view output is supporting evidence only.
- Native proof must point to the generated app Xcode project, scheme, bundle ID, screenshots, and UI snapshots.
- Production credentials, publishing, deploys, pushes, and paid services are out of scope for proof runs.

## Required Artifacts

Every generated app must own its pipeline state under `.forge/`:

```text
.forge/spec.json
.forge/product-thesis.md
.forge/competitive-notes.md
.forge/activation-onboarding.md
.forge/retention-loop.md
.forge/monetization.md
.forge/user-journeys.md
.forge/DESIGN.md
.forge/progress.md
.forge/evidence/
```

## Phase Gates

### P0 Product Gate

Must answer:

- target user;
- pain and promise;
- must-have vs nice-to-have features;
- explicit non-goals;
- why this app deserves to exist.

Reject if the pitch is a renamed template, a commodity dashboard, or a feature list with no user behavior.

### P0.5 Competitive/Reference Gate

Must capture:

- comparable apps or patterns;
- what to copy;
- what to avoid;
- design references or style direction;
- positioning gap.

Reject if references are only mood words or if the design direction cannot be checked in a screenshot.

### P1 Activation/Onboarding Gate

Must define:

- first-session path;
- measurable activation event;
- aha moment;
- minimum input before value;
- onboarding copy and states;
- permission timing.

Reject if onboarding explains for too long before the first useful action.

### P2 Retention Gate

Must define:

- repeat-use loop;
- trigger/reminder logic;
- progress or insight cadence;
- what user sees on day 1, day 3, and day 7;
- what compounds with more use.

Reject if retention is only "streaks" or "come back to see charts later."

### P3 Monetization Gate

Must define:

- whether monetization is appropriate yet;
- free value;
- paid value;
- paywall timing;
- App Store-safe claims;
- placeholder product IDs;
- restore purchase expectations;
- when not to monetize yet.

Reject if paid value blocks first value, if claims cannot be supported in-app, or if product IDs are missing.

### P4 UX/State Gate

Must define:

- user journeys;
- screen map;
- first-use, returning, empty, loading, error, permission, offline/local, and recovery states as applicable;
- edge cases and bad-network behavior where relevant.

Reject if implementation would require inventing states during coding.

### P5 Design Gate

Must define:

- visual identity;
- references and anti-references;
- `DESIGN.md` contract;
- screen blueprints;
- anti-template criteria;
- component/token strategy;
- screenshot acceptance criteria.

Reject if the contract would allow default template cards, generic tab layouts, cheap traffic-light palettes, or equal-weight dashboards for a distinctive app.

### P6 Native Build Gate

Must produce:

- generated app copy;
- native SwiftUI implementation;
- View -> ViewModel -> Manager architecture;
- models/mock data when managers exist;
- no raw demo-only hardcoding when a manager/model is appropriate.

Reject if native work points at the template project instead of the generated app.

Native repair lessons now encoded by `scripts/forge-e2e-native-verify.mjs`:

- discover the generated `.xcodeproj` from the app path rather than assuming the template project name;
- require a domain manager/model when the screen reads or writes app data;
- require data-sufficiency gates for insight products, so mock insight cards do not make confident claims before the readiness threshold;
- keep product-specific launch/testing hooks explicit and mock-only, such as `UI-TESTING SKIP_ALL_GATES`;
- scan app Swift for template copy and hard-gate regressions before judging quality.

### P7 Verification Gate

Must produce:

- Xcode build result;
- app-code warning scan;
- simulator run;
- screenshot capture;
- UI/accessibility snapshot;
- smoke flow notes.

Reject if the evidence is static-only or if screenshots/UI snapshots are missing for key flows.

Screenshot matrix for generated proof apps:

- activation/onboarding state when onboarding is part of the product proof;
- primary daily/core-loop state;
- progress/insight sufficiency state, especially when insight claims are gated;
- monetization/paywall or Pro boundary state when monetization is in scope.

The verifier script checks for native screenshot evidence under `.forge/evidence/` and should be run after simulator capture.

### P8 Judge/Repair Gate

Must produce separate judgments for:

- product usefulness;
- activation and UX;
- retention;
- monetization;
- visual/design originality;
- engineering/build quality.

At least one repair loop is required when quality falls below the bar. Repair must update reusable pipeline artifacts when the failure is systemic.

### P9 Handoff Gate

Must produce:

- App Store positioning;
- subtitle/description draft;
- screenshot plan from real app states;
- production TODOs;
- launch/monetization notes;
- Matvii polish checklist.

Reject if the handoff is generic marketing copy disconnected from simulator evidence.

Current bridge: `scripts/forge-e2e-handoff.mjs`.

The handoff bridge must:

- read the generated app `.forge/spec.json`;
- require real native screenshot evidence before writing App Store copy;
- write the generated app handoff under `.forge/app-store-handoff.md`;
- record a receipt under `.forge/evidence/handoff-receipt.json`;
- separate source-evidenced screenshot slots from future screenshot slots;
- keep App Store Connect, production credentials, publishing, and deployment out of proof runs.

## Foundation Generator Contract

`scripts/forge-e2e-foundation.mjs` is the current local bridge for P0-P5 foundation artifacts. It must:

- read an idea JSON;
- write artifacts into the generated app `.forge/` directory;
- record a receipt under `.forge/evidence/`;
- be app-path driven;
- avoid writing Swift files;
- avoid writing benchmark content into the Forge template app.

The bridge is successful only when a later Worker builds native screens from these artifacts and a later Judge verifies product/design/retention/monetization quality from simulator evidence.
