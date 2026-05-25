import { describe, it, beforeEach } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
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

  it("keeps reusable verifier source free of DayRateLab and fixture-domain literals", () => {
    const source = fs.readFileSync(verifier, "utf8");
    for (const forbidden of ["HabitSpark", "JournalFlow", "activation-first-value.png"]) {
      assert.equal(source.includes(forbidden), false, `verifier source must not contain ${forbidden}`);
    }
  });
});
