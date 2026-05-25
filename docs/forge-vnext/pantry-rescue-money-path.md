# Pantry Rescue Queue — Money Path / Pro Boundary Repair

Generated: 2026-05-25T18:23:11Z / 2026-05-25 20:23:11 CEST
Kanban task: `t_d39b995a`
Parent judge: `t_e91cbb17`
Status: local recommendation artifact only — no native app, no App Store/TestFlight/signing/IAP/payment action.

## Verdict

Recommendation: explicit monetization deferral.

Pantry Rescue Queue should not claim a passing money path yet. The local recommendation is:

1. Defer live monetization, price-point claims, StoreKit/IAP setup, App Store pricing copy, and any "launch candidate" monetization language.
2. Allow only a local, non-purchasable Pro-boundary prototype as a learning surface after the manual-rescue MVP is accepted.
3. Treat the money-path gate as `repair_required` until native/prototype evidence proves that the free first-use loop is useful before any upgrade pressure and that the Pro boundary increases repeat value without hiding the core rescue promise.

Concrete local-only Pro boundary to test later, not to sell now:

- Free/local proof value:
  - one solo household setup;
  - manual quick-add for fridge/freezer/pantry items;
  - current rescue queue with eat / freeze / cook / ignore / do-not-buy-again actions;
  - basic expiry urgency and one current weekly rescue recap;
  - local-only data, no account, no sync, no barcode, no OCR, no payments.
- Pro/local prototype value:
  - multiple named storage zones and saved filters;
  - recurring reminder templates by food type/location;
  - duplicate-buy memory and "do not buy again" history;
  - weekly/monthly waste-saved recap history;
  - export/share draft of rescue list as local text/CSV;
  - future shared-household concept screen only if clearly marked deferred.
- Never gate in the first proof:
  - the first useful rescue queue;
  - basic manual add;
  - expiry urgency;
  - marking an item rescued/ignored;
  - trust/privacy/local-only settings.

This is a deferral, not a kill. The direction can continue as a product repair candidate if the manual MVP passes activation/retention evidence. It should be killed or rescoped if the prototype shows that users only believe the product when scanner/OCR/sync/import exists.

## Why money path does not pass yet

Observed facts from local/public read-only inputs:

- `.forge/research/evidence-matrix.json` marks money path as not passing because public competitor pricing exists but in-app/logged-in paywall UX was not captured.
- `docs/forge-vnext/second-proof-app-direction-gate.md` scores money-path believability at 5 against a hard minimum of 6.
- Parent judge `t_e91cbb17` explicitly listed "no in-app/logged-in competitor paywall visual audit and no app-specific Pro boundary proof or Matvii-approved monetization deferral" as a blocker.
- `docs/forge-vnext/lanes/launch-learning-package.md` requires `pricing-draft.json` to either declare a monetization model with native paywall/upgrade-boundary evidence or explicitly declare `no_monetization_yet`; it also says screenshot plans need a monetization boundary/paywall screenshot if monetized.

Hypotheses, not proven facts:

- Users may pay for pantry rescue if it saves food waste and grocery duplicates.
- A solo-household user may accept manual add if the rescue payoff is immediate and calmer than inventory-table competitors.
- Duplicate-buy memory, recap history, and reminder templates may be credible Pro value.
- A local-only app may earn trust from privacy/offline positioning even without account sync.

These hypotheses are plausible enough to prototype but not strong enough to pass a product gate as monetization evidence.

## Competitor pricing and paywall limitations

Read-only sources used:

- Public App Store pages for Pantry Check, NoWaste, Cooklist, Panzy, and Pantry Manager.
- Public iTunes Lookup API for current listing metadata, ratings, descriptions, public price, and track URLs.
- Existing local evidence matrix `.forge/research/evidence-matrix.json` and direction gate notes.

Additional local recheck performed for this artifact:

- Public iTunes Lookup API request for app IDs `966702368,926211004,1352600944,6748056076,512026829`.
- Public App Store page HTML fetch for each app, searching for the public "In-App Purchases" section.
- No app install, account, purchase, logged-in flow, StoreKit action, App Store Connect action, TestFlight action, or payment action.

