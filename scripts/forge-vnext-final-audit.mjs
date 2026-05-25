#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const repoRoot = path.resolve(new URL('..', import.meta.url).pathname);
const fixtureRoot = path.join(repoRoot, 'docs', 'forge-vnext', 'fixtures');

const DEFAULT_FIXTURES = [
  {
    id: 'minimal-app-specific-pass',
    expectation: 'pass',
    gates: [
      gate('product', 'pass', ['scripts/forge-vnext-gate-validate.mjs', 'product', fixturePath('minimal-app-specific-pass')]),
      gate('design-final', 'pass', ['scripts/forge-vnext-design-gate-verify.mjs', '--phase', 'final', fixturePath('minimal-app-specific-pass')]),
      gate('verifier', 'pass', ['scripts/forge-vnext-verifier.mjs', '--app-path', fixturePath('minimal-app-specific-pass')]),
      gate('launch-learning', 'pass', ['scripts/forge-vnext-launch-package.mjs', 'validate', fixturePath('minimal-app-specific-pass')])
    ]
  },
  {
    id: 'shallow-dashboard-fail',
    expectation: 'fail',
    gates: [
      gate('product', 'fail', ['scripts/forge-vnext-gate-validate.mjs', 'product', fixturePath('shallow-dashboard-fail')]),
      gate('design-pre-native', 'fail', ['scripts/forge-vnext-design-gate-verify.mjs', '--phase', 'pre-native', fixturePath('shallow-dashboard-fail')])
    ]
  },
  {
    id: 'token-reskin-fail',
    expectation: 'fail',
    gates: [
      gate('design-pre-native', 'fail', ['scripts/forge-vnext-design-gate-verify.mjs', '--phase', 'pre-native', fixturePath('token-reskin-fail')])
    ]
  },
  {
    id: 'missing-evidence-fail',
    expectation: 'fail',
    gates: [
      gate('verifier', 'fail', ['scripts/forge-vnext-verifier.mjs', '--app-path', fixturePath('missing-evidence-fail')])
    ]
  },
  {
    id: 'substitute-evidence-missing-owner-fail',
    expectation: 'fail',
    gates: [
      gate('verifier', 'fail', ['scripts/forge-vnext-verifier.mjs', '--app-path', fixturePath('substitute-evidence-missing-owner-fail')])
    ]
  },
  {
    id: 'substitute-evidence-pass',
    expectation: 'pass',
    gates: [
      gate('verifier', 'pass', ['scripts/forge-vnext-verifier.mjs', '--app-path', fixturePath('substitute-evidence-pass')])
    ]
  }
];

function fixturePath(id) {
  return path.join(fixtureRoot, id);
}

function gate(name, expected, argv) {
  return { name, expected, argv };
}

