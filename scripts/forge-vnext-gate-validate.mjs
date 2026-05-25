#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const PRODUCT_DIMENSIONS = [
  'pain_problem_clarity',
  'target_user_sharpness',
  'use_case_activation',
  'repeat_use_retention_loop',
  'money_path_believability',
  'product_distinctiveness_taste',
  'blueprint_coverage_launch_slice_integrity',
  'evidence_integrity'
];

const PASSING_VERDICTS = new Set(['pass', 'launch_candidate']);
const BLOCKING_VERDICTS = new Set(['repair', 'ask_matvii', 'kill_recommended', 'launch_candidate_blocked']);
const SCORECARD_PIPELINE_KEYS = ['pipeline_score', 'pipeline_scores', 'pipeline_dimensions', 'pipeline_product_enforcement_score'];

function usage() {
  return `Usage:\n  node scripts/forge-vnext-gate-validate.mjs product <fixture-or-app-root>\n\nProduct mode expects:\n  .forge/gates/product-taste-gate.json\n  .forge/gates/product-coverage-matrix.json\n  .forge/scorecards/app-scorecard.json`;
}

function readJson(filePath, errors) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    errors.push(`cannot read JSON ${filePath}: ${error.message}`);
    return null;
  }
}

function exists(root, relPath) {
  if (!relPath || typeof relPath !== 'string') return false;
  return fs.existsSync(path.resolve(root, relPath));
}

function ensure(condition, errors, message) {
  if (!condition) errors.push(message);
}

function evidenceMap(receipt) {
  return new Map((receipt.evidence_index ?? []).map((item) => [item.id, item]));
}

function validateDimension(name, dimension, evidenceById, errors, computedFailures) {
  if (!dimension || typeof dimension !== 'object') {
    errors.push(`missing score dimension: ${name}`);
    computedFailures.push(name);
    return;
  }
  const { score, minimum, weight, evidence_ids: evidenceIds, rationale } = dimension;
  ensure(Number.isInteger(score) && score >= 0 && score <= 10, errors, `${name}: score must be an integer 0-10`);
  ensure(Number.isInteger(minimum) && minimum >= 0 && minimum <= 10, errors, `${name}: minimum must be an integer 0-10`);
  ensure(typeof weight === 'number' && weight > 0, errors, `${name}: weight must be a positive number`);
  ensure(Array.isArray(evidenceIds) && evidenceIds.length > 0, errors, `${name}: evidence_ids must be non-empty`);
  ensure(typeof rationale === 'string' && rationale.trim().length > 0, errors, `${name}: rationale is required`);
  if (Number.isInteger(score) && Number.isInteger(minimum) && score < minimum) {
    computedFailures.push(`${name} score ${score} below hard minimum ${minimum}`);
  }
  if (Array.isArray(evidenceIds)) {
    for (const evidenceId of evidenceIds) {
      const evidence = evidenceById.get(evidenceId);
      if (!evidence) {
        errors.push(`${name}: evidence_id ${evidenceId} is not in evidence_index`);
      } else if (['missing', 'stale'].includes(evidence.status)) {
        computedFailures.push(`${name} uses ${evidence.status} evidence ${evidenceId}`);
      }
    }
  }
}

