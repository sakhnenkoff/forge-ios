# Taste-first next proof app gate

Generated: 2026-05-26 11:15 CEST  
Task: `t_40554af0`  
Workspace: `/Users/matvii/Developer/Personal/forge-e2e-clean`  
Inputs: `docs/forge-vnext/forge-greatness-scorecard-charter.md`, `docs/forge-vnext/next-app-direction-research-gate.md`, refreshed public iTunes lookup probes on 2026-05-26.  
Safety: read-only public App Store/iTunes research and local markdown writing only. No native generation, no app repo, no App Store/TestFlight/signing/account/money/public action.

## Decision summary

Recommended direction: **Pet Care Relay**.

Taste-first reason: this is the only candidate where the first useful screenshot can feel emotionally specific instead of like a generic tracker. The proof app can open on a pet-specific daily relay: who needs care, what is due, what changed, and what is ready for the vet. That gives Forge a hard design contract before any Swift is generated.

Gate posture: **accept with tight taste/safety contract**.

Do not generate native yet. The downstream native-proof card should only proceed after Matvii accepts or repairs this direction gate.

## Taste gate question for Matvii

Choose one:

1. **ACCEPT — Pet Care Relay**  
   Build the next local proof around a local-first pet-care relay for owners with recurring meds/care/refills/appointments. The proof must start from the `Milo's Morning Relay` screenshot contract below, include no diagnosis/treatment advice, and exclude clinic integrations, chat, insurance, e-commerce, sync, payments, IAP, notifications requiring entitlements, or external sending.

2. **REPAIR — Keep Pet Care Relay, but repair taste before native**  
   Use this if the direction is strategically right but the first screenshot still sounds like a checklist, medical record, or generic pet dashboard. Repair means one design/product pass only: sharper emotional tone, first screenshot composition, copy, empty states, and safety boundary. Still no native generation.

3. **REJECT — Kill Pet Care Relay for this proof**  
   Use this if the medical-adjacent surface, pet category, sync/integration expectation, or indie wedge feels wrong. If rejected, the best alternate is **Closet Cost-Per-Wear Coach**, but it must be repaired around photo/AI expectations before native work.

Default if unanswered: block native generation.

## Recommendation: Pet Care Relay

### Product/taste choice

A local-first command center for anxious pet owners who need a daily handoff: what care is due today, what happened recently, and what should be ready for the next vet/groomer visit.

This should not feel like "tasks for pets." It should feel like a warm, calm relay board for a real animal whose routine can otherwise fall through cracks.

### Expected first screenshot

Title: `Milo's Morning Relay`

Visible above the fold:

- Pet identity card with name, age/species, and a calm status line: `2 things due before noon`.
- A tactile today rail with two large care cards: `Heartworm dose`, `Refill food by Friday`.
- One recent note card: `Limp looked better after short walk yesterday`.
- A `Vet packet is 70% ready` strip showing appointment date and missing pieces.
- Primary action: `Mark care done`; secondary action: `Add quick note`.
- Safety microcopy: `Track and prepare. Not medical advice.`

Immediate taste fail if the first screenshot is a generic list of reminders, a dashboard grid, a medical chart, or a clinic-booking clone.

### Evidence strength

Overall evidence strength: **medium-high for direction gate, low for launch claims**.

Public evidence refreshed via iTunes lookup on 2026-05-26:

- `PetDesk`: 4.858 rating, 480,261 ratings, updated 2026-04-15. Listing emphasizes appointments, reminders, messages/to-dos, providers, medication refills.
- `Digitail - Smarter Pet Care`: 4.901 rating, 2,790 ratings, updated 2026-05-06. Listing emphasizes digital medical record, sharing with vet, appointments, chat, day-to-day activities, refills.
- `Pet Care Tracker Dog Cat Log`: 4.824 rating, 921 ratings, updated 2026-05-18. Listing emphasizes pet schedules, daily reminders, health records, activity logs, vaccinations.
- Prior raw evidence found public DogCat IAP rows: monthly $4.49, yearly $39.99.

Strength interpretation:

- Strong: the category exists, recent competitors ship, and recurring reminders/records/vet-sharing are repeated product patterns.
- Medium: evidence is public listing/rating/pricing evidence, not review mining or interviews.
- Weak: no pet-owner interviews, no complaint language, no paywall conversion data, no proof that an indie local-only wedge beats clinic-network incumbents.

