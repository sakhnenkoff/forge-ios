#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';

const TAXONOMY_VERSION = 'forge.blocker-taxonomy.v1';

const PROBE_BLOCKERS = [
  {
    id: 'probe-impl-generic-review-with-verifier',
    title: 'Implementation blocked: generic human review requested',
    reason: 'review-required: implementation finished, needs human eyes before continuing',
    children: [
      { id: 'probe-verifier-child', title: 'Verifier: run proof-app checks', assignee: 'forgeverifier' },
      { id: 'probe-judge-child', title: 'Judge: skeptical native proof audit', assignee: 'forgejudge' }
    ],
    expected_classification: 'dependency_shape_bug'
  },
  {
    id: 'probe-generated-residue',
    title: 'Generated app contains copied Forge control-plane residue',
    reason: 'verifier found skills/, forge-cli, StoreKit paywall, auth, and scripts copied into proof app',
    expected_classification: 'pipeline_bug'
  },
  {
    id: 'probe-visual-invisible',
    title: 'Native proof visual state invisible to Matvii',
    reason: 'no screenshot packet or visual review artifact exists before final acceptance',
    expected_classification: 'pipeline_bug'
  },
  {
    id: 'probe-watchdog-vague-blocked',
    title: 'Watchdog update says blocked',
    reason: 'blocked; no exact inspect command, unblock command, dispatch command, or log command provided',
    expected_classification: 'pipeline_bug'
  },
  {
    id: 'probe-repeated-cleanup',
    title: 'Repeated app-specific cleanup after every trial',
    reason: 'same generated junk cleanup repeats instead of becoming a generator sanitizer, substrate, or verifier patch',
    expected_classification: 'pipeline_bug'
  },
  {
    id: 'probe-real-taste-gate',
    title: 'Matvii direction gate: choose Pantry Rescue tradeoff',
    reason: 'taste/product approval needed before native generation; two viable options remain',
    expected_classification: 'real_human_gate'
  },
  {
    id: 'probe-build-failure',
    title: 'Mock build failed',
    reason: 'xcodebuild compile error in generated app ViewModel; verifier cannot pass until code is repaired',
    expected_classification: 'mechanical_repair'
  },
  {
    id: 'probe-worker-error',
    title: 'Worker blocked without context',
    reason: 'stuck; unclear what to do next',
    expected_classification: 'worker_error'
  }
];

const CLASS_DETAILS = {
  real_human_gate: {
    matvii_needed: true,
    routing_action: 'ask_matvii_exact_decision',
    default_assignee: null,
    prevention_kind: 'document_gate_boundary',
    summary: 'Needs Matvii because it touches taste, safety, deletion, external/account/money/signing/App Store/TestFlight/work-system, or final acceptance.'
  },
  mechanical_repair: {
    matvii_needed: false,
    routing_action: 'create_or_dispatch_repair_task',
    default_assignee: 'forgeverifier',
    prevention_kind: 'repair_current_artifact',
    summary: 'A concrete artifact is broken; route to the lane that can repair or verify it.'
  },
  pipeline_bug: {
    matvii_needed: false,
    routing_action: 'create_pipeline_hardening_task',
    default_assignee: 'forgejudge',
    prevention_kind: 'add_generator_substrate_verifier_or_watchdog_guard',
    summary: 'The same failure class can recur unless Forge adds a durable prevention mechanism.'
  },
  worker_error: {
    matvii_needed: false,
    routing_action: 'reclaim_reassign_or_retry_with_corrected_instructions',
    default_assignee: 'forgejudge',
    prevention_kind: 'fix_worker_prompt_or_assignment',
    summary: 'The worker failed to follow available instructions or produced an unusable block reason.'
  },
  dependency_shape_bug: {
    matvii_needed: false,
    routing_action: 'fix_kanban_dependency_edges_or_card_status',
    default_assignee: 'forgejudge',
    prevention_kind: 'fix_routing_convention',
    summary: 'The board shape is wrong; fix dependencies/statuses instead of asking Matvii.'
  }
};

