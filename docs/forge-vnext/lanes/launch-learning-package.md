# Forge vNext Lane D: Launch Package + Learning Loop

Date: 2026-05-25
Kanban: `t_15d897f7`
Status: implementation-ready spec
Scope: diagnosis/spec only; no second app generation, no DayRateLab polish, no live App Store Connect/TestFlight/monetization/account actions.

## Goal

Define the app-specific launch package and durable learning loop Forge must produce after every generated app run.

Forge vNext must end each app run with:

1. a local, App Store Connect-ready launch package that can be reviewed without touching live ASC;
2. separated privacy, pricing, copy, screenshot, evidence, and TestFlight-readiness artifacts;
3. app score and pipeline score postmortem artifacts with hard minimums;
4. reviewable learning patch proposals that improve Forge only after human approval;
5. a curated external tools/skills vetting path before adopting launch or marketing helpers.

Non-goal: actually submitting, publishing, signing, creating bundle IDs, creating live in-app purchases, activating paid services, or writing real privacy declarations into Apple systems.

---

## Core decisions

- Launch output is app-specific. A generic handoff script may create the folder shape, but all substance must come from the app's own research, positioning, product strategy, evidence, and design artifacts.
- Forge writes local ASC-ready drafts, not live ASC mutations. The package should be copy/paste/import ready for a human, but must not call App Store Connect APIs or require credentials.
- Privacy, pricing, copy, screenshots, and TestFlight-readiness are separate artifacts. A single markdown handoff is not enough.
- App quality and pipeline quality are scored separately. A weak app can still teach Forge; a strong app from a messy pipeline still requires pipeline patches.
- Learning patches are proposals, not automatic changes. They become durable only after human review.
- External launch/marketing/screenshot tools are treated as dependencies requiring vetting, not blindly installed helpers.

---

## Artifact ownership and paths

For each generated app repo, Forge should create an app-owned `.forge/launch/` and `.forge/learning/` package:

```text
<generated-app-repo>/
  .forge/
    launch/
      launch-package.json
      launch-package.md
      asc-draft.json
      privacy-draft.json
      pricing-draft.json
      copy-draft.md
      screenshot-plan.json
      screenshot-contact-sheet.md
      testflight-local-checklist.md
      evidence-index.json
      review-receipt.md
    learning/
      app-scorecard.json
      pipeline-scorecard.json
      postmortem.md
      learning-patches.json
      learning-patches.md
      external-tools-vetting.md
```

Forge itself should keep reusable schemas/templates under a Forge-owned docs/scripts area, not inside the template app:

```text
Forge repo candidate paths:
  docs/forge-vnext/schemas/launch-package.schema.json
  docs/forge-vnext/schemas/asc-draft.schema.json
  docs/forge-vnext/schemas/privacy-draft.schema.json
  docs/forge-vnext/schemas/pricing-draft.schema.json
  docs/forge-vnext/schemas/screenshot-plan.schema.json
  docs/forge-vnext/schemas/scorecard.schema.json
  docs/forge-vnext/schemas/learning-patches.schema.json
  scripts/forge-launch-package.mjs
  scripts/forge-learning-postmortem.mjs
  scripts/forge-vet-external-tool.mjs
```

The implementation workers can choose exact script names, but the generated app artifact paths above should be stable so final auditors and dashboards can discover them.

---

## Launch package schema

`launch-package.json` is the manifest and status index for the full local package.

Required top-level fields:

```json
{
  "schemaVersion": 1,
  "app": {
    "name": "Focus Pantry",
    "bundleId": "local.draft.only.focuspantry",
    "platform": "iOS",
    "minimumOS": "18.0",
    "repoPath": "/absolute/path/to/generated-app",
    "generatedAt": "2026-05-25T12:00:00Z"
  },
  "sourceInputs": {
    "research": [".forge/research/evidence-matrix.json"],
    "product": [".forge/product/product-strategy.json"],
    "design": [".forge/design/design-system.json", ".forge/design/prototype/index.html"],
    "verification": [".forge/verification/evidence-index.json"],
    "audit": [".forge/audit/final-audit.md"]
  },
  "artifactStatus": {
    "ascDraft": "ready_for_human_review",
    "privacyDraft": "ready_for_human_review",
    "pricingDraft": "ready_for_human_review",
    "copyDraft": "ready_for_human_review",
    "screenshotPlan": "blocked_missing_assets",
    "testflightLocalChecklist": "repair_required"
  },
  "launchReadiness": {
    "verdict": "repair_required",
    "blockingReasons": [
      "No native screenshot for paywall/money boundary",
      "Privacy draft needs human confirmation before any live use"
    ],
    "humanApprovalRequiredBefore": [
      "App Store Connect login/API usage",
      "bundle ID creation",
      "signing/capabilities changes",
      "TestFlight upload",
      "privacy declaration submission",
      "live IAP/paywall activation"
    ]
  },
  "artifacts": {
    "ascDraft": ".forge/launch/asc-draft.json",
    "privacyDraft": ".forge/launch/privacy-draft.json",
    "pricingDraft": ".forge/launch/pricing-draft.json",
    "copyDraft": ".forge/launch/copy-draft.md",
    "screenshotPlan": ".forge/launch/screenshot-plan.json",
    "testflightLocalChecklist": ".forge/launch/testflight-local-checklist.md",
    "evidenceIndex": ".forge/launch/evidence-index.json",
    "humanReviewReceipt": ".forge/launch/review-receipt.md"
  }
}
```

Allowed status values:

- `not_started`
- `drafted`
- `ready_for_human_review`
- `repair_required`
- `blocked_missing_input`
- `blocked_needs_approval`
- `approved_local_only`

`approved_local_only` means the local draft is approved as a package artifact. It does not authorize live ASC/TestFlight/App Store actions.

---

## App Store Connect-ready local drafts

`asc-draft.json` should mirror the fields a human will later need for ASC, while remaining local-only.

Required sections:

```json
{
  "schemaVersion": 1,
  "safety": {
    "localDraftOnly": true,
    "liveAppStoreConnectTouched": false,
    "requiresHumanApprovalBeforeUse": true
  },
  "appInfo": {
    "name": "Focus Pantry",
    "subtitle": "Plan meals from what you already have",
    "primaryCategory": "Food & Drink",
    "secondaryCategory": "Productivity",
    "contentRights": "draft_unknown_until_human_confirms",
    "ageRatingNotes": ["No user-generated public content", "No medical advice"]
  },
  "localizations": [
    {
      "locale": "en-US",
      "promotionalText": "Turn pantry odds and ends into a calm weekly plan.",
      "description": "...full ASC-length description draft...",
      "keywords": ["meal plan", "pantry", "grocery", "leftovers"],
      "supportURL": "draft_required_before_live_use",
      "marketingURL": "optional_draft_required_before_live_use",
      "whatsNew": "Initial TestFlight draft."
    }
  ],
  "reviewNotesDraft": {
    "demoAccount": "not_applicable_or_human_to_fill",
    "instructions": "Open the app, choose pantry items, generate a 3-day plan, then review grocery gaps.",
    "knownLimitations": ["Local-only mock data in current build"]
  },
  "attachments": {
    "screenshots": [".forge/evidence/screenshots/activation.png"],
    "previewVideo": ".forge/evidence/video/core-flow.mp4"
  }
}
```

Rules:

- Do not include credentials, real personal support emails, live URLs, real bundle IDs, or ASC IDs unless the human explicitly provides them for local draft use.
- Use placeholder markers like `draft_required_before_live_use` where external resources are needed.
- Copy must cite which research/product artifacts informed it in `launch-package.json.sourceInputs` or `copy-draft.md`.
- If a field cannot be inferred safely, mark it as `human_required`, not guessed.

---

## Privacy artifact

`privacy-draft.json` is a local draft for App Privacy/Data Safety discussion. It must be conservative and evidence-linked.

