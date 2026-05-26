# Forge visual excellence research and judge layer

Generated: 2026-05-26
Task: `t_282054bb`
Workspace: `/Users/matvii/Developer/Personal/forge-e2e-clean`
Status: research + operating proposal before any next native proof app is accepted.
Safety: read-only public web/App Store/GitHub research and local markdown writing only. No paid-service signups, no credential actions, no public posting, no native app generation.

## 0. Executive verdict

The Pantry feedback is a hard design-system failure: Forge currently proves that an app exists, but not that it has taste. The missing layer is not more polish. It is a repeatable visual evidence and judgment loop that forces agents to:

1. gather category-specific and general high-quality visual references;
2. synthesize a new product-specific visual language instead of copying screenshots or reskinning tokens;
3. build a local prototype/design contract before native work;
4. capture native screenshots for activation, core loop, returning-progress state, empty/error, and money boundary;
5. run a visual judge that can say `hard_fail_ai_slop` before Matvii sees it;
6. create repair cards until the screenshots pass, or kill/park the app direction.

This layer should become a required gate between direction approval and native expansion, and again between native screenshot evidence and human review.

## 1. Research constraints and caveats

- X/Twitter search was attempted through the local `search-x` skill, but `XAI_API_KEY` is not configured. Browser-based X search redirected to login. I did not log in, mutate accounts, or bypass the wall.
- Public discourse evidence below therefore uses public blogs and Hacker News/Show HN search results, plus the observation that Forge needs a future X/search path if Matvii wants X as a required input.
- The App Store references below came from Apple public iTunes Search API metadata and screenshot URLs. Treat these as research/provenance links, not assets to copy into generated apps.
- Vision tool analysis failed in this run because the configured auxiliary vision request rejected its temperature parameter. The proposed pipeline should not rely on agent self-vision alone; it needs stored screenshots, accessibility snapshots, and a rubric/judge pass that can be retried by another worker.

## 2. What “AI slop” means for Forge

For Forge, “AI slop” is not merely ugly UI. It is a bundle of failure signals:

- Generic first screen: title + subtitle + rounded cards + CTA, with nouns swapped for the app category.
- Token reskin: colors/radii/fonts changed while workflow shape is unchanged.
- No product-specific surface: removing pet/food/car/etc. words leaves the same app.
- Screenshot mismatch: approved design metaphor exists in docs, but native screenshots show plain forms/lists.
- No lived-in state: empty dashboards, fake metrics, placeholder images, generic progress bars.
- Copy filler: “Track your progress”, “Stay organized”, “Get insights”, “Unlock Pro” without category-specific stakes.
- Feature inflation: app tries to look mature with tabs/settings/paywall before proving one sharp loop.
- Stale template residue: old sample-app docs/assets/paywalls/auth paths leaking into the new app.

A visual judge must be allowed to fail all of the above even if build/tests/verifier pass.

## 3. App and product reference findings

### 3.1 Category references for the current selected direction: Pet Care Relay

Public App Store/iTunes evidence confirms that pet-care apps exist, are active, and frequently center reminders, records, care tasks, vet contact, and household/clinic coordination. This is enough to define a category quality bar, but not enough to copy a UI.

