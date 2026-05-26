import { describe, it, beforeEach } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const repoRoot = path.resolve(new URL("..", import.meta.url).pathname);
const verifier = path.join(repoRoot, "scripts/forge-vnext-verifier.mjs");
const fixtureRoot = path.join(repoRoot, "docs/forge-vnext/fixtures");

function runVerifier(fixtureName, extraArgs = []) {
  return runVerifierAtPath(path.join(fixtureRoot, fixtureName), extraArgs);
}

function runVerifierAtPath(appPath, extraArgs = []) {
  return spawnSync(process.execPath, [verifier, "--app-path", appPath, ...extraArgs], {
    cwd: repoRoot,
    encoding: "utf8"
  });
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function writeFile(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, value);
}

function sha256File(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function parseStdoutJson(result) {
  assert.equal(result.status, 0, `expected success, got ${result.status}
stdout:
${result.stdout}
stderr:
${result.stderr}`);
  return JSON.parse(result.stdout);
}

describe("Forge vNext generic verifier", () => {
  it("ships the verifier/evidence/module schemas as valid JSON", () => {
    for (const schema of [
      "forge.verification-plan.v1.schema.json",
      "forge.evidence-index.v1.schema.json",
      "forge.substitute-evidence.v1.schema.json",
      "forge.module-plan.v1.schema.json"
    ]) {
      const schemaPath = path.join(repoRoot, "docs/forge-vnext/schemas", schema);
      assert.ok(fs.existsSync(schemaPath), `${schema} should exist`);
      const parsed = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
      assert.equal(parsed.$schema, "https://json-schema.org/draft/2020-12/schema");
    }
  });

  it("documents the substrate module manifest proposal with default proof modules", () => {
    const manifestPath = path.join(repoRoot, "docs/forge-vnext/module-substrate-manifest.md");
    assert.ok(fs.existsSync(manifestPath), "module substrate manifest proposal should exist");
    const manifest = fs.readFileSync(manifestPath, "utf8");
    for (const required of [
      "local-proof-shell",
      "auth-account",
      "paywall-purchases",
      "sync-backend",
      "settings-profile",
      "onboarding",
      "public-launch",
      "forbidden_by_default",
      "product_prerequisites",
      "absence_gates"
    ]) {
      assert.match(manifest, new RegExp(required.replaceAll("-", "[- ]")), `manifest should mention ${required}`);
    }
  });

  it("verifies two fixture apps with different .forge verification plans without changing verifier source", () => {
    const habit = parseStdoutJson(runVerifier("verifier-habit-pass"));
    const journal = parseStdoutJson(runVerifier("verifier-journal-pass"));

    assert.equal(habit.status, "pass");
    assert.equal(journal.status, "pass");
    assert.notEqual(habit.app_id, journal.app_id);
    assert.notDeepEqual(habit.screenshot_slots, journal.screenshot_slots);
  });

  it("fails when required evidence from the plan is missing", () => {
    const result = runVerifier("missing-evidence-fail");

    assert.notEqual(result.status, 0, `expected failure
stdout:
${result.stdout}
stderr:
${result.stderr}`);
    assert.match(result.stderr, /missing required evidence/i);
    assert.match(result.stderr, /screenshots\.activation-first-value/);
  });

  it("passes with approved substitute evidence only when index and substitute record include rationale and owner", () => {
    const passing = parseStdoutJson(runVerifier("substitute-evidence-pass"));
    assert.equal(passing.status, "pass_with_substitutions");
    assert.match(passing.warnings.join("\n"), /substitute/i);

    const rejected = runVerifier("substitute-evidence-missing-owner-fail");
    assert.notEqual(rejected.status, 0, `expected rejection
stdout:
${rejected.stdout}
stderr:
${rejected.stderr}`);
    assert.match(rejected.stderr, /approved substitute.*owner/i);
  });

  it("fails when accepted evidence transcript source hashes are stale", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-stale-evidence-hash-"));
    try {
      const appPath = path.join(tempRoot, "app");
      fs.cpSync(path.join(fixtureRoot, "verifier-habit-pass"), appPath, { recursive: true });

      const planRel = ".forge/verification-plan.json";
      const sourceRel = "HabitSpark/Features/HabitLoop/HabitLoopViewModel.swift";
      const transcriptRel = ".forge/evidence/ui-state-transcript.json";
      const planPath = path.join(appPath, planRel);
      const plan = JSON.parse(fs.readFileSync(planPath, "utf8"));
      plan.evidence_slots.push({
        id: "transcript.ui-state",
        class: "transcript",
        required: true,
        artifact: transcriptRel,
        acceptance: ["UI state transcript must match current verification inputs"]
      });
      writeJson(planPath, plan);

      const transcriptPath = path.join(appPath, transcriptRel);
      writeJson(transcriptPath, {
        schema_version: "forge.ui-state-transcript.v1",
        sources: [
          { path: planRel, sha256: "0".repeat(64) },
          { path: sourceRel, sha256: "0".repeat(64) }
        ],
        states: [
          { id: "activation-first-value", summary: "first useful value visible" }
        ]
      });

      const indexPath = path.join(appPath, ".forge/evidence/evidence-index.json");
      const index = JSON.parse(fs.readFileSync(indexPath, "utf8"));
      index.slots.push({
        id: "transcript.ui-state",
        class: "transcript",
        required: true,
        status: "accepted",
        artifact: transcriptRel
      });
      writeJson(indexPath, index);

      const result = runVerifierAtPath(appPath);

      assert.notEqual(result.status, 0, `expected stale transcript hash rejection\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
      assert.match(
        result.stderr,
        /stale evidence source hash in \.forge\/evidence\/ui-state-transcript\.json for \.forge\/verification-plan\.json: expected 0{64}, got [a-f0-9]{64}/
      );
      assert.match(
        result.stderr,
        /stale evidence source hash in \.forge\/evidence\/ui-state-transcript\.json for HabitSpark\/Features\/HabitLoop\/HabitLoopViewModel\.swift: expected 0{64}, got [a-f0-9]{64}/
      );
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("requires current visual screenshot sequence evidence with accessibility snapshots", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-visual-sequence-"));
    try {
      const appPath = path.join(tempRoot, "app");
      fs.cpSync(path.join(fixtureRoot, "verifier-habit-pass"), appPath, { recursive: true });

      const requiredStates = [
        "activation",
        "core-loop-after-action",
        "returning-progress",
        "empty-error",
        "money-boundary"
      ];
      const planPath = path.join(appPath, ".forge/verification-plan.json");
      const plan = JSON.parse(fs.readFileSync(planPath, "utf8"));
      plan.checks.push({
        id: "visual-sequence-required",
        type: "visual_evidence_sequence",
        severity: "blocker",
        states: requiredStates,
        rationale: "Post-native visual review needs current screenshots plus accessibility snapshots for every required loop state; pixel diffs alone are not a taste judge."
      });
      for (const state of requiredStates) {
        plan.screenshot_slots.push({
          id: `visual.screenshot.${state}`,
          class: "screenshot",
          required: true,
          artifact: `.forge/evidence/screenshots/native/${state}.png`,
          visual_state: state,
          accessibility_snapshot_slot: `visual.accessibility.${state}`
        });
        plan.evidence_slots.push({
          id: `visual.accessibility.${state}`,
          class: "accessibility_snapshot",
          required: true,
          artifact: `.forge/evidence/screenshots/native/accessibility-snapshots/${state}.json`,
          visual_state: state
        });
      }
      writeJson(planPath, plan);

      const indexPath = path.join(appPath, ".forge/evidence/evidence-index.json");
      const index = JSON.parse(fs.readFileSync(indexPath, "utf8"));
      for (const state of requiredStates) {
        const screenshotRel = `.forge/evidence/screenshots/native/${state}.png`;
        const accessibilityRel = `.forge/evidence/screenshots/native/accessibility-snapshots/${state}.json`;
        const screenshotPath = path.join(appPath, screenshotRel);
        const accessibilityPath = path.join(appPath, accessibilityRel);
        writeFile(screenshotPath, `png fixture bytes for ${state}`);
        writeJson(accessibilityPath, {
          schema_version: "forge.accessibility-snapshot.v1",
          state,
          elements: [{ label: `${state} visible control` }]
        });
        index.slots.push({
          id: `visual.screenshot.${state}`,
          class: "screenshot",
          required: true,
          status: "accepted",
          artifact: screenshotRel,
          artifact_sha256: sha256File(screenshotPath)
        });
        index.slots.push({
          id: `visual.accessibility.${state}`,
          class: "accessibility_snapshot",
          required: true,
          status: "accepted",
          artifact: accessibilityRel,
          artifact_sha256: sha256File(accessibilityPath)
        });
      }
      writeJson(indexPath, index);

      const passing = parseStdoutJson(runVerifierAtPath(appPath));
      assert.deepEqual(passing.visual_evidence_sequence_states, requiredStates);
      assert.equal(passing.status, "pass");

      const missingStatePlan = JSON.parse(fs.readFileSync(planPath, "utf8"));
      missingStatePlan.checks.find((check) => check.id === "visual-sequence-required").states = requiredStates.filter((state) => state !== "money-boundary");
      writeJson(planPath, missingStatePlan);
      const missingState = runVerifierAtPath(appPath);
      assert.notEqual(missingState.status, 0, "expected verifier contract to require money-boundary state");
      assert.match(missingState.stderr, /required visual evidence state missing from check contract: money-boundary/i);
      writeJson(planPath, plan);

      fs.appendFileSync(path.join(appPath, ".forge/evidence/screenshots/native/core-loop-after-action.png"), "stale mutation");
      const stale = runVerifierAtPath(appPath);
      assert.notEqual(stale.status, 0, "expected stale screenshot hash rejection");
      assert.match(stale.stderr, /stale visual evidence artifact hash.*core-loop-after-action\.png/i);

      const repairedIndex = JSON.parse(fs.readFileSync(indexPath, "utf8"));
      const corePath = path.join(appPath, ".forge/evidence/screenshots/native/core-loop-after-action.png");
      repairedIndex.slots.find((slot) => slot.id === "visual.screenshot.core-loop-after-action").artifact_sha256 = sha256File(corePath);
      fs.unlinkSync(path.join(appPath, ".forge/evidence/screenshots/native/accessibility-snapshots/returning-progress.json"));
      writeJson(indexPath, repairedIndex);
      const missingAccessibility = runVerifierAtPath(appPath);
      assert.notEqual(missingAccessibility.status, 0, "expected missing accessibility snapshot rejection");
      assert.match(missingAccessibility.stderr, /missing visual evidence artifact.*returning-progress\.json/i);

      writeFile(path.join(tempRoot, "outside.png"), "outside fixture that must not be readable");
      const escapeIndex = JSON.parse(fs.readFileSync(indexPath, "utf8"));
      const escapeSlot = escapeIndex.slots.find((slot) => slot.id === "visual.screenshot.activation");
      escapeSlot.artifact = "../outside.png";
      escapeSlot.artifact_sha256 = sha256File(path.join(tempRoot, "outside.png"));
      writeJson(indexPath, escapeIndex);
      const escapedPath = runVerifierAtPath(appPath);
      assert.notEqual(escapedPath.status, 0, "expected path traversal artifact rejection");
      assert.match(escapedPath.stderr, /path escapes app root: \.\.\/outside\.png/i);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("keeps reusable verifier source free of DayRateLab and fixture-domain literals", () => {
    const source = fs.readFileSync(verifier, "utf8");
    for (const forbidden of ["HabitSpark", "JournalFlow", "activation-first-value.png"]) {
      assert.equal(source.includes(forbidden), false, `verifier source must not contain ${forbidden}`);
    }
  });
});
