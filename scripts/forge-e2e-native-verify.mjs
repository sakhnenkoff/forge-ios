#!/usr/bin/env node

import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";

function usage() {
  return `Usage:
  node scripts/forge-e2e-native-verify.mjs --app-path <generated-app-path>

Verifies reusable Forge P6/P7 native proof expectations for a generated iOS app.
`;
}

function parseArgs(argv) {
  const args = {};

  for (let index = 2; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") {
      args.help = true;
      continue;
    }
    if (arg === "--app-path") {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) {
        throw new Error("Missing value for --app-path");
      }
      args.appPath = value;
      index += 1;
      continue;
    }
    throw new Error(`Unknown argument: ${arg}`);
  }

  return args;
}

async function pathExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

async function readText(filePath) {
  return fs.readFile(filePath, "utf8");
}

async function walkFiles(root, predicate = () => true) {
  const result = [];
  const entries = await fs.readdir(root, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      result.push(...await walkFiles(fullPath, predicate));
    } else if (predicate(fullPath)) {
      result.push(fullPath);
    }
  }

  return result;
}

async function findProject(appPath) {
  const entries = await fs.readdir(appPath, { withFileTypes: true });
  const project = entries.find((entry) => entry.isDirectory() && entry.name.endsWith(".xcodeproj"));
  if (!project) {
    throw new Error(`No .xcodeproj found in generated app path: ${appPath}`);
  }
  return project.name;
}

function assertIncludes(errors, label, text, needles) {
  for (const needle of needles) {
    if (!text.includes(needle)) {
      errors.push(`${label} missing required marker: ${needle}`);
    }
  }
}

async function main() {
  const args = parseArgs(process.argv);
  if (args.help) {
    console.log(usage());
    return;
  }
  if (!args.appPath) {
    throw new Error("Missing required --app-path");
  }

  const appPath = path.resolve(args.appPath);
  const appName = path.basename(appPath);
  const sourceRoot = path.join(appPath, appName);
  const forgeRoot = path.join(appPath, ".forge");
  const evidenceRoot = path.join(forgeRoot, "evidence");
  const errors = [];

  const projectName = await findProject(appPath);
  const specPath = path.join(forgeRoot, "spec.json");
  const designPath = path.join(forgeRoot, "DESIGN.md");
  const screenshotPath = path.join(evidenceRoot, "native-today-screen.jpg");
  const patternsScreenshotPath = path.join(evidenceRoot, "native-patterns-screen.jpg");

  for (const requiredPath of [specPath, designPath, screenshotPath, patternsScreenshotPath]) {
    if (!await pathExists(requiredPath)) {
      errors.push(`Missing required native proof artifact: ${requiredPath}`);
    }
  }

  const swiftFiles = await walkFiles(sourceRoot, (filePath) => filePath.endsWith(".swift"));
  const swiftTextByPath = new Map();
  for (const filePath of swiftFiles) {
    swiftTextByPath.set(filePath, await readText(filePath));
  }
  const allSwift = [...swiftTextByPath.values()].join("\n");

  const bannedPatterns = [
    /TODO/,
    /Font\.system\(size:/,
    /Color\(red:/,
    /Color\(#/,
    /Color\(\.sRGB/,
    /AsyncImage/,
    /@StateObject/,
    /Your money/,
    /spending/i,
    /budget/i,
    /banknote/,
    /templates/i,
    /finances/i,
    /financial/i,
    /bill reminders/i,
  ];

  for (const pattern of bannedPatterns) {
    if (pattern.test(allSwift)) {
      errors.push(`Banned native/template pattern matched: ${pattern}`);
    }
  }

  const homeView = await readText(path.join(sourceRoot, "Features/Home/HomeView.swift"));
  const homeViewModel = await readText(path.join(sourceRoot, "Features/Home/HomeViewModel.swift"));
  const appServices = await readText(path.join(sourceRoot, "App/Dependencies/AppServices.swift"));
  const dayRateManager = await readText(path.join(sourceRoot, "Managers/DayRate/DayRateManager.swift"));

  assertIncludes(errors, "HomeView", homeView, [
    "DSScreen",
    ".toast(",
    ".onAppear",
    "AppServices.self",
    ".redacted(reason:",
    "ContentUnavailableView",
    "Patterns",
    "Pro",
  ]);

  assertIncludes(errors, "HomeViewModel", homeViewModel, [
    "@Observable",
    "private var hasLoaded",
    "var toast: Toast?",
    "LoggableEvent",
    "toast = .error",
    "hasEnoughPatternData",
  ]);

  assertIncludes(errors, "DayRateManager", dayRateManager, [
    "protocol DayRateManagerProtocol",
    "final class MockDayRateManager",
    "StringIdentifiable",
    "static let placeholders",
    "static let mockList",
  ]);

  assertIncludes(errors, "AppServices", appServices, [
    "let dayRateManager: DayRateManagerProtocol",
    "MockDayRateManager()",
  ]);

  if (!projectName.startsWith(appName)) {
    errors.push(`Generated project name ${projectName} does not match app directory ${appName}`);
  }

  if (errors.length > 0) {
    console.error(`NATIVE_VERIFY_FAILED for ${appPath}`);
    for (const error of errors) {
      console.error(`- ${error}`);
    }
    process.exitCode = 1;
    return;
  }

  console.log(JSON.stringify({
    status: "NATIVE_VERIFY_OK",
    appPath,
    projectName,
    evidence: {
      todayScreenshot: screenshotPath,
      patternsScreenshot: patternsScreenshotPath,
    },
  }, null, 2));
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