Required fields:

```json
{
  "schemaVersion": 1,
  "safety": {
    "localDraftOnly": true,
    "notLegalAdvice": true,
    "requiresHumanConfirmationBeforeSubmission": true
  },
  "dataCollectionSummary": {
    "collectsData": "unknown|yes|no",
    "tracking": "unknown|yes|no",
    "thirdPartySDKs": [
      {
        "name": "Firebase",
        "purpose": "analytics/crash/performance draft",
        "enabledInCurrentBuild": false,
        "evidence": "Package.resolved or project config path"
      }
    ]
  },
  "dataTypes": [
    {
      "appleCategory": "Identifiers",
      "collected": "unknown|yes|no",
      "linkedToUser": "unknown|yes|no",
      "usedForTracking": "unknown|yes|no",
      "purposes": ["App Functionality"],
      "evidencePaths": ["Sources/App/Managers/LocalStore.swift"],
      "confidence": "low|medium|high",
      "humanReviewNeeded": true
    }
  ],
  "permissions": [
    {
      "permission": "Camera",
      "used": false,
      "evidencePaths": [],
      "notes": "No camera entitlement or usage string found."
    }
  ],
  "openQuestions": [
    "Will analytics be enabled before TestFlight?",
    "What support contact and privacy policy URL should be used?"
  ]
}
```

Gate rule: no launch package can be `ready_for_human_review` without a privacy draft. Unknowns are allowed; silent assumptions are not.

---

## Pricing and monetization artifact

`pricing-draft.json` records the money path without activating money systems.

Required fields:

```json
{
  "schemaVersion": 1,
  "monetizationThesis": "Freemium weekly planning with Pro export and unlimited saved plans.",
  "recommendedModel": "free|paid_upfront|freemium|subscription|one_time_iap|ads|no_monetization_yet",
  "pricePoints": [
    {
      "tier": "Pro Monthly",
      "draftPriceUSD": 4.99,
      "rationale": "Comparable pantry/meal planning apps cluster around $3.99-$7.99/month.",
      "sourcePaths": [".forge/research/pricing-evidence.md"]
    }
  ],
  "paywallBoundary": {
    "freeValue": ["3-day plan", "10 pantry items"],
    "paidValue": ["unlimited plans", "PDF grocery export", "saved meal history"],
    "nativeEvidenceRequired": ["paywall screenshot", "upgrade trigger screenshot"]
  },
  "liveSystems": {
    "storeKitConfigured": false,
    "iapProductsCreated": false,
    "requiresHumanApprovalBeforeAnyActivation": true
  },
  "risks": [
    "Revenue thesis is competitor-informed but not user-validated.",
    "Paywall may weaken activation if shown before first useful plan."
  ]
}
```

Gate rule: pricing can be speculative, but it must be explicit, competitor-informed when research exists, and connected to native money-boundary evidence.

---

## Copy artifact

`copy-draft.md` should be human-readable and include variants, not just a single description.

Required sections:

```markdown
# Copy Draft: <App Name>

## Positioning source
- Target user:
- Pain:
- Core promise:
- Competitor contrast:
- Evidence sources:

## App Store metadata draft
- Name:
- Subtitle:
- Promotional text:
- Keywords:

## Description variant A: direct utility
...

## Description variant B: emotional/taste-led
...

## Screenshot captions
1. Activation screen: ...
2. Core loop: ...
3. Retention/progress: ...
4. Money boundary/paywall: ...
5. Trust/privacy/offline/local: ...

## In-app launch copy checks
- Empty state:
- First-run guidance:
- Error copy:
- Upgrade copy:

## Claims audit
| Claim | Evidence path | Status |
|---|---|---|
| "Plan meals in under 2 minutes" | .forge/evidence/video/core-flow.mp4 | supported/repair/unsupported |
```

Gate rule: every marketing claim must map to evidence or be marked unsupported.

---

## Screenshot artifacts

`screenshot-plan.json` defines what images must exist before a launch-candidate claim.