| Reference | Public evidence | Useful visual/product signal | Forge borrow | Forge avoid |
| --- | --- | --- | --- | --- |
| PetDesk | App Store listing: rating ~4.858, ~480k ratings, updated 2026-04-15. Listing emphasizes appointments, reminders, messages/to-dos, providers, refills. Screenshot URLs available from iTunes API. | Incumbent trust and pet-profile/to-do structure. | Clear pet identity, due-care prominence, calm service trust. | Clinic-network/appointment/message gravity; generic provider portal feel. |
| Digitail - Smarter Pet Care | Rating ~4.901, ~2.8k ratings, updated 2026-05-06. Listing emphasizes digital medical record, vet sharing, appointments, chat, refills. | Medical-record/vet-packet expectations. | Vet packet as local prep artifact; safety copy. | Diagnosis/treatment advice, chat, online booking, external sharing. |
| Pet Care Tracker Dog Cat Log / DogCat | Rating ~4.824, ~921 ratings, updated 2026-05-18. Listing emphasizes schedules, reminders, records, activity logs, vaccination/health tracking. | Routine/task density and care-log completeness. | Recurring care item + completion/snooze + timeline loop. | Dense “ultimate tracker” sprawl; medical-dashboard aesthetics. |
| DogLog | Rating ~4.775, ~1.3k ratings, updated 2025-12-17. Listing emphasizes reduced stress, daily pet tasks, family coordination, puppy logs. | Household handoff and stress-reduction language. | Warm relay metaphor: “who needs care / what changed / what is ready.” | Sync/family scope before local proof approval. |
| GreatPetCare / PetPage / Thrive | Ratings visible; listings emphasize reminders, records, appointments, prescriptions/invoices. | The category’s default path is clinic utility. | Trust, care readiness, appointment prep. | Becoming a clinic app clone instead of an indie local-first relay. |

Pet Care Relay visual contract implication: first screenshot should not be “reminders for pets.” It should be a pet-specific morning/evening relay board for a named animal. The image should make the owner feel, “I know what Milo needs next and what changed since yesterday,” without medical-advice creep.

### 3.2 High-quality general iOS/product references

These are not category clones. They are taste references for craft, density, state, and product-specific composition.

| Reference | Public evidence | What it teaches Forge |
| --- | --- | --- |
| Flighty | App Store listing: Apple Design Award winner/finalist language, ~4.845 rating, ~131k ratings, updated 2026-04-29. | Product-specific visual language: a flight is not shown as generic rows, but as timeline/status, risk, and real-time confidence. Borrow “state-rich command surface,” not aviation aesthetics. |
| Crouton | App Store listing: recipe manager/meal planner, ~4.824 rating, ~2.7k ratings, updated 2026-04-20. | Warm utility and cooking-context surfaces. Borrow tactile cooking-session focus and low-friction capture; avoid recipe-app cloning. |
| Gentler Streak | App Store listing: Apple Design Award/Social Impact mention, ~4.713 rating, ~8.8k ratings, updated 2026-05-15. | Emotional stance matters: not another “do more” tracker. For pet care, the stance should be “calm relay, no guilt/medical panic.” |
| Linear | Public `linear.app/method` page. | Opinionated product craft, tight states, purposeful motion/density. Borrow decisiveness and coherent system, not developer-tool chrome. |
| Apple Human Interface Guidelines | Public Apple doc says the HIG contains guidance and best practices for great Apple-platform experiences. | Baseline native fit: hierarchy, accessibility, platform conventions, privacy/trust. HIG compliance is necessary but not sufficient for taste. |

## 4. Pattern libraries and third-party reference sources

Use these as inspiration/evidence sources, not as assets or UI to copy.

| Source | Current public signal | Use in Forge | Safety notes |
| --- | --- | --- | --- |
| Apple iTunes Search API / App Store public pages | Public app metadata, ratings, descriptions, screenshot URLs. | Category app discovery, screenshot URL provenance, competitor feature surface audit. | Store source URL, timestamp, app id, screenshot URL. Do not embed competitor art in generated app. |
| Apple HIG | Public platform design guidance. | Native fit rubric, accessibility and interaction baseline. | Cite guidance; do not overfit into bland native defaults. |
| Mobbin | Public homepage available; library may require account for deep access. | Visual pattern research if already accessible locally. | No paid/account action without approval; document access level. |
| Page Flows | Public homepage says 100,000+ recorded user flows/app screens/UI patterns. | Flow-level reference for onboarding, adding item, reminder completion, timeline/packet review. | Same: no account/payment action; cite pages/URLs, synthesize. |
| Nicelydone | Public homepage available. | Polished SaaS/product references for craft and hierarchy. | Better for general taste than iOS-native fidelity; avoid SaaS-card infection. |
| Refero | Public design-inspiration category, but `www.refero.design` DNS failed in this run. | Candidate future source if accessible. | Treat access failure as non-blocking; do not invent references. |
| DesignArena | Public site reachable; HN result describes it as a crowdsourced benchmark for AI-generated UI/UX. | Useful conceptually: visual preference/judging should compare outputs, not trust self-report. | Do not depend on live service unless explicitly approved. |

