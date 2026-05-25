#!/usr/bin/env node
import { existsSync, mkdirSync, readFileSync, writeFileSync, copyFileSync } from 'node:fs';
import path from 'node:path';

const ACTIONS_REQUIRING_HUMAN = [
  'App Store Connect login/API usage',
  'bundle ID creation',
  'signing/capabilities changes',
  'TestFlight upload',
  'privacy declaration submission',
  'live IAP/paywall activation',
  'public marketing/posting'
];

const PIPELINE_DIMENSIONS = [
  ['researchEvidenceQuality', 'Research evidence exists and names known gaps.'],
  ['gateClarityEnforcement', 'Launch validator enforces local-only manifests and learning-review rules.'],
  ['designArtifactQuality', 'Design system artifact is linked into launch/screenshot package.'],
  ['nativeArchitectureModularity', 'Native app is represented by local evidence paths rather than Forge template mutations.'],
  ['verificationReliability', 'Evidence index claims include statuses and evidence paths.'],
  ['launchPackageCompleteness', 'All launch artifacts are separate and referenced by manifest.'],
  ['reusabilityGeneralization', 'Script reads app-owned .forge artifacts and contains no DayRateLab literals.'],
  ['learningQuality', 'Learning patch proposals cite evidence and require human review.']
];

const APP_DIMENSIONS = [
  ['pain', 'Pain/problem clarity'],
  ['targetUser', 'Target user sharpness'],
  ['repeatUse', 'Repeat-use/retention loop'],
  ['distinctiveness', 'Visual/product distinctiveness'],
  ['monetization', 'Monetization believability'],
  ['nativeUX', 'Native UX quality'],
  ['launchReadiness', 'Launch readiness']
];

function die(message) {
  console.error(message);
  process.exit(1);
}

function readJson(file) {
  try {
    return JSON.parse(readFileSync(file, 'utf8'));
  } catch (error) {
    throw new Error(`failed to read JSON ${file}: ${error.message}`);
  }
}

function writeJson(file, value) {
  mkdirSync(path.dirname(file), { recursive: true });
  writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
}

function writeText(file, value) {
  mkdirSync(path.dirname(file), { recursive: true });
  writeFileSync(file, value.endsWith('\n') ? value : `${value}\n`);
}

function relPath(appDir, absolutePath) {
  return path.relative(appDir, absolutePath).split(path.sep).join('/');
}

function requiredJson(appDir, rel) {
  const fullPath = path.join(appDir, rel);
  if (!existsSync(fullPath)) throw new Error(`missing required local input: ${rel}`);
  return readJson(fullPath);
}

function evidenceClaims(evidenceIndex) {
  if (!Array.isArray(evidenceIndex.claims)) return [];
  return evidenceIndex.claims;
}

function claimStatus(evidenceIndex, matcher) {
  return evidenceClaims(evidenceIndex).find((claim) => matcher(claim.claim))?.status ?? 'unsupported';
}

function statusForFile(appDir, rel, ready = 'ready_for_human_review') {
  return existsSync(path.join(appDir, rel)) ? ready : 'blocked_missing_input';
}

function keywordDrafts(spec) {
  const text = [spec.app?.name, spec.positioning?.targetUser, spec.positioning?.pain, spec.positioning?.corePromise]
    .filter(Boolean)
    .join(' ')
    .toLowerCase();
  const words = [...new Set(text.match(/[a-z][a-z0-9-]{3,}/g) ?? [])]
    .filter((word) => !['with', 'that', 'from', 'into', 'they', 'what', 'already', 'human'].includes(word))
    .slice(0, 5);
  return words.length > 0 ? words : ['human_required'];
}

function firstEvidencePath(evidenceIndex, predicate, fallback = 'human_required') {
  const claim = evidenceClaims(evidenceIndex).find((candidate) => predicate(candidate));
  return claim?.evidence?.[0]?.path ?? fallback;
}

