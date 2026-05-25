# Forge vNext Second Proof App Direction Gate

Generated: 2026-05-25T18:59:39+02:00
Task: `t_0ba879f1`
Status: direction recommendation only — no native app repo generated.

## Gate verdict

Recommendation: build `ShiftTill` as the second Forge vNext proof app, pending Matvii approval.

Why this is the best next proof:

- It has a sharp painful job: tipped workers need to know what they actually made after every shift, not a generic finance dashboard.
- It has an obvious repeat-use loop: every shift creates a log, every week creates a payout/tax/export question, every pattern creates a better forecast.
- It has believable direct monetization because competing tip/income trackers already exist with large review counts and paid/full-version complaints.
- It is feasible for a local second proof app: Forge can prove activation, core loop, retention, and money boundary with mock data, native screenshots, and a local launch package without external accounts.
- It creates strong design pressure: an end-of-shift receipt/cash-drawer interaction is visibly different from DayRateLab and from generic cards.

Decision needed from Matvii: approve `ShiftTill` for product/design gate work and native generation, ask for a repair to the direction, or reject and choose one of the alternates.

## Inputs and repaired criteria used

Source Forge artifacts:

- `docs/forge-vnext/final-dry-run-receipt.md`
- `docs/forge-vnext/executable-pipeline-integration.md`
- `docs/forge-vnext-charter.md`
- `docs/forge-vnext/lanes/product-taste-gates.md`
- `docs/forge-vnext/lanes/design-look-feel-gates.md`

Repaired gate criteria applied:

- Pain/problem clarity >= 7
- Target user sharpness >= 7
- Use-case activation >= 7
- Repeat-use / retention loop >= 7
- Money-path believability >= 6 for utility/prosumer apps, unless explicitly deferred
- Product distinctiveness / taste >= 7
- Future native slice must prove activation, core loop, returning-user/progress, and money boundary
- Evidence must include independent demand/pain signals and explicit gaps; weak evidence must ask Matvii instead of pretending to pass
- Design must reject token-only scaffold reskins, generic card dashboards, and copy/palette-only distinctiveness

Research method:

- Local App Store Search API lookups via `itunes.apple.com/search` for competitor existence, ratings, review counts, descriptions, and IDs.
- App Store customer review RSS samples for selected competitors via `itunes.apple.com/us/rss/customerreviews/id=.../sortBy=mostRecent/json`.
- This is direction-gate evidence, not full market validation. The next app run must produce a formal `.forge/research/evidence-matrix.json` before native expansion.

## Candidate 1 — ShiftTill

Working name: `ShiftTill`

One-line direction: An end-of-shift income ritual for tipped workers that turns cash/card tips, tip-outs, hours, and hourly wage into a trusted take-home ledger and next-shift forecast.

Target user:

- Primary: US restaurant servers, bartenders, baristas, delivery/service workers, and other tipped/commission workers with variable income.
- Excluded users: salaried workers, people who only need a restaurant tip calculator, enterprise payroll admins, and accountants looking for full bookkeeping.

Painful job:

- "I just finished a shift; how much did I actually make after tip-out, cash/card split, hourly wage, taxes/withholding estimate, and the shift pattern I care about?"
- Cost of doing nothing: underestimating/overestimating weekly income, losing cash/card records, poor tax prep, and not learning which shifts are worth taking.

Repeat-use loop:

1. Trigger: shift ends or schedule changes.
2. Action: log cash tips, card tips, hours, hourly wage, tip-out, role/location, and notes in under 30 seconds.
3. Reward/progress: see real hourly rate, take-home estimate, week target progress, and whether this shift beat personal baseline.
4. Next trigger: forecast upcoming shifts, weekly payout, export/tax prep, and streak of logged shifts.

Money path:

- Free: single job, limited history/export, simple shift logging.
- Pro: unlimited jobs/locations, CSV/tax export, shift-pattern forecasts, backup/sync if later approved, advanced tip-out templates.
- Boundary is value-aligned: the user pays when the app becomes their reliable income ledger, not for basic logging.

Distinctive design angle:

- Emotional tone: "closing-time clarity" — a calm cash drawer after a chaotic shift.
- Interaction shape: receipt-stack ledger, not finance dashboard. Each shift is a tactile receipt that slides into a weekly till.
- Signature surfaces:
  - `Close Shift` one-thumb flow with segmented cash/card/tip-out strips.
  - `This Week Till` stacked receipts that fold into totals and forecast.
  - `Best Shifts` pattern board with night/day/role/location chips, not generic charts first.
  - Paywall boundary as "unlock the locked drawer" for export/forecast templates.
- Explicitly rejects: generic finance cards, net-worth dashboard, big pie charts as first screen, scaffold `DSCard` metric grid.

Evidence / confidence / gaps:

Evidence found:

- App Store search for `tip tracker server waiter app` returned multiple direct competitors:
  - `ServerLife - Tip Tracker`, id `1098987860`, Finance, rating 4.81588, 8,978 ratings. Description claims "Over 750,000 workers" and "65 million income entries" and positions around real take-home pay shift by shift.
  - `TipTracker - track your income`, id `1161307849`, Finance/Utilities, rating 4.77694, 9,177 ratings. Description includes hourly income, hours, tips, graphs, calendar, multiple jobs, custom categories, CSV export.
  - `Waiter Pal: Tip Tracker`, id `1619187216`, Finance, rating 4.88077, 780 ratings. Description says it replaces pen-and-paper tip tracking and supports cash/credit tips and average hourly pay.
- Review samples show pain and willingness to pay:
  - ServerLife review: "perfect for keeping track of literally everything about your job and the money you're making" and "I bought the full version".
  - ServerLife review: "accurately see my take home, per day, per hour, per week, per month".
  - TipTracker negative reviews complain about paid app still showing ads and entries not saving, which suggests trust/reliability and paid boundary are real product issues.

Confidence: high for demand/pain existence; medium for differentiation until we inspect more competitor screenshots and paywall details.

Gaps to close next:

- Need competitor screenshot/design review to avoid cloning ServerLife/TipTracker.
- Need App Store pricing/paywall evidence; Search API only showed free listing prices, not IAP products.
- Need exact privacy stance for local-only income data.
- Need validate whether target should be US-only for tip/tax assumptions or allow generic currency/tax-free MVP.

## Candidate 2 — Pantry Rescue Queue

Working name: `Pantry Rescue Queue`

One-line direction: A household food-expiry app that stops acting like inventory software and instead creates a daily rescue queue of what must be eaten, frozen, cooked, or bought next.

Target user:

- Primary: household food managers, families, meal preppers, and people with pantry/freezer/fridge overflow who repeatedly waste food or buy duplicates.
- Excluded users: restaurants/retail inventory teams, macro/calorie trackers, recipe-only users, and people who want grocery delivery commerce.

Painful job:

- "What is about to go bad, what can I still rescue tonight, and what should I not buy again?"
- Cost of doing nothing: expired food, duplicate purchases, freezer archaeology, and guilt/friction around meal planning.

Repeat-use loop:

1. Trigger: grocery trip, unpacking food, nightly dinner decision, or expiry reminder.
2. Action: scan/add item with expiry/location; swipe into eat/freeze/cook/ignore.
3. Reward/progress: rescue queue shrinks, waste avoided, shopping list excludes duplicates.
4. Next trigger: next reminder, next grocery trip, weekly waste-saved recap.

Money path:

- Free: one household, manual add, limited inventory/history.
- Pro: barcode/receipt acceleration, family sync, multiple locations/freezers, smart shopping list and export.
- Money path is plausible but more competitive and more feature-heavy than ShiftTill.

Distinctive design angle:

- Emotional tone: "rescue mission, not pantry spreadsheet".
- Interaction shape: perishable triage lane with urgency bands and action cards (`eat tonight`, `freeze`, `batch cook`, `buy later`).
- Signature surface is a fridge-light rescue queue, not an inventory table or generic grocery dashboard.

Evidence / confidence / gaps:

Evidence found:

- App Store search for `pantry inventory expiration` and `food expiry tracker` returned direct competitors:
  - `Pantry Check - Grocery List`, id `966702368`, rating 4.51499, 1,534 ratings. Description includes barcode scanner, real-time syncing/family sharing, automatic expiration reminders, smart shopping lists, locations, usage timeline.
  - `NoWaste: Food Inventory List`, id `926211004`, rating 4.15591, 744 ratings. Description includes freezer/fridge/pantry lists, use-first, shopping list, meal planning, reducing waste and saving money.
  - `BEEP - Expiry Date Tracking`, id `1242739153`, rating 4.14957, 234 ratings. Description focuses on scanning barcodes and reminders before expiry.
- Review samples show the pain is real:
  - Pantry Check review: app "prevents me from purchasing duplicates and tells me when products are about to expire".
  - Pantry Check review asks for desired stock quantity to improve generated shopping lists.
  - NoWaste negative review says adding food is "clunky and time-consuming" and barcode expiration dates default incorrectly.
  - NoWaste negative review says scanned items were lost after freeze, highlighting trust/reliability pain.

Confidence: medium-high for pain and category; medium for second-proof feasibility because barcode/receipt/OCR/family sync can balloon scope.

Gaps to close next:

- Need decide whether the proof can skip real barcode/OCR and still be honest. A manual/mock-add proof risks under-proving the main friction.
- Need understand how much of the money path depends on sync/scanning, which requires external services later.
- Need competitor visual review to avoid inventory table/card-shell outcome.

## Candidate 3 — MedRunway

Working name: `MedRunway`

One-line direction: A local-first medication supply runway that helps chronic-med users know what they took, how many doses remain, and when refill risk becomes urgent.

Target user:

- Primary: adults managing several recurring medications/supplements and refill dates, especially for chronic conditions or caregiver-assisted routines.
- Excluded users: emergency medical advice users, diagnosis/treatment users, pharmacy fulfillment users, and clinical providers.

Painful job:

- "Did I take the medication, how many doses are left, and am I about to run out before I can refill?"
- Cost of doing nothing: missed doses, refill gaps, anxious manual counting, caregiver uncertainty.

Repeat-use loop:

1. Trigger: scheduled dose or low-supply threshold.
2. Action: mark taken/skipped; update remaining count; confirm refill request status.
3. Reward/progress: runway timeline shows safe days left and next refill deadline.
4. Next trigger: next dose, caregiver check-in, refill warning, weekly adherence view.

Money path:

- Free: local reminders and supply count for limited meds.
- Pro candidate: multiple profiles/caregiver exports, advanced refill scheduling, local PDF summary.
- This is the weakest money path because trust, privacy, and accessibility expectations are high; monetization must not exploit health anxiety.

Distinctive design angle:

- Emotional tone: "quiet control before the runway ends".
- Interaction shape: runway strips per medication with dose dots and refill horizon, not a generic habit checklist.
- Signature surfaces:
  - Today dose rail.
  - Supply runway timeline.
  - Refill risk card with conservative language.
  - Caregiver-safe summary screen.

Evidence / confidence / gaps:

Evidence found:

- App Store search for `medication refill reminder app` returned large direct competitors:
  - `Medisafe Medication Management`, id `573916946`, Medical/Health & Fitness, rating 4.70889, 99,893 ratings.
  - `Pill Reminder - All in One`, id `816347839`, rating 4.71995, 27,127 ratings. Description includes recurring reminders, remaining quantity tracking, and refill alerts.
  - `Pill Reminder MyTherapy`, id `662170995`, rating 4.78711, 8,009 ratings.