### Retention loop

- Trigger: morning/evening pet-care moment, refill date, appointment prep, symptom event.
- Action: complete/snooze a care item; add a quick note; update refill or appointment prep.
- Reward: today's relay clears; timeline becomes trustworthy; vet packet becomes less stressful.
- Return hook: next due care, next refill, weekly pet check, upcoming vet/groomer appointment.

This is credible because the loop is naturally recurring and emotionally reinforced: the user is not maintaining data for its own sake; they are reducing guilt and uncertainty around a living animal.

### Monetization believability

Believable later, not in the proof:

- Advanced multi-pet history.
- Recurring care templates.
- Vet/groomer packet export/print/share preview.
- Medication/refill history insights.
- Household handoff after sync is separately approved.

Evidence basis: DogCat has visible subscription IAP rows; adjacent competitors maintain updated pet health/care apps. Do not implement StoreKit, paywall, payments, IAP, account, or external export in the proof.

### Risks

- Medical-advice creep: the app must never recommend diagnosis, medication changes, or treatment.
- Integration gravity: clinic booking/chat/refill submission are obvious competitor patterns but out of scope.
- Sync expectation: household care is real, but sync/account infrastructure would expand the proof. Treat household handoff as future work.
- Generic UI risk: if the proof becomes checklists/cards/charts with pet labels, it fails the Forge taste bar.
- Privacy sensitivity: pet health notes are not human medical records, but they still need local-only/private copy.

### Native-proof contract if accepted

The first native proof must demonstrate only these local loops:

1. Add one pet.
2. Add one recurring care item.
3. Complete or snooze today's care card.
4. Add one quick note.
5. See a pet timeline update.
6. See a local vet-packet preview.
7. Show safety copy: tracking/prep only, no diagnosis/advice.

No other feature may be added to make the app look bigger.

## Alternative A: Closet Cost-Per-Wear Coach

### Product/taste choice

A wardrobe app for people who already own enough clothes but want to wear them better: log outfits, surface neglected pieces, and understand cost-per-wear without becoming an AI stylist fantasy.

### Expected first screenshot

Title: `Shop your closet this week`

Visible above the fold:

- A capsule rail with 20 manually added wardrobe items.
- Three outfit cards assembled from owned pieces.
- A `neglected but useful` card with one item and a nudge: `worn 1 time, works with 4 outfits`.
- A small cost-per-wear meter.
- Primary action: `Log today's outfit`.

### Evidence strength

Evidence strength: **medium**.

Refreshed public iTunes/App Store evidence:

- `Whering`: 4.673 rating, 10,123 ratings, updated 2026-04-27. Listing claims large free social styling/digital closet usage and emphasizes closet insights/inspiration.
- `Stylebook`: $4.99 upfront, 4.675 rating, 8,622 ratings, updated 2025-06-15. Listing emphasizes 90+ wardrobe features, outfit calendar, packing lists, wardrobe stats.
- `Acloset`: 4.360 rating, 3,932 ratings, updated 2026-05-22. Listing emphasizes digital wardrobe, photo item adding, AI stylist, spending habits.
- Prior raw evidence captured Acloset subscription tiers up to Premium/Expert yearly and Whering credit/supporter IAP rows.

### Retention loop

- Trigger: getting dressed, laundry reset, packing, shopping temptation.
- Action: log outfit, mark item worn, check neglected piece or capsule suggestion.
- Reward: less decision fatigue, visible wardrobe utilization, calmer shopping decisions.
- Return hook: next morning outfit, weekly capsule reset, trip packing.

### Monetization believability

Strongest monetization precedent of the three: paid upfront and subscription/IAP competitors exist. Plausible Pro boundary: unlimited closet, advanced stats, packing/capsule templates, export boards, optional photo cleanup/AI later.

### Risks / gate posture

Gate posture: **repair before native**.

Why not recommended: taste upside is high, but a first proof without real garment photos/background removal/AI could feel fake. If Forge uses placeholder garment tiles, the app may look like a generic grid and fail the first screenshot test. Repair this only if Matvii wants a more stylish/consumer direction and accepts a very narrow 20-item capsule proof.

