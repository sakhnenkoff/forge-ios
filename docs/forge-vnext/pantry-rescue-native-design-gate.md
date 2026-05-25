# Pantry Rescue Queue — Native Design Gate

Generated: 2026-05-25T18:57:02Z / 2026-05-25T20:57:02+0200
Kanban task: `t_9fd2c755`
Parent product spec: `docs/forge-vnext/pantry-rescue-native-proof-spec.md`
Companion static design artifact: `docs/forge-vnext/artifacts/pantry-rescue-native-design-blueprint.html`
Status: local product/design/native-proof preparation only. No Swift, no generated app repo, no App Store/TestFlight/signing/IAP/payment/account action.

## 1. Scope boundary

This artifact translates the accepted manual-MVP direction into app-specific design instructions for a later native SwiftUI proof.

Allowed in this artifact:

- product-design handshake;
- app-specific visual language;
- screen blueprints and component strategy;
- copy tone, empty states, accessibility notes;
- static local HTML design blueprint for review.

Explicitly not allowed here or in the later native proof unless a new gate approves it:

- complete inventory management;
- barcode scanning;
- OCR;
- receipt import;
- loyalty-card import;
- cloud/account sync;
- live family sharing;
- grocery APIs;
- StoreKit/IAP/paywall/payment surfaces;
- public launch/App Store/TestFlight/signing/account actions;
- DayRateLab-derived UI, names, screenshots, fixtures, verifier assumptions, or dashboard/card-shell inspiration.

Money posture remains `no_monetization_yet`.

## 2. Product-design handshake

App: Pantry Rescue Queue

Target user:
A solo household food operator who does one weekly grocery trip, has fridge/freezer/pantry overflow, and repeatedly discovers expiring food or duplicate buys while deciding dinner.

Core workflow:
Open directly into one manual quick-add, choose location and urgency, receive a rescue queue decision, commit one action, see the queue get quieter, and optionally store a duplicate-avoidance caution for a later grocery moment.

Core emotional job:
Turn “ugh, this might go bad” into “I know what to do tonight, and I will not repeat this buy blindly.”

Repeat-use moment:
Weekly rescue recap or grocery pre-check that references prior rescue actions and turns them into the next action, not just historical metrics.

Design implications:

- Product fact: first value must appear under 30 seconds.
  Design consequence: first launch is a focused Rescue Mouth, not onboarding, dashboard, or table.
  Must show in flow: visible prompt, already-focused item entry, location chips, urgency rail, and one primary action path.

- Product fact: manual quick-add is acceptable only if it produces a decision.
  Design consequence: the post-add surface is a Rescue Lane with verbs, not an inventory row.
  Must show in flow: `Cook tonight`, `Freeze`, `Ignore`, and `Do not buy again` are visible near the item.

- Product fact: the app is about relief from food waste guilt.
  Design consequence: use soft urgency, warm food-station materials, and relief-oriented progress copy.
  Must show in flow: queue count changes as “the fridge got quieter,” not a KPI dashboard.

- Product fact: duplicate caution is created from behavior.
  Design consequence: caution memory appears inline after action and later in recap/pre-buy context.
  Must show in flow: “Should I warn you before buying spinach again?” follows a rescue action.

- Product fact: scanner/sync features are deferred but common competitor expectations.
  Design consequence: do not tease camera, import, account, household, or sync affordances; trust comes from honest local-only language.
  Must show in flow: settings/about only has local-proof trust copy and boundaries.

- Product fact: native proof must avoid generic Forge scaffold output.
  Design consequence: wrap DS primitives in app-specific compositions; identity comes from mouth/lane/progress/caution shapes.
  Must show in flow: a screenshot cannot pass if it looks like Home / Items / Insights cards with different copy.

## 3. Design thesis

One-sentence direction:
Pantry Rescue Queue should feel like a small, warm rescue station for perishable food: one intake mouth, one triage lane, one calm progress path, and a memory that helps the next grocery decision.

Core metaphor:
A fridge with “noisy” items waiting in a rescue lane. The UI helps the user quiet the lane one item at a time.

Signature surfaces:

- Rescue Mouth: oversized one-line prompt for the at-risk food.
- Urgency Rail: tactile urgency choices attached to the prompt, not database fields.
- Rescue Lane: ranked, vertical lane where the first item exposes action verbs immediately.
- Triage Verb Sheet/Panel: one action moment with outcome preview.
- Quiet Fridge Progress Path: count and path showing the queue becoming calmer.
- Caution Memory Slip: small warm note created from a rescue action.
- Weekly Rescue Recap: returning state with prior action, caution, remaining item, and next action.
- Local Trust Note: minimal settings/about surface that clarifies no account, sync, scanner, or payments in this proof.

Explicitly rejected patterns:

- generic dashboard/card shell before the first useful result;
- inventory-table-first list with columns for quantity, expiry, location, price, or category;
- tab-first scaffold such as Home / Items / Insights / Settings;
- scanner/OCR/import/sync affordances;
- recipe feed as the primary surface;
- gamified streaks/confetti/achievement boards;
- metric tiles as the main progress representation;
- paywall/pro/trial/pricing surfaces.

## 4. Visual identity

Mood sentence:
A warm kitchen note pinned to a quiet fridge: slightly urgent, tactile, forgiving, and relieved when one thing is handled.

Palette intent:

- Fridge paper: warm off-white / cream background, not clinical white.
- Leaf rescue: muted green for safe/rescued/planned outcomes.
- Edge urgency: squash/amber for “needs attention,” not alarm red by default.
- Night action: deep blue-green for primary commitment buttons.
- Caution slip: pale amber with dashed/bent-paper treatment for duplicate memory.
- Divider line: low-contrast pantry twine / paper edge.

Typography intent:

- Large rounded display for item names and the first prompt.
- Compact uppercase eyebrow only for context labels such as `tonight's first rescue`.
- Body copy should be calm and concrete, never analytical dashboard language.
- Use at least three text sizes on each primary screen: screen promise, item/action, supporting nudge.

Shape and texture:

- Rescue Mouth uses an exaggerated rounded “intake” container with strong border and shadow lip.
- Rescue Lane is less card-like than scaffold cards: visually a path/lane with peeking next item.
- Caution Memory is a slip/note, not a settings row.
- Weekly Recap uses a route/path composition, not a chart grid.
- Reusable DS primitives may sit underneath, but visible app components must have Pantry Rescue names and behavior.

Motion personality for later native proof:

- Soft intake: quick-add field fills and chips settle into place.
- Lane reveal: new item slides into first position, next items peek below.
- Action commit: selected verb compresses, item moves from “yelling” to “planned/rescued.”
- Caution creation: memory slip folds/slides in after action.
- Recap return: weekly path unfurls from prior action to next rescue.
- Reduce Motion: all motions become short fades/position changes with no bounce or parallax.

## 5. Screen blueprints

### 5.1 First Launch / Manual Quick-Add — Rescue Mouth

Purpose:
Prove activation. The user should understand and act before reading instructions.

Composition:

- `DSScreen(title:)` can be the root, but the visible title should be the rescue promise, not “Home.”
- Top: small local-only trust crumb such as `local proof · no account` if needed.
- Dominant middle/bottom: Rescue Mouth with prompt `What needs rescuing?`.
- Item entry: one large text field placeholder `spinach, yogurt, chicken...`.
- Location chips: `fridge`, `freezer`, `pantry`.
- Urgency rail: `tonight`, `1-2 days`, `this week`, `not sure`.
- Primary CTA: `Put it in the rescue queue` or auto-advance once item/location/urgency are selected.
- Secondary help: `Not sure? Use “this week” and adjust later.`

State requirements:

- Empty: `Nothing is yelling right now. Add one thing if dinner feels uncertain.`
- Validation: inline, not toast: `Name one food first.` / `Pick where it is hiding.`
- Loading: no full-screen spinner; if any async/mock delay exists, the mouth keeps its shape with a subtle `finding the first rescue...` label.
- Error: Toast only: `Couldn't save this rescue. Try again.`

Acceptance:

- No onboarding carousel, account gate, scanner prompt, empty inventory table, metrics, or tab bar before this prompt.
- First useful action path requires only item + location + urgency.

### 5.2 Rescue Queue — Rescue Lane

