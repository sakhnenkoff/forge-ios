import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import path from 'node:path';

const repoRoot = path.resolve(new URL('..', import.meta.url).pathname);
const scriptPath = path.join(repoRoot, 'scripts', 'forge-vnext-final-audit.mjs');

function runAudit(args = []) {
  return spawnSync(process.execPath, [scriptPath, '--json', ...args], {
    cwd: repoRoot,
    encoding: 'utf8'
  });
}

test('final audit validates the default fixture matrix and asks for human decision before any second app generation', () => {
  const result = runAudit();
  assert.equal(result.status, 0, result.stderr || result.stdout);
  const report = JSON.parse(result.stdout);

  assert.equal(report.overall_status, 'ready_for_human_decision');
  assert.equal(report.safety.second_app_generated, false);
  assert.deepEqual(report.decision_options.map((option) => option.id), ['proceed', 'repair', 'tighten']);

  const byFixture = new Map(report.fixtures.map((fixture) => [fixture.id, fixture]));
  assert.equal(byFixture.get('minimal-app-specific-pass').status, 'pass');
  assert.ok(byFixture.get('minimal-app-specific-pass').gates.every((gate) => gate.actual === 'pass'));

  assert.equal(byFixture.get('shallow-dashboard-fail').status, 'expected_fail');
  assert.ok(byFixture.get('shallow-dashboard-fail').gates.some((gate) => gate.name === 'product' && gate.actual === 'fail'));
  assert.ok(byFixture.get('shallow-dashboard-fail').gates.some((gate) => gate.name === 'design-pre-native' && gate.actual === 'fail'));

  assert.equal(byFixture.get('token-reskin-fail').status, 'expected_fail');
  assert.ok(byFixture.get('token-reskin-fail').gates.some((gate) => gate.name === 'design-pre-native' && gate.actual === 'fail'));

  assert.equal(byFixture.get('missing-evidence-fail').status, 'expected_fail');
  assert.ok(byFixture.get('missing-evidence-fail').gates.some((gate) => gate.name === 'verifier' && gate.actual === 'fail'));

  assert.equal(byFixture.get('substitute-evidence-missing-owner-fail').status, 'expected_fail');
  assert.ok(byFixture.get('substitute-evidence-missing-owner-fail').gates.some((gate) => gate.name === 'verifier' && gate.actual === 'fail'));

  assert.ok(report.evidence_gaps.some((gap) => gap.includes('fixture screenshots')));
  assert.ok(report.repair_suggestions.some((suggestion) => suggestion.includes('replace placeholder')));
});

test('final audit can run only the minimal pass fixture through every local validator', () => {
  const result = runAudit(['--fixture', 'minimal-app-specific-pass']);
  assert.equal(result.status, 0, result.stderr || result.stdout);
  const report = JSON.parse(result.stdout);

  assert.equal(report.fixtures.length, 1);
  assert.equal(report.fixtures[0].id, 'minimal-app-specific-pass');
  assert.equal(report.fixtures[0].status, 'pass');
  assert.deepEqual(report.fixtures[0].gates.map((gate) => [gate.name, gate.actual]), [
    ['product', 'pass'],
    ['design-final', 'pass'],
    ['verifier', 'pass'],
    ['launch-learning', 'pass']
  ]);
});
