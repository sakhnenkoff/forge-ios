#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const VALID_PHASES = new Set(['pre-native', 'native-review', 'final']);

function usage() {
  console.error('Usage: node scripts/forge-vnext-design-gate-verify.mjs [--phase pre-native|native-review|final] <app-or-fixture-root>');
}

function parseArgs(argv) {
  let phase = 'pre-native';
  const positional = [];
  for (let i = 2; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--phase') {
      phase = argv[++i];
    } else if (arg.startsWith('--phase=')) {
      phase = arg.slice('--phase='.length);
    } else if (arg === '-h' || arg === '--help') {
      usage();
      process.exit(0);
    } else {
      positional.push(arg);
    }
  }
  if (!VALID_PHASES.has(phase) || positional.length !== 1) {
    usage();
    process.exit(2);
  }
  return { phase, root: path.resolve(positional[0]) };
}

function exists(p) {
  return fs.existsSync(p);
}

function readText(file, failures) {
  try {
    return fs.readFileSync(file, 'utf8');
  } catch (error) {
    failures.push(`missing or unreadable file: ${file}`);
    return '';
  }
}

function readJson(file, failures) {
  const text = readText(file, failures);
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch (error) {
    failures.push(`invalid JSON in ${file}: ${error.message}`);
    return null;
  }
}

function arr(value) {
  return Array.isArray(value) ? value : [];
}

function str(value) {
  return typeof value === 'string' ? value : '';
}

function hasAny(text, needles) {
  const haystack = str(text).toLowerCase();
  return needles.some((needle) => haystack.includes(needle));
}

