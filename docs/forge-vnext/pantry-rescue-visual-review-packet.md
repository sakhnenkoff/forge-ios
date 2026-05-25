# Pantry Rescue Queue — Visual Review Packet

Generated: 2026-05-25
Kanban task: `t_9fc4030b`
App under review: `/Users/matvii/Developer/Personal/PantryRescueQueue`
Current screenshot: `/Users/matvii/.hermes/media/pantry-rescue-current-screenshot.jpg`
Screenshot size: 368 × 800 px
Safety posture: local review only. No public, external, App Store, TestFlight, signing, account, payment, or money action was performed.

## 1. Inputs reviewed

- Design assessment contract: `docs/forge-vnext/design-assessment-loop.md`
- Native design gate: `docs/forge-vnext/pantry-rescue-native-design-gate.md`
- Native proof spec: `docs/forge-vnext/pantry-rescue-native-proof-spec.md`
- Static design blueprint: `docs/forge-vnext/artifacts/pantry-rescue-native-design-blueprint.html`
- Current simulator screenshot: `/Users/matvii/.hermes/media/pantry-rescue-current-screenshot.jpg`
- App implementation evidence:
  - `/Users/matvii/Developer/Personal/PantryRescueQueue/.forge/evidence/evidence-index.json`
  - `/Users/matvii/Developer/Personal/PantryRescueQueue/.forge/evidence/activation.first_use.md`
  - `/Users/matvii/Developer/Personal/PantryRescueQueue/.forge/evidence/core_loop.rescue_action.md`
  - `/Users/matvii/Developer/Personal/PantryRescueQueue/.forge/evidence/memory.duplicate_caution.md`
  - `/Users/matvii/Developer/Personal/PantryRescueQueue/.forge/evidence/progress.weekly_recap.md`
  - `/Users/matvii/Developer/Personal/PantryRescueQueue/.forge/evidence/money.deferred_boundary.md`
- Native UI source checked for provenance of visible surfaces:
  - `/Users/matvii/Developer/Personal/PantryRescueQueue/PantryRescueQueue/Features/Home/HomeView.swift`
  - `/Users/matvii/Developer/Personal/PantryRescueQueue/PantryRescueQueue/Features/Home/HomeViewModel.swift`

## 2. Screenshot packet status

Required by `design-assessment-loop.md`:

- First-use / activation screen: PRESENT via current screenshot.
- Core-loop after one meaningful action: NOT PRESENT as a screenshot in this packet.
- Returning-user / progress state: PARTIAL only. Accessibility hierarchy exposes offscreen progress/recap labels, but the current screenshot does not show a complete returning state.
- Money / deferred boundary: PRESENT as visible trust crumb and implementation evidence.

Current screenshot path:

`/Users/matvii/.hermes/media/pantry-rescue-current-screenshot.jpg`

The screenshot proves the app is visible and opens on a Pantry-specific rescue prompt, not on an account gate, scanner, paywall, metrics dashboard, or inventory table. It does not prove the full design loop because it captures the empty/first-use state only.

## 3. Visible labels from current screenshot

OCR/visual text recovered from `/Users/matvii/.hermes/media/pantry-rescue-current-screenshot.jpg`:

- `LOCAL PROOF • NO ACCOUNT • NO SCANNER • NO PAYMENTS`
- `What needs rescuing?`
- `spinach, yogurt, chicken...`
- `WHERE IS IT HIDING?`
- `fridge`
- `freezer`
- `pantry`
- `HOW URGENT DOES IT FEEL?`
- `tonight`
- `1-2 days`
- `this week`
- `not sure`
- `Put it in the rescue queue`
- `Not sure? Use "this week" and adjust later.`
- `The fridge is quiet. Add one thing if dinner feels uncertain.`
- `Nothing is yelling right now. Add one thing if dinner feels uncertain.`

Visible structure:

- A small uppercase local-proof crumb sits at the top.
- A large rounded prompt area acts as the Rescue Mouth.
- One large food text field is followed by location chips and urgency chips.
- A full-width primary CTA appears before empty-state copy.
- Below the mouth, empty-state/progress copy starts to appear.

## 4. Accessibility snapshot summary

Command used for the live simulator evidence:

`DEVELOPER_DIR=/Applications/Xcode-26.5.0.app/Contents/Developer xcodebuildmcp simulator snapshot-ui --simulator-id D7D2DE96-156E-4AD0-B19C-7FF8149A7031 --output json`

Key accessible labels and controls observed:

- Application label: `Pantry Rescue Queue - Dev`
- Static labels:
  - `LOCAL PROOF. NO ACCOUNT, SCANNER, OR PAYMENTS.`
  - `What needs rescuing?`
  - `WHERE IS IT HIDING?`
  - `HOW URGENT DOES IT FEEL?`
  - `Not sure? Use “this week” and adjust later.`
  - `The fridge is quiet. Add one thing if dinner feels uncertain.`
  - `Nothing is yelling right now. Add one thing if dinner feels uncertain.`
  - `Queue changed. 0 items remain at risk.`
  - `This week the fridge got quieter.`
  - `No rescues logged this week. Start with one thing that looks tired.`
  - `Next action: start with one thing that looks tired.`
  - `Local proof: your rescue queue stays on this device.`
  - `This proof does not include accounts, sync, scanner, OCR, receipt import, sharing, StoreKit, subscriptions, trials, or payments.`
- Text field:
  - label `Food to rescue`, value `spinach, yogurt, chicken...`
