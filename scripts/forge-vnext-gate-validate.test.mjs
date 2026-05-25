#!/usr/bin/env node
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import path from 'node:path';

const repo = path.resolve(import.meta.dirname, '..');
const validator = path.join(repo, 'scripts', 'forge-vnext-gate-validate.mjs');

function runProduct(fixtureName) {
  return spawnSync(process.execPath, [validator, 'product', path.join(repo, 'docs', 'forge-vnext', 'fixtures', fixtureName)], {
    cwd: repo,
    encoding: 'utf8'
  });
}

const pass = runProduct('minimal-app-specific-pass');
assert.equal(pass.status, 0, `minimal app-specific fixture should pass product validation\nSTDOUT:\n${pass.stdout}\nSTDERR:\n${pass.stderr}`);
assert.match(pass.stdout, /product\/taste validation passed/i);

const fail = runProduct('shallow-dashboard-fail');
assert.notEqual(fail.status, 0, 'shallow dashboard fixture must fail product validation');
const failOutput = `${fail.stdout}\n${fail.stderr}`;
assert.match(failOutput, /shallow|hard minimum|returning-user|money/i, failOutput);
assert.match(failOutput, /repeat_use_retention_loop|blueprint_coverage_launch_slice_integrity|money_path_believability/i, failOutput);