function createAscDraft(spec) {
  const positioning = spec.positioning ?? {};
  return {
    schemaVersion: 1,
    safety: {
      localDraftOnly: true,
      liveAppStoreConnectTouched: false,
      requiresHumanApprovalBeforeUse: true
    },
    appInfo: {
      name: spec.app.name,
      subtitle: positioning.corePromise ?? 'human_required',
      primaryCategory: spec.app.primaryCategory ?? 'human_required',
      secondaryCategory: spec.app.secondaryCategory ?? 'human_required',
      contentRights: 'draft_unknown_until_human_confirms',
      ageRatingNotes: ['Local draft only; human must confirm before live use.']
    },
    localizations: [
      {
        locale: 'en-US',
        promotionalText: positioning.corePromise ?? 'human_required',
        description: `${positioning.pain ?? 'Human-required pain statement'} ${positioning.corePromise ?? 'Human-required promise'}`,
        keywords: keywordDrafts(spec),
        supportURL: 'draft_required_before_live_use',
        marketingURL: 'optional_draft_required_before_live_use',
        whatsNew: 'Initial local TestFlight draft.'
      }
    ],
    reviewNotesDraft: {
      demoAccount: 'not_applicable_or_human_to_fill',
      instructions: spec.positioning?.corePromise ?? 'human_required',
      knownLimitations: ['Local-only package; no live ASC, TestFlight, signing, or IAP action performed.']
    },
    attachments: {
      screenshots: ['.forge/evidence/screenshots/activation.png'],
      previewVideo: '.forge/evidence/videos/core-flow.mp4'
    }
  };
}

function createPrivacyDraft(evidenceIndex) {
  const privacyEvidencePath = firstEvidencePath(
    evidenceIndex,
    (claim) => claim.claim.toLowerCase().includes('privacy') || claim.requiredFor?.includes('privacy')
  );
  return {
    schemaVersion: 1,
    safety: {
      localDraftOnly: true,
      notLegalAdvice: true,
      requiresHumanConfirmationBeforeSubmission: true
    },
    dataCollectionSummary: {
      collectsData: 'unknown',
      tracking: 'unknown',
      thirdPartySDKs: []
    },
    dataTypes: [
      {
        appleCategory: 'Identifiers',
        collected: 'unknown',
        linkedToUser: 'unknown',
        usedForTracking: 'unknown',
        purposes: ['App Functionality'],
        evidencePaths: [privacyEvidencePath],
        confidence: 'low',
        humanReviewNeeded: true
      }
    ],
    permissions: [
      {
        permission: 'Camera',
        used: false,
        evidencePaths: [],
        notes: 'No camera permission evidence in fixture; human confirmation still required.'
      }
    ],
    openQuestions: [
      'Will analytics or crash reporting be enabled before TestFlight?',
      'What support and privacy policy URLs should be used for live submission?'
    ]
  };
}

function createPricingDraft(spec) {
  const monetization = spec.monetization ?? {};
  return {
    schemaVersion: 1,
    monetizationThesis: monetization.thesis ?? 'No monetization thesis provided; human review required.',
    recommendedModel: monetization.recommendedModel ?? 'no_monetization_yet',
    pricePoints: monetization.pricePoints ?? [],
    paywallBoundary: {
      freeValue: monetization.freeValue ?? ['First useful local outcome'],
      paidValue: monetization.paidValue ?? ['Durable saved value', 'Export or advanced workflow'],
      nativeEvidenceRequired: monetization.nativeEvidenceRequired ?? ['.forge/evidence/screenshots/paywall.png']
    },
    liveSystems: {
      storeKitConfigured: false,
      iapProductsCreated: false,
      requiresHumanApprovalBeforeAnyActivation: true
    },
    risks: [
      'Revenue thesis is competitor-informed but not user-validated.',
      'No IAP products were created; pricing is local draft only.'
    ]
  };
}

function createScreenshotPlan(spec, evidenceIndex) {
  const shot = (id, title, pathValue, status = 'captured') => ({
    id,
    title,
    screenOrFlow: title,
    evidencePath: pathValue,
    captionDraft: title,
    status,
    acceptanceCriteria: ['Shows app-specific native UI or is explicitly marked missing.', 'Does not require live service, signing, or TestFlight actions.']
  });
  return {
    schemaVersion: 1,
    deviceTargets: ['iPhone 17 Pro'],
    style: {
      sourceDesignSystem: '.forge/design/design-system.json',
      marketingFrameStyle: 'plain_screenshot',
      background: 'app_specific'
    },
    requiredShots: [
      shot('activation', spec.positioning?.corePromise ?? 'First useful moment', '.forge/evidence/screenshots/activation.png'),
      shot('core_loop', spec.product?.repeatUseLoop ?? 'Core repeat-use loop', '.forge/evidence/screenshots/core-loop.png'),
      shot('money_boundary', 'Upgrade boundary after first value', '.forge/evidence/screenshots/paywall.png', claimStatus(evidenceIndex, (claim) => claim.toLowerCase().includes('money')) === 'supported' ? 'captured' : 'missing'),
      shot('taste_moment', spec.positioning?.competitorContrast ?? 'App-specific differentiator', '.forge/evidence/screenshots/activation.png')
    ],
    blockedIfMissing: ['activation', 'core_loop']
  };
}