## 5. Blog/forum/discourse evidence

The discourse pattern is consistent: people are becoming more hostile to generic AI output and more interested in filters/benchmarks/judges that protect quality.

- Hacker News search for `AI slop` returned high-engagement public discussions including `AI slop is killing online communities` (~834 points, ~734 comments), Kagi `SlopStop` (~589 points, ~264 comments), and posts about AI slop/suspicion. The relevant lesson is not about UI directly; it is that audiences notice generated sameness, low-effort filler, and unearned confidence.
- Kagi’s public SlopStop announcement frames AI slop as search/community pollution and introduces community-driven detection. Forge should copy the posture: fail suspect output before it pollutes the human review queue.
- Hacker News search for `AI generated UI` surfaced `DesignArena` as a benchmark for AI-generated UI/UX, plus tools such as UI-stack that enforce design systems on generated UI. This supports adding an explicit AI UI judge layer rather than treating design as subjective polish.
- NN/g’s public “Aesthetic-Usability Effect” says visually appealing interfaces can make users more tolerant of minor usability issues. Forge should use this carefully: visual appeal can improve perceived quality, but it can also mask weak loops. The judge needs both taste and workflow evidence.
- NN/g’s 10 usability heuristics remain useful as a baseline: visibility of system status, match with the real world, user control, consistency, error prevention, recognition, flexibility, minimalist design, error recovery, help/documentation. Forge’s visual judge should include these but add a stricter “app-specific shape” layer.

## 6. GitHub/tools that can improve the layer

| Tool/repo | Public signal | Forge use |
| --- | --- | --- |
| `pointfreeco/swift-snapshot-testing` | GitHub: ~4.2k stars; “Delightful Swift snapshot testing.” | Native Swift snapshot tests for key screens/components once apps are generated. Good for regression, not taste by itself. |
| `uber/ios-snapshot-test-case` | GitHub: ~1.8k stars; snapshot view unit tests for iOS. | Alternative/reference for iOS snapshot testing. |
| `mapbox/pixelmatch` | GitHub: ~6.8k stars; small JS pixel-level image comparison library. | Compare native screenshots against prior repair iterations or approved prototype renders. Pixel diffs should be advisory, not taste verdicts. |
| `garris/BackstopJS` | GitHub: ~7.1k stars; visual regression testing. | Useful for local HTML prototypes and web-based design artifacts. |
| `reg-viz/reg-suit` | GitHub: ~1.3k stars; visual regression testing suite. | Candidate if Forge wants CI-style visual artifacts/diffs. |
| `blink-diff` / odiff wrappers | Public GitHub tools for screenshot diffing. | Fast screenshot regression/diff step. |
| `xcodebuildmcp simulator snapshot-ui` | Already used locally in Pantry packet for accessibility hierarchy. | Capture visible labels/controls so visual packets include machine-readable evidence. |
| App Store/iTunes API probe scripts | Used in prior Forge direction gates. | Make screenshot URL harvesting repeatable without browser/account dependence. |

Tool boundary: visual regression tools catch changes and mismatches; they do not know if a design is good. The judge rubric below must sit above pixel diffs.

## 7. Proposed visual evidence packet format

Every app trial should have a packet under the generated app repo, plus a summarized markdown copy under `docs/forge-vnext/` for the Forge run.

Recommended generated-app paths:

```text
.forge/design/visual-evidence-packet.json
.forge/design/references.md
.forge/design/references.json
.forge/design/original-synthesis.md
.forge/design/original-synthesis.json
.forge/design/design-system.md
.forge/design/design-system.json
.forge/design/prototype/index.html
.forge/design/prototype/prototype-receipt.json
.forge/evidence/screenshots/native/activation.png
.forge/evidence/screenshots/native/core-loop.png
.forge/evidence/screenshots/native/returning-progress.png
.forge/evidence/screenshots/native/empty-error.png
.forge/evidence/screenshots/native/money-boundary.png
.forge/evidence/screenshots/native/accessibility-snapshots/*.json
.forge/judges/visual-judge-pre-native.json
.forge/judges/visual-judge-post-native.json
.forge/judges/visual-repair-log.md
```