Required screenshot categories:

1. activation/first useful moment;
2. core repeat-use loop;
3. retention/progress/history or equivalent;
4. monetization boundary/paywall if monetized;
5. app-specific differentiator/taste moment;
6. settings/privacy/trust surface when relevant.

Example:

```json
{
  "schemaVersion": 1,
  "deviceTargets": ["iPhone 17 Pro"],
  "style": {
    "sourceDesignSystem": ".forge/design/design-system.json",
    "marketingFrameStyle": "native_device_frame|plain_screenshot|tool_generated",
    "background": "app_specific"
  },
  "requiredShots": [
    {
      "id": "activation",
      "title": "First useful plan",
      "screenOrFlow": "Onboarding -> Pantry input -> Plan result",
      "evidencePath": ".forge/evidence/screenshots/activation.png",
      "captionDraft": "Make tonight's plan from what you already have.",
      "status": "missing|captured|approved|repair_required",
      "acceptanceCriteria": [
        "Shows real app UI, not mock HTML",
        "Proves first useful moment without account or live service dependency"
      ]
    }
  ],
  "blockedIfMissing": ["activation", "core_loop"]
}
```

`screenshot-contact-sheet.md` should then show all captured image paths, captions, and pass/repair notes. Implementation workers can generate the markdown with local relative image links.

Gate rule: launch package cannot claim TestFlight/App Store readiness if required screenshot categories are missing or are only prototype images. Prototype screenshots may be included as design reference, not native evidence.

---

## TestFlight-ready local checklist

`testflight-local-checklist.md` is a local readiness checklist only. It must not imply upload approval.

Required checklist:

```markdown
# TestFlight-ready Local Checklist

## Build and project hygiene
- [ ] App builds with release-like configuration locally
- [ ] No generated-app contamination in Forge template
- [ ] Bundle ID is still draft/local unless human provided one
- [ ] Signing/account changes not performed by agents
- [ ] Minimum OS and device targets documented

## Verification evidence
- [ ] Tests pass or failures are explained with repair plan
- [ ] Native app launches in simulator
- [ ] Core flow video exists
- [ ] Required screenshot set exists
- [ ] Final skeptical audit exists

## Product launch readiness
- [ ] Activation/core loop/retention/money boundary match product strategy
- [ ] App-specific design system is visible in native screenshots
- [ ] Privacy draft complete enough for human review
- [ ] Pricing/paywall recommendation present or explicit no-monetization decision
- [ ] ASC local draft complete enough for human review

## Explicitly not done by agents
- [ ] No live ASC usage
- [ ] No TestFlight upload
- [ ] No real privacy declaration submission
- [ ] No IAP/product creation
- [ ] No public posting/marketing
```

---

## Evidence index linkage

`.forge/launch/evidence-index.json` should either reference or extend the generic verification evidence index. It answers: "What proof supports every launch claim?"

Required fields:

```json
{
  "schemaVersion": 1,
  "claims": [
    {
      "claim": "User can complete the core loop locally",
      "requiredFor": ["copy", "launch_readiness", "scorecard"],
      "evidence": [
        {"type": "video", "path": ".forge/evidence/video/core-flow.mp4"},
        {"type": "test", "path": ".forge/verification/test-results.json"}
      ],
      "status": "supported|partial|unsupported",
      "notes": "Video covers happy path only; no error path yet."
    }
  ]
}
```

Final audit must reject unsupported claims in copy, pricing, or readiness.

---

## App scorecard

`.forge/learning/app-scorecard.json` scores the generated app as a product. It uses app-specific thresholds set during product strategy and finalized before implementation expands.

Required dimensions:

- pain/problem clarity;
- target user sharpness;
- repeat-use/retention loop;
- visual/product distinctiveness;
- monetization believability;
- native UX quality;
- launch readiness.

Example:

```json
{
  "schemaVersion": 1,
  "overallScore": 7.1,
  "verdict": "repair_required|kill_recommended|launch_candidate|testflight_local_candidate",
  "thresholds": {
    "launchCandidateMinimumOverall": 8.0,
    "hardMinimumPerCriticalDimension": 7.0,
    "criticalDimensions": ["pain", "repeatUse", "nativeUX", "launchReadiness"]
  },
  "dimensions": [
    {
      "id": "repeatUse",
      "label": "Repeat-use/retention loop",
      "score": 6,
      "weight": 1.25,
      "hardMinimum": 7,
      "status": "fail",
      "evidencePaths": [".forge/evidence/screenshots/history.png"],
      "rationale": "Progress/history exists in strategy but native proof is too thin.",
      "repairRecommendation": "Add native progress/history slice or lower launch claim."
    }
  ],
  "cannotAverageAwayFailures": true,
  "openRisks": ["Monetization is plausible but unvalidated"]
}
```

Rules:

- A high average cannot hide a failed critical dimension.
- `kill_recommended` is allowed, but Matvii decides kills.
- If evidence is missing, score conservatively and name the missing artifact.

---

## Pipeline scorecard

`.forge/learning/pipeline-scorecard.json` scores Forge's run quality, independent of whether the app is good.

Required dimensions:

- research evidence quality;
- gate clarity and enforcement;
- design artifact quality;
- native architecture/modularity;
- verification reliability;
- launch package completeness;
- reusability/generalization;
- learning quality.

Example:

```json
{
  "schemaVersion": 1,
  "overallScore": 6.8,
  "verdict": "pipeline_repair_required|pipeline_acceptable|pipeline_regression",
  "dimensions": [
    {
      "id": "launchPackageCompleteness",
      "score": 8,
      "status": "pass",
      "evidencePaths": [".forge/launch/launch-package.json"],
      "rationale": "All local drafts exist and unsupported claims were marked."
    },
    {
      "id": "reusabilityGeneralization",
      "score": 5,
      "status": "fail",
      "evidencePaths": ["scripts/forge-e2e-native-verify.mjs"],
      "rationale": "Verifier required app-specific source edits.",
      "repairRecommendation": "Move app-specific checks to generated verifier config."
    }
  ],
  "regressions": [
    "Launch script still had fixed screenshot story order"
  ],
  "durableLearningNeeded": true
}
```

---

## Postmortem format

`.forge/learning/postmortem.md` should be concise but complete.

Required sections:

```markdown
# Postmortem: <App Name>

## Verdict
- App verdict:
- Pipeline verdict:
- Recommended next action: launch-candidate repair / kill discussion / pipeline repair / generate next app

## What Forge produced
- Research:
- Product strategy:
- Design:
- Native app:
- Evidence:
- Launch package:

## What worked
- ...

## What failed or remained shallow
- ...

## App score summary
- Overall:
- Failed hard minimums:
- Top repair:

## Pipeline score summary
- Overall:
- Failed hard minimums:
- Top repair:

## Evidence gaps
- ...

## Decision log
- Gate decisions:
- Human approvals/blocks:
- Agent disagreements escalated:

## Learning patch proposals
- See `.forge/learning/learning-patches.json`.
```

Gate rule: a run is not complete until postmortem links to both scorecards and the launch package manifest.

---

## Learning patch proposal format

`.forge/learning/learning-patches.json` contains reviewable patch proposals. These are not automatically applied.

Patch target types:

- `prompt`
- `gate`
- `verifier_rule`
- `architecture_template`
- `design_reference`
- `optional_module`
- `docs`
- `script`
- `external_tool_or_skill`

Required fields:

```json
{
  "schemaVersion": 1,
  "patches": [
    {
      "id": "lp-001",
      "title": "Require money-boundary native evidence before monetized launch claims",
      "targetType": "gate",
      "targetPath": "docs/forge-vnext/schemas/launch-package.schema.json",
      "problem": "Previous run had pricing copy but no native paywall/upgrade boundary screenshot.",
      "evidencePaths": [
        ".forge/launch/pricing-draft.json",
        ".forge/learning/app-scorecard.json"
      ],
      "proposedChange": "Add `paywallBoundary.nativeEvidenceRequired` as a blocking field when monetization is not `no_monetization_yet`.",
      "expectedBenefit": "Prevents launch packages from overclaiming monetization readiness.",
      "risk": "May block useful non-monetized TestFlight learning if applied too strictly.",
      "complexity": "low|medium|high",
      "reviewStatus": "proposed|approved|rejected|needs_revision|applied",
      "requiresHumanReview": true,
      "applicationPlan": [
        "Update schema",
        "Update launch package generator",
        "Add validator fixture for monetized app missing paywall screenshot"
      ]
    }
  ]
}
```

`learning-patches.md` should group the same patches into human review buckets:

- approve now;
- revise first;
- reject / too much complexity;
- defer until after second proof app.

Rules:

- A learning patch must cite evidence from the run.
- A learning patch must describe risk and complexity, not only benefit.
- Patches that increase complexity must have stronger evidence.
- External tool adoption must use the vetting path below before being proposed as `approved`.

---

## Curated external tools/skills vetting path

External helpers can improve launch/screenshot/marketing workflows, but must not become hidden dependencies or supply-chain risk.

Initial candidates from the charter:

- `ParthJadhav/app-store-screenshots` for App Store screenshot generation.
- `coreyhaines31/marketingskills` for marketing/copy/positioning playbooks.

Vetting artifact: `.forge/learning/external-tools-vetting.md`

Required evaluation checklist per tool/skill:

```markdown
## Tool: <name>

### Candidate use
- What Forge would use it for:
- Which artifact it would produce or improve:

### Source and maintenance
- URL:
- License:
- Last meaningful update:
- Install/runtime requirements:
- Works offline/local-only? yes/no/partial

### Safety
- Requires credentials? yes/no
- Sends data externally? yes/no/unknown
- Executes untrusted code? yes/no
- Touches public/external/money systems? yes/no
- Can be sandboxed to generated app workspace? yes/no

### Fit
- App-specific enough or generic template risk?
- Can outputs be reviewed before use?
- Does it preserve Forge-owned artifact schemas?
- Does it introduce a hard dependency or optional enhancement?

### Trial result
- Local command tested:
- Input fixture:
- Output artifact:
- Failure modes:

### Recommendation
- reject / optional-curated / vendor-after-review / replace-with-own-script
- Rationale:
- Required follow-up before adoption:
```

Adoption gates:

1. Research-only note: candidate is listed with URL and intended use.
2. Local sandbox trial: run only on dummy/generated inputs, no credentials, no network submission.
3. Output review: confirm generated screenshots/copy improve app-specific quality instead of creating generic marketing sludge.
4. Security/maintenance check: license, update health, dependency footprint, external calls.
5. Optional integration proposal: create a learning patch with target type `external_tool_or_skill`.
6. Human approval: only after approval can it become a curated optional Forge helper.

Default recommendation for vNext implementation: keep launch package generation schema-first and local. Treat external screenshot/marketing tools as optional enrichers whose outputs must flow back into Forge-owned artifacts.

---

## Implementation worker tasks

### Task D1: Add launch and learning schemas

Objective: create machine-readable schemas for launch package, ASC draft, privacy draft, pricing draft, screenshot plan, scorecards, and learning patches.

Files:

- Create: `docs/forge-vnext/schemas/launch-package.schema.json`
- Create: `docs/forge-vnext/schemas/asc-draft.schema.json`
- Create: `docs/forge-vnext/schemas/privacy-draft.schema.json`
- Create: `docs/forge-vnext/schemas/pricing-draft.schema.json`
- Create: `docs/forge-vnext/schemas/screenshot-plan.schema.json`
- Create: `docs/forge-vnext/schemas/scorecard.schema.json`
- Create: `docs/forge-vnext/schemas/learning-patches.schema.json`

Acceptance:

- Schemas require `schemaVersion`, `safety.localDraftOnly` where applicable, evidence path arrays for claims, and explicit status enums.
- Privacy schema allows `unknown` but requires human review notes.
- Learning patch schema requires problem, evidence, proposed change, benefit, risk, complexity, review status.

### Task D2: Add local launch package generator

Objective: generate the stable `.forge/launch/` folder from app specs/evidence without live services.

Files:

- Create: `scripts/forge-launch-package.mjs`
- Test: fixture generated app under a local temp/test fixture if this repo has script tests.

Acceptance:

- Script accepts generated app repo path and reads only local `.forge` artifacts.
- Script refuses to run live ASC/TestFlight/IAP actions.
- Script writes all required launch artifacts, marking missing inputs as `blocked_missing_input` instead of guessing.
- Script exits non-zero only for malformed inputs/schema violations, not for honest product gaps.

### Task D3: Add postmortem and scorecard generator

Objective: generate `.forge/learning/` scorecards, postmortem shell, and learning patch proposal shell.

Files:

- Create: `scripts/forge-learning-postmortem.mjs`

Acceptance:

- App score and pipeline score are separate.
- Critical dimension hard minimum failures force repair/kill/blocked verdicts even when average score is high.
- Postmortem links to launch manifest, evidence index, app scorecard, pipeline scorecard, and patch proposals.

### Task D4: Add launch/learning validation to final audit

Objective: make final audit fail unsupported launch claims and missing learning artifacts.

Files:

- Modify existing final audit/verifier script after discovery.

Acceptance:

- Audit checks that every marketing claim has supporting evidence or is marked unsupported.
- Audit checks privacy/pricing/copy/screenshot/TestFlight checklist artifacts exist separately.
- Audit checks learning patch proposals exist and are not auto-applied.

### Task D5: Vet optional external tools

Objective: evaluate screenshot and marketing helper candidates without adopting them blindly.

Files:

- Create: `docs/forge-vnext/external-tools-vetting.md` or generate per-app `.forge/learning/external-tools-vetting.md`.

Acceptance:

- `ParthJadhav/app-store-screenshots` and `coreyhaines31/marketingskills` are evaluated using the checklist above.
- No candidate is made mandatory without human approval.
- Any adoption is proposed through `learning-patches.json` as `external_tool_or_skill`.

---

## Final audit requirements for lane D

A generated app run cannot be called complete unless:

- `.forge/launch/launch-package.json` exists and references all required launch artifacts;
- ASC draft is local-only and contains no live credential/account mutation;
- privacy draft exists with unknowns and human-review needs made explicit;
- pricing draft exists or explicitly declares `no_monetization_yet` with rationale;
- copy draft exists and all claims are evidence-linked or marked unsupported;
- screenshot plan exists and required missing native screenshots block launch-candidate claims;
- local TestFlight checklist exists and says what agents did not do;
- app scorecard and pipeline scorecard exist separately;
- postmortem links to evidence, scorecards, launch package, decisions, gaps, and patch proposals;
- learning patches are proposed with review statuses and not silently applied;
- external tool adoption, if proposed, has a vetting artifact.

---

## Open risks

- ASC fields and App Privacy categories change over time. Schemas should be versioned and treated as local review aids, not canonical legal/submission truth.
- Privacy inference from code can be wrong. Human confirmation remains mandatory.
- Screenshot tooling can produce polished but generic assets. The design gate must still judge app-specific taste and native truth.
- Learning patches may create complexity creep. The patch format requires risk/complexity so Matvii can reject marginal improvements.
- If launch package generation becomes too script-heavy too early, it may hide product judgment behind schema compliance. Final audit must still judge substance.

## Suggested next task

Implement lane D schemas first: create the seven `docs/forge-vnext/schemas/*.schema.json` files and a lightweight validator/generator fixture that produces `.forge/launch/launch-package.json` plus `.forge/learning/learning-patches.json` from local-only sample inputs. Do this before integrating any external screenshot or marketing tools.
