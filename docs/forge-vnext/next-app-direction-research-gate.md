# Forge vNext next-app direction research gate

Generated: 2026-05-26 05:59 CEST  
Task: `t_af23dabc`  
Raw evidence: `docs/forge-vnext/next-app-direction-research-raw-evidence.json`  
Inputs: `docs/forge-vnext/persistent-orchestrator-charter.md`, `docs/forge-vnext-charter.md`, parent capability inventory `docs/forge-vnext/app-direction-research-capability-inventory.md`

## Safety receipt

This research used only read-only public App Store/iTunes data and local document writing.

Actions not taken:

- no native iOS generation;
- no generated app repo creation;
- no app installation;
- no logged-in competitor account use;
- no public posting/mutation;
- no money, IAP, StoreKit, paid service, credential, account, signing, App Store Connect, TestFlight, bundle ID, or work-system action.

Native generation remains blocked. This artifact is meant to feed a skeptical `forgejudge` audit and, if it survives, a real Matvii product/taste decision.

## Research method

Available/verified source paths from the parent inventory were used as follows:

1. Public App Store search via `https://itunes.apple.com/search?entity=software&country=us` for search-density proxies.
2. Public iTunes lookup via `https://itunes.apple.com/lookup?id=...&country=us&entity=software` for listing metadata, descriptions, ratings, update recency, prices, seller URLs, screenshots, and advisory flags.
3. Logged-out public `apps.apple.com` page text extraction for visible IAP/pricing snippets where available.

Explicit source limitations:

- Search `resultCount` is returned-result count, not true search volume.
- Ratings/review counts are demand/popularity proxies, not proof of pain or willingness to pay.
- Public App Store HTML exposes some IAP rows, but not the real in-app paywall experience.
- No Reddit/X/community review mining was performed because first-class access is missing or disabled; these remain evidence gaps.
- No work-system/private signals were used.

## Candidate summary

### Recommendation

Continue with Candidate A: `Pet Care Relay`.

Working gate question for Matvii after judge audit:

> Do you accept a local-first, no-diagnosis pet care relay MVP whose proof app focuses on recurring care, medication/refill reminders, appointment prep, and a vet-shareable timeline, with clinic integrations, chat, insurance, e-commerce, AI advice, and live health recommendations explicitly excluded?

Why this is the strongest direction:

- It has the best combination of painful emotional stakes, repeat use, feasible local-native proof, and monetization precedent.
- It avoids competing head-on with clinic networks by owning the “what do I need to do for this pet today, and what should I tell the vet?” loop.
- The first proof can be honestly local-only: add pet, add care item, complete today, see timeline, prepare visit packet.
- Safety boundaries are crisp: no diagnosis, no treatment recommendation, no vet replacement.

Recommended next action: `continue_for_judge_then_matvii_gate`, not native generation.

## Search-density probes

These probes are not demand proof by themselves; they only show that public App Store categories exist with rating volume.

| Query | Returned results | Top-10 rating-count sum | Interpretation |
|---|---:|---:|---|
| `pet care tracker` | 48 | 494,038 | Strong category presence; dominated by PetDesk but includes indie tracker apps. |
| `pet medication reminder` | 49 | 709,685 | Strong reminder-app demand but polluted by human medication apps; pet-specific signal is weaker. |
| `car maintenance` | 46 | 156,278 | Mature utility category with large incumbent and indie trackers. |
| `vehicle maintenance log` | 47 | 156,026 | Similar signal; clear repeat-use utility. |
| `wardrobe outfit planner` | 46 | 66,792 | Active category with paid/subscription and AI styling competitors. |
| `closet outfit planner` | 49 | 29,185 | Same category; lower query-volume proxy but still meaningful. |

## Evidence matrix

