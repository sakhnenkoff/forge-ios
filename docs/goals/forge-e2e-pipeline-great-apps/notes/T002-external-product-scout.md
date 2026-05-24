# T002 Scout Receipt: External Product And Pipeline Quality Patterns

Date: 2026-05-24
Task: T002 external/product scout
Mode: read-only web/product research plus this receipt/state update

## Scope

Researched source-backed patterns Forge should encode for good iOS app generation: product usefulness, activation/onboarding, retention, monetization, UX/state coverage, design references, screenshot-driven verification, App Store handoff, and repair loops.

No app or template implementation was performed.

## Sources Checked

Authoritative / primary:

- Apple Developer, "Creating Your Product Page" - product page screenshots, description, keywords, IAP metadata, ratings, localization, product page optimization.
  URL: `https://developer.apple.com/app-store/product-page/`
- Apple Developer, "App Review Guidelines" - monetization transparency, IAP requirements, review manipulation, notification restrictions, metadata/brand restrictions.
  URL: `https://developer.apple.com/app-store/review/guidelines/`
- Apple Human Interface Guidelines, "Onboarding" - immediate use, skippable tutorial, contextual instruction.
  URL: `https://developer.apple.com/design/human-interface-guidelines/onboarding`
- Apple Developer Documentation, Xcode screenshot/localization screenshot workflow.
  URL: `https://developer.apple.com/documentation/xcode/creating-screenshots-of-your-app-for-localizers`

Industry/product sources:

- Amplitude, "What Is Product Analytics? A Data-Backed Guide" - activation, retention, feature adoption, conversion, and activation-retention relationship.
  URL: `https://amplitude.com/explore/analytics/product-analytics-guide`
- RevenueCat, "State of Subscription Apps 2026" - paywall text density, offer use, intro offer reliance, structured monetization experimentation.
  URL: `https://www.revenuecat.com/state-of-subscription-apps-2026-shopping/`

Lower-authority sources were searched but not treated as requirements:

- App Store screenshot blog posts and Reddit threads. They reinforce the same direction as Apple -- first screenshots must communicate value quickly -- but they should not override Apple guidance.

## Reusable Patterns Forge Should Encode

### 1. Product gate: prove the app deserves to exist

Pattern:

- Start with target user, pain, promise, and "why now".
- Force a comparison against existing alternatives.
- Define the one behavior the user opens the app for.
- Kill commodity features that do not serve that behavior.

Why it matters:

- Amplitude frames activation and retention as lifecycle metrics, not as UI polish. Forge should not start screen generation until it can name the activation event and likely retention behavior.

Forge encoding:

- Add a product thesis artifact with:
  - target user;
  - core promise;
  - existing alternatives;
  - table stakes vs differentiators;
  - must-have vs nice-to-have;
  - explicit non-goals;
  - "why this deserves to exist".

DayRate implication:

- "Rate your day and see a grid" is not enough. "Predict your day, rate the outcome, and unlock earned self-knowledge through Day Twins, Micro-Patterns, and Time Capsules" is a product thesis.

### 2. Competitive/reference gate: research before screen maps

Pattern:

- Capture competitors, positioning, pricing, table stakes, common complaints, design references, and a positioning gap before proposing screen scope.
- References should be translated into actionable design rules, not mood words.

Forge encoding:

- Produce `.forge/competitive-notes.md` before `.forge/DESIGN.md`.
- Require each planned feature to be tagged:
  - `table_stakes`;
  - `differentiator`;
  - `retention_driver`;
  - `monetization_driver`;
  - `defer_or_kill`.
- Require each reference to state what to copy and what to avoid.

DayRate implication:

- Copy the ritual discipline and anticipation of daily apps, not the generic mood-grid UI of mood trackers.

### 3. Activation/onboarding gate: first value before explanation

Pattern:

- Apple HIG guidance is directionally clear: people want to start using the app immediately, tutorials should be skippable, and instructional content should be contextual.
- Activation should be a measurable value moment, not "completed onboarding".

Forge encoding:

- `.forge/activation-onboarding.md` must name:
  - activation event;
  - minimum inputs required before value;
  - first-session path;
  - aha moment;
  - skippable/explain-later content;
  - permission timing.
- The generated onboarding screen should perform or preview the core action, not only describe the app.