| Competitor | Observed public pricing / IAP facts | Observed public positioning facts | Paywall limitation | Implication for Pantry Rescue Queue |
|---|---|---|---|---|
| Pantry Check - Grocery List | Free listing. Public App Store page exposes IAP: Premium 2,000 items at `$1.99`, `$7.99`, `$9.49`, `$11.99`; Pro 10,000 items at `$4.99`, `$14.99`, `$19.99`, `$29.99`. iTunes Lookup returns `formattedPrice: Free`, rating about `4.51`, `1534` ratings. | Public description emphasizes barcode scanner, real-time sync/family sharing, automatic expiration reminders, smart shopping lists, custom locations, prices/totals, inventory, usage timeline, cloud database, and tracking up to 200 items free. | Only public IAP labels/prices and listing copy were observed. No in-app paywall order, upgrade trigger, purchase screen, trial terms beyond listing metadata, or visual paywall UX was audited. | Competitor anchors users around scale limits and scanner/sync. Pantry Rescue should not monetize by pretending to match scanner/sync; if tested, gate Pro around rescue-history depth and reminder intelligence after free value. |
| NoWaste: Food Inventory List | Free listing. Public App Store page exposes IAP: NoWaste Pro Annual `$6.99`, NoWaste Pro Lifetime `$29.99`. iTunes description also states annual Pro subscription at `$6.99/year`. Lookup returns rating about `4.16`, `744` ratings. | Public description says Pro scanner, unlimited inventory lists beyond 6 free lists, and storage expansion from 500 to 5000 items. It also emphasizes barcode/receipt/photo adding, sync, AI assistant, sorting/filtering, shopping, and meal planning. | Public listing reveals Pro feature copy, but not the in-app timing, pressure, layout, cancellation/trial UX, or actual paywall visuals. | Clear precedent for freemium limits around list count/storage/scanner. Pantry Rescue should avoid a storage-count-only Pro boundary because that would drag it back into inventory software. |
| Cooklist: Pantry Meals Recipes | Free listing. Public App Store page exposes IAP: Cooklist Pro Monthly `$5.99`, `$7.99`, `$9.99`; Cooklist Pro Yearly `$49.99`, `$59.99`; yearly access `$59.99`. Lookup returns rating about `4.73`, `11134` ratings. | Public description focuses on grocery loyalty-card import, automatic purchase import, receipt storage, recipes, meal planning, shopping list/cart generation, household sharing, cloud backup, and expiration notifications. | Public IAP prices and feature claims were visible, but no in-app paywall or purchase path was opened. | Cooklist is adjacent rather than direct. It proves willingness to expose subscription pricing in the broader pantry/meal-planning category, but it also raises automation expectations Pantry Rescue cannot claim in this proof. |
| Pantry Inventory - Panzy | Free listing. Public App Store page exposes IAP: Monthly `$3.99`, Yearly `$12.99`/`$14.99`, Lifetime `$24.99`. Lookup returns rating about `4.60`, `89` ratings. | Public description says Panzy+ unlocks unlimited pantry items, auto shopping list, sync across devices, and no ads; listing also emphasizes barcode scanner, iCloud sync, reminders, pantry/fridge/freezer organization, and a 7-day free trial on yearly. | Public page gives IAP names/prices and feature copy, but not in-app paywall sequencing, trial screen, or paid conversion evidence. | A small entrant can monetize pantry utility, but its paid boundary still leans on unlimited items/sync/no ads. Pantry Rescue should test whether rescue outcomes can be the boundary instead of generic item limits. |
| Pantry Manager | Paid upfront `$3.99` listing. Public App Store page exposes IAP: Sync Photos `$0.99`. Lookup returns rating about `3.59`, `82` ratings. | Public description emphasizes household item management, expiration reminders, shopping list from owned items, optional barcode add, cloud sync, local photos, CSV export, custom categories/stores/locations/tags, and Apple Watch. | Paid listing plus one IAP is public, but no current in-app purchase screen or paid-user conversion evidence was observed. | Manual-first/upfront paid precedent exists, but modest rating and broad inventory scope suggest an upfront paid proof would be risky without strong native value evidence. |

Synthesis:

- Observed fact: Pantry/food-inventory apps use free + IAP/subscription/lifetime/upfront models in public listings.
- Observed fact: Public Pro boundaries commonly include scanner access, storage/item/list limits, sync, auto shopping lists, no ads, cloud/family features, export/photos.
- Observed limitation: Public App Store pages are not equivalent to in-app paywall UX audits. They do not prove conversion, upgrade timing, trial comprehension, or whether paywalls harm activation.
- Hypothesis: Pantry Rescue Queue can differentiate by making Pro about rescue intelligence/history rather than raw inventory capacity, but this has not been proven.

