import test from 'node:test';
import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { mkdtempSync, cpSync, readFileSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';

const repoRoot = path.resolve(new URL('..', import.meta.url).pathname);
const scriptPath = path.join(repoRoot, 'scripts', 'forge-vnext-launch-package.mjs');
const fixtureRoot = path.join(repoRoot, 'docs', 'forge-vnext', 'fixtures', 'minimal-app-specific-pass');

function cloneFixture() {
  const dir = mkdtempSync(path.join(tmpdir(), 'forge-launch-package-'));
  cpSync(fixtureRoot, dir, { recursive: true });
  return dir;
}

function runScript(args, cwd = repoRoot) {
  return execFileSync(process.execPath, [scriptPath, ...args], { cwd, encoding: 'utf8' });
}

test('generate creates separate local-only launch and learning artifacts from app-specific fixture', () => {
  const appDir = cloneFixture();
  try {
    runScript(['generate', appDir]);

    const launchDir = path.join(appDir, '.forge', 'launch');
    const learningDir = path.join(appDir, '.forge', 'learning');
    const launchPackage = JSON.parse(readFileSync(path.join(launchDir, 'launch-package.json'), 'utf8'));
    const privacyDraft = JSON.parse(readFileSync(path.join(launchDir, 'privacy-draft.json'), 'utf8'));
    const pricingDraft = JSON.parse(readFileSync(path.join(launchDir, 'pricing-draft.json'), 'utf8'));
    const pipelineScorecard = JSON.parse(readFileSync(path.join(learningDir, 'pipeline-scorecard.json'), 'utf8'));
    const appScorecard = JSON.parse(readFileSync(path.join(learningDir, 'app-scorecard.json'), 'utf8'));
    const learningPatches = JSON.parse(readFileSync(path.join(learningDir, 'learning-patches.json'), 'utf8'));

    assert.equal(launchPackage.safety.localDraftOnly, true);
    assert.equal(launchPackage.safety.liveExternalActionsPerformed, false);
    assert.equal(launchPackage.app.name, 'Focus Pantry');
    assert.notEqual(launchPackage.app.name, 'DayRateLab');
    assert.equal(launchPackage.artifacts.privacyDraft, '.forge/launch/privacy-draft.json');
    assert.equal(launchPackage.artifacts.pricingDraft, '.forge/launch/pricing-draft.json');
    assert.equal(launchPackage.artifacts.copyDraft, '.forge/launch/copy-draft.md');
    assert.equal(launchPackage.artifacts.screenshotPlan, '.forge/launch/screenshot-plan.json');
    assert.equal(launchPackage.artifacts.testflightLocalChecklist, '.forge/launch/testflight-local-checklist.md');
    assert.ok(launchPackage.sourceInputs.research.includes('.forge/research/evidence-matrix.json'));
    assert.ok(launchPackage.launchReadiness.humanApprovalRequiredBefore.includes('TestFlight upload'));

    assert.equal(privacyDraft.safety.localDraftOnly, true);
    assert.equal(privacyDraft.safety.requiresHumanConfirmationBeforeSubmission, true);
    assert.equal(pricingDraft.liveSystems.iapProductsCreated, false);
    assert.equal(pricingDraft.liveSystems.requiresHumanApprovalBeforeAnyActivation, true);

    assert.notDeepEqual(appScorecard.dimensions.map((d) => d.id), pipelineScorecard.dimensions.map((d) => d.id));
    assert.equal(pipelineScorecard.verdict, 'pipeline_acceptable');
    assert.ok(learningPatches.patches.length >= 1);
    assert.ok(learningPatches.patches.every((patch) => patch.reviewStatus === 'proposed'));
    assert.ok(learningPatches.patches.every((patch) => patch.requiresHumanReview === true));

    runScript(['validate', appDir]);
  } finally {
    rmSync(appDir, { recursive: true, force: true });
  }
});

test('validate rejects learning patches that are treated as applied without human review', () => {
  const appDir = cloneFixture();
  try {
    runScript(['generate', appDir]);
    const patchesPath = path.join(appDir, '.forge', 'learning', 'learning-patches.json');
    const patches = JSON.parse(readFileSync(patchesPath, 'utf8'));
    patches.patches[0].reviewStatus = 'applied';
    patches.patches[0].requiresHumanReview = false;
    writeFileSync(patchesPath, JSON.stringify(patches, null, 2) + '\n');

    const result = spawnSync(process.execPath, [scriptPath, 'validate', appDir], { encoding: 'utf8' });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /learning patches must remain proposed and require human review/);
  } finally {
    rmSync(appDir, { recursive: true, force: true });
  }
});
