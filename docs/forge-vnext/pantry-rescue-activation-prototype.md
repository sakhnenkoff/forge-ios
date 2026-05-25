# Pantry Rescue Queue — Activation Prototype / Storyboard

Generated: 2026-05-25T20:22:48+0200
Task: `t_6fdcb138`
Related gate: `docs/forge-vnext/second-proof-app-direction-gate.md`
Static prototype: `docs/forge-vnext/artifacts/pantry-rescue-activation-prototype.html`

## Scope and safety

This is a non-native prototype/storyboard artifact only. It does not create an app repo, generate Swift, use external accounts, touch App Store/TestFlight/signing/IAP/payment systems, or reuse any prior proof app as inspiration. The prior proof app remains only a negative guardrail: do not ship another generic dashboard/card shell.

The artifact repairs two blockers from judge `t_e91cbb17`:

- `G-ACTIVATION-PROOF-1`: no timed prototype/storyboard proving one manual quick-add can create a useful rescue queue in under 30 seconds.
- `G-RETENTION-PROOF-1`: no returning-user/progress sketch for weekly recap, duplicate-avoidance memory, or queue-clearing progress.

It is still not native evidence and not user-behavior evidence. It can support product/design synthesis if a judge accepts it, but it cannot by itself approve native generation.

## Prototype thesis

If the first session opens directly on a rescue decision, not an inventory database, one manual quick-add can feel useful in under 30 seconds:

1. user names one food item;
2. chooses where it is and how urgent it feels;
3. immediately receives a ranked rescue queue action;
4. commits one action: eat tonight, freeze, cook, ignore, or do-not-buy-again;
5. sees progress that accumulates into the next session.

The useful result is not “item added to inventory.” The useful result is “I know what to do with this expiring thing now, and the app remembers it so I do not buy it again blindly.”

## Stopwatch activation script: target under 30 seconds

Persona: solo household food operator, Sunday evening, notices spinach wilting while deciding dinner.

Start condition: app opens cold. No barcode/OCR/sync. User has not created a full pantry inventory.

Target budget: 25 seconds comfortable, 30 seconds maximum.

Script:

- 0.0s — Open app. First visible prompt: “What needs rescuing?” Cursor is already in the one-line quick-add field. No dashboard first.
- 2.0s — Type `spinach` or tap the recent/common chip if present.
- 6.0s — Tap location chip `fridge`.
- 8.5s — Tap urgency chip `sad tonight` / `1-2 days`.
- 11.0s — App creates a rescue lane entry: `Spinach — rescue tonight`.
- 12.0s — App surfaces one primary outcome: `Cook tonight: eggs + spinach` and two fallback actions: `freeze` and `do-not-buy-again`.
- 16.0s — User taps `Cook tonight`.
- 18.0s — Queue shrinks from `3 at risk` to `2 at risk`; a small progress message appears: `1 rescue planned this week`.
- 21.0s — Duplicate memory appears inline, not as a settings page: `Remember for next grocery trip: you often leave spinach half-used. Add to do-not-buy-again?`
- 25.0s — User taps `remember`. The app records a shopping caution: `Warn me before spinach next trip`.
- 30.0s max — User has a concrete rescue action, queue progress, and duplicate-avoidance memory.

Pass condition for a paper/prototype review:

- A reviewer can follow the above path in the static prototype/storyboard without seeing an inventory table first.
- The first useful result appears by step 4 / 12 seconds in the script.
- A commitment and visible progress state happen by 18 seconds.
- Duplicate-avoidance memory appears before 30 seconds.

Fail condition:

- User must enter quantity, category, purchase date, price, barcode, account, household, or a complete inventory before seeing value.
- The result is only a row in a table/list with an expiry date.
- Progress is abstract metrics instead of a visible rescue/avoidance outcome.

## Storyboard frames

### Frame 1 — Empty rescue mouth, not dashboard

Screen shape: a single “rescue mouth” input at the bottom half, with three tactile storage chips and one urgency rail.