- Review samples show recurring pain and trust expectations:
  - Medisafe negative review says app became hard to open after years of use.
  - Medisafe negative review complains about a $60/year transition and navigation difficulty.
  - Medisafe review asks to sync meds with Apple Health instead of re-entering medication data.

Confidence: high that medication reminders/refills are real; low-medium that this is the right second proof app now.

Gaps to close next:

- Need privacy/legal/medical disclaimers and an explicit no-medical-advice stance.
- Need decide if Apple Health import is out of scope; if users expect it, a local mock proof may feel incomplete.
- Need accessibility bar much higher than normal.
- Need money path that does not feel predatory.

## Product/taste scorecard summary

Scores are direction-gate estimates on the repaired 0-10 scale. They are not final app scores because no native app exists yet.

| Dimension | Hard min | ShiftTill | Pantry Rescue Queue | MedRunway |
|---|---:|---:|---:|---:|
| Pain/problem clarity | 7 | 8 | 8 | 8 |
| Target user sharpness | 7 | 8 | 7 | 7 |
| Use-case activation | 7 | 8 | 7 | 7 |
| Repeat-use / retention loop | 7 | 8 | 8 | 8 |
| Money-path believability | 6 | 7 | 6 | 5 |
| Product distinctiveness / taste | 7 | 8 | 7 | 7 |
| Blueprint coverage / launch-slice integrity risk | 8 native gate | 8 | 7 | 7 |
| Evidence integrity at direction gate | 8 native gate | 8 | 8 | 8 |
| Direction verdict | — | pass_to_matvii_approval | repair_or_approve_with_scope_warning | ask_matvii_or_defer |

Interpretation:

- `ShiftTill` clears all direction hard minimums and has the cleanest path to proving every required native surface locally.
- `Pantry Rescue Queue` has strong pain but the proof can become dishonest if scanning/OCR/sync are treated as future magic. It needs scope repair before native work.
- `MedRunway` has the strongest human stakes but also the highest trust/privacy/accessibility and medical-domain risk. It is not the best second proof unless Matvii explicitly wants a higher-risk health utility.

## Why ShiftTill is best now

1. It tests Forge's repaired gates without demanding external integrations.
   - Activation can be a local after-shift logging flow.
   - Core loop can be local shift entry + totals.
   - Retention can be local weekly history/patterns.
   - Money boundary can be a local Pro/export/forecast paywall concept.

2. It avoids DayRateLab's failure mode.
   - DayRateLab risk was a polished calculator/dashboard without enough repeat loop/product evidence.
   - ShiftTill's first screen can be the user's painful trigger (`Close Shift`), not a dashboard.
   - The native proof can show state transitions: empty week -> close shift -> receipt added -> weekly till/forecast updated -> export/paywall boundary.

3. It is specific enough for app-specific design.
   - The receipt/cash-drawer metaphor can drive layout, components, copy, haptics, and empty states.
   - It can reject generic finance cards and prove a workflow shape.

4. It has clearer monetization than the alternates.
   - Income history/export/forecasting are credible paid value boundaries.
   - Competitor reviews indicate users pay or object when paid boundaries are mishandled.

5. It is small enough for one proof slice but not toy-sized.
   - The MVP can be honest with mock/local data.
   - Future real features exist, but the proof does not require accounts, banks, payroll APIs, camera/OCR, Apple Health, App Store Connect, or external services.

## Explicit non-goals for recommended direction

For the second proof app, `ShiftTill` must not attempt:

- Real payroll, bank, employer, POS, or tax-service integrations.
- Legal/tax advice or exact tax filing calculations.
- Multi-user cloud sync or account creation.
- Real in-app purchase setup, App Store Connect, TestFlight, signing, bundle IDs, or live paywalls.
- AI prediction claims; only transparent local forecasting from mock/history data.
- Generic personal finance dashboard, budgeting suite, or net-worth app expansion.
- DayRateLab reuse, polishing, naming, copy, screenshots, or verifier shortcuts.