## Alternative B: Maintenance Milepost

### Product/taste choice

A local-first older-car maintenance app that turns uncertainty into a next-due lane, service timeline, and mechanic conversation packet.

### Expected first screenshot

Title: `Before the next trip`

Visible above the fold:

- Vehicle card for one older car with odometer and confidence status.
- `Due soon` lane: oil, tires, registration.
- Last service receipt summary.
- `Mechanic packet` preview with recent work and questions.
- Primary action: `Log service` or `Update mileage`.

### Evidence strength

Evidence strength: **medium**.

Refreshed public iTunes/App Store evidence:

- `CARFAX Car Care`: 4.840 rating, 123,201 ratings, updated 2026-05-06. Listing emphasizes maintenance/repairs, reminders, service history, value, recall alerts.
- `Vehicle Maintenance Tracker`: 4.548 rating, 2,679 ratings, updated 2026-05-25. Listing emphasizes vehicle details, due dates, maintenance records, receipts, multi-vehicle history.
- `Fuelly`: 4.737 rating, 29,010 ratings, updated 2024-06-03. Listing emphasizes fuel economy, maintenance records, reminders, expenses, photo/PDF attachments.
- Prior raw evidence captured Fuelly IAP: annual $7.99, monthly $0.99.

### Retention loop

- Trigger: odometer update, service reminder, repair bill, pre-trip check.
- Action: log service, update mileage, reset due interval, enter receipt summary.
- Reward: next due work is clear; mechanic conversations and resale record improve.
- Return hook: mileage/date thresholds, mechanic visits, trip prep.

### Monetization believability

Believable but low ceiling. Future Pro could be multi-vehicle, PDF/resale report, receipt photo storage, cost trends, custom intervals. Public IAP precedent exists but at low price points.

### Risks / gate posture

Gate posture: **reject/park unless the goal is safe utility**.

Why not recommended: build feasibility is high, but taste risk is worst. It wants to become forms, tables, reminders, and receipt cards. Incumbents also own privileged data moats: CARFAX history, recalls, service shops, value estimates. Forge can build it, but it is least likely to prove greatness.

## Cross-candidate taste scorecard

| Dimension | Pet Care Relay | Closet Cost-Per-Wear | Maintenance Milepost |
|---|---:|---:|---:|
| First screenshot emotional specificity | 9 | 8 | 5 |
| Non-generic workflow shape | 8 | 7 | 5 |
| Evidence strength for direction gate | 8 | 7 | 7 |
| Retention loop credibility | 8 | 8 | 6 |
| Monetization believability | 7 | 8 | 5 |
| Native proof honesty without external systems | 8 | 5 | 9 |
| Safety/privacy/integration risk | 6 | 7 | 8 |
| Overall gate posture | ACCEPT | REPAIR | REJECT/PARK |

Interpretation:

- **Pet Care Relay** wins because it balances taste, repeated pain, local proof feasibility, and monetization evidence.
- **Closet Cost-Per-Wear** is the taste/monetization upside candidate, but likely needs photo/AI repair before it can feel real.
- **Maintenance Milepost** is the safe-build candidate, but too likely to become a generic utility.

## Hard fail checklist for downstream native proof

If Matvii accepts Pet Care Relay, any downstream product/design/native worker must hard-fail before generation if:

- The first screen is a generic checklist/dashboard rather than `Milo's Morning Relay` or an equivalent pet-specific relay surface.
- The feature list includes diagnosis, treatment advice, AI medical advice, clinic booking, vet chat, refill submission, insurance, e-commerce, sync/account, payments, IAP, public sharing, or external sending.
- The proof lacks a retention loop: due care -> completion/snooze -> timeline -> future prep.
- The proof lacks a local vet-packet preview.
- The app uses generic SaaS copy instead of warm, safety-conscious pet-owner language.
- The design/native lane tries to make the app look bigger by adding unrelated features.

## Final gate verdict

Verdict: **ask Matvii to ACCEPT / REPAIR / REJECT Pet Care Relay**.

Recommended answer: **ACCEPT Pet Care Relay with the screenshot/safety contract above**.

Next action if accepted: unblock the child native-proof pipeline card only with this gate attached. Native generation remains blocked until Matvii chooses accept or a reviewer explicitly unblocks with approval context.