Copy:

- Title: `Rescue one thing before dinner`
- Prompt: `What is about to go sad?`
- Placeholder: `spinach, yogurt, chicken...`
- Chips: `fridge`, `freezer`, `pantry`
- Urgency rail: `tonight`, `1-2 days`, `this week`, `not sure`

Why it avoids generic inventory UI:

- There is no table, item count dashboard, or card grid.
- The screen asks for one distressed food item, not full inventory setup.
- Location/urgency are action ingredients, not database attributes.

### Frame 2 — Rescue queue outcome

After entering `spinach / fridge / tonight`, the screen morphs into a lane with one urgent item at the front.

Primary lane copy:

- `Spinach is first in the rescue queue.`
- `Best rescue: cook tonight with eggs or pasta.`
- `Fallback: freeze before bed.`
- `If this keeps happening: remember as a caution for next grocery trip.`

Actions:

- `Cook tonight`
- `Freeze`
- `Ignore this time`
- `Do not buy again`

Why this is useful:

- It converts manual add into a decision, not a record.
- It gives a concrete default while preserving user agency.
- It makes the “do-not-buy-again” memory part of the activation path.

### Frame 3 — Queue-clearing progress

After tapping `Cook tonight`:

- Queue count visibly changes: `3 at risk -> 2 at risk`.
- Weekly progress appears as a small path, not a metric card: `1 rescue planned · 2 left before Friday`.
- The lane moves spinach into `planned tonight`, leaving the next rescue target peeking below.

Why this matters:

- It proves the core loop has a state transition.
- It creates an emotional reward: guilt turns into a plan.
- It sets up the returning session without pretending the user built a full database.

### Frame 4 — Duplicate-avoidance memory

Before exit:

- Prompt: `Should I warn you before buying spinach again?`
- Choices: `yes, nudge me`, `only if still unused`, `no memory`

Stored memory example:

```json
{
  "item": "spinach",
  "memory_type": "duplicate_avoidance_caution",
  "condition": "warn_on_next_grocery_trip_if_recent_rescue_or_unused_item_exists",
  "created_from": "activation_rescue_action"
}
```

Why this is not scanner/sync scope creep:

- It does not require a grocery API or account.
- It can surface as local copy in a future shopping-list/check-before-buy moment.
- It records a human decision, not automated purchase detection.

## Returning-user / progress loop sketch

Loop: trigger -> action -> reward/progress -> next trigger.

### Trigger 1: weekly rescue recap

Timing: Sunday evening or configured weekly cadence.

Recap copy:

- `This week you rescued 3 things and ignored 1.`
- `Spinach became a caution. Yogurt was cleared twice.`
- `Next likely rescue: mushrooms by Tuesday.`

Useful proof requirement:

- A returning state must show at least one prior rescue action and one remaining queue item.
- The recap must create a next action, not only summarize metrics.

### Trigger 2: duplicate-avoidance memory

Moment: before grocery trip or when user opens the app to plan shopping.

Memory copy:

- `Before you buy: spinach is on your caution list.`
- `Last time: half used, cooked at the edge.`
- Actions: `buy smaller`, `skip this week`, `clear caution`.

Useful proof requirement:

- The memory must be created from a past rescue/ignore/do-not-buy-again action.
- It must appear in a future context where it changes a purchase decision.

### Trigger 3: queue-clearing progress

Moment: nightly dinner decision or reminder.

Progress copy:

- `2 left before Friday: mushrooms, yogurt.`
- `Clear one tonight to keep the fridge quiet.`
- Actions preserve the core verbs: `eat`, `freeze`, `cook`, `ignore`, `do-not-buy-again`.

Useful proof requirement:

- The queue count changes after an action.
- Cleared/ignored/do-not-buy-again states remain visible enough to create learning, not vanish as completed rows.

### Evidence that would prove repeat use

Prototype-level evidence needed before synthesis can be confident:

- storyboard includes first session and at least one returning session with changed state;
- returning state references a prior rescue decision, not generic placeholder history;
- duplicate caution appears because of a previous item action;
- weekly recap has a next action;
- user can clear one queue item and see progress update.

Native/user evidence needed later before launch-candidate claims:

- simulator video or screenshot sequence covering activation -> first useful outcome -> committed action -> returning recap;
- local persistence proof for remembered cautions and cleared queue items;
- usability test or dogfood stopwatch run showing first useful result under 30 seconds without scanner/OCR/sync;
- at least one compact-width screenshot showing the lane does not collapse into card/table clutter.

## Design-pressure notes

The app should feel like a small rescue station, not pantry admin software.

Banned default shapes:

- inventory table with columns for name, quantity, location, expiry;
- dashboard of metric cards before the first useful result;
- generic item cards whose only special traits are color/icon/category;
- tab-first scaffold: Home / Items / Insights / Settings;
- recipe feed as the primary surface;
- barcode/OCR/sync affordances in the first proof.

Required app-specific structures:

- Rescue Mouth: one-line item capture with location/urgency chips attached to the prompt.
- Rescue Lane: ranked queue where each item exposes rescue verbs immediately.
- Caution Memory: do-not-buy-again/duplicate warning created from a rescue action.
- Quiet Fridge Progress: queue-clearing progress expressed as “fewer things yelling at you,” not abstract productivity metrics.
- Weekly Rescue Recap: a returning-user surface that turns past actions into next actions.

Visual/emotional pressure:

- Food should feel perishable and time-sensitive without alarmist red dashboards.
- Use lane/triage language: `first`, `next`, `safe`, `too late`, `remember`.
- Prefer soft urgency and relief over gamified streaks/confetti.
- Empty state should be a calm fridge: `Nothing is yelling right now. Add one thing if dinner feels uncertain.`
- Error/edge state should be forgiving: `Not sure when it expires? Use “this week” and adjust later.`

Anti-generic checks:

- Token-swap test: if `spinach`, `fridge`, `rescue`, and `do-not-buy-again` were removed, the flow would stop making sense. Pass.
- Card-dashboard density test: first useful screen is an input + lane, not a stack/grid of metric cards. Pass for prototype direction.
- Scaffold dependency test: visible identity is carried by workflow shape and verbs, not colors/buttons. Pass for prototype direction.
- Screen-shape uniqueness: activation mouth, rescue lane, progress path, and weekly recap are different because their jobs differ. Pass for prototype direction.

## Static HTML prototype notes

`docs/forge-vnext/artifacts/pantry-rescue-activation-prototype.html` is a local static storyboard with three clickable state transitions:

1. `Start 30s activation` moves from empty rescue mouth to filled quick-add state.
2. `Show rescue queue` reveals the first useful outcome.
3. `Cook tonight` updates queue progress and duplicate memory.
4. `Open weekly recap` shows returning-user recap and next action.

It is intentionally lightweight. It is evidence for product/design synthesis, not a production UI and not native evidence.

## Verdict

Recommendation: `proceed-to-synthesis`, with explicit boundaries.

Why:

- The storyboard gives a concrete under-30-second activation path and a local static prototype that makes the first manual add produce a useful rescue decision.
- It adds a returning-user loop covering weekly recap, duplicate-avoidance memory, queue-clearing progress, and repeat-use proof requirements.
- It applies design pressure against inventory tables, generic cards, and scaffold dashboards.

What remains blocked:

- Native app generation remains blocked until judge/human approval.
- Money/paywall proof remains weak from the prior gate and is not repaired here except by preserving local-only boundary language.
- Real user repeat-use evidence does not exist yet; this artifact only defines what would prove it.

If a judge finds the static flow still too abstract or not reviewable enough, the next verdict should be `repair_again` with a narrower ask: record a timed walkthrough against this HTML prototype and require one independent reviewer to identify the first useful result without reading the spec.

If a reviewer believes scanner/OCR/sync is mandatory even after seeing this path, the honest verdict should be `kill_batch` or return to candidate selection before native work.