function usage() {
  return `Usage:\n  node scripts/forge-vnext-blocker-classifier.mjs --probe [--json]\n  node scripts/forge-vnext-blocker-classifier.mjs --input <blockers.json> [--json]\n\nInput JSON may be an array of blocker cards or an object with a blockers/cards/tasks array. This tool is local-only: it reads files, classifies blocker text, and prints routing/prevention recommendations; it does not mutate Kanban or call external services.`;
}

function parseArgs(argv) {
  const args = { json: false, probe: false, input: null };
  for (let index = 2; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--json') args.json = true;
    else if (arg === '--probe') args.probe = true;
    else if (arg === '--input') args.input = argv[++index];
    else if (arg.startsWith('--input=')) args.input = arg.slice('--input='.length);
    else if (arg === '--help' || arg === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return args;
}

function normalizeText(value) {
  if (value === null || value === undefined) return '';
  if (typeof value === 'string') return value;
  if (Array.isArray(value)) return value.map(normalizeText).join(' ');
  if (typeof value === 'object') return Object.values(value).map(normalizeText).join(' ');
  return String(value);
}

function blockerText(blocker) {
  return normalizeText([
    blocker.id,
    blocker.title,
    blocker.body,
    blocker.reason,
    blocker.result,
    blocker.summary,
    blocker.comments,
    blocker.metadata,
    blocker.children,
    blocker.parent_handoffs
  ]).toLowerCase();
}

function hasAny(text, patterns) {
  return patterns.some((pattern) => pattern.test(text));
}

function childLooksLikeVerifierOrJudge(blocker) {
  const children = Array.isArray(blocker.children) ? blocker.children : [];
  const childText = normalizeText(children).toLowerCase();
  return /\b(verifier|verification|judge|audit|reviewer|forgeverifier|forgejudge)\b/.test(childText);
}

export function classifyBlocker(blocker) {
  const text = blockerText(blocker);
  const genericReview = hasAny(text, [
    /generic human review/,
    /review-required/,
    /needs? (human )?eyes/,
    /human review/,
    /manual review/
  ]);

  if (genericReview && childLooksLikeVerifierOrJudge(blocker)) {
    return buildClassification(blocker, 'dependency_shape_bug', [
      'implementation card asked for generic review while verifier/judge children already own verification'
    ]);
  }

  if (hasAny(text, [
    /missing dependency edge/,
    /wrong parent/,
    /wrong child/,
    /blocked on child/,
    /waiting for verifier child/,
    /waiting for judge child/,
    /dependency shape/,
    /fan-?in/,
    /fan-?out/
  ])) {
    return buildClassification(blocker, 'dependency_shape_bug', ['Kanban dependency/status shape appears wrong']);
  }

  if (hasAny(text, [
    /visual state invisible/,
    /screenshot packet/,
    /visual review packet/,
    /watchdog.*without action/,
    /watchdog.*no exact/,
    /no exact inspect/,
    /no inspect command/,
    /no unblock command/,
    /no dispatch command/,
    /repeated .*cleanup/,
    /cleanup repeats/,
    /same .*cleanup repeats/
  ])) {
    return buildClassification(blocker, 'pipeline_bug', ['matches specific Forge blocker-prevention rule before human-gate fallback']);
  }

  if (hasAny(text, [
    /\btaste\b/,
    /product approval/,
    /direction gate/,
    /final acceptance/,
    /safety gate/,
    /delete|deletion|quarantine/,
    /external\b/,
    /account/,
    /credentials?/,
    /money\b/,
    /signing/,
    /app store/,
    /testflight/,
    /work-system/,
    /public post|public launch|publish/
  ])) {
    return buildClassification(blocker, 'real_human_gate', ['matches explicit human-gate boundary']);
  }

  if (hasAny(text, [
    /template residue/,
    /generated residue/,
    /control-plane residue/,
    /copied forge/,
    /dayratelab/,
    /storekit paywall|auth|firebase|forge-cli|skills\//,
    /generator sanitizer/,
    /absence gate/,
    /substrate/,
    /verifier patch/,
    /pipeline hardening/,
    /watchdog.*without action/,
    /watchdog.*no exact/,
    /no exact inspect/,
    /no inspect command/,
    /no unblock command/,
    /no dispatch command/,
    /visual state invisible/,
    /screenshot packet/,
    /visual review packet/,
    /before final acceptance/,
    /repeated .*cleanup/,
    /cleanup repeats/,
    /same .*cleanup repeats/,
    /should be automated/,
    /automation missing/
  ])) {
    return buildClassification(blocker, 'pipeline_bug', ['matches recurring Forge pipeline failure/prevention pattern']);
  }

  if (hasAny(text, [
    /build failed/,
    /xcodebuild/,
    /compile error/,
    /test failed/,
    /verifier failed/,
    /gate failed/,
    /missing evidence/,
    /missing screenshot/,
    /missing video/,
    /schema invalid/,
    /repair required/,
    /fix required/
  ])) {
    return buildClassification(blocker, 'mechanical_repair', ['concrete artifact failure can be repaired by a worker']);
  }

  if (hasAny(text, [
    /\bstuck\b/,
    /unclear what to do/,
    /silly reason/,
    /unnecessary block/,
    /no context/,
    /missing instructions/,
    /prompt fragment/,
    /codex ceiling/,
    /spawn_failed/,
    /profile config/,
    /bad assignee/,
    /wrong profile/
  ])) {
    return buildClassification(blocker, 'worker_error', ['worker block reason is not a real human gate']);
  }

  return buildClassification(blocker, 'worker_error', ['fallback: blocker lacks enough evidence for human gate; retry/reassign before asking Matvii']);
}

function buildClassification(blocker, classification, signals) {
  const details = CLASS_DETAILS[classification];
  const preventionTask = details.matvii_needed ? null : {
    title: preventionTitle(blocker, classification),
    assignee: details.default_assignee,
    body: preventionBody(blocker, classification, signals),
    routing_convention: 'Create as child of the blocked card or current orchestrator/watchdog card; unblock/retry the original only after the prevention task is recorded or dispatched.'
  };

  return {
    schema_version: TAXONOMY_VERSION,
    blocker_id: blocker.id ?? null,
    title: blocker.title ?? null,
    classification,
    signals,
    matvii_needed: details.matvii_needed,
    routing_action: details.routing_action,
    prevention_kind: details.prevention_kind,
    summary: details.summary,
    exact_decision_needed: details.matvii_needed ? exactDecision(blocker) : null,
    prevention_task: preventionTask,
    notice: notice(blocker, classification, details, preventionTask)
  };
}

function preventionTitle(blocker, classification) {
  const label = blocker.title ? String(blocker.title).replace(/\s+/g, ' ').trim() : (blocker.id ?? 'unlabeled blocker');
  const clipped = label.length > 72 ? `${label.slice(0, 69)}...` : label;
  if (classification === 'pipeline_bug') return `Prevent recurring blocker: ${clipped}`;
  if (classification === 'mechanical_repair') return `Repair blocker: ${clipped}`;
  if (classification === 'dependency_shape_bug') return `Fix Kanban routing for blocker: ${clipped}`;
  return `Retry/reassign blocked worker: ${clipped}`;
}

function preventionBody(blocker, classification, signals) {
  return [
    `Source blocker: ${blocker.id ?? 'unknown'}`,
    `Class: ${classification}`,
    `Signals: ${signals.join('; ')}`,
    'Acceptance:',
    '- original blocker has a concrete route that does not ask Matvii unless it is a real_human_gate;',
    '- a durable prevention exists: verifier/test/gate, generator/substrate patch, watchdog/orchestrator routing update, or documented skill/doc rule;',
    '- the blocked card gets a compact notice with inspect/resume command and the spawned prevention task id.'
  ].join('\n');
}

function exactDecision(blocker) {
  const title = blocker.title ? ` for ${blocker.title}` : '';
  return `Matvii must make the taste/safety/external decision${title}; do not auto-unblock until that decision is recorded.`;
}

function notice(blocker, classification, details, preventionTask) {
  return {
    what_blocked: blocker.title ?? blocker.id ?? 'unknown blocker',
    why: details.summary,
    is_matvii_needed: details.matvii_needed ? 'yes' : 'no',
    launched_task: preventionTask ? preventionTask.title : null,
    exact_decision_needed: details.matvii_needed ? exactDecision(blocker) : null,
    exact_command_to_inspect: blocker.id ? `hermes kanban show ${blocker.id}` : 'hermes kanban list --status blocked',
    exact_command_to_resume: blocker.id ? `hermes kanban unblock ${blocker.id}` : 'hermes kanban unblock <task-id>'
  };
}

function coerceBlockers(json) {
  if (Array.isArray(json)) return json;
  if (Array.isArray(json.blockers)) return json.blockers;
  if (Array.isArray(json.cards)) return json.cards;
  if (Array.isArray(json.tasks)) return json.tasks;
  if (json.task) return [json.task];
  throw new Error('Input JSON must be an array or contain blockers/cards/tasks/task');
}

async function loadBlockers(args) {
  if (args.probe) return PROBE_BLOCKERS;
  if (!args.input) throw new Error('Pass --probe or --input <blockers.json>');
  const inputPath = path.resolve(args.input);
  return coerceBlockers(JSON.parse(await fs.readFile(inputPath, 'utf8')));
}

export function classifyBlockers(blockers) {
  const classifications = blockers.map(classifyBlocker);
  return {
    schema_version: TAXONOMY_VERSION,
    generated_at: new Date().toISOString(),
    source: 'forge-vnext-blocker-classifier',
    counts: classifications.reduce((counts, item) => {
      counts[item.classification] = (counts[item.classification] ?? 0) + 1;
      return counts;
    }, {}),
    blockers: classifications
  };
}

function renderMarkdown(report) {
  const lines = [];
  lines.push('# Forge vNext Blocker Classification Report');
  lines.push('');
  lines.push(`Generated: ${report.generated_at}`);
  lines.push(`Taxonomy: ${report.schema_version}`);
  lines.push('');
  lines.push('## Counts');
  for (const key of Object.keys(CLASS_DETAILS)) lines.push(`- ${key}: ${report.counts[key] ?? 0}`);
  lines.push('');
  lines.push('## Blockers');
  for (const blocker of report.blockers) {
    lines.push(`- ${blocker.blocker_id ?? '(no id)'}: ${blocker.classification}`);
    lines.push(`  - Matvii needed: ${blocker.matvii_needed ? 'yes' : 'no'}`);
    lines.push(`  - Routing action: ${blocker.routing_action}`);
    if (blocker.prevention_task) lines.push(`  - Prevention task: ${blocker.prevention_task.title} → ${blocker.prevention_task.assignee}`);
    if (blocker.exact_decision_needed) lines.push(`  - Decision: ${blocker.exact_decision_needed}`);
  }
  lines.push('');
  return `${lines.join('\n')}\n`;
}

export async function main(argv = process.argv) {
  const args = parseArgs(argv);
  if (args.help) {
    console.log(usage());
    return;
  }
  const blockers = await loadBlockers(args);
  const report = classifyBlockers(blockers);

  const mismatches = blockers
    .map((blocker, index) => ({ blocker, actual: report.blockers[index].classification }))
    .filter(({ blocker, actual }) => blocker.expected_classification && blocker.expected_classification !== actual);

  if (args.json) console.log(JSON.stringify(report, null, 2));
  else console.log(renderMarkdown(report));

  if (mismatches.length > 0) {
    for (const { blocker, actual } of mismatches) {
      console.error(`Classification mismatch for ${blocker.id ?? blocker.title}: expected ${blocker.expected_classification}, got ${actual}`);
    }
    process.exitCode = 1;
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 2;
  });
}