function validateCoverage(root, receipt, coverage, evidenceById, errors, computedFailures) {
  ensure(coverage.schema_version === 'forge.product_coverage_matrix.v1', errors, 'coverage matrix schema_version must be forge.product_coverage_matrix.v1');
  ensure(coverage.app_id === receipt.app?.id, errors, 'coverage matrix app_id must match product receipt app.id');
  ensure(Array.isArray(coverage.surfaces) && coverage.surfaces.length > 0, errors, 'coverage matrix requires surfaces');
  ensure(Array.isArray(coverage.required_roles), errors, 'coverage matrix requires required_roles');
  ensure(Array.isArray(coverage.missing_blockers), errors, 'coverage matrix requires missing_blockers');

  const roleSatisfied = new Set();
  const surfaces = Array.isArray(coverage.surfaces) ? coverage.surfaces : [];
  for (const surface of surfaces) {
    ensure(typeof surface.id === 'string' && surface.id.length > 0, errors, 'coverage surface requires id');
    ensure(['activation', 'core_loop', 'retention', 'monetization', 'approved_monetization_deferral', 'dashboard', 'supporting'].includes(surface.product_role), errors, `${surface.id ?? '<unknown>'}: invalid product_role`);
    ensure(['proven', 'missing', 'prototype_only', 'deferred_non_blocking', 'deferred_blocks_launch', 'not_applicable'].includes(surface.status), errors, `${surface.id ?? '<unknown>'}: invalid status`);
    ensure(Array.isArray(surface.native_evidence_ids), errors, `${surface.id ?? '<unknown>'}: native_evidence_ids must be an array`);
    if (surface.status === 'deferred_blocks_launch') computedFailures.push(`${surface.id}: deferred_blocks_launch blocks passing verdict`);
    if (surface.status === 'missing' && surface.launch_impact_if_missing === 'blocks_launch_candidate') computedFailures.push(`${surface.id}: missing blocker surface`);
    const hasPresentNativeEvidence = (surface.native_evidence_ids ?? []).some((id) => {
      const evidence = evidenceById.get(id);
      return evidence && ['present', 'substitute'].includes(evidence.status) && exists(root, evidence.path);
    });
    if (surface.status === 'proven' && surface.required_status === 'native_required_now' && !hasPresentNativeEvidence) {
      computedFailures.push(`${surface.id}: proven native_required_now surface has no present native evidence`);
    }
    if (surface.status === 'proven' && hasPresentNativeEvidence) {
      if (surface.product_role === 'activation') roleSatisfied.add('activation');
      if (surface.product_role === 'core_loop') roleSatisfied.add('core_loop');
      if (surface.product_role === 'retention') roleSatisfied.add('retention');
      if (surface.product_role === 'monetization') roleSatisfied.add('monetization_or_approved_deferral');
    }
    if (surface.product_role === 'approved_monetization_deferral' && ['proven', 'deferred_non_blocking'].includes(surface.status)) {
      roleSatisfied.add('monetization_or_approved_deferral');
    }
  }

  for (const role of coverage.required_roles ?? []) {
    if (!roleSatisfied.has(role)) computedFailures.push(`coverage missing required role: ${role}`);
  }
  for (const blocker of coverage.missing_blockers ?? []) computedFailures.push(`coverage missing_blocker: ${blocker}`);
}