- Buttons:
  - `fridge`
  - `freezer`
  - `pantry`
  - `Tonight, urgent`
  - `1-2 days`
  - `this week`
  - `not sure`
  - `Put it in the rescue queue`

Accessibility verdict:

- The first-use controls have meaningful labels and minimum-size chip/button frames in the snapshot.
- The visible first-use hierarchy is app-specific: it names food rescue, hiding place, urgency, and queue insertion.
- The snapshot also reveals layout debt: progress/recap/trust content exists below the current viewport, while the captured screenshot only shows the empty activation state and duplicated empty-state copy.

## 5. Inspiration / provenance disclosure

Product sources used by the Pantry Rescue direction/spec:

- Apple App Store category/search and competitor listing evidence from `.forge/research/evidence-matrix.json` and `.forge/research/pantry-rescue-raw-evidence.json`.
- User-pain synthesis around duplicate purchases, expiry tracking, freezer/pantry visibility, add-flow friction, scanner/sync expectations, and public pricing/IAP visibility.
- Local Forge artifacts: `pantry-rescue-native-proof-spec.md`, `pantry-rescue-native-design-gate.md`, `pantry-rescue-activation-prototype.md`, and `pantry-rescue-money-path.md`.

Design references used:

- The local static design blueprint `docs/forge-vnext/artifacts/pantry-rescue-native-design-blueprint.html` and the design gate's own product-specific metaphor: a warm kitchen note / rescue station / quiet fridge path.
- No external UI screenshot pack, template marketplace design, or DayRateLab visual reference was used for this packet.

DayRateLab non-use statement:

- DayRateLab was not used as inspiration, baseline, naming source, UI pattern, fixture source, screenshot reference, or verifier assumption for the Pantry Rescue visual direction.
- DayRateLab remains a negative guardrail only: the design gate explicitly rejects DayRate-derived dashboard/card-shell reuse.
- Important honesty note: the parent verifier reported copied template residue in the generated app repository, including DayRate/public-launch residue in repo docs/scripts and disabled paywall/auth surfaces in source. That residue is not visible in the current Pantry Rescue screenshot, but it remains a strict-scope cleanup blocker outside this visual packet.

## 6. Design judge verdict

Verdict: `needs_repair_before_design_gate_pass`

Reason:

The current native proof is not a pure generic dashboard or token-reskinned DayRate screen. The first-use screenshot has app-specific Pantry Rescue semantics: Rescue Mouth, food entry, hiding-place chips, urgency choices, local-only boundary copy, and rescue-queue CTA. It also avoids the worst banned first screens: no metrics dashboard, inventory table, account gate, scanner prompt, paywall, tab scaffold, or onboarding carousel is visible.

But the available screenshot evidence is not sufficient to pass the visual design gate. It only shows the empty activation state. The packet lacks simulator screenshots for the post-add Rescue Lane, visible rescue verbs, action commit, duplicate caution slip, and returning weekly recap. The current viewport also shows duplicated empty-state language and pushes progress/recap/trust content below the fold, making the proof feel closer to a stacked card/form scaffold than the promised rescue lane + quiet fridge path.

Checklist:

- App-specific? PARTIAL YES. Strong Pantry Rescue copy and first-use structure are visible.
- Generic card dashboard? NO for the first viewport, but later sections risk generic rounded-card stacking.
- Token reskin? NOT PROVEN. The first-use Rescue Mouth would lose coherence if food/rescue concepts were removed, but full loop screenshots are missing.
- Emotional/taste direction? PARTIAL. Warm/local/rescue copy is present; tactile rescue-lane/caution-slip identity is not yet visible in screenshots.
- Design gate pass? NO. Needs visual evidence and UI specificity repairs.

## 7. Concrete repair cards

Actual child Kanban repair cards created:

1. `t_f1e32ef4` — Repair Pantry Rescue visual evidence sequence for design gate
   - Capture/link local screenshots for first-use Rescue Mouth, post-add Rescue Lane with immediate verbs, after-action queue/progress/caution state, and returning weekly recap.

2. `t_d1ccb686` — Repair Pantry Rescue native UI visual specificity
   - Remove duplicated empty-state copy, make progress/recap/caution less like generic rounded cards, ensure the triggered caution slip is visually distinct, and keep immediate rescue verbs visible in the post-add lane.

Suggested acceptance criteria for those repairs:

- A reviewer can see `Cook tonight`, `Freeze`, `Ignore this time`, and `Do not buy again` in a simulator screenshot without reading source.
- A screenshot proves that tapping a verb changes queue/progress state.
- A screenshot proves the duplicate caution prompt or accepted caution memory slip.
- A returning screenshot shows `This week the fridge got quieter.` with a prior action and a concrete next action, not just empty-state placeholder text.
- The first viewport contains one coherent empty/first-use message, not duplicate empty-state blocks.
- The visual rhythm clearly separates Rescue Mouth, Rescue Lane, Caution Slip, and Quiet Fridge/Weekly Recap for product reasons.

## 8. Human-facing action for Telegram/design gate

Do not ask Matvii for approval yet.

Send/attach this packet as a compact design-gate status only if needed, with the current screenshot path and verdict:

- Current screenshot: `/Users/matvii/.hermes/media/pantry-rescue-current-screenshot.jpg`
- Verdict: `needs_repair_before_design_gate_pass`
- Plain-English reason: first-use looks Pantry-specific and local-only, but the screenshot packet does not yet prove the core rescue loop, caution memory, or returning recap, and the current viewport still has scaffold-like empty/progress stacking.

Recommended next action:

Run the two repair cards, then re-run this visual packet after the repaired screenshot sequence exists.
