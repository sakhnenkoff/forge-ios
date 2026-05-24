# Forge E2E Pipeline: Build Genuinely Good iOS Apps

## Owner outcome

Make the **Forge pipeline** excellent at delivering genuinely good iOS apps end-to-end: useful product scope, strong user flows, onboarding, retention, monetization, distinctive design, native SwiftUI implementation, simulator verification, quality repair, App Store handoff, and a clear Matvii polish path.

This goal is about Forge capability, not a one-off app. The proof app exists only to verify the pipeline.

## Core thesis

Forge should be Matvii's personal iOS app factory:

```text
raw app idea
→ product thesis
→ user/market/competitor understanding
→ first-session activation
→ retention loop
→ monetization plan
→ UX flows and states
→ visual identity / DESIGN.md
→ generated app copy
→ native SwiftUI implementation
→ Xcode build/run/screenshot/UI proof
→ product/design/retention/monetization judging
→ repair loop
→ App Store handoff
→ Matvii polish/publish decision
```

The products are the apps Forge builds. Forge itself is the reusable rocket launcher.

## What counts as success

Success is **not**:

- a static `app-view`;
- docs/specs only;
- a renamed template;
- hardcoding a sample app into the Forge template;
- manually building DayRate Lab and calling Forge good;
- a build passing without product/design/retention/monetization quality;
- patching the previous flawed goal.

Success is:

> Forge's reusable pipeline gains/validates concrete stages that can take one app idea to an 80%-ship-ready generated iOS app, and the proof app demonstrates that the pipeline can deliver a good app E2E.

## Proof app

Default benchmark app: **DayRate Lab**.

DayRate Lab is only a benchmark because it is small enough for a vertical proof and has real product requirements:

- first-session activation: user makes one prediction quickly;
- daily loop: prediction → evening rating;
- retention loop: repeated days unlock patterns/insights;
- monetization: Pro value via deeper history, exports, reminders, pattern reports, or time capsule;
- design: dark, minimal, data-color, not generic template cards;
- App Store story: simple daily self-knowledge ritual.

Judge may choose another proof app only if it has stronger feasibility, retention, monetization, and design potential, and records the rationale.

## Hard rules

- Fresh goal only. Do not continue the superseded `forge-app-factory-real-app-proof` goal.
- Do not mutate the Forge template into the proof app.
- Do not hardcode DayRate Lab into `Forge/Features/**` in the template repo.
- Do not push, publish, deploy, spend money, or use production credentials.
- Do not reset/revert/delete commits without explicit Matvii approval.
- Old local proof commits are archived evidence, not accepted architecture.
- Use a generated app copy outside the template repo for proof.
- Use `DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer` for Xcode commands.
- Prefer `xcodebuildmcp` for simulator build/run/screenshot/UI snapshot where practical.

## Required reusable pipeline stages

Forge must define, improve, or validate these reusable stages. Each stage must produce artifacts or instructions that future apps can reuse.

1. **Product gate**
   - target user;
   - pain/promise;
   - must-have vs nice-to-have features;
   - explicit non-goals;
   - why this app deserves to exist.

2. **Competitive/reference gate**
   - comparable apps/patterns;
   - what to copy/avoid;
   - design references or style direction;
   - positioning gap.

3. **Activation/onboarding gate**
   - first-session path;
   - aha moment;
   - minimum input required before value;
   - onboarding copy and states.

4. **Retention gate**
   - repeat-use loop;
   - trigger/reminder logic;
   - progress/insight cadence;
   - what user sees on day 1, day 3, day 7.

5. **Monetization gate**
   - free value;
   - paid value;
   - paywall timing;
   - App Store-safe claims;
   - placeholder product IDs;
   - when not to monetize yet.

6. **UX/state gate**
   - user journeys;
   - screen map;
   - loading/empty/error/first-use/returning-user states;
   - edge cases and bad-network behavior where relevant.

7. **Design gate**
   - visual identity;
   - references;
   - `DESIGN.md` contract;
   - screen blueprints;
   - anti-template criteria;
   - component/token strategy.

8. **Native build gate**
   - generated app copy;
   - Codex/build agent creates native SwiftUI;
   - follows AGENTS.md;
   - no raw demo-only hardcoding when a ViewModel/Manager/Model is appropriate.

9. **Verification gate**
   - Xcode build;
   - warning scan;
   - simulator run;
   - screenshot capture;
   - UI/accessibility snapshot;
   - relevant smoke flows.

10. **Judge/repair gate**
    - product judge;
    - UX/retention/monetization judge;
    - visual/design judge;
    - engineering/build judge;
    - at least one focused repair loop if quality is below bar.

11. **Handoff gate**
    - App Store positioning;
    - subtitle/description draft;
    - screenshot plan;
    - production TODOs;
    - launch/monetization notes;
    - Matvii polish checklist.

## Expected proof path

Generated proof app path should be outside the template, for example:

```text
/Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab
```

Expected artifacts inside generated app:

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

Expected native app proof:

- onboarding activation screen/flow;
- home/core daily loop;
- insight/progress state;
- monetization/paywall plan or surface;
- Xcode build and run;
- screenshots/UI snapshots for key flows;
- Judge receipts and repair iteration.

## Final oracle

Complete only when a final Judge receipt records `full_outcome_complete: true` and proves all of the following:

- Forge pipeline stages/gates above exist as reusable artifacts, skill changes, scripts, or validated instructions;
- proof app was generated by exercising the Forge pipeline, not manually hand-built outside it;
- generated app lives outside the template repo;
- template repo is preserved or contaminated local proof commits are handled with Matvii-approved strategy;
- current remote `forge-marketplace` v5 architecture is understood and either integrated, aligned, or explicitly deferred with rationale;
- proof app has product, UX, retention, monetization, and design artifacts;
- proof app has native SwiftUI implementation for core flows;
- Xcode build succeeds with no app-code warnings;
- simulator run, screenshots, and UI/accessibility snapshots exist;
- judges record that the app is plausibly good enough for Matvii to polish toward App Store, not generic AI slop;
- App Store handoff and polish checklist exist;
- related changes are locally committed only, with unrelated files excluded.

## Completion bar

The generated app does not need to be fully shipped. It must be an **80% ship-ready proof** of a **reusable Forge pipeline**: good enough that Matvii can polish the final 20%, and strong enough that the next app can use the same pipeline rather than repeating a one-off hack.