| Evidence ID | Candidate | Source(s) | Evidence type | Signal | Confidence | Limitation |
|---|---|---|---|---|---|---|
| E-PET-SEARCH-001 | Pet Care Relay | iTunes search `pet care tracker`, `pet medication reminder` | Search/category density proxy | 48/49 returned results; large rating volume around pet care and reminders. | Medium | `pet medication reminder` mixes human med apps; ratings are proxy only. |
| E-PET-COMP-002 | Pet Care Relay | PetDesk, Digitail, DogCat App public listings | Competitor/listing copy | App Store listings emphasize appointments, reminders, to-dos, records, refills, activity tracking, vet sharing. | High for category existence; medium for indie wedge. | Big clinic-network products may not validate a standalone indie app. |
| E-PET-MONEY-003 | Pet Care Relay | DogCat public App Store page | Pricing/IAP | DogCat Plus Monthly $4.49 and Yearly $39.99 visible publicly; pet-care utilities monetize. | Medium | No paywall screenshots or conversion data. |
| E-PET-SAFETY-004 | Pet Care Relay | App Store advisories on DogCat/Digitail | Safety/risk | Medical/treatment information is present in category; proof must avoid advice/diagnosis. | High | Regulatory/medical-advice risk remains if scope creeps. |
| E-CAR-SEARCH-001 | Maintenance Milepost | iTunes search `car maintenance`, `vehicle maintenance log` | Search/category density proxy | 46/47 returned results; top-10 rating-count sums around 156k. | Medium | Demand may belong to large incumbents and ad/sync ecosystems. |
| E-CAR-COMP-002 | Maintenance Milepost | CARFAX, Vehicle Maintenance Tracker, Fuelly listings | Competitor/listing copy | Repeated feature patterns: service history, reminders, mileage/fuel, receipts, recall alerts, cost estimates. | High for pain/category. | CARFAX has privileged vehicle-history/recall/shop data; an indie proof cannot replicate that. |
| E-CAR-MONEY-003 | Maintenance Milepost | Fuelly public App Store page | Pricing/IAP | Fuelly Premium Annual $7.99 and Monthly $0.99 visible publicly. | Medium | Low price ceiling; utility may be ad-supported or commoditized. |
| E-CLOSET-SEARCH-001 | Closet Cost-Per-Wear Coach | iTunes search `wardrobe outfit planner`, `closet outfit planner` | Search/category density proxy | 46/49 returned results; meaningful ratings across digital closet/outfit apps. | Medium | Strong fashion categories do not prove cost-per-wear beachhead. |
| E-CLOSET-COMP-002 | Closet Cost-Per-Wear Coach | Whering, Stylebook, Acloset listings | Competitor/listing copy | Listings emphasize digital closet, outfit ideas, calendar, packing lists, wardrobe stats, shopping sense-check, AI stylist. | High for category. | Competitors set high photo/AI/social expectations. |
| E-CLOSET-MONEY-003 | Closet Cost-Per-Wear Coach | Stylebook, Whering, Acloset public pages | Pricing/IAP | Stylebook is $4.99 upfront; Whering and Acloset expose public IAP/subscription/credit tiers. | Medium-high | Paid willingness may attach to advanced AI/photo workflows, not manual MVP. |
| E-ACCESS-GAPS-001 | All | Parent capability inventory | Access limitation | Reddit/X/social review mining unavailable or substitute-only; no App Store scraper installed. | High | Judge should not treat this as fully triangulated market research. |

## Candidate A — Pet Care Relay

### One-line direction

A local-first pet-care command center for anxious pet owners who need a reliable daily relay: what care is due today, what happened recently, and what should be ready for the next vet/groomer visit.

### Target user

Primary beachhead: a solo or couple pet owner with one to three pets, recurring meds/supplements/flea-tick tasks, vaccinations, appointments, and occasional symptom notes who currently scatters care across memory, calendar reminders, vet emails, and paper records.

Excluded users/use cases:

- veterinarians and clinic staff;
- users needing clinic booking integration on day one;
- users needing diagnosis, treatment recommendations, telehealth, insurance, payments, e-commerce, or live prescription refill submission;
- users who require family/cloud sync for the first local proof to feel honest.

### Painful problem

“I love this animal, but I keep losing the thread: did we give the meds, when is the refill due, what changed before the vet visit, and what do I need to ask?”

Cost of doing nothing: missed or double-handled routine care, stressful vet visits, poor recall of symptoms, guilt, and friction when multiple people help with the animal.

### Repeat-use loop

- Trigger: morning/evening pet-care moment, refill date, appointment, symptom event.
- Action: complete or snooze a care card; add a quick note/photo-free symptom log; mark refill/appointment prep.
- Reward: today’s relay clears; pet timeline becomes more useful; next vet packet is automatically less stressful.
- Next trigger: next dose/care reminder, weekly pet health check, or upcoming appointment.

### Monetization believability

Public evidence:

- DogCat App exposes public IAP: DogCat Plus Monthly $4.49 and Yearly $39.99.
- Category competitors maintain updated apps with health records, reminders, appointments, refill requests, and pet activity logs.

Believable future local-only Pro boundary, not for the first proof:

- multi-pet advanced history;
- printable/shareable vet packet;
- recurring care templates;
- medication/refill history analytics;
- household handoff notes after sync is separately approved.

No live monetization, StoreKit, IAP, payment, or price-point implementation is approved by this gate.

### Evidence sources

- Pet Care Tracker Dog Cat Log: `https://apps.apple.com/us/app/pet-care-tracker-dog-cat-log/id1551003273`
- PetDesk: `https://apps.apple.com/us/app/petdesk/id631377773`
- Digitail - Smarter Pet Care: `https://apps.apple.com/us/app/digitail-smarter-pet-care/id1473042508`
- iTunes search probes: `pet care tracker`, `pet medication reminder`

### Scores for direction gate

| Dimension | Score | Hard-min status | Rationale |
|---|---:|---|---|
| Pain/problem clarity | 8 | pass | Repeated competitor patterns around reminders, records, appointments, refills, activity tracking. |
| Target user sharpness | 8 | pass | Pet owner with recurring care and vet-prep anxiety is concrete and emotionally legible. |
| Repeat-use loop | 8 | pass | Daily/weekly care and appointment prep create natural recurrence. |
| Monetization believability | 7 | pass-with-gap | Public DogCat subscription rows support willingness, but no paywall/user conversion evidence. |
| Native proof feasibility | 8 | pass | Local reminders/timeline/checklist/visit packet can be built without network or accounts. |
| Product/taste distinctiveness | 8 | pass | “Relay” and “vet packet” can avoid generic task dashboard if designed around pet state and handoff. |
| Evidence integrity | 7 | pass-for-judge | Public App Store evidence is adequate for a human gate, not launch claims. |

### Recommendation

`continue_for_judge_then_matvii_gate`.

Do not generate native yet. Judge should approve only if the no-diagnosis boundary and local-only proof scope are crisp enough.

### Evidence gaps / repair points

- No public review-text mining yet; need complaint themes before launch claims.
- No Reddit/forum/community triangulation; first-class access missing.
- No vet/pet-owner interview evidence.
- Need decide whether family sync is mandatory for credibility. Recommendation: not mandatory for proof; mark as deferred.
- Need medical-safety copy gate: “track and prepare, never diagnose or advise treatment.”

## Candidate B — Maintenance Milepost

### One-line direction

A local-first vehicle maintenance app that turns “I should probably deal with the car” into a mileage/date-based next-due lane, receipt timeline, and cost memory for one older vehicle.

### Target user

Primary beachhead: owner of a 5+ year-old car who does not have dealership app trust, wants to avoid missed oil/tire/brake/battery maintenance, and needs a simple record for resale or mechanic conversations.

Excluded users/use cases:

- fleet managers;
- users needing VIN decoding, CARFAX history, shop booking, recall databases, insurance, payments, or live parts/service estimates;
- enthusiast tuning/logbook users.

### Painful problem

“I know maintenance matters, but I don’t remember what was done, what is due next, and whether this mechanic bill is part of a pattern.”

Cost of doing nothing: missed service, larger repairs, poor resale documentation, repeated uncertainty at the mechanic.

### Repeat-use loop

- Trigger: odometer update, service reminder, repair bill, pre-trip check.
- Action: log service, attach/enter receipt summary, reset due interval, update mileage.
- Reward: next-due lane is clear; maintenance timeline and annual cost estimate become more trustworthy.
- Next trigger: mileage/date threshold or mechanic visit.

### Monetization believability

Public evidence:

- Fuelly exposes public IAP: Premium Annual $7.99 and Monthly $0.99.
- Vehicle Maintenance Tracker and CARFAX listings validate maintenance records, reminders, receipts, and mileage/fuel tracking as established utility patterns.

Believable future Pro boundary:

- multiple vehicles;
- PDF export/resale report;
- receipt photo storage after privacy review;
- advanced cost trends;
- custom interval templates.

### Evidence sources