## Required evidence before money claims can pass hard minimums

Money-path believability can pass only after the following local/prototype/native evidence exists and is accepted by a judge:

1. Activation-before-upgrade proof
   - Evidence: prototype/native video or timed walkthrough showing one manual item becoming a useful rescue queue entry in under 30 seconds.
   - Required result: no upgrade surface appears before the user sees useful rescue value.
   - Gate reason: if free activation is not useful, any Pro boundary is coercive or premature.

2. Returning-user proof
   - Evidence: prototype/native screen set for day-2/week-2 state: queue changed, item rescued/expired/ignored, weekly recap updated, duplicate-buy memory visible.
   - Required result: Pro features attach to repeated value, not initial setup friction.
   - Gate reason: money path depends on repeat utility, not one-time novelty.

3. Local Pro-boundary screenshot/prototype
   - Evidence: local non-purchasable paywall/upgrade-boundary screen and at least one contextual upgrade trigger.
   - Required result: screen clearly says local prototype / no purchase; separates Free vs Pro value; no StoreKit/product IDs/prices unless explicitly local draft placeholders.
   - Gate reason: the product gate must see what is being gated, not just read monetization prose.

4. Claim-to-evidence pricing draft
   - Evidence: local `.forge/launch/pricing-draft.json` or equivalent draft with `recommendedModel: no_monetization_yet` until the above evidence exists.
   - Required result: every price/pro/upgrade claim maps to competitor evidence or is marked hypothesis/unsupported.
   - Gate reason: launch-learning lane requires explicit pricing artifacts and evidence-linked claims.

5. Paywall harm check
   - Evidence: side-by-side prototype path with no upgrade prompt during first-use vs contextual upgrade after repeat value.
   - Required result: judge confirms upgrade prompt does not block activation, does not hide essential rescue function, and does not make the app feel like a generic inventory upsell.
   - Gate reason: monetization cannot pass by damaging the product/taste gate.

6. Matvii approval or explicit deferral decision
   - Evidence: human decision after judge audit: accept local Pro-boundary test, keep monetization deferred, repair again, or kill/rescope.
   - Required result: no native generation or launch package claims should treat monetization as approved before this decision.

## Local launch and copy implications while monetization is deferred

Allowed local launch/copy posture:

- Positioning: "Rescue what is about to go bad before you buy more."
- Promise: local, manual, fast rescue queue for expiring food.
- Trust copy: local-only proof, no account, no sync, no barcode/OCR claims, no payment.
- Upgrade copy: either absent or explicitly marked as a local prototype concept.
- Pricing draft: `recommendedModel: no_monetization_yet` with competitor-informed future options.
- Screenshot plan: include monetization boundary only as `missing/blocked` or `prototype_only`; do not call it launch-ready.
- ASC/local copy: avoid "Pro", "subscription", "premium", "trial", "purchase", or price claims unless the section is clearly a future concept and not live launch copy.

Recommended wording while deferred:

- Good: "First prove the rescue loop: add one item, see what to do tonight, and remember what not to buy again."
- Good: "Local proof only. Barcode, OCR, sync, family sharing, and purchases are intentionally out of scope."
- Good: "Future Pro candidates: deeper rescue history, smarter duplicate-buy memory, reminder templates, and exports — pending evidence."
- Bad: "Upgrade to Pro for unlimited pantry management."
- Bad: "Save money automatically with smart scanning."
- Bad: "Family sync and receipt import are coming soon."

If launch package artifacts are generated before money evidence improves, their status should be:

- `pricing-draft.json`: drafted / repair_required, `recommendedModel: no_monetization_yet`.
- `copy-draft.md`: monetization claims marked unsupported or omitted.
- `screenshot-plan.json`: money-boundary screenshot status `blocked_missing_input` or `prototype_only`.
- `launch-package.json`: launch readiness `repair_required`, blocking reason includes "Monetization deferred; no native/local Pro-boundary evidence accepted."

## Gate decision

Current gate state: repair_required.

Pantry Rescue Queue is allowed to continue only as a local product repair candidate. The next honest money-path task is not StoreKit or pricing setup; it is a local prototype/judge task that tests whether a non-purchasable Pro boundary can be shown without weakening first-use rescue value.

Until that evidence exists, the product should proceed with explicit monetization deferral, not a concrete paid launch claim.