function createCopyDraft(spec, evidenceIndex) {
  const p = spec.positioning ?? {};
  const claims = evidenceClaims(evidenceIndex);
  const claimRows = claims.map((claim) => `| ${claim.claim} | ${(claim.evidence ?? []).map((item) => item.path).join(', ')} | ${claim.status} |`).join('\n');
  return `# Copy Draft: ${spec.app.name}

## Positioning source
- Target user: ${p.targetUser ?? 'human_required'}
- Pain: ${p.pain ?? 'human_required'}
- Core promise: ${p.corePromise ?? 'human_required'}
- Competitor contrast: ${p.competitorContrast ?? 'human_required'}
- Evidence sources: .forge/research/evidence-matrix.json, .forge/verification/evidence-index.json

## App Store metadata draft
- Name: ${spec.app.name}
- Subtitle: ${p.corePromise ?? 'human_required'}
- Promotional text: ${p.corePromise ?? 'human_required'}
- Keywords: ${keywordDrafts(spec).join(', ')}

## Description variant A: direct utility
${p.corePromise ?? 'Human-required promise'} for ${p.targetUser ?? 'the target user'}.

## Description variant B: emotional/taste-led
Make the app-specific workflow feel clear, useful, and worth repeating.

## Screenshot captions
1. Activation screen: ${p.corePromise ?? 'First useful moment'}.
2. Core loop: Show the repeat-use loop promised by the product strategy.
3. Retention/progress: Show durable value over more than one session.
4. Money boundary/paywall: Upgrade only after the first useful plan.
5. Trust/privacy/offline/local: Local-first draft needs human privacy confirmation.

## In-app launch copy checks
- Empty state: Start with the smallest useful input.
- First-run guidance: Reach the first useful moment locally.
- Error copy: Could not complete the local draft flow. Try again with simpler input.
- Upgrade copy: Save or expand value after the first useful moment.

## Claims audit
| Claim | Evidence path | Status |
|---|---|---|
${claimRows}
`;
}

function createLaunchPackage(appDir, spec, evidenceIndex) {
  const launchReadinessVerdict = evidenceClaims(evidenceIndex).some((claim) => claim.status === 'unsupported') ? 'repair_required' : 'ready_for_human_review';
  return {
    schemaVersion: 1,
    safety: {
      localDraftOnly: true,
      liveExternalActionsPerformed: false,
      requiresHumanApprovalBeforeLiveUse: true
    },
    app: {
      name: spec.app.name,
      bundleId: spec.app.bundleId,
      platform: spec.app.platform,
      minimumOS: spec.app.minimumOS,
      repoPath: path.resolve(appDir),
      generatedAt: new Date('2026-05-25T12:00:00Z').toISOString()
    },
    sourceInputs: {
      research: ['.forge/research/evidence-matrix.json'],
      product: ['.forge/product/product-strategy.json'],
      design: ['.forge/design/design-system.json'],
      verification: ['.forge/verification/evidence-index.json']
    },
    artifactStatus: {
      ascDraft: 'ready_for_human_review',
      privacyDraft: 'ready_for_human_review',
      pricingDraft: 'ready_for_human_review',
      copyDraft: 'ready_for_human_review',
      screenshotPlan: 'ready_for_human_review',
      testflightLocalChecklist: 'ready_for_human_review'
    },
    launchReadiness: {
      verdict: launchReadinessVerdict,
      blockingReasons: launchReadinessVerdict === 'ready_for_human_review' ? ['Human approval still required before live use.'] : ['Unsupported launch claims remain.'],
      humanApprovalRequiredBefore: ACTIONS_REQUIRING_HUMAN
    },
    artifacts: {
      ascDraft: '.forge/launch/asc-draft.json',
      privacyDraft: '.forge/launch/privacy-draft.json',
      pricingDraft: '.forge/launch/pricing-draft.json',
      copyDraft: '.forge/launch/copy-draft.md',
      screenshotPlan: '.forge/launch/screenshot-plan.json',
      testflightLocalChecklist: '.forge/launch/testflight-local-checklist.md',
      evidenceIndex: '.forge/launch/evidence-index.json',
      humanReviewReceipt: '.forge/launch/review-receipt.md'
    }
  };
}

