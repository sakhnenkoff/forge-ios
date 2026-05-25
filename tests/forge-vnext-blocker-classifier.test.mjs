import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { classifyBlocker, classifyBlockers } from '../scripts/forge-vnext-blocker-classifier.mjs';

const repoRoot = path.resolve(new URL('..', import.meta.url).pathname);
const scriptPath = path.join(repoRoot, 'scripts', 'forge-vnext-blocker-classifier.mjs');

function runClassifier(args = []) {
  return spawnSync(process.execPath, [scriptPath, '--json', ...args], {
    cwd: repoRoot,
    encoding: 'utf8'
  });
}

test('probe classifies observed Forge blocker classes and proposes prevention tasks', () => {
  const result = runClassifier(['--probe']);
  assert.equal(result.status, 0, result.stderr || result.stdout);
  const report = JSON.parse(result.stdout);

  assert.equal(report.schema_version, 'forge.blocker-taxonomy.v1');
  const byId = new Map(report.blockers.map((blocker) => [blocker.blocker_id, blocker]));

  assert.equal(byId.get('probe-impl-generic-review-with-verifier').classification, 'dependency_shape_bug');
  assert.equal(byId.get('probe-generated-residue').classification, 'pipeline_bug');
  assert.equal(byId.get('probe-visual-invisible').classification, 'pipeline_bug');
  assert.equal(byId.get('probe-watchdog-vague-blocked').classification, 'pipeline_bug');
  assert.equal(byId.get('probe-repeated-cleanup').classification, 'pipeline_bug');
  assert.equal(byId.get('probe-real-taste-gate').classification, 'real_human_gate');
  assert.equal(byId.get('probe-build-failure').classification, 'mechanical_repair');
  assert.equal(byId.get('probe-worker-error').classification, 'worker_error');

  for (const blocker of report.blockers.filter((item) => item.classification !== 'real_human_gate')) {
    assert.equal(blocker.matvii_needed, false);
    assert.ok(blocker.prevention_task?.title, `missing prevention task for ${blocker.blocker_id}`);
    assert.match(blocker.prevention_task.body, /durable prevention/);
  }

  assert.equal(byId.get('probe-real-taste-gate').matvii_needed, true);
  assert.equal(byId.get('probe-real-taste-gate').prevention_task, null);
  assert.match(byId.get('probe-real-taste-gate').exact_decision_needed, /Matvii must make/);
});

test('generic review is not treated as a real human gate when verifier or judge children exist', () => {
  const classification = classifyBlocker({
    id: 'blocked-impl',
    title: 'Feature implementation complete',
    reason: 'review-required: needs human eyes before merge',
    children: [{ title: 'Forge verifier evidence check', assignee: 'forgeverifier' }]
  });

  assert.equal(classification.classification, 'dependency_shape_bug');
  assert.equal(classification.matvii_needed, false);
  assert.equal(classification.routing_action, 'fix_kanban_dependency_edges_or_card_status');
});

test('classification report keeps counts stable for routing dashboards', () => {
  const report = classifyBlockers([
    { id: 'a', title: 'App Store signing question' },
    { id: 'b', title: 'xcodebuild compile error' },
    { id: 'c', title: 'template residue copied into generated app' }
  ]);

  assert.deepEqual(report.counts, {
    real_human_gate: 1,
    mechanical_repair: 1,
    pipeline_bug: 1
  });
});