Minimum packet schema:

```json
{
  "schema_version": "forge.visual_evidence_packet.v1",
  "app": { "id": "pet-care-relay", "name": "Pet Care Relay", "run_id": "..." },
  "safety": {
    "public_or_paid_actions": false,
    "source_capture_policy": "reference_urls_only_or_local_thumbnails_with_attribution",
    "copy_assets_from_references": false
  },
  "references": [
    {
      "id": "ref.petdesk.appstore.2026-05-26",
      "name": "PetDesk",
      "type": "category_app",
      "source_url": "https://apps.apple.com/...",
      "screenshot_urls": ["https://is1-ssl.mzstatic.com/..."],
      "why_relevant": "pet identity + reminders + clinic incumbent baseline",
      "borrow": ["due-care prominence", "pet identity"],
      "avoid": ["clinic booking clone", "provider portal density"],
      "transformation_required": "turn to local morning relay, not appointment dashboard"
    }
  ],
  "original_synthesis": {
    "one_sentence_direction": "A warm morning relay for a named pet: what is due, what changed, what is ready for the vet.",
    "core_shape": "named pet header + due-before-noon rail + recent note + vet packet readiness strip",
    "signature_surfaces": ["Pet identity card", "Today care rail", "Recent note", "Vet packet strip", "Safety microcopy"],
    "explicitly_rejected_patterns": ["generic checklist", "medical chart", "clinic booking clone", "token-reskinned dashboard"]
  },
  "prototype": {
    "path": ".forge/design/prototype/index.html",
    "states": ["activation", "core-loop-after-action", "returning-progress", "empty-error", "money-boundary"],
    "receipt_path": ".forge/design/prototype/prototype-receipt.json"
  },
  "native_screenshots": [
    {
      "state": "activation",
      "path": ".forge/evidence/screenshots/native/activation.png",
      "required_visible_claims": ["Milo's Morning Relay", "2 things due before noon", "Track and prepare. Not medical advice."],
      "accessibility_snapshot_path": ".forge/evidence/screenshots/native/accessibility-snapshots/activation.json"
    }
  ],
  "judge_results": {
    "pre_native": ".forge/judges/visual-judge-pre-native.json",
    "post_native": ".forge/judges/visual-judge-post-native.json"
  }
}
```

## 8. Judge rubric: fail “AI slop” before human review

Run twice:

1. Pre-native: after references + original synthesis + design prototype, before native generation/expansion.
2. Post-native: after simulator screenshots/accessibility snapshots, before Matvii/human review.

### 8.1 Hard-fail conditions

Any one of these forces `verdict: hard_fail_ai_slop` or a more specific hard fail:

- `missing_references`: fewer than 5 references total, or fewer than 3 category references, or no high-quality general craft reference.
- `copying_reference`: packet says or shows direct copying of competitor layout/assets/brand instead of transformation.
- `missing_original_synthesis`: no borrow/avoid/transform explanation for each reference.
- `generic_first_screen`: first screen could become another app by swapping nouns.
- `token_reskin`: layout/components match the Forge template or previous app with only colors/copy changed.
- `no_signature_surface`: none of the promised category-specific surfaces appear above the fold.
- `prototype_missing`: no local prototype/design receipt before native expansion.
- `native_mismatch`: native screenshots contradict the approved prototype/design system.
- `screenshots_missing`: activation/core-loop/returning-progress/empty-error/money-boundary screenshots missing without approved substitute.
- `empty_shell`: screenshots show empty state, placeholder content, dashboard, table, tabs, settings, auth, onboarding, or paywall before first useful loop.
- `stale_residue`: old sample app names/paywalls/auth/screenshots/design references appear outside explicit negative-audit context.
- `human_says_slop`: Matvii says “regular AI slop” or equivalent.