- CARFAX Car Care: `https://apps.apple.com/us/app/carfax-car-care/id552472249`
- Vehicle Maintenance Tracker: `https://apps.apple.com/us/app/vehicle-maintenance-tracker/id1315913699`
- Fuelly: `https://apps.apple.com/us/app/fuelly-mpg-service-tracker/id295905460`
- iTunes search probes: `car maintenance`, `vehicle maintenance log`

### Scores for direction gate

| Dimension | Score | Hard-min status | Rationale |
|---|---:|---|---|
| Pain/problem clarity | 8 | pass | Maintenance/reminder/receipt/history patterns are consistent across competitors. |
| Target user sharpness | 7 | pass | Older-car owner is clear, but could be too broad without a stronger beachhead. |
| Repeat-use loop | 7 | pass | Mileage/date/service cycles recur, though less frequently than pet care. |
| Monetization believability | 6 | pass-with-gap | Fuelly IAP exists but low ceiling suggests commodity utility. |
| Native proof feasibility | 9 | pass | Local mileage intervals, logs, and receipt summaries are straightforward. |
| Product/taste distinctiveness | 6 | repair | Risk of becoming a generic forms-and-reminders app. Needs a stronger visual/workflow concept. |
| Evidence integrity | 7 | pass-for-judge | Public evidence is solid for category, weaker for indie differentiation. |

### Recommendation

`repair_before_matvii_gate`.

This is feasible and useful, but too utilitarian unless Forge finds a distinctive taste angle. A good repair would be “pre-trip confidence lane” or “mechanic conversation packet” rather than another vehicle log.

### Evidence gaps / repair points

- No app review pain mining; need complaints about existing maintenance apps.
- Need avoid CARFAX’s unavailable data moat: recalls, shops, vehicle value, official history.
- Need a taste/design wedge before native proof.
- Need verify whether users will pay for local-only car records when free incumbents exist.

## Candidate C — Closet Cost-Per-Wear Coach

### One-line direction

A local-first wardrobe app that helps a user wear what they already own by logging outfits, surfacing neglected pieces, and showing cost-per-wear / packing / capsule decisions without starting from an AI stylist fantasy.

### Target user

Primary beachhead: style-conscious but overwhelmed clothing owner who buys repeats, forgets underused pieces, struggles to pack or plan outfits, and wants a practical “shop my closet” loop.

Excluded users/use cases:

- fashion influencers needing social/community reach;
- users needing AI try-on, body modeling, automatic background removal, marketplace shopping, or social styling for first proof;
- users unwilling to manually add a small starter closet.

### Painful problem

“I own enough clothes, but I still feel like I have nothing to wear, I repeat the same safe outfits, and I cannot see what is worth keeping/buying.”

Cost of doing nothing: wasted purchases, underused wardrobe, morning decision fatigue, bad packing, and poor relationship with clothes.

### Repeat-use loop

- Trigger: getting dressed, laundry/reset day, trip packing, shopping temptation.
- Action: choose/log outfit; mark worn; see underworn piece suggestion or cost-per-wear nudge; build capsule/packing set.
- Reward: cost-per-wear improves, forgotten pieces re-enter rotation, shopping decisions become calmer.
- Next trigger: next morning outfit or shopping/packing moment.

### Monetization believability

Public evidence:

- Stylebook is paid upfront at $4.99.
- Whering exposes public IAP/credit/supporter rows including credits and supporter tiers.
- Acloset exposes subscriptions: Basic Monthly $3.99, Premium Monthly $9.99, Basic Yearly $27.99, Premium Yearly $59.99, Expert Monthly $24.99, Expert Yearly $147.99, plus beans purchases.

Believable future Pro boundary:

- unlimited closet size;
- advanced stats/cost-per-wear;
- packing/capsule templates;
- export/share boards;
- optional AI/photo cleanup only after approval.

### Evidence sources

- Whering: `https://apps.apple.com/us/app/whering-your-digital-closet/id1519461680`
- Stylebook: `https://apps.apple.com/us/app/stylebook/id335709058`
- Acloset: `https://apps.apple.com/us/app/acloset-ai-fashion-assistant/id1542311809`
- iTunes search probes: `wardrobe outfit planner`, `closet outfit planner`

### Scores for direction gate

