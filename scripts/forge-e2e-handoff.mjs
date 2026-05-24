#!/usr/bin/env node

import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";

function usage() {
  return `Usage:
  node scripts/forge-e2e-handoff.mjs --app-path <generated-app-path>

Creates a local App Store and owner handoff artifact from generated app .forge state.
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

async function readJson(filePath) {
  return JSON.parse(await fs.readFile(filePath, "utf8"));
}

async function readJsonIfExists(filePath) {
  if (!await pathExists(filePath)) {
    return null;
  }
  return readJson(filePath);
}

function bulletList(items) {
  return items.map((item) => `- ${item}`).join("\n");
}

function paidValue(spec) {
  const values = spec.monetization?.paidValue ?? [];
  if (values.length > 0) {
    return values;
  }
  return ["Deeper history", "Export", "Advanced review surfaces"];
}

function productIds(spec) {
  const ids = spec.monetization?.placeholderProductIds ?? [];
  if (ids.length > 0) {
    return ids;
  }
  return [`${spec.app.slug.replaceAll("-", "")}.pro.monthly`];
}

function makeHandoff(spec, evidence, generatedAt) {
  const app = spec.app;
  const product = spec.product;
  const appName = app.name;
  const audience = product.audience ?? [];
  const differentiators = product.differentiators ?? [];
  const metrics = product.metrics ?? [];
  const nonGoals = product.nonGoals ?? [];
  const ids = productIds(spec);
  const paid = paidValue(spec);

  return `# ${appName} App Store Handoff

Generated: ${generatedAt}

## Positioning

${appName} is a private daily reflection app for people who want to predict, rate, and understand which days actually work without maintaining a heavy journal.

Primary promise: ${product.promise}

Category direction: Health & Fitness or Lifestyle. Choose Health & Fitness only if the production app keeps its claims non-clinical and clearly reflective rather than diagnostic.

Primary audience:
${bulletList(audience)}

Differentiators:
${bulletList(differentiators)}

Non-goals to preserve:
${bulletList(nonGoals)}

## App Store Draft

Name: ${appName}

Subtitle: Predict, rate, read your days

Short positioning line: A thirty-second ritual for seeing what makes a day work.

Description draft:

${appName} helps you close the loop between what you expect from a day and what actually happened.

Each day, make a quick prediction, answer one small prompt, and rate the day when it ends. Over time, ${appName} waits for enough real entries before showing Micro-Patterns and Day Twin comparisons, so the product feels earned instead of noisy.

Free users keep the daily prediction and rating loop. Pro can add deeper pattern archives, Day Twin search, exports, and monthly reviews after the user has felt the core value.

Suggested keywords:
reflection, journal, mood, routine, habits, daily, patterns, self care, productivity

## Screenshot Plan

Use real simulator states before producing final App Store screenshots. Do not rely on static mockups alone.

1. Today daily loop
   - Source evidence: ${evidence.today}
   - Story: predict the day, rate what happened, and answer one signal question.
   - Caption: "Predict the day before it shapes you."

2. Pattern readiness
   - Source evidence: ${evidence.patterns}
   - Story: the app refuses fake insight claims until enough rated days exist.
   - Caption: "Patterns unlock when there is enough signal."

3. Pro boundary
   - Source evidence needed: capture the Pro surface or paywall in simulator.
   - Story: free daily value stays open; paid value is deeper pattern memory.
   - Caption: "Go deeper after the ritual has value."

4. First-session activation
   - Source evidence needed: capture onboarding or first prediction state.
   - Story: the first useful action happens quickly.
   - Caption: "Start with one quick prediction."

5. History or day detail
   - Source evidence needed: capture once native history/detail exists.
   - Story: past days remain readable without becoming a dashboard.
   - Caption: "Read the days that shaped the pattern."

## Monetization Notes

Model: ${spec.monetization?.model ?? "freemium"}

Placeholder product IDs:
${bulletList(ids)}

Paid value:
${bulletList(paid)}

Rules:
- Keep the daily prediction, rating, one-question prompt, and recent history free.
- Do not show the paywall before first value.
- Present Pro after the user sees that pattern memory is useful.
- Restore purchase must be visible in every paywall implementation.
- Claims must stay grounded in app state; avoid promising diagnosis, therapy, or guaranteed life improvement.

## Activation And Retention Checks

Activation event: first completed prediction or rating in under thirty seconds.

Retention metrics to keep:
${bulletList(metrics)}

Launch-day loop:
- Day 1: user predicts and rates one day.
- Day 3: user sees continuity and recent history.
- Day 7+: user sees readiness progress and a reason to keep going.
- Day 14+: Micro-Patterns and Day Twin comparisons can become confident.

## Production TODO

- Replace mock in-memory DayRate data with durable local persistence and sync-ready boundaries.
- Add focused tests for save prediction, save rating, readiness threshold, and paywall routing.
- Capture final simulator screenshots for Today, Patterns, Pro/paywall, onboarding, and history/detail.
- Configure real StoreKit or RevenueCat products for the placeholder IDs.
- Add privacy policy, terms, and clear data-use copy before any external beta.
- Review accessibility labels, Dynamic Type, VoiceOver order, and color contrast on real device sizes.
- Add production app icon, launch screen polish, and final display name.
- Confirm Firebase/Mixpanel/Crashlytics configuration for non-mock environments without using production credentials in proof runs.
- Prepare App Review notes explaining that health-adjacent copy is reflective, non-clinical, and not diagnostic.

## Matvii Polish Checklist

- Decide whether the product should ship as Health & Fitness or Lifestyle.
- Review final copy for the private-instrument tone from DESIGN.md.
- Decide the exact 14-day threshold and whether the first teaser appears earlier.
- Choose reminder behavior, including whether reminders are default-off.
- Validate the Pro promise against what is already visible in the app.
- Run one real week of manual use before committing to launch positioning.
`;
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
  const forgeRoot = path.join(appPath, ".forge");
  const evidenceRoot = path.join(forgeRoot, "evidence");
  const specPath = path.join(forgeRoot, "spec.json");
  const handoffPath = path.join(forgeRoot, "app-store-handoff.md");
  const receiptPath = path.join(evidenceRoot, "handoff-receipt.json");
  const evidence = {
    today: path.join(evidenceRoot, "native-today-screen.jpg"),
    patterns: path.join(evidenceRoot, "native-patterns-screen.jpg"),
  };

  const missing = [];
  for (const requiredPath of [specPath, evidence.today, evidence.patterns]) {
    if (!await pathExists(requiredPath)) {
      missing.push(requiredPath);
    }
  }
  if (missing.length > 0) {
    throw new Error(`Missing required handoff inputs:\n${missing.map((item) => `- ${item}`).join("\n")}`);
  }

  const spec = await readJson(specPath);
  const existingReceipt = await readJsonIfExists(receiptPath);
  const generatedAt = existingReceipt?.generatedAt ?? new Date().toISOString();
  const markdown = makeHandoff(spec, evidence, generatedAt);
  await fs.writeFile(handoffPath, markdown);

  const receipt = {
    kind: "forge.e2e.handoff-receipt",
    generatedAt,
    status: "HANDOFF_OK",
    appPath,
    appName: spec.app.name,
    outputs: {
      handoff: handoffPath,
      receipt: receiptPath,
    },
    evidence,
    boundaries: [
      "No App Store Connect access used.",
      "No production credentials used.",
      "No publishing or deployment performed.",
    ],
  };
  await fs.writeFile(receiptPath, `${JSON.stringify(receipt, null, 2)}\n`);
  console.log(JSON.stringify(receipt, null, 2));
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