function validateProduct(root) {
  const errors = [];
  const receiptPath = path.join(root, '.forge/gates/product-taste-gate.json');
  const coveragePath = path.join(root, '.forge/gates/product-coverage-matrix.json');
  const scorecardPath = path.join(root, '.forge/scorecards/app-scorecard.json');
  const receipt = readJson(receiptPath, errors);
  const coverage = readJson(coveragePath, errors);
  const scorecard = readJson(scorecardPath, errors);
  if (!receipt || !coverage || !scorecard) return { ok: false, errors };

  ensure(receipt.schema_version === 'forge.product_taste_gate.v1', errors, 'product receipt schema_version must be forge.product_taste_gate.v1');
  ensure(receipt.gate?.name === 'product_taste', errors, 'gate.name must be product_taste');
  ensure(['direction', 'slice_selection', 'native_evidence', 'final_audit'].includes(receipt.gate?.stage), errors, 'gate.stage is invalid');
  ensure([...PASSING_VERDICTS, ...BLOCKING_VERDICTS].includes(receipt.gate?.verdict), errors, 'gate.verdict is invalid');
  ensure(receipt.recommendation?.type === receipt.gate?.verdict || (receipt.gate?.verdict === 'launch_candidate' && receipt.recommendation?.type === 'pass'), errors, 'recommendation.type should match the gate verdict intent');

  for (const artifact of receipt.source_artifacts ?? []) {
    ensure(exists(root, artifact.path), errors, `source artifact missing: ${artifact.path}`);
  }
  const evidenceById = evidenceMap(receipt);
  for (const evidence of receipt.evidence_index ?? []) {
    ensure(typeof evidence.id === 'string' && evidence.id.length > 0, errors, 'evidence item requires id');
    ensure(Array.isArray(evidence.proves), errors, `${evidence.id}: proves must be an array`);
    if (['present', 'substitute'].includes(evidence.status)) ensure(exists(root, evidence.path), errors, `evidence path missing: ${evidence.id} -> ${evidence.path}`);
  }

  const computedFailures = [];
  for (const name of PRODUCT_DIMENSIONS) validateDimension(name, receipt.scores?.dimensions?.[name], evidenceById, errors, computedFailures);

  const hard = receipt.hard_minimums ?? {};
  if ((hard.demand_evidence_types_count ?? 0) < (hard.required_demand_evidence_types_count ?? 2)) computedFailures.push('hard minimum failed: demand evidence types count');
  if (!hard.has_excluded_user_statement) computedFailures.push('hard minimum failed: excluded-user statement missing');
  if (!hard.has_revenue_taste_tradeoff_statement) computedFailures.push('hard minimum failed: revenue-vs-taste tradeoff statement missing');
  if (!hard.activation_evidence_present) computedFailures.push('hard minimum failed: activation evidence missing');
  if (!hard.core_loop_evidence_present) computedFailures.push('hard minimum failed: core-loop evidence missing');
  if (!hard.retention_evidence_present) computedFailures.push('hard minimum failed: returning-user/retention evidence missing');
  if (!hard.money_boundary_evidence_present_or_deferred_by_approval) computedFailures.push('hard minimum failed: money boundary evidence or approved deferral missing');
  for (const contradiction of hard.contradictions_unresolved ?? []) computedFailures.push(`hard minimum failed: unresolved contradiction ${contradiction}`);

  ensure(receipt.coverage_matrix_ref === '.forge/gates/product-coverage-matrix.json', errors, 'coverage_matrix_ref must point at .forge/gates/product-coverage-matrix.json for product mode fixtures');
  ensure(exists(root, receipt.coverage_matrix_ref), errors, `coverage_matrix_ref missing: ${receipt.coverage_matrix_ref}`);
  validateCoverage(root, receipt, coverage, evidenceById, errors, computedFailures);

  ensure(scorecard.schema_version === 'forge.app_scorecard.v1', errors, 'app scorecard schema_version must be forge.app_scorecard.v1');
  ensure(scorecard.app_id === receipt.app?.id, errors, 'app scorecard app_id must match product receipt app.id');
  ensure(scorecard.score_scope === 'app_quality_only', errors, 'app scorecard score_scope must be app_quality_only');
  ensure(typeof scorecard.pipeline_scorecard_ref === 'string' && scorecard.pipeline_scorecard_ref.length > 0, errors, 'app scorecard must link to separate pipeline_scorecard_ref');
  for (const key of SCORECARD_PIPELINE_KEYS) ensure(!(key in scorecard), errors, `app scorecard must not embed pipeline field ${key}`);

  if (PASSING_VERDICTS.has(receipt.gate?.verdict) && computedFailures.length > 0) {
    errors.push(`passing verdict has hard minimum failures: ${computedFailures.join('; ')}`);
  }
  if (receipt.gate?.verdict === 'kill_recommended') {
    ensure(receipt.human_decision?.required === true, errors, 'kill_recommended must require human decision');
  }
  if (PASSING_VERDICTS.has(receipt.gate?.verdict) && (receipt.scores?.hard_minimum_failures ?? []).length > 0) {
    errors.push('passing verdict cannot include scores.hard_minimum_failures');
  }

  return { ok: errors.length === 0, errors, computedFailures };
}

function main() {
  const [mode, target] = process.argv.slice(2);
  if (!mode || !target || mode === '--help' || mode === '-h') {
    console.log(usage());
    process.exit(mode ? 0 : 2);
  }
  if (mode !== 'product') {
    console.error(`Unsupported mode: ${mode}\n${usage()}`);
    process.exit(2);
  }
  const root = path.resolve(target);
  const result = validateProduct(root);
  if (!result.ok) {
    console.error(`product/taste validation failed for ${root}`);
    for (const error of result.errors) console.error(`- ${error}`);
    process.exit(1);
  }
  console.log(`product/taste validation passed for ${root}`);
}

main();
