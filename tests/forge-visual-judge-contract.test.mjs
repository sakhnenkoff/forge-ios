import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

const repoRoot = path.resolve(new URL('..', import.meta.url).pathname);
const schemasRoot = path.join(repoRoot, 'docs/forge-vnext/schemas');
const fixturesRoot = path.join(repoRoot, 'docs/forge-vnext/fixtures');

const requiredDimensions = [
  'reference_quality',
  'original_synthesis',
  'first_screen_specificity',
  'workflow_shape',
  'native_ios_craft',
  'visual_hierarchy_density',
  'emotional_tone_copy',
  'evidence_integrity',
  'distinctiveness_non_bullshit'
];

const hardMinimums = {
  reference_quality: 8,
  original_synthesis: 10,
  first_screen_specificity: 11,
  workflow_shape: 9,
  native_ios_craft: 7,
  visual_hierarchy_density: 7,
  emotional_tone_copy: 6,
  evidence_integrity: 8,
  distinctiveness_non_bullshit: 8
};

function readJson(relativePath) {
  return JSON.parse(fs.readFileSync(path.join(repoRoot, relativePath), 'utf8'));
}

function readFixture(fixture, file = '.forge/judges/visual-judge-post-native.json') {
  return JSON.parse(fs.readFileSync(path.join(fixturesRoot, fixture, file), 'utf8'));
}

function assertJudgeShape(judge) {
  assert.equal(judge.schema_version, 'forge.visual_judge.v1');
  assert.equal(judge.rubric_version, 'forge.visual_judge.rubric.v1');
  assert.ok(['pre_native', 'post_native'].includes(judge.stage));
  assert.ok(['pass', 'repair_required', 'hard_fail_ai_slop', 'hard_fail_safety', 'kill_direction'].includes(judge.verdict));
  assert.equal(judge.score_thresholds.total_pass_min, 80);
  assert.equal(judge.score_thresholds.hard_fail_policy, 'any_hard_fail_blocks_even_if_total_score_passes');
  assert.deepEqual(judge.score_thresholds.hard_minimums, hardMinimums);
  for (const dimension of requiredDimensions) {
    assert.equal(typeof judge.scores[dimension], 'number', `${dimension} score missing`);
    assert.ok(judge.dimension_findings.some((finding) => finding.dimension === dimension), `${dimension} finding missing`);
  }
  assert.equal(
    judge.scores.total,
    requiredDimensions.reduce((sum, dimension) => sum + judge.scores[dimension], 0),
    'total score must equal dimension sum'
  );
}

function assertJudgeBusinessRules(judge) {
  assertJudgeShape(judge);
  if (judge.verdict === 'pass') {
    assert.equal(judge.hard_fails.length, 0, 'pass verdict cannot carry hard failures');
    assert.ok(judge.scores.total >= judge.score_thresholds.total_pass_min, 'pass verdict must meet total threshold');
    for (const [dimension, hardMin] of Object.entries(judge.score_thresholds.hard_minimums)) {
      assert.ok(judge.scores[dimension] >= hardMin, `pass verdict must meet hard minimum for ${dimension}`);
    }
  } else {
    assert.equal(judge.human_gate_allowed, false, 'non-pass verdicts cannot allow human review');
  }

  if (judge.stage === 'pre_native' && judge.verdict === 'pass') {
    assert.equal(judge.next_gate, 'native_expansion');
    assert.equal(judge.next_gate_allowed, true);
    assert.equal(judge.human_gate_allowed, false);
  }

  if (judge.stage === 'post_native' && judge.verdict === 'pass') {
    assert.equal(judge.next_gate, 'human_review');
    assert.equal(judge.next_gate_allowed, true);
    assert.equal(judge.human_gate_allowed, true);
    assert.ok(Array.isArray(judge.inputs.native_screenshots) && judge.inputs.native_screenshots.length >= 5);
    assert.ok(Array.isArray(judge.inputs.accessibility_snapshots) && judge.inputs.accessibility_snapshots.length >= 5);
  }
}

test('visual judge schemas are valid JSON Schema documents', () => {
  for (const schemaName of ['forge.visual-judge.v1.schema.json', 'forge.visual-evidence-packet.v1.schema.json']) {
    const schema = JSON.parse(fs.readFileSync(path.join(schemasRoot, schemaName), 'utf8'));
    assert.equal(schema.$schema, 'https://json-schema.org/draft/2020-12/schema');
    assert.ok(schema.$id.includes(schemaName));
  }
});