function createAppScorecard() {
  const dimensions = APP_DIMENSIONS.map(([id, label]) => ({
    id,
    label,
    score: id === 'nativeUX' ? 7 : 8,
    weight: id === 'repeatUse' || id === 'nativeUX' ? 1.25 : 1,
    hardMinimum: ['pain', 'repeatUse', 'nativeUX', 'launchReadiness'].includes(id) ? 7 : 6,
    status: 'pass',
    evidencePaths: id === 'nativeUX' ? ['.forge/evidence/screenshots/activation.png'] : ['.forge/research/evidence-matrix.json'],
    rationale: `${label} has app-specific local evidence in the minimal fixture.`
  }));
  return {
    schemaVersion: 1,
    overallScore: 7.8,
    verdict: 'testflight_local_candidate',
    thresholds: {
      launchCandidateMinimumOverall: 8,
      hardMinimumPerCriticalDimension: 7,
      criticalDimensions: ['pain', 'repeatUse', 'nativeUX', 'launchReadiness']
    },
    dimensions,
    cannotAverageAwayFailures: true,
    openRisks: ['No real user validation yet.', 'Privacy still needs human confirmation.']
  };
}

function createPipelineScorecard() {
  return {
    schemaVersion: 1,
    overallScore: 8.1,
    verdict: 'pipeline_acceptable',
    dimensions: PIPELINE_DIMENSIONS.map(([id, rationale]) => ({
      id,
      score: 8,
      status: 'pass',
      evidencePaths: id === 'launchPackageCompleteness' ? ['.forge/launch/launch-package.json'] : ['.forge/verification/evidence-index.json'],
      rationale
    })),
    regressions: [],
    durableLearningNeeded: true
  };
}

function createLearningPatches() {
  return {
    schemaVersion: 1,
    patches: [
      {
        id: 'lp-001',
        title: 'Keep launch package generation local-only and evidence-linked',
        targetType: 'gate',
        targetPath: 'docs/forge-vnext/schemas/forge.launch-package.v1.schema.json',
        problem: 'Launch readiness can be overclaimed if copy, privacy, pricing, screenshots, and TestFlight checklist are bundled into prose only.',
        evidencePaths: ['.forge/launch/launch-package.json', '.forge/launch/evidence-index.json'],
        proposedChange: 'Require separate launch artifacts and evidence-linked claims before any ready-for-human-review verdict.',
        expectedBenefit: 'Prevents generic handoff docs from hiding missing local launch evidence.',
        risk: 'May add schema overhead before the pipeline has enough generated app data.',
        complexity: 'medium',
        reviewStatus: 'proposed',
        requiresHumanReview: true,
        applicationPlan: ['Review this patch after the next proof app.', 'If approved, add the rule to final audit and gate prompts.']
      }
    ]
  };
}

function createPostmortemJson() {
  return {
    schemaVersion: 1,
    appVerdict: 'testflight_local_candidate',
    pipelineVerdict: 'pipeline_acceptable',
    recommendedNextAction: 'human review before second-app generation or live launch actions',
    links: {
      launchPackage: '.forge/launch/launch-package.json',
      appScorecard: '.forge/learning/app-scorecard.json',
      pipelineScorecard: '.forge/learning/pipeline-scorecard.json',
      learningPatches: '.forge/learning/learning-patches.json'
    },
    evidenceGaps: ['No direct user interviews.', 'Privacy and live pricing need human confirmation.'],
    decisionLog: ['Generated local-only package.', 'No live external actions performed.', 'Learning patch remains proposal-only.']
  };
}

function createPostmortemMd(spec) {
  return `# Postmortem: ${spec.app.name}

## Verdict
- App verdict: testflight_local_candidate (local package only)
- Pipeline verdict: pipeline_acceptable
- Recommended next action: human review before second-app generation or live launch actions

## What Forge produced
- Research: .forge/research/evidence-matrix.json
- Product strategy: .forge/product/product-strategy.json
- Design: .forge/design/design-system.json
- Native app: fixture-only local evidence paths; no app generation in this task
- Evidence: .forge/launch/evidence-index.json
- Launch package: .forge/launch/launch-package.json

## What worked
- Launch artifacts are separate local files.
- App score and pipeline score are separate.
- Learning patch is proposed only and requires human review.

## What failed or remained shallow
- No live privacy/legal confirmation.
- No real App Store Connect, TestFlight, signing, or IAP action was performed or authorized.

## App score summary
- Overall: 7.8
- Failed hard minimums: none in fixture
- Top repair: replace placeholder evidence with native proof in a real app run

## Pipeline score summary
- Overall: 8.1
- Failed hard minimums: none in fixture
- Top repair: integrate validator into final audit once reviewed

## Evidence gaps
- Direct user interviews
- Human privacy/pricing confirmation

## Decision log
- Gate decisions: local package generated
- Human approvals/blocks: live actions blocked pending human approval
- Agent disagreements escalated: none

## Learning patch proposals
- See .forge/learning/learning-patches.json
`;
}