function countClickableTransitions(html) {
  const patterns = [/<button\b/gi, /onclick\s*=/gi, /<a\b[^>]*href\s*=/gi, /data-action\s*=/gi, /addEventListener\s*\(/gi];
  return patterns.reduce((count, pattern) => count + (html.match(pattern) ?? []).length, 0);
}

function findDesignRoot(root) {
  const candidates = [path.join(root, 'design'), path.join(root, '.forge', 'design')];
  return candidates.find(exists) ?? candidates[1];
}

function resolveArtifact(root, designRoot, artifactPath) {
  if (!artifactPath) return '';
  if (path.isAbsolute(artifactPath)) return artifactPath;
  const rootCandidate = path.resolve(root, artifactPath);
  if (exists(rootCandidate)) return rootCandidate;
  const designCandidate = path.resolve(designRoot, artifactPath.replace(/^design\//, ''));
  return designCandidate;
}

function requireFields(object, fields, label, failures) {
  for (const field of fields) {
    if (object?.[field] === undefined || object?.[field] === null || object?.[field] === '') {
      failures.push(`${label} missing required field: ${field}`);
    }
  }
}

function validateHandshake(handshake, failures) {
  requireFields(handshake, ['app_name', 'target_user', 'core_workflow', 'core_emotional_job', 'repeat_use_moment', 'launch_bar', 'design_implications'], 'product_design_handshake', failures);
  const implications = arr(handshake?.design_implications);
  if (implications.length < 5) failures.push('product_design_handshake requires at least 5 design implications');
  for (const [index, implication] of implications.entries()) {
    requireFields(implication, ['product_fact', 'design_consequence', 'must_show_in_screen_or_flow'], `product_design_handshake.design_implications[${index}]`, failures);
  }
  const implicationText = JSON.stringify(implications).toLowerCase();
  for (const [name, terms] of Object.entries({ activation: ['activation', 'first', 'onboard'], retention: ['retention', 'repeat', 'return', 'progress'], monetization: ['money', 'paywall', 'pricing', 'monetization', 'paid'] })) {
    if (name === 'monetization' && !handshake?.monetization_boundary) continue;
    if (!terms.some((term) => implicationText.includes(term))) failures.push(`product_design_handshake missing ${name} implication`);
  }
  const genericPhrases = ['modern dashboard', 'clean cards', 'simple tracker', 'use cards to show', 'dashboard with insights'];
  if (hasAny(JSON.stringify(handshake), genericPhrases)) failures.push('product_design_handshake uses generic dashboard/card language instead of app-specific product language');
}

function validateReferences(referencesJson, failures) {
  const references = arr(referencesJson?.references);
  if (references.length < 3) failures.push('references.json requires at least 3 references');
  const types = new Set(references.map((reference) => reference.type));
  for (const type of ['ios_native', 'category', 'emotional']) {
    if (!types.has(type)) failures.push(`references.json requires at least one ${type} reference`);
  }
  const doNotCopyCount = references.reduce((count, reference) => count + arr(reference.do_not_copy).length, 0);
  if (doNotCopyCount < 5) failures.push('references.json requires at least 5 do_not_copy constraints across references');
  references.forEach((reference, index) => {
    requireFields(reference, ['name', 'type', 'source', 'why_relevant', 'borrow', 'do_not_copy', 'risk_if_overused'], `references[${index}]`, failures);
    if (arr(reference.borrow).length === 0) failures.push(`references[${index}] requires specific borrow traits`);
    if (arr(reference.do_not_copy).length === 0) failures.push(`references[${index}] requires do_not_copy constraints`);
  });
}

function validateSynthesis(synthesisJson, failures) {
  const synthesis = synthesisJson?.original_synthesis;
  requireFields(synthesis, ['one_sentence_direction', 'core_metaphor_or_shape', 'signature_interactions', 'signature_surfaces', 'reference_synthesis', 'explicitly_rejected_patterns', 'proof_screen_or_flow'], 'original_synthesis', failures);
  if (arr(synthesis?.reference_synthesis).length < 3) failures.push('original_synthesis requires at least 3 transformed reference traits');
  if (arr(synthesis?.explicitly_rejected_patterns).length < 3) failures.push('original_synthesis requires at least 3 explicitly rejected patterns');
  if (arr(synthesis?.signature_interactions).length < 2) failures.push('original_synthesis requires app-specific signature interactions, not only surfaces');
  if (hasAny(JSON.stringify(synthesis), ['clean modern dashboard', 'dashboard cards', 'large metric cards'])) failures.push('original_synthesis appears satisfiable by dashboard/card/token changes only');
}

function validateEmotionalTone(toneJson, failures) {
  const tone = toneJson?.emotional_tone;
  requireFields(tone, ['mood_sentence', 'session_arc', 'voice_rules', 'anti_tone', 'screens_that_must_express_tone'], 'emotional_tone', failures);
  requireFields(tone?.session_arc, ['open', 'act', 'return', 'close'], 'emotional_tone.session_arc', failures);
  if (arr(tone?.voice_rules).length < 3) failures.push('emotional_tone requires at least 3 voice rules');
  if (arr(tone?.anti_tone).length < 3) failures.push('emotional_tone requires at least 3 anti-tone rules');
  if (!hasAny(arr(tone?.anti_tone).join(' '), ['dashboard', 'card', 'admin', 'metric tile'])) failures.push('emotional_tone anti_tone must reject generic dashboard/card/admin feel');
  const mood = str(tone?.mood_sentence).toLowerCase();
  const bannedOnly = ['clean', 'modern', 'simple', 'sleek', 'intuitive', 'premium'].filter((word) => mood.includes(word));
  if (bannedOnly.length >= 3 && mood.length < 80) failures.push('emotional_tone mood sentence is generic banned-word soup');
}

function validateDesignSystem(systemJson, failures) {
  const system = systemJson?.design_system;
  requireFields(system, ['principles', 'tokens', 'components', 'screen_composition_rules', 'empty_error_loading_rules', 'accessibility_rules', 'banned_patterns'], 'design_system', failures);
  if (arr(system?.principles).length < 4) failures.push('design_system requires at least 4 principles');
  for (const [index, principle] of arr(system?.principles).entries()) {
    requireFields(principle, ['name', 'why', 'visible_consequence'], `design_system.principles[${index}]`, failures);
  }
  for (const group of ['colors', 'typography', 'spacing_and_shape']) {
    if (arr(system?.tokens?.[group]).length < 1) failures.push(`design_system.tokens.${group} requires at least 1 product-rationalized token`);
  }
  const components = arr(system?.components);
  if (components.length < 8) failures.push('design_system requires at least 8 app-specific components or variants');
  const structuralWords = ['structure', 'behavior', 'interaction', 'workflow', 'layout', 'composition', 'state'];
  const structuralComponentCount = components.filter((component) => hasAny(arr(component.must_differ_from_scaffold_by).join(' '), structuralWords)).length;
  if (structuralComponentCount < 5) failures.push('design_system requires at least 5 components that differ by structure/behavior, not tokens only');
  const banned = arr(system?.banned_patterns).join(' ').toLowerCase();
  if (arr(system?.banned_patterns).length < 5) failures.push('design_system requires at least 5 banned patterns');
  for (const required of ['dashboard', 'card', 'scaffold']) {
    if (!banned.includes(required)) failures.push(`design_system.banned_patterns must explicitly mention ${required}`);
  }
  const stateRules = arr(system?.empty_error_loading_rules).join(' ').toLowerCase();
  if (!hasAny(stateRules, ['empty', 'error', 'loading', 'blocked'])) failures.push('design_system empty/error/loading rules must be app-specific and explicit');
  const a11y = arr(system?.accessibility_rules).join(' ').toLowerCase();
  for (const required of ['contrast', 'dynamic', 'motion', 'voiceover']) {
    if (!a11y.includes(required)) failures.push(`design_system accessibility rules missing ${required}`);
  }
  const componentNames = components.map((component) => str(component.name));
  const genericComponentCount = componentNames.filter((name) => /^DS(Card|Button|Screen)|^Card$|^Button$/.test(name)).length;
  if (genericComponentCount > components.length / 2) failures.push('design_system visible identity is dominated by scaffold components');
}

function validatePrototype(root, designRoot, receipt, failures) {
  const prototype = receipt?.prototype;
  requireFields(prototype, ['entry_file', 'viewports_tested', 'flows', 'screens_or_states', 'known_limitations', 'human_review_recommendation'], 'prototype', failures);
  const entryFile = resolveArtifact(root, designRoot, prototype?.entry_file);
  if (!exists(entryFile)) {
    failures.push(`prototype entry file missing: ${prototype?.entry_file ?? '(unset)'}`);
  } else {
    const html = readText(entryFile, failures);
    if (countClickableTransitions(html) < 2) failures.push('prototype must include at least 2 clickable transitions');
    if (/<script\b[^>]*src\s*=\s*["']https?:/i.test(html) || /<link\b[^>]*href\s*=\s*["']https?:/i.test(html)) failures.push('prototype must be local/static with no external network dependency');
  }
  const covered = new Set(arr(prototype?.flows).map((flow) => flow.product_gate_covered));
  for (const required of ['activation', 'core_loop']) {
    if (!covered.has(required)) failures.push(`prototype must cover ${required}`);
  }
  if (![...covered].some((gate) => ['empty_error', 'monetization'].includes(gate))) failures.push('prototype must cover at least one non-happy state: empty_error or monetization');
  if (arr(prototype?.screens_or_states).length < 3) failures.push('prototype requires at least 3 screens or states');
  if (prototype?.human_review_recommendation !== 'approve') failures.push('prototype human_review_recommendation must be approve to pass pre-native');
}

function validateReceipt(receipt, phase, failures) {
  requireFields(receipt, ['schema_version', 'app_id', 'app_name', 'spec_hash_or_timestamp', 'gate_status', 'artifacts', 'product_design_handshake', 'subgate_verdicts', 'generic_ui_rejection_tests', 'blocking_findings', 'repair_plan', 'approval'], 'design-gate-receipt', failures);
  if (receipt?.schema_version !== 'forge.design_gate.v1') failures.push('design-gate-receipt schema_version must be forge.design_gate.v1');
  if (receipt?.gate_status !== 'pass') failures.push('design-gate-receipt gate_status must be pass');
  if (arr(receipt?.blocking_findings).length > 0) failures.push('design-gate-receipt blocking_findings must be empty for pass');
  const verdicts = receipt?.subgate_verdicts ?? {};
  for (const key of ['references_synthesis', 'emotional_tone', 'design_system', 'prototype', 'motion_haptics', 'generic_ui_rejection_tests']) {
    if (verdicts[key] !== 'pass') failures.push(`subgate_verdicts.${key} must be pass`);
  }
  if (phase === 'pre-native') {
    if (!['not_started', 'pass'].includes(verdicts.native_screenshots)) failures.push('pre-native allows native_screenshots only as not_started or pass');
  } else if (verdicts.native_screenshots !== 'pass') {
    failures.push(`${phase} requires subgate_verdicts.native_screenshots pass`);
  }
  if (receipt?.approval?.human_review_required_before_swift_expansion !== true) failures.push('approval must require human review before Swift expansion');
  if (receipt?.approval?.recommended_decision !== 'approve') failures.push('approval.recommended_decision must be approve to pass');

  const tests = receipt?.generic_ui_rejection_tests ?? {};
  if (tests.token_swap_test?.verdict !== 'pass') failures.push('token_swap_test must pass: token-only scaffold reskins are blocked');
  if (arr(tests.token_swap_test?.why_not_interchangeable).length < 3) failures.push('token_swap_test requires at least 3 why_not_interchangeable reasons');
  if (arr(tests.token_swap_test?.app_specific_structural_choices).length < 3) failures.push('token_swap_test requires at least 3 app-specific structural choices');
  const cardTest = tests.card_dashboard_test ?? {};
  if (cardTest.verdict === 'fail') failures.push('card_dashboard_test fail blocks design gate');
  if (cardTest.verdict === 'justified_exception' && (!cardTest.justification_if_exception || arr(cardTest.distinctive_non_card_mechanisms).length < 1)) failures.push('card_dashboard_test justified_exception needs product rationale and distinctive behavior');
  if ((cardTest.card_like_regions_count ?? 0) >= 5 && cardTest.verdict !== 'justified_exception') failures.push('high card_like_regions_count requires justified_exception or repair');
  const scaffoldTest = tests.scaffold_dependency_test ?? {};
  if (scaffoldTest.verdict !== 'pass') failures.push('scaffold_dependency_test must pass');
  const identity = str(scaffoldTest.identity_carried_by).toLowerCase();
  const identityKinds = ['layout', 'components', 'interactions', 'workflow_shape'].filter((kind) => identity.includes(kind));
  if (identityKinds.length < 2) failures.push('scaffold_dependency_test identity must be carried by at least two of layout/components/interactions/workflow_shape');
  const shapeTest = tests.screen_shape_uniqueness_test ?? {};
  if (shapeTest.verdict !== 'pass') failures.push('screen_shape_uniqueness_test must pass');
  if (arr(shapeTest.screen_shapes).length < 3) failures.push('screen_shape_uniqueness_test requires at least 3 screen/state shapes');
  const toneTest = tests.emotional_tone_blind_test ?? {};
  if (!['yes', 'partial'].includes(toneTest.match)) failures.push('emotional_tone_blind_test must match yes or partial');
}

function validateNativeReview(root, designRoot, receipt, failures) {
  const artifactPath = receipt?.artifacts?.screenshot_review_json ?? 'design/screenshot-review.json';
  const review = readJson(resolveArtifact(root, designRoot, artifactPath), failures)?.native_screenshot_review;
  requireFields(review, ['screenshots', 'rubric_scores', 'blocking_findings', 'repair_required', 'verdict'], 'native_screenshot_review', failures);
  if (review?.verdict !== 'pass') failures.push('native_screenshot_review.verdict must be pass');
  if (arr(review?.blocking_findings).length > 0) failures.push('native_screenshot_review blocking_findings must be empty');
  const screenshots = arr(review?.screenshots);
  const requiredCategories = ['activation', 'core_loop', 'retention', 'empty_error'];
  const hasMoney = Boolean(receipt?.product_design_handshake?.monetization_boundary);
  if (hasMoney) requiredCategories.push('monetization');
  for (const category of requiredCategories) {
    if (!screenshots.some((shot) => shot.required_by_gate === category)) failures.push(`native_screenshot_review missing screenshot category: ${category}`);
  }
  for (const shot of screenshots) {
    const shotPath = resolveArtifact(root, designRoot, shot.path);
    if (!exists(shotPath)) failures.push(`native screenshot evidence file missing: ${shot.path}`);
    for (const key of ['distinctiveness_score', 'workflow_clarity_score', 'apple_native_fit_score']) {
      if ((shot[key] ?? 0) <= 0) failures.push(`native screenshot ${shot.screen_or_state ?? shot.path} has non-positive ${key}`);
    }
  }
  const scores = review?.rubric_scores ?? {};
  const critical = ['app_specific_identity', 'workflow_clarity', 'emotional_tone_match', 'non_generic_composition'];
  for (const [key, value] of Object.entries(scores)) {
    if (value === 0) failures.push(`native_screenshot_review rubric score ${key} must not be 0`);
  }
  for (const key of critical) {
    if ((scores[key] ?? 0) < 2) failures.push(`native_screenshot_review critical score ${key} must be at least 2`);
  }
  if (critical.filter((key) => (scores[key] ?? 0) >= 3).length < 2) failures.push('native_screenshot_review needs at least two critical dimensions scored 3');
}

function validateFinal(root, designRoot, failures) {
  const motion = readJson(path.join(designRoot, 'motion-haptics.json'), failures)?.motion_haptics;
  requireFields(motion, ['principles', 'interactions', 'banned_motion', 'verification_notes'], 'motion_haptics', failures);
  if (arr(motion?.interactions).length < 1) failures.push('final phase requires motion/haptics interactions or explicit fixture evidence');
  for (const [index, interaction] of arr(motion?.interactions).entries()) {
    requireFields(interaction, ['trigger', 'user_intent', 'motion', 'haptic', 'duration_ms', 'easing', 'feedback_purpose', 'reduce_motion_behavior', 'failure_mode_if_missing_or_overdone'], `motion_haptics.interactions[${index}]`, failures);
  }
}

function main() {
  const { phase, root } = parseArgs(process.argv);
  const failures = [];
  if (!exists(root)) failures.push(`root does not exist: ${root}`);
  const designRoot = findDesignRoot(root);
  if (!exists(designRoot)) failures.push(`design artifact directory missing: expected ${path.join(root, 'design')} or ${path.join(root, '.forge', 'design')}`);

  const receipt = readJson(path.join(designRoot, 'design-gate-receipt.json'), failures);
  const artifacts = receipt?.artifacts ?? {};
  const references = readJson(resolveArtifact(root, designRoot, artifacts.references_json ?? 'design/references.json'), failures);
  const synthesis = readJson(resolveArtifact(root, designRoot, artifacts.synthesis_json ?? 'design/synthesis.json'), failures);
  const tone = readJson(resolveArtifact(root, designRoot, artifacts.emotional_tone_json ?? 'design/emotional-tone.json'), failures);
  const system = readJson(resolveArtifact(root, designRoot, artifacts.design_system_json ?? 'design/design-system.json'), failures);
  const prototypeReceipt = readJson(resolveArtifact(root, designRoot, artifacts.prototype_receipt ?? 'design/prototype/prototype-receipt.json'), failures);

  validateReceipt(receipt, phase, failures);
  validateHandshake(receipt?.product_design_handshake, failures);
  validateReferences(references, failures);
  validateSynthesis(synthesis, failures);
  validateEmotionalTone(tone, failures);
  validateDesignSystem(system, failures);
  validatePrototype(root, designRoot, prototypeReceipt, failures);
  if (phase === 'native-review' || phase === 'final') validateNativeReview(root, designRoot, receipt, failures);
  if (phase === 'final') validateFinal(root, designRoot, failures);

  if (failures.length > 0) {
    console.error(`Forge vNext design gate FAILED (${phase}) for ${root}`);
    for (const failure of failures) console.error(`- ${failure}`);
    process.exit(1);
  }
  console.log(`Forge vNext design gate passed (${phase}) for ${root}`);
}

main();