## Kill risks for recommended direction

Structural risks that could make Matvii kill or repair the direction:

1. Competitor saturation risk
   - Existing apps are mature and well-rated. ShiftTill must differentiate on trust, speed, design, and the after-shift ritual, not just "another tip tracker".

2. Tax/trust risk
   - If tax estimates are too prominent, the app may imply precision it cannot safely provide. Keep first proof to transparent take-home estimates and export prep language.

3. Boring spreadsheet risk
   - If implementation drifts into table/calendar/cards/charts first, it fails the design gate. The proof must lead with the close-shift interaction and receipt-stack week state.

4. Money-path irritation risk
   - Reviews of competitors complain about ads after payment. ShiftTill must make the Pro boundary calm and trust-preserving: paid export/templates/forecasting, never interrupting the logging ritual.

5. Geography risk
   - Tipping/tax assumptions vary by country. First proof should state US-tipped-worker assumptions or use currency/tax-neutral language until Matvii chooses localization.

## Proposed `.forge/spec.json` outline for ShiftTill

```json
{
  "schema_version": "forge.spec.v1",
  "app": {
    "id": "shifttill",
    "name": "ShiftTill",
    "tagline": "Close every shift knowing what you really made.",
    "category": "finance_utility",
    "platform": "ios",
    "local_only_for_proof": true
  },
  "target_user": {
    "primary": "US tipped and commission workers who log income after each shift",
    "contexts": ["restaurant servers", "bartenders", "baristas", "delivery/service workers"],
    "excluded": ["salaried workers", "restaurant tip calculators only", "payroll admins", "tax professionals"]
  },
  "problem": {
    "painful_job": "After each shift, know real take-home income from tips, hours, hourly wage, tip-out, and weekly pattern without spreadsheet friction.",
    "current_workarounds": ["notes app", "paper notebook", "spreadsheet", "memory", "generic income tracker"],
    "cost_of_doing_nothing": ["lost records", "bad weekly income estimates", "tax prep friction", "not knowing best shift patterns"]
  },
  "activation": {
    "promise": "Log a complete shift and see real hourly/take-home estimate in under 30 seconds.",
    "first_use_flow": ["choose role/location", "enter cash tips", "enter card tips", "enter hours/tip-out", "save receipt", "see weekly till update"]
  },
  "core_loop": {
    "trigger": "shift ended",
    "action": "close shift by logging receipt fields",
    "reward": "receipt joins weekly till and updates take-home/forecast",
    "next_trigger": "next scheduled shift, weekly target, export/tax prep reminder"
  },
  "retention": {
    "returning_user_state": "week with multiple shift receipts, baseline comparison, best-shift pattern chips, export readiness",
    "progress_signals": ["logged shift streak", "weekly target progress", "average hourly by role/location", "unexported weeks count"]
  },
  "monetization": {
    "strategy": "freemium_local_proof_only",
    "free_boundary": ["single job", "basic shift logging", "last 30 shifts"],
    "pro_boundary": ["unlimited history", "multi-job/location templates", "CSV/tax export", "shift forecast", "advanced tip-out templates"],
    "live_iap": false,
    "requires_matvii_approval_before_live_use": true
  },
  "design": {
    "emotional_tone": "closing-time clarity after a chaotic shift",
    "core_metaphor": "cash drawer and stacked shift receipts",
    "signature_interactions": ["one-thumb close-shift receipt", "receipt slides into weekly till", "locked drawer for export/pro boundary", "pattern chips from past receipts"],
    "banned_patterns": ["generic finance dashboard first", "metric card grid as primary proof", "pie-chart hero", "tax advice copy", "DayRateLab visual reuse"]
  },
  "screens": [
    {
      "id": "activation.close_shift",
      "name": "Close Shift",
      "role": "activation",
      "native_required_now": true,
      "evidence_required": ["screenshot", "flow_video_or_substitute"]
    },
    {
      "id": "core.receipt_saved",
      "name": "Shift Receipt Saved",
      "role": "core_loop",
      "native_required_now": true,
      "evidence_required": ["screenshot"]
    },
    {
      "id": "retention.weekly_till",
      "name": "This Week Till",
      "role": "retention",
      "native_required_now": true,
      "evidence_required": ["screenshot"]
    },
    {
      "id": "money.export_drawer",
      "name": "Export / Forecast Pro Boundary",
      "role": "monetization",
      "native_required_now": true,
      "evidence_required": ["screenshot"]
    },
    {
      "id": "empty.first_shift_prompt",
      "name": "Empty Week Prompt",
      "role": "empty_error",
      "native_required_now": true,
      "evidence_required": ["screenshot"]
    }
  ],
  "verification": {
    "mock_build_required": true,
    "simulator_run_required": true,
    "screenshots_required": ["activation.close_shift", "core.receipt_saved", "retention.weekly_till", "money.export_drawer", "empty.first_shift_prompt"],
    "generic_verifier_must_pass_without_source_edits": true
  },
  "launch_bar": {
    "local_launch_package_required": true,
    "privacy_draft_required": true,
    "pricing_draft_required": true,
    "app_scorecard_required": true,
    "pipeline_scorecard_required": true,
    "no_external_actions_without_approval": true
  }
}
```