test('pre-native pass fixture allows native expansion but not human review', () => {
  const judge = readFixture('visual-judge-pre-native-pass', '.forge/judges/visual-judge-pre-native.json');
  assertJudgeBusinessRules(judge);
  assert.equal(judge.stage, 'pre_native');
  assert.equal(judge.verdict, 'pass');
  assert.deepEqual(judge.hard_fails, []);
  assert.equal(judge.scores.total >= 80, true);
  assert.equal(judge.next_gate, 'native_expansion');
  assert.equal(judge.next_gate_allowed, true);
  assert.equal(judge.human_gate_allowed, false);
});

test('post-native pass fixture is the only happy path into human review', () => {
  const judge = readFixture('visual-judge-post-native-pass');
  assertJudgeBusinessRules(judge);
  assert.equal(judge.stage, 'post_native');
  assert.equal(judge.verdict, 'pass');
  assert.deepEqual(judge.hard_fails, []);
  assert.equal(judge.next_gate, 'human_review');
  assert.equal(judge.next_gate_allowed, true);
  assert.equal(judge.human_gate_allowed, true);
  assert.deepEqual(judge.inputs.native_screenshots.map((shot) => shot.state), [
    'activation',
    'core-loop-after-action',
    'returning-progress',
    'empty-error',
    'money-boundary'
  ]);
});

test('AI slop fail fixture blocks despite usable references/evidence', () => {
  const judge = readFixture('visual-judge-ai-slop-fail');
  assertJudgeBusinessRules(judge);
  assert.equal(judge.verdict, 'hard_fail_ai_slop');
  assert.ok(judge.hard_fails.includes('generic_first_screen'));
  assert.ok(judge.hard_fails.includes('token_reskin'));
  assert.ok(judge.hard_fails.includes('human_says_slop'));
  assert.equal(judge.next_gate_allowed, false);
  assert.equal(judge.human_gate_allowed, false);
  assert.ok(judge.repair_requests.some((repair) => repair.severity === 'blocking'));
});

test('missing screenshot fail fixture blocks post-native review', () => {
  const judge = readFixture('visual-judge-missing-screenshots-fail');
  assertJudgeBusinessRules(judge);
  assert.equal(judge.stage, 'post_native');
  assert.equal(judge.verdict, 'hard_fail_ai_slop');
  assert.ok(judge.hard_fails.includes('screenshots_missing'));
  assert.ok(judge.hard_fails.includes('empty_shell'));
  assert.equal(judge.next_gate_allowed, false);
  assert.equal(judge.human_gate_allowed, false);
});

test('visual judge business rules reject invalid pass artifacts', () => {
  const preNative = readFixture('visual-judge-pre-native-pass', '.forge/judges/visual-judge-pre-native.json');
  assert.throws(
    () => assertJudgeBusinessRules({ ...preNative, human_gate_allowed: true }),
    /Expected values to be strictly equal/
  );

  const lowScore = JSON.parse(JSON.stringify(preNative));
  lowScore.scores.reference_quality = 8;
  lowScore.scores.original_synthesis = 10;
  lowScore.scores.first_screen_specificity = 11;
  lowScore.scores.total = requiredDimensions.reduce((sum, dimension) => sum + lowScore.scores[dimension], 0);
  assert.equal(lowScore.scores.total, 79);
  assert.throws(() => assertJudgeBusinessRules(lowScore), /total threshold/);

  const belowMinimum = JSON.parse(JSON.stringify(preNative));
  belowMinimum.scores.first_screen_specificity = 10;
  belowMinimum.scores.total = requiredDimensions.reduce((sum, dimension) => sum + belowMinimum.scores[dimension], 0);
  assert.throws(() => assertJudgeBusinessRules(belowMinimum), /hard minimum/);

  const postNative = readFixture('visual-judge-post-native-pass');
  const missingNativeEvidence = JSON.parse(JSON.stringify(postNative));
  missingNativeEvidence.inputs.native_screenshots = missingNativeEvidence.inputs.native_screenshots.slice(0, 4);
  assert.throws(() => assertJudgeBusinessRules(missingNativeEvidence), /native_screenshots/);
});

test('markdown summary names the contract, thresholds, and fixture matrix', () => {
  const summary = fs.readFileSync(path.join(repoRoot, 'docs/forge-vnext/visual-judge-contract-and-rubric.md'), 'utf8');
  for (const required of [
    'forge.visual-judge.v1.schema.json',
    'forge.visual-evidence-packet.v1.schema.json',
    'scores.total >= 80',
    'human_says_slop',
    'visual-judge-post-native-pass',
    'visual-judge-ai-slop-fail'
  ]) {
    assert.ok(summary.includes(required), `summary should include ${required}`);
  }
});