function parseArgs(argv) {
  const args = { json: false, fixture: null, receipt: null };
  for (let index = 2; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--json') args.json = true;
    else if (arg === '--fixture') args.fixture = argv[++index];
    else if (arg.startsWith('--fixture=')) args.fixture = arg.slice('--fixture='.length);
    else if (arg === '--receipt') args.receipt = argv[++index];
    else if (arg.startsWith('--receipt=')) args.receipt = arg.slice('--receipt='.length);
    else if (arg === '-h' || arg === '--help') args.help = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return args;
}

function usage() {
  return `Usage:\n  node scripts/forge-vnext-final-audit.mjs [--json] [--fixture <fixture-id>] [--receipt <path>]\n\nRuns the Forge vNext local dry-run fixture matrix. Expected-fail fixtures are successful when they fail at the configured gate. This script performs no app generation, no signing, no TestFlight/App Store Connect calls, and no external network actions.`;
}

function runGate(definition) {
  const executable = process.execPath;
  const [script, ...rest] = definition.argv;
  const result = spawnSync(executable, [path.join(repoRoot, script), ...rest], {
    cwd: repoRoot,
    encoding: 'utf8',
    maxBuffer: 1024 * 1024 * 8
  });
  const actual = result.status === 0 ? 'pass' : 'fail';
  return {
    name: definition.name,
    expected: definition.expected,
    actual,
    ok: actual === definition.expected,
    command: ['node', script, ...rest.map((item) => path.isAbsolute(item) ? path.relative(repoRoot, item) : item)].join(' '),
    exit_code: result.status,
    stdout: trimOutput(result.stdout),
    stderr: trimOutput(result.stderr)
  };
}

function trimOutput(value) {
  const text = (value ?? '').trim();
  if (text.length <= 3000) return text;
  return `${text.slice(0, 1200)}\n... <trimmed> ...\n${text.slice(-1200)}`;
}

function evaluateFixture(fixture) {
  const gates = fixture.gates.map(runGate);
  const matchedExpectations = gates.every((item) => item.ok);
  const anyExpectedFailureHappened = fixture.expectation === 'fail' && gates.some((item) => item.expected === 'fail' && item.actual === 'fail');
  const status = fixture.expectation === 'pass'
    ? (matchedExpectations ? 'pass' : 'unexpected_fail')
    : (matchedExpectations && anyExpectedFailureHappened ? 'expected_fail' : 'unexpected_pass_or_wrong_gate');
  return {
    id: fixture.id,
    path: path.relative(repoRoot, fixturePath(fixture.id)),
    expectation: fixture.expectation,
    status,
    gates
  };
}

function buildReport(fixtures) {
  const fixtureReports = fixtures.map(evaluateFixture);
  const matrixOk = fixtureReports.every((fixture) => ['pass', 'expected_fail'].includes(fixture.status));
  return {
    schema_version: 'forge.vnext_final_audit.v1',
    generated_at: new Date().toISOString(),
    overall_status: matrixOk ? 'ready_for_human_decision' : 'repair_required',
    safety: {
      local_repo_edits_only: true,
      second_app_generated: false,
      app_store_connect_touched: false,
      testflight_touched: false,
      signing_or_iap_touched: false,
      external_network_actions: false
    },
    fixtures: fixtureReports,
    evidence_gaps: [
      'minimal-app-specific-pass uses fixture screenshots/video placeholders, not native simulator captures from a new generated app',
      'schema enforcement is currently manual inside dependency-free Node validators rather than a shared JSON Schema engine',
      'launch/privacy/pricing artifacts are local drafts and still require human review before any live use'
    ],
    repair_suggestions: [
      'replace placeholder fixture screenshots/video with real native simulator evidence during the approved second-app run',
      'add a shared schema validator such as Ajv only after Matvii accepts the added dependency/policy',
      'keep the verifier evidence index as the source of truth and fail any app that lacks required screenshots, videos, or approved substitutes',
      'repair product/design gates before native expansion whenever a fixture-like app fails the shallow dashboard or token-reskin checks'
    ],
    decision_options: [
      {
        id: 'proceed',
        label: 'Proceed to second-app generation',
        meaning: 'Accept this local dry-run bar and generate one new proof app under the repaired gates.'
      },
      {
        id: 'repair',
        label: 'Repair first',
        meaning: 'Fix the named evidence/schema/tooling gaps before generating the second app.'
      },
      {
        id: 'tighten',
        label: 'Tighten the bar',
        meaning: 'Raise fixture expectations, add more negative fixtures, or require full JSON Schema validation before proceeding.'
      }
    ]
  };
}

function renderMarkdown(report) {
  const lines = [];
  lines.push('# Forge vNext Final Dry-Run Receipt');
  lines.push('');
  lines.push(`Generated: ${report.generated_at}`);
  lines.push(`Overall status: ${report.overall_status}`);
  lines.push('Second app generated: false');
  lines.push('');
  lines.push('## Fixture gate matrix');
  lines.push('');
  lines.push('| Fixture | Status | Gates |');
  lines.push('|---|---|---|');
  for (const fixture of report.fixtures) {
    const gates = fixture.gates.map((item) => `${item.name}: ${item.actual} (expected ${item.expected})`).join('<br>');
    lines.push(`| ${fixture.id} | ${fixture.status} | ${gates} |`);
  }
  lines.push('');
  lines.push('## Evidence gaps');
  for (const gap of report.evidence_gaps) lines.push(`- ${gap}`);
  lines.push('');
  lines.push('## Repair suggestions');
  for (const suggestion of report.repair_suggestions) lines.push(`- ${suggestion}`);
  lines.push('');
  lines.push('## Matvii decision options');
  for (const option of report.decision_options) lines.push(`- ${option.id}: ${option.meaning}`);
  lines.push('');
  return `${lines.join('\n')}\n`;
}

function main() {
  const args = parseArgs(process.argv);
  if (args.help) {
    console.log(usage());
    return;
  }
  let fixtures = DEFAULT_FIXTURES;
  if (args.fixture) {
    fixtures = DEFAULT_FIXTURES.filter((fixture) => fixture.id === args.fixture);
    if (fixtures.length === 0) throw new Error(`Unknown fixture: ${args.fixture}`);
  }
  for (const fixture of fixtures) {
    if (!existsSync(fixturePath(fixture.id))) throw new Error(`Missing fixture path: ${fixturePath(fixture.id)}`);
  }
  const report = buildReport(fixtures);
  if (args.receipt) {
    const receiptPath = path.resolve(args.receipt);
    mkdirSync(path.dirname(receiptPath), { recursive: true });
    writeFileSync(receiptPath, renderMarkdown(report));
  }
  if (args.json) console.log(JSON.stringify(report, null, 2));
  else console.log(renderMarkdown(report));
  if (report.overall_status !== 'ready_for_human_decision') process.exitCode = 1;
}

try {
  main();
} catch (error) {
  console.error(error.message);
  process.exitCode = 2;
}