Purpose:
Turn quick-add into a decision.

Composition:

- Header copy: `Spinach is first in the rescue queue.`
- A single leading lane item dominates; next one or two items may peek below.
- Item shows name, location, urgency language, and one recommended action.
- Primary decision panel: `Best rescue: cook tonight` plus one concrete suggestion, e.g. `eggs + spinach`.
- Fallback verbs are visible: `Freeze`, `Ignore this time`, `Do not buy again`.
- Keep verbs close to the item; do not hide them behind row swipe-only interactions.

State requirements:

- Active queue: ranked by urgency; first item gets visual priority.
- Multiple items: lane shape remains; do not become an inventory table.
- Empty queue: `The fridge is quiet. Add one thing if dinner feels uncertain.`
- Long names: truncate gracefully but keep verb buttons visible.

Acceptance:

- Reviewer can identify the recommended rescue action without reading any spec.
- The useful result is a decision, not just `Spinach · fridge · tonight` in a row.

### 5.3 Item Triage Action

Purpose:
Capture the action and its consequence.

Composition:

- Presented inline or as a compact bottom sheet/panel from the lane item.
- Title: `What happens to spinach?`
- Verb choices with outcome previews:
  - `Cook tonight` -> `moves to planned tonight`.
  - `Freeze` -> `leaves the urgent lane`.
  - `Ignore this time` -> `counts as ignored, may appear in recap`.
  - `Do not buy again` -> `creates a caution memory`.
- Primary selected action uses strong night/leaf treatment.
- Confirmation text is plain: `Done — spinach is no longer yelling tonight.`

State requirements:

- Every verb produces visible queue/progress change.
- Destructive/negative choices are not moralizing. Use `Ignore this time`, not `Failed`.
- Errors are toasts with recovery copy.

Acceptance:

- Tapping a verb changes at least one visible state: queue position, status, progress path, or caution prompt.

### 5.4 Duplicate Caution Memory

Purpose:
Turn repeated waste/duplicate-buy pain into a local memory.

Composition:

- Appears as a caution slip after a rescue/ignore/do-not-buy-again action.
- Copy: `Should I warn you before buying spinach again?`
- Choices: `yes, nudge me`, `only if still unused`, `no memory`.
- If accepted: `Caution saved for your next grocery check.`
- Later context copy: `Before you buy: spinach is on your caution list. Last time: rescued at the edge.`

State requirements:

- Caution must name the source item and prior action.
- Caution cannot be a static settings toggle or generic list entry.
- User can clear/snooze: `clear caution`, `skip this week`, `buy smaller`.

Acceptance:

- A screenshot sequence can prove action -> caution created -> caution surfaced later.

### 5.5 Weekly Recap / Progress

Purpose:
Prove returning value and progress without generic analytics.

Composition:

- Opening line: `This week the fridge got quieter.`
- Recap facts as sentences/path nodes, not metric tiles:
  - `3 things rescued`;
  - `1 ignored without guilt`;
  - `spinach became a caution`;
  - `mushrooms are next by Tuesday`.
- Next action dominates: `Clear one tonight` / `Plan mushrooms`.
- Queue progress path shows remaining items, with prior rescued items visible enough to explain the recap.

State requirements:

- Returning state references prior actions from local state.
- Recap has a next action; it is not only a summary.
- Zero-recap state: `No rescues logged this week. Start with one thing that looks tired.`

Acceptance:

- A skeptical reviewer cannot fairly call it an insights dashboard: the recap is a rescue route to the next action.

### 5.6 Settings / About / Trust Note

Purpose:
Clarify proof boundaries without adding scope.

Composition:

- Minimal local trust note: `Local proof: your rescue queue stays on this device.`
- Optional grouped rows: `Reset local demo data`, `About Pantry Rescue Queue`, `What this proof does not do`.
- Boundary copy names deferred features honestly: no account, sync, scanner, OCR, receipt import, payments, or sharing in this proof.

State requirements:

- No sign-in button, upgrade button, pricing row, import prompt, scanner option, sync toggle, or sharing invitation.
- Settings is not a primary navigation destination in first launch. It can be a small toolbar action after the core flow exists.

Acceptance:

- Settings reduces trust ambiguity without advertising deferred features as coming soon.

## 6. Component strategy for SwiftUI implementation

Use Forge DS primitives under the hood, but create app-specific wrappers/compositions where identity matters.

Keep / use directly:

- `DSScreen` as root container.
- `DSButton` and `DSIconButton` for interactive elements.
- `Toast` for save/persistence errors.
- `ContentUnavailableView` or `EmptyStateView` for empty states, with Pantry Rescue copy.
- `StaggeredVStack` or equivalent for intentional entrance animation.

Compose into app-specific components:

- `RescueMouthView`: prompt, entry field, location chips, urgency rail.
- `UrgencyRail`: urgency choices with forgiving “not sure” path.
- `RescueLaneView`: ranked lane layout with peeking next items.
- `RescueLaneItemView`: item summary plus immediate verbs.
- `TriageVerbPanel`: action choices with outcome previews.
- `QuietFridgeProgressView`: queue-clearing path/progress sentence.
- `CautionMemorySlip`: duplicate caution prompt and accepted state.
- `WeeklyRescueRecapView`: prior actions -> next action route.
- `LocalProofTrustNote`: local-only boundary copy.

Skip / ban for this proof:

- Generic `DashboardCard` / metric tile grid as main surface.
- Generic tab scaffold as first information architecture.
- Inventory row/table component as primary UI.
- Scanner/camera/import/sync/account/paywall components.
- Chart components unless a later proof explicitly needs them; weekly progress should be path/sentence-first.

Architecture notes for later implementation:

- Screens with local rescue data need a manager before ViewModels, per `AGENTS.md`.
- ViewModels must be `@MainActor @Observable`, include `var toast: Toast?`, use `hasLoaded`, and track key events.
- Views must use `DSScreen`, `.toast(...)`, and `.onAppear(...)`.
- Models need realistic mock data and placeholders: at-risk item, long item name, no urgency certainty, cleared item, ignored item, active caution, no-caution state.

## 7. Copy tone

Voice principles:

- Speak like a calm kitchen helper, not a productivity coach.
- Use food/rescue verbs: `rescue`, `cook`, `freeze`, `quiet`, `remember`, `warn`, `skip`.
- Avoid shame language: no `failed`, `wasted again`, `bad habit`, `streak broken`.
- Prefer concrete next actions over abstract insights.
- Be honest about uncertainty: `Not sure? Use “this week” and adjust later.`

Approved copy examples:

- First prompt: `What needs rescuing?`
- First-use title: `Rescue one thing before dinner.`
- Useful result: `Spinach is first in the rescue queue.`
- Progress: `Queue got quieter.`
- Empty: `Nothing is yelling right now.`
- Edge: `Not sure when it expires? Use “this week” and adjust later.`
- Caution: `Should I warn you before buying spinach again?`
- Recap: `This week the fridge got quieter.`
- Error: `Couldn't save this rescue. Try again.`
- Trust: `Local proof: your rescue queue stays on this device.`

Banned copy posture:

- `Optimize your pantry`;
- `Track inventory` as the first promise;
- `Upgrade to Pro`, `trial`, `subscribe`, `premium`;
- `Scan to start`, `Import receipt`, `Sync household`;
- generic productivity copy such as `Stay on top of everything`.

## 8. Accessibility notes

Text and Dynamic Type:

- Core prompt, item name, and primary verb must remain readable at large Dynamic Type.
- Verb buttons may wrap to two lines before shrinking below legible size.
- Long item names truncate at safe boundaries and remain available to VoiceOver.

VoiceOver:

- Rescue Mouth field label: `Food to rescue`.
- Location chips: `Fridge, selected` / `Freezer` / `Pantry`.
- Urgency chips: `Tonight, urgent` / `One to two days` / `This week` / `Not sure`.
- Lane item label should combine item, location, urgency, and recommended action.
- Triage buttons include effects: `Cook tonight, moves spinach to planned tonight`.
- Progress path has a sentence alternative: `Queue changed from 3 at risk to 2 at risk`.
- Caution slip: `Duplicate caution prompt for spinach`.

Touch and layout:

- Chips and verbs must hit at least 44x44 pt.
- Core action should be reachable one-handed on compact phones.
- Do not rely on color alone for urgency; pair color with text and shape.
- Compact width must preserve action visibility before decorative details.

Contrast and color:

- Amber urgency and green rescue states must meet contrast on cream backgrounds.
- Caution slip border/dash cannot be the only indicator of caution state.
- Dark mode can be deferred, but if enabled later must keep warm-fridge identity without low-contrast brown-on-black.

Motion:

- Respect Reduce Motion; lane moves become fades and static state changes.
- Haptics are meaningful only for action commit/caution saved, not every tap.

## 9. Static design blueprint artifact

Created/updated artifact:

- `docs/forge-vnext/artifacts/pantry-rescue-native-design-blueprint.html`

Review target:

- Open locally in a browser.
- Click `Fill rescue mouth`, `Show rescue lane`, `Commit cook tonight`, and `Return next week`.
- Confirm visible states cover first launch/manual quick-add, rescue queue, item triage action, duplicate caution memory, weekly recap/progress, and local trust note.

Known limitation:

- This is still local static HTML. It is design evidence, not native/simulator/user evidence.

## 10. Design acceptance criteria for later screenshot/native review

A later native SwiftUI proof should pass design review only if screenshots/video demonstrate all of the following:

Activation and first-use:

- First screenshot opens on Rescue Mouth or equivalent direct rescue prompt.
- No account, scanner, OCR, import, sync, payment, onboarding carousel, dashboard, table, or tab scaffold appears before value.
- One manual item + location + urgency can reach a useful rescue action in under 30 seconds.

Core loop:

- Rescue Lane presents a ranked first item and visible immediate verbs.
- The recommended action is visually dominant and semantically specific.
- Tapping a verb visibly changes queue/progress state.

Duplicate caution:

- Caution memory is created from a user action.
- A later state surfaces the caution with the prior item/action context.
- Caution can be accepted, deferred, or declined without shame copy.

Weekly recap/progress:

- Returning screen references prior rescue actions from local state.
- Recap has a next action, not only metrics.
- Progress reads as a quieting/rescue path, not generic analytics cards.

Visual/product identity:

- At least three app-specific structural choices are visible: Rescue Mouth, Rescue Lane, Caution Slip, Quiet Fridge Path, or Weekly Route.
- Token-swap test passes: if food/rescue/caution language were removed, the screen structure would no longer make sense.
- Card-dashboard density test passes: first useful screen is not primarily a metric/card grid.
- Scaffold dependency test passes: identity is carried by layout, components, interactions, and workflow shape, not colors alone.
- Screen-shape uniqueness test passes: activation, lane/action, caution, and recap differ for product reasons.

Accessibility and polish:

- Compact-width screenshot preserves core action visibility.
- Dynamic Type and VoiceOver labels are planned or evidenced for the core flow.
- Errors use Toast; validation is inline; no raw error strings.
- No full-screen spinner replaces the core surface.

Boundary preservation:

- No barcode/OCR/receipt/loyalty-card/import/cloud/account/sync/family-sharing/grocery API affordance appears.
- No StoreKit/IAP/paywall/trial/price/premium copy appears.
- Settings/about, if shown, reinforces local proof and non-goals without teasing deferred features.

Recommended verdict for this design gate:

- `pass_for_pre_native_design_preparation`.
- Native generation still requires the separate allowed implementation task/gate; this artifact is a guide and review contract, not executable permission by itself.

## 11. Self-review checklist

- [x] Reads parent product spec and activation/direction artifacts.
- [x] Preserves manual quick-add + rescue queue MVP.
- [x] Defines app-specific design language and visual identity.
- [x] Avoids generic dashboard/card shell, inventory-table-first, tab-first, scanner/OCR/sync affordances.
- [x] Defines first launch/manual quick-add, rescue queue, triage action, duplicate caution memory, weekly recap/progress, and settings/about screen blueprints.
- [x] Defines copy tone, empty states, visual identity, component strategy, and accessibility notes.
- [x] Creates companion local static prototype artifact for design review.
- [x] Includes screenshot/native design acceptance criteria.
- [x] Does not create Swift/native app code or a new app repo.