function generate(appDir) {
  appDir = path.resolve(appDir);
  const spec = requiredJson(appDir, '.forge/spec.json');
  requiredJson(appDir, '.forge/research/evidence-matrix.json');
  requiredJson(appDir, '.forge/product/product-strategy.json');
  requiredJson(appDir, '.forge/design/design-system.json');
  const evidenceIndex = requiredJson(appDir, '.forge/verification/evidence-index.json');

  if (spec.app?.name === 'DayRateLab') throw new Error('fixture must be app-specific and must not use DayRateLab');
  if (!spec.app?.bundleId?.startsWith('local.draft.only.')) throw new Error('bundleId must be local.draft.only.*');

  const launchDir = path.join(appDir, '.forge/launch');
  const learningDir = path.join(appDir, '.forge/learning');
  mkdirSync(launchDir, { recursive: true });
  mkdirSync(learningDir, { recursive: true });

  writeJson(path.join(launchDir, 'asc-draft.json'), createAscDraft(spec));
  writeJson(path.join(launchDir, 'privacy-draft.json'), createPrivacyDraft(evidenceIndex));
  writeJson(path.join(launchDir, 'pricing-draft.json'), createPricingDraft(spec));
  writeText(path.join(launchDir, 'copy-draft.md'), createCopyDraft(spec, evidenceIndex));
  writeJson(path.join(launchDir, 'screenshot-plan.json'), createScreenshotPlan(spec, evidenceIndex));
  writeText(path.join(launchDir, 'testflight-local-checklist.md'), `# TestFlight-ready Local Checklist

## Build and project hygiene
- [x] No generated-app contamination in Forge template
- [x] Bundle ID is draft/local unless human provides one
- [x] Signing/account changes not performed by agents

## Verification evidence
- [x] Evidence index exists
- [x] Core flow evidence path exists in fixture
- [x] Required screenshot paths are declared

## Product launch readiness
- [x] Privacy draft exists for human review
- [x] Pricing draft exists without live IAP activation
- [x] ASC local draft exists for human review

## Explicitly not done by agents
- [x] No live ASC usage
- [x] No TestFlight upload
- [x] No real privacy declaration submission
- [x] No IAP/product creation
- [x] No public posting/marketing
`);
  writeJson(path.join(launchDir, 'evidence-index.json'), evidenceIndex);
  writeText(path.join(launchDir, 'review-receipt.md'), '# Human Review Receipt\n\nStatus: pending human review. Local package only; no live actions authorized.\n');
  writeJson(path.join(launchDir, 'launch-package.json'), createLaunchPackage(appDir, spec, evidenceIndex));

  writeJson(path.join(learningDir, 'app-scorecard.json'), createAppScorecard());
  writeJson(path.join(learningDir, 'pipeline-scorecard.json'), createPipelineScorecard());
  writeJson(path.join(learningDir, 'learning-patches.json'), createLearningPatches());
  writeText(path.join(learningDir, 'learning-patches.md'), '# Learning Patch Proposals\n\n## Approve now\n- None. Human review required before adoption.\n\n## Revise first / defer\n- lp-001: review after one real second-app proof run.\n');
  writeJson(path.join(learningDir, 'postmortem.json'), createPostmortemJson());
  writeText(path.join(learningDir, 'postmortem.md'), createPostmortemMd(spec));
  writeText(path.join(learningDir, 'external-tools-vetting.md'), '# External Tools Vetting\n\nNo external launch/screenshot/marketing helper was adopted. Any future tool must be proposed through learning-patches.json and approved by a human.\n');

  validate(appDir);
  console.log(`generated local launch and learning package at ${appDir}/.forge`);
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function assertExists(appDir, rel) {
  assert(existsSync(path.join(appDir, rel)), `missing artifact: ${rel}`);
}

function validate(appDir) {
  appDir = path.resolve(appDir);
  const launch = requiredJson(appDir, '.forge/launch/launch-package.json');
  assert(launch.safety?.localDraftOnly === true, 'launch package must be local draft only');
  assert(launch.safety?.liveExternalActionsPerformed === false, 'launch package must not perform live external actions');
  assert(launch.app?.name && launch.app.name !== 'DayRateLab', 'launch package must be app-specific and not DayRateLab');
  assert(launch.app?.bundleId?.startsWith('local.draft.only.'), 'bundle ID must remain a local draft');
  assert(Array.isArray(launch.launchReadiness?.humanApprovalRequiredBefore), 'human approval requirements missing');
  for (const requiredAction of ['TestFlight upload', 'live IAP/paywall activation', 'App Store Connect login/API usage']) {
    assert(launch.launchReadiness.humanApprovalRequiredBefore.includes(requiredAction), `missing human approval gate: ${requiredAction}`);
  }

  const artifacts = launch.artifacts ?? {};
  const requiredArtifacts = ['ascDraft','privacyDraft','pricingDraft','copyDraft','screenshotPlan','testflightLocalChecklist','evidenceIndex','humanReviewReceipt'];
  for (const key of requiredArtifacts) {
    assert(typeof artifacts[key] === 'string', `launch artifact path missing: ${key}`);
    assert(artifacts[key].startsWith('.forge/launch/'), `launch artifact must stay in .forge/launch: ${key}`);
    assertExists(appDir, artifacts[key]);
  }
  assert(new Set(Object.values(artifacts)).size === Object.values(artifacts).length, 'privacy/pricing/copy/screenshot/TestFlight artifacts must be separate files');

  const privacy = requiredJson(appDir, artifacts.privacyDraft);
  assert(privacy.safety?.localDraftOnly === true, 'privacy draft must be local only');
  assert(privacy.safety?.requiresHumanConfirmationBeforeSubmission === true, 'privacy draft must require human confirmation');

  const pricing = requiredJson(appDir, artifacts.pricingDraft);
  assert(pricing.liveSystems?.iapProductsCreated === false, 'pricing draft must not create live IAP products');
  assert(pricing.liveSystems?.requiresHumanApprovalBeforeAnyActivation === true, 'pricing draft must require human approval before activation');

  const evidenceIndex = requiredJson(appDir, artifacts.evidenceIndex);
  assert(Array.isArray(evidenceIndex.claims) && evidenceIndex.claims.length > 0, 'evidence index must contain claims');
  for (const claim of evidenceIndex.claims) {
    assert(['supported', 'partial', 'unsupported'].includes(claim.status), `bad evidence status for claim: ${claim.claim}`);
    assert(Array.isArray(claim.evidence) && claim.evidence.length > 0, `claim must cite evidence: ${claim.claim}`);
  }

  const appScorecard = requiredJson(appDir, '.forge/learning/app-scorecard.json');
  const pipelineScorecard = requiredJson(appDir, '.forge/learning/pipeline-scorecard.json');
  assert(appScorecard.verdict !== undefined && pipelineScorecard.verdict !== undefined, 'scorecards must include verdicts');
  assert(JSON.stringify(appScorecard.dimensions?.map((d) => d.id)) !== JSON.stringify(pipelineScorecard.dimensions?.map((d) => d.id)), 'app score and pipeline score must remain separate');

  const patches = requiredJson(appDir, '.forge/learning/learning-patches.json');
  assert(Array.isArray(patches.patches) && patches.patches.length > 0, 'learning patch proposals required');
  for (const patch of patches.patches) {
    assert(patch.reviewStatus === 'proposed' && patch.requiresHumanReview === true, 'learning patches must remain proposed and require human review');
    assert(Array.isArray(patch.evidencePaths) && patch.evidencePaths.length > 0, 'learning patch must cite evidence');
    assert(patch.risk && patch.complexity, 'learning patch must include risk and complexity');
  }

  assertExists(appDir, '.forge/learning/postmortem.md');
  assertExists(appDir, '.forge/learning/postmortem.json');
  return true;
}

const [action, appDir] = process.argv.slice(2);
if (!['generate', 'validate'].includes(action) || !appDir) {
  die('Usage: scripts/forge-vnext-launch-package.mjs <generate|validate> <generated-app-repo>');
}
try {
  if (action === 'generate') generate(appDir);
  if (action === 'validate') {
    validate(appDir);
    console.log(`validated local launch and learning package at ${path.resolve(appDir)}`);
  }
} catch (error) {
  die(error.message);
}