## Next native-generation acceptance bar if Matvii approves

Before native Swift generation starts:

- `.forge/spec.json` exists for `ShiftTill` and includes the outline fields above.
- `.forge/research/evidence-matrix.json` exists with at least:
  - 3 competitor apps,
  - review/pain excerpts,
  - pricing/paywall evidence or explicit pricing gap,
  - confidence and gaps.
- Product/taste direction gate emits markdown + JSON receipt and passes all direction hard minimums or blocks for Matvii.
- Design pre-native gate emits references, original synthesis, emotional tone, design system, and local clickable prototype receipt.
- Design gate explicitly passes token-swap, card-dashboard, scaffold-dependency, screen-shape, and emotional-tone tests.
- `.forge/verification-plan.json` exists before implementation with app-specific required screenshots/evidence.

Native proof completion bar:

- Generated app lives in a separate local repo outside the Forge template.
- Mock build succeeds.
- Simulator run succeeds.
- Screenshots/evidence prove:
  - activation: close a first shift,
  - core loop: receipt saved and totals changed,
  - retention/progress: week with multiple receipts and baseline/pattern state,
  - monetization: local export/forecast Pro boundary,
  - empty/error/constrained state.
- Generic verifier passes without source edits and without DayRateLab literals.
- Local launch package exists with app-specific privacy/pricing/copy/screenshot plan.
- App scorecard and pipeline scorecard remain separate.
- Postmortem and learning-patches proposal exist.
- No App Store/TestFlight/signing/IAP/money/external account actions occur.

## Matvii decision options

Option A — Approve recommended direction: `ShiftTill`

- Proceed to product/design gate artifacts and then native generation under the repaired gates.
- Recommended.

Option B — Repair before approval

- Keep `ShiftTill`, but ask for one focused repair before generation:
  - inspect competitor screenshots/paywalls more deeply,
  - decide US-only vs currency-neutral proof,
  - tighten tax wording and privacy stance.

Option C — Reject and choose another direction

- Choose `Pantry Rescue Queue` if Matvii wants household/food-waste utility and accepts barcode/OCR/sync scope risk.
- Choose `MedRunway` if Matvii wants higher-stakes health utility and accepts privacy/accessibility/medical-domain risk.

## Stop condition

This task stops here. Do not create the native app repo, do not polish DayRateLab, and do not touch App Store/TestFlight/signing/money/external accounts until Matvii explicitly approves a direction.