DayRate implication:

- Activation event: user makes the first morning prediction or simulated first prediction within onboarding.
- Avoid notification permission on first screen; explain the ritual first and ask later.

### 4. Retention gate: design day 1, day 3, day 7 deliberately

Pattern:

- Retention is not an outcome of "nice UI"; it comes from a repeat loop, triggers, compounding value, and an earned reason to return.
- Amplitude reports early activation is a strong predictor of later retention and gives day-seven return as a meaningful activation signal.

Forge encoding:

- `.forge/retention-loop.md` must define:
  - daily/weekly repeat loop;
  - trigger logic;
  - user value on day 1, day 3, day 7;
  - progress/insight cadence;
  - what gets better with more data;
  - what happens if the user misses a day.
- Judge should reject apps whose only retention mechanism is "streak" unless the product has stronger value.

DayRate implication:

- Day 1: prediction/rating feedback and a question.
- Day 3: first small contrast or Day Twin pattern.
- Day 7: Micro-Pattern readiness.

### 5. Monetization gate: paid value must follow user value

Pattern:

- Apple requires monetization to be understandable in metadata/review notes, digital unlocks to use IAP, and restore mechanisms for restorable purchases.
- RevenueCat's 2026 report emphasizes structured paywall experimentation across design, pricing, placement, and promotion rather than a single best paywall pattern.

Forge encoding:

- `.forge/monetization.md` must include:
  - whether monetization is appropriate yet;
  - free value;
  - paid value;
  - paywall triggers;
  - placeholder product IDs;
  - restore purchase surface;
  - App Store-safe claims;
  - pricing experiment notes;
  - what must not be locked before activation.

DayRate implication:

- Free: daily prediction, rating, question, basic grid/history.
- Pro: deeper history, exports, reminders, pattern reports, Time Capsule depth, Micro-Patterns after enough data.
- Do not hard-sell before the user understands the daily ritual.

### 6. UX/state gate: every core journey needs states

Pattern:

- Product quality requires first-use, returning, empty, loading, error, and edge-state behavior before implementation.
- Bad-network behavior is relevant only when network-backed features exist; local-first apps need local data, permission, empty-history, and missed-day states instead.

Forge encoding:

- `.forge/user-journeys.md` should cover:
  - first-session activation;
  - returning daily loop;
  - insight/progress path;
  - Pro upsell path;
  - empty/insufficient data;
  - permission denied/deferred;
  - offline/local-only behavior;
  - missed reminders;
  - recovery after failed save.

DayRate implication:

- Since the proof can stay mock/local, edge states should focus on missing predictions, no ratings yet, not enough days for patterns, denied reminders, and skipped days.

### 7. Design gate: reference-backed, anti-template, screenshot-visible

Pattern:

- A design contract must be evaluable from a screenshot. If a DESIGN.md rule cannot be seen or checked, it is too vague.
- Forge needs "copy this/avoid this" reference translation and explicit anti-template criteria.

Forge encoding:

- `.forge/DESIGN.md` should include:
  - visual identity;
  - references with specific takeaways;
  - component/token strategy;
  - screen blueprints;
  - anti-template criteria;
  - voice/copy;
  - screenshot acceptance criteria for each key screen.
- Add a design "red flag" list for generic output:
  - equal-weight cards;
  - default tabs when app is single-loop;
  - cheap traffic-light palettes;
  - generic rating circles;
  - overexplaining before first action.

DayRate implication:

- Dark minimal/data-color direction is correct, but it must specify the year grid/ritual as the hero and ban generic mood tracker UI.

### 8. Native build and verification gate: proof must be from the generated app

Pattern:

- Screenshot/UI evidence is not optional; the pipeline should capture actual simulator output before judging quality.
- Apple/Xcode screenshot workflows and prior xcodebuildmcp evidence support treating screenshots and accessibility snapshots as durable proof artifacts.

Forge encoding:

- Verification receipt must record:
  - generated app path;
  - Xcode project and scheme;
  - bundle ID;
  - build command;
  - app-code warning scan;
  - simulator run;
  - screenshot paths;
  - UI/accessibility snapshot paths;
  - smoke flow steps.
- Reject evidence that points to the template `Forge.xcodeproj` for the proof app.

DayRate implication:

- All native proof must run against `/Users/matvii/Developer/Personal/forge-proof-apps/DayRateLab/DayRateLab.xcodeproj`.

### 9. Judge/repair gate: separate product/design/engineering judgments

Pattern:

- A build that compiles can still be a bad app.
- Judge should score product, UX/retention, monetization, design, and engineering separately, then require repair that feeds lessons back into reusable pipeline artifacts.

Forge encoding:

- Judge receipt should include:
  - product usefulness;
  - activation clarity;
  - retention loop;
  - monetization appropriateness;
  - visual/design originality;
  - engineering/build correctness;
  - repair scope;
  - reusable pipeline lessons.
- Repair Worker should update both app output and the pipeline artifact that would prevent recurrence.

DayRate implication:

- If the app uses generic rating circles again, repair must update DESIGN.md/anti-template gate, not only the Swift file.

### 10. Handoff gate: App Store story from real app evidence

Pattern:

- Apple product page guidance emphasizes up to 10 screenshots, first one to three images appearing in search results, each screenshot focused on a main benefit/feature, a unique first description sentence, 100-character keyword limit, and localized screenshots/metadata where relevant.
- Apple review guidance requires clear monetization, IAP for digital unlocks, restore mechanisms, and no manipulative review behavior.

Forge encoding:

- `.forge/handoff.md` should include:
  - positioning;
  - subtitle options;
  - description draft;
  - screenshot sequence;
  - product page keywords;
  - IAP/product ID placeholders;
  - privacy/submission TODOs;
  - launch/monetization notes;
  - Matvii polish checklist.
- Screenshot plan must map to actual captured screens/states, not imagined marketing copy.

DayRate implication:

- First screenshots should show the core ritual, the year/pattern hero, and the first earned insight/Pro value, not onboarding copy or generic settings.

## Concrete Quality Gates/Rubrics For Forge

### Product score

Pass only if:

- one target user is named;
- one core pain/promise is named;
- primary action is obvious;
- at least one differentiator is not a template feature;
- non-goals are explicit.

### Activation score

Pass only if:

- activation event is measurable;
- first-session path reaches it quickly;
- onboarding can be skipped or reduced;
- no permission/paywall blocks first value unless explicitly justified.

### Retention score

Pass only if:

- repeat loop is stated in one sentence;
- day 1/day 3/day 7 value exists;
- trigger/reminder logic is user-benefit-driven;
- progress/insight cadence compounds.

### Monetization score

Pass only if:

- free value is useful;
- paid value is clearly incremental;
- paywall timing follows or previews value;
- placeholder product IDs exist;
- App Store-safe claims and restore path are planned.

### Design score

Pass only if:

- design has references and anti-references;
- each screen has one visual hero;
- component choices are not template defaults by inertia;
- screenshot acceptance criteria are specific;
- color/type/surface rules are checkable.

### Verification score

Pass only if:

- app builds on Mock with no app-code warnings;
- simulator run evidence exists;
- screenshots and UI snapshots exist for key flows;
- smoke flows are recorded;
- evidence paths point to the generated app.

### Handoff score

Pass only if:

- App Store listing draft exists;
- screenshot sequence is planned from real app states;
- production TODOs are explicit;
- monetization/launch notes are bounded and App Store-safe;
- Matvii polish checklist is concrete.

## Pipeline Mapping

Recommended mapping for the next Judge:

- `forge-plan` / new local gate docs: product, competitive, activation, retention, monetization, UX/state.
- `forge-design`: DESIGN.md, references, anti-template rules, screenshot acceptance criteria.
- `forge-tailor` or generated app local design-system edits: component/token strategy.
- `forge-arch` / Worker: models, managers, ViewModels, navigation.
- `forge-craft` / Worker: native SwiftUI screens.
- `forge-verify`: Xcode build/run/screenshot/UI snapshot warning scan.
- `forge-judge`: product/UX/retention/monetization/design/engineering review.
- `forge-ship` / `forge-storefront`: handoff package and App Store story.

## Scout Verdict

T002 is complete.

Recommended next task: T003 Judge should choose the target architecture and first Worker slice. The strongest safe first Worker slice is likely a reusable gate/artifact package plus generated-app foundation, not native screens yet, unless Judge decides existing DayRateLab scaffold and `.forge` artifacts are already strong enough.
