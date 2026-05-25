import { describe, it, beforeEach } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

const repoRoot = path.resolve(new URL("..", import.meta.url).pathname);
const verifier = path.join(repoRoot, "scripts/forge-vnext-verifier.mjs");
const fixtureRoot = path.join(repoRoot, "docs/forge-vnext/fixtures");

function runVerifier(fixtureName, extraArgs = []) {
  return spawnSync(process.execPath, [verifier, "--app-path", path.join(fixtureRoot, fixtureName), ...extraArgs], {
    cwd: repoRoot,
    encoding: "utf8"
  });
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
  it("ships the three verifier/evidence schemas as valid JSON", () => {
    for (const schema of [
      "forge.verification-plan.v1.schema.json",
      "forge.evidence-index.v1.schema.json",
      "forge.substitute-evidence.v1.schema.json"
    ]) {
      const schemaPath = path.join(repoRoot, "docs/forge-vnext/schemas", schema);
      assert.ok(fs.existsSync(schemaPath), `${schema} should exist`);
      const parsed = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
      assert.equal(parsed.$schema, "https://json-schema.org/draft/2020-12/schema");
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

  it("keeps reusable verifier source free of DayRateLab and fixture-domain literals", () => {
    const source = fs.readFileSync(verifier, "utf8");
    for (const forbidden of ["DayRateLab", "DayRate", "HabitSpark", "JournalFlow", "activation-first-value.png"]) {
      assert.equal(source.includes(forbidden), false, `verifier source must not contain ${forbidden}`);
    }
  });
});