### 8.2 Numeric rubric, 100 points

Fail if total < 80, any dimension below its hard minimum, or any hard-fail condition is true.

| Dimension | Weight | Hard minimum | What judge checks |
| --- | ---: | ---: | --- |
| Reference quality and provenance | 12 | 8 | Sources are real, relevant, attributed, legal/safe, and not self-referential. |
| Original synthesis | 14 | 10 | Clear borrow/avoid/transform logic; app gets a new visual metaphor/shape. |
| First-screen product specificity | 14 | 11 | Above-the-fold screenshot proves the category/job without generic dashboard/list/table. |
| Workflow shape | 12 | 9 | Activation -> action -> changed state -> returning-progress loop is visible, not just described. |
| Native iOS craft | 10 | 7 | HIG-aligned hierarchy, touch targets, accessibility labels, platform feel. |
| Visual hierarchy and density | 10 | 7 | Important work is visually dominant; no card soup, decoration, or fake metrics. |
| Emotional tone and copy | 8 | 6 | Copy matches user anxiety/relief and avoids generic SaaS filler. |
| Evidence integrity | 10 | 8 | Screenshots/accessibility snapshots/prototype receipts are current and indexed. |
| Distinctiveness/non-bullshit | 10 | 8 | Removing labels would not reduce it to another generated app shell. |

### 8.3 Required judge output

```json
{
  "schema_version": "forge.visual_judge.v1",
  "stage": "pre_native|post_native",
  "verdict": "pass|repair_required|hard_fail_ai_slop|hard_fail_safety|kill_direction",
  "confidence": "low|medium|high",
  "scores": {
    "reference_quality": 0,
    "original_synthesis": 0,
    "first_screen_specificity": 0,
    "workflow_shape": 0,
    "native_ios_craft": 0,
    "visual_hierarchy_density": 0,
    "emotional_tone_copy": 0,
    "evidence_integrity": 0,
    "distinctiveness_non_bullshit": 0,
    "total": 0
  },
  "hard_fails": ["generic_first_screen"],
  "comparison_summary": "Reference quality bar vs generated screenshots in plain English.",
  "repair_requests": [
    {
      "id": "repair.signature_surface_missing",
      "severity": "blocking",
      "target_state": "activation",
      "request": "Replace generic checklist with named-pet morning relay surface showing due care, recent note, and vet packet readiness."
    }
  ],
  "human_gate_allowed": false
}
```

Human review should only be requested when:

- `verdict == pass` or a genuine product/taste decision remains after judge pass;
- hard fails are empty;
- the packet includes current screenshots;
- comparison summary is short enough to inspect quickly.

## 9. Pet Care Relay visual contract example

If Matvii accepts the existing Pet Care Relay direction, the pre-native packet should demand this first-screen shape:

- Title: `Milo's Morning Relay`.
- Named pet identity card with species/age and calm status: `2 things due before noon`.
- Today rail with two concrete care cards: `Heartworm dose`, `Refill food by Friday`.
- Recent note: `Limp looked better after short walk yesterday`.
- Vet packet strip: `Vet packet is 70% ready`, with appointment date and missing pieces.
- Primary action: `Mark care done`; secondary action: `Add quick note`.
- Safety copy: `Track and prepare. Not medical advice.`

Immediate judge fail if the screenshot is:

- a generic checklist/dashboard;
- a medical chart;
- a clinic booking/messages/refill app;
- a tab scaffold with pets/reminders/settings;
- a calendar grid with pet labels;
- a paywall/auth/onboarding-first app;
- a static mockup with no care completion or returning-progress state.

## 10. Legal/safe reference capture policy

Agents may:

- collect public source URLs, app names, ids, ratings, descriptions, update dates, and screenshot URLs;
- save small local research thumbnails only inside local `.forge/design/references/` when needed for private review, with source URL + timestamp + “research only” metadata;
- write textual visual analysis: composition, hierarchy, tone, interactions, what to borrow/avoid;
- synthesize new layouts and copy that are visibly transformed from references.

Agents must not:

- copy competitor assets, icons, screenshots, brand names, illustrations, photos, or distinctive layouts into generated apps;
- scrape behind paywalls/logins or use paid services/accounts without explicit approval;
- redistribute reference screenshots publicly;
- claim a generated screenshot is original if it reproduces a reference composition too closely;
- use protected app data or private accounts as reference material.

Recommended packet language for each reference:

```text
This reference is used for comparative research only. Forge may borrow the abstract design principle described below, but must not copy the asset, brand, copy, exact layout, or visual identity.
```

## 11. Pipeline changes/cards needed

### Required pipeline changes

1. Add `visual_reference_research` lane before design prototype.
   - Inputs: accepted direction, category keywords, safety constraints.
   - Outputs: `.forge/design/references.{md,json}` with at least 5 references and borrow/avoid/transform notes.

2. Add `original_visual_synthesis` gate.
   - Inputs: references.
   - Outputs: signature surfaces, core metaphor/shape, rejected patterns, first-screen contract.
   - Hard fail if it only says “use native cards, warm colors, rounded corners.”

3. Add `prototype_before_native` gate.
   - Local static HTML/prototype or equivalent visual artifact for required states.
   - Judge runs before any native expansion.

4. Add `native_screenshot_sequence` evidence requirement.
   - Activation, core loop after action, returning-progress/progress, empty/error, money/deferred boundary.
   - Include accessibility snapshots and evidence-index entries.
   - Verifier contract/script: `docs/forge-vnext/screenshot-sequence-verifier-contract.md` and `visual_evidence_sequence` check in `scripts/forge-vnext-verifier.mjs`.

5. Add `visual_judge_pre_native` and `visual_judge_post_native` tasks.
   - Assignee should be a judge/reviewer profile, not the implementation worker.
   - Judge can create repair cards and block human review.

6. Add `visual_repair_loop`.
   - Blocking repairs route to design or implementation workers with exact screenshot/state acceptance criteria.
   - Repeat until pass/kill.

7. Add `reference_capture_policy` to Forge docs/schemas.
   - Prevent unsafe copying and paid/account actions.

8. Add a lightweight visual-diff/regression step.
   - Use snapshot tests/pixel diffs to detect regressions from approved prototype/baseline.
   - Do not let pixel diff substitute for taste judgment.

### Suggested concrete Kanban cards

- `forgedesign`: Implement visual evidence packet schema and fixture.
  - Create schema docs and pass/fail fixtures under `docs/forge-vnext/schemas/` and `docs/forge-vnext/fixtures/`.

- `forgedesign`: Build Pet Care Relay reference + synthesis packet before native work.
  - Use PetDesk/Digitail/DogCat/DogLog/GreatPetCare + Flighty/Crouton/Gentler/Apple HIG/Linear as references.

- `forgejudge`: Implement visual judge rubric artifact.
  - Produce `visual-judge-pre-native.json` and `visual-judge-post-native.json` contracts with hard-fail reasons and score thresholds.

- `forgeverifier`: Add screenshot sequence verifier.
  - Verify required screenshot files, accessibility snapshots, current evidence-index entries, and no stale screenshot reuse.

- `forgeverifier`: Evaluate Swift/iOS snapshot testing integration.
  - Spike `pointfreeco/swift-snapshot-testing` or native screenshot capture for generated app key states.

- `forgeorchestrator`: Wire visual judge into app-generation lane.
  - Native generation cannot proceed without pre-native visual judge pass; human review cannot proceed without post-native visual judge pass.

## 12. Acceptance bar for this layer

This layer is working when the next generated app cannot reach Matvii with only “it builds and screenshots exist.” It must arrive with:

- a reference packet that proves the app had visual inspiration beyond Forge defaults;
- an original synthesis that explains how references were transformed;
- a prototype/design contract for the exact product loop;
- current native screenshots for required states;
- a visual judge verdict that explicitly compares references/prototype/native output;
- repair cards already created for any slop signals;
- no human approval request until slop hard fails are cleared.

If the judge would have failed Pantry before Matvii said “regular AI slop,” the layer is doing its job.