| Dimension | Score | Hard-min status | Rationale |
|---|---:|---|---|
| Pain/problem clarity | 7 | pass | Category validates closet organization/outfit/stats pain, but cost-per-wear beachhead is inferred. |
| Target user sharpness | 7 | pass | Style-conscious “shop my closet” user is understandable but needs interview/review proof. |
| Repeat-use loop | 8 | pass | Getting dressed is daily; packing/shopping are reinforcing loops. |
| Monetization believability | 8 | pass | Paid upfront and subscription/IAP competitors are visible publicly. |
| Native proof feasibility | 6 | repair | Manual small closet works, but category expectation heavily favors photos/AI/background removal. |
| Product/taste distinctiveness | 8 | pass | Strong design potential if focused on wardrobe insight rather than generic grid. |
| Evidence integrity | 7 | pass-for-judge | Public evidence supports category; specific wedge needs more proof. |

### Recommendation

`repair_before_matvii_gate`.

This has the highest design/monetization upside, but the first proof risks feeling fake without photos or AI. Repair by narrowing to a 20-item capsule/cost-per-wear proof with manually entered placeholder garments and an explicit “no AI stylist yet” boundary.

### Evidence gaps / repair points

- Need review mining around manual item entry, photo cleanup, AI trust, and wardrobe stats.
- Need decide whether a proof without real garment photos passes taste bar.
- Need avoid accidentally building another generic grid/calendar/list app.
- Need privacy posture for clothing photos if later added.

## Cross-candidate scorecard

| Dimension | Pet Care Relay | Maintenance Milepost | Closet Cost-Per-Wear Coach |
|---|---:|---:|---:|
| Pain/problem clarity | 8 | 8 | 7 |
| Target user sharpness | 8 | 7 | 7 |
| Repeat-use loop | 8 | 7 | 8 |
| Monetization believability | 7 | 6 | 8 |
| Native proof feasibility | 8 | 9 | 6 |
| Product/taste distinctiveness | 8 | 6 | 8 |
| Evidence integrity | 7 | 7 | 7 |
| Direction-gate posture | continue | repair | repair |

Interpretation:

- `Pet Care Relay` is the best balance: strong enough to ask a concrete human decision after judge audit, and feasible to prove locally without external systems.
- `Maintenance Milepost` is the safest build but weakest taste/product differentiation.
- `Closet Cost-Per-Wear Coach` has the strongest monetization/design upside but needs repair around photo/AI expectations before it is honest.

## Recommended direction packet for forgejudge

Chosen direction: `Pet Care Relay`.

Proposed exact judge question:

- Is the public evidence, safety boundary, repeat loop, and local proof scope strong enough to ask Matvii whether to continue with Pet Care Relay as the next proof app direction?

Proposed exact Matvii decision if judge approves:

- Accept or reject a local-first pet-care relay MVP focused on recurring care, medication/refill reminders, appointment prep, and vet-shareable timeline, with no diagnosis/advice and no clinic/chat/e-commerce/sync/integration/payment features in the proof.

Native generation would need to prove:

1. First-use activation: add pet and one recurring care item in under 60 seconds.
2. Daily relay: due care card can be completed/snoozed and updates the pet timeline.
3. Vet-prep packet: timeline condenses recent symptoms/care into a local share/export preview without sending anything externally.
4. Safety copy: the app never recommends treatment or diagnosis.
5. Distinctive app-specific surface: not a generic checklist dashboard.

Launch-candidate claims would still be blocked by:

- no user interviews or real pet-owner validation;
- no review-mined pain themes;
- no native screenshots/build/test evidence yet;
- no privacy review for pet health notes;
- no paywall/monetization proof;
- no notification reliability proof;
- no sync/household handoff decision.

## Final gate verdict

Verdict: `continue_with_pet_care_relay_for_skeptical_audit`.

Confidence: medium-high for a human direction gate; low for launch claims; native generation still disallowed.

Why not a stronger confidence:

- App Store public evidence triangulates category existence and monetization precedent, but not first-party user pain.
- Missing Reddit/X/community/review-text mining means the language of pain is inferred from competitor listing copy.
- The recommended direction has health-adjacent safety risk that must be constrained before design/native work.

Next allowed actions:

1. `forgejudge` skeptically audits this artifact plus raw evidence JSON.
2. If judge approves, prepare a compact Matvii approval packet with the exact Pet Care Relay decision.
3. If Matvii accepts, create product/design gate artifacts before native generation.
4. Do not generate Swift, app repo, StoreKit, notifications requiring entitlements, external integrations, or launch assets until the gate passes.
