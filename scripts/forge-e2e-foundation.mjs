#!/usr/bin/env node

import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";

function usage() {
  return `Usage:
  node scripts/forge-e2e-foundation.mjs --idea <idea.json> --app-path <generated-app-path> [--clean] [--generated-at <iso>]

Writes Forge E2E foundation artifacts into <generated-app-path>/.forge.
This bridge creates planning/product/design artifacts only. It does not edit Swift files.
`;
}

function parseArgs(argv) {
  const args = { clean: false };

  for (let index = 2; index < argv.length; index += 1) {
    const arg = argv[index];

    if (arg === "--clean") {
      args.clean = true;
      continue;
    }

    if (arg === "--idea" || arg === "--app-path" || arg === "--generated-at") {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) {
        throw new Error(`Missing value for ${arg}`);
      }
      args[arg.slice(2).replaceAll("-", "_")] = value;
      index += 1;
      continue;
    }

    if (arg === "--help" || arg === "-h") {
      args.help = true;
      continue;
    }

    throw new Error(`Unknown argument: ${arg}`);
  }

  return args;
}

async function readJson(filePath) {
  return JSON.parse(await fs.readFile(filePath, "utf8"));
}

async function writeText(filePath, value) {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
  await fs.writeFile(filePath, `${value.trimEnd()}\n`);
}

async function writeJson(filePath, value) {
  await writeText(filePath, JSON.stringify(value, null, 2));
}

function list(items) {
  return items.map((item) => `- ${item}`).join("\n");
}

function table(rows) {
  return rows.map((row) => `| ${row.join(" | ")} |`).join("\n");
}

function slugToProductPrefix(slug) {
  return String(slug).replace(/[^a-z0-9]/gi, "").toLowerCase();
}

function swiftTypeName(value, fallback) {
  const text = String(value ?? fallback)
    .replace(/[^A-Za-z0-9]+/g, " ")
    .trim()
    .split(/\s+/)
    .map((part) => `${part.charAt(0).toUpperCase()}${part.slice(1)}`)
    .join("");
  return text || fallback;
}

function inferDomain(idea) {
  const corpus = [
    idea.name,
    idea.problem,
    idea.promise,
    ...(idea.differentiators ?? []),
    ...(idea.coreLoop ?? []),
    ...(idea.screens ?? []).flatMap((screen) => [screen.title, screen.purpose, ...(screen.data ?? [])]),
  ].join(" ").toLowerCase();
  const appType = swiftTypeName(idea.name, "App");

  if (corpus.includes("day") || corpus.includes("rating") || corpus.includes("prediction")) {
    return {
      entry: "DayEntry",
      insight: corpus.includes("pattern") ? "MicroPattern" : "DayInsight",
      category: "daily self-tracking",
      cliche: "generic mood tracker visuals",
      primaryAction: "prediction and rating",
    };
  }

  if (corpus.includes("habit")) {
    return {
      entry: "HabitEntry",
      insight: "HabitInsight",
      category: "habit tracking",
      cliche: "generic habit checklist visuals",
      primaryAction: "habit check-in",
    };
  }

  return {
    entry: `${appType}Entry`,
    insight: `${appType}Insight`,
    category: "the category",
    cliche: "obvious category cliches",
    primaryAction: "core action",
  };
}

function sentence(value, fallback = "") {
  const text = String(value ?? fallback).replace(/\s+/g, " ").trim();
  return text.endsWith(".") || text.endsWith("!") || text.endsWith("?") ? text : `${text}.`;
}

function inferBundleId(appPath, projectName) {
  const appName = projectName.replace(/\.xcodeproj$/, "");
  return `com.matvii.${appName.replace(/[^A-Za-z0-9]/g, "").toLowerCase()}`;
}

async function findProject(appPath) {
  const entries = await fs.readdir(appPath, { withFileTypes: true });
  const project = entries.find((entry) => entry.isDirectory() && entry.name.endsWith(".xcodeproj"));
  if (!project) {
    throw new Error(`No .xcodeproj found in generated app path: ${appPath}`);
  }
  return project.name;
}

function buildSpec(idea, context) {
  const productPrefix = slugToProductPrefix(idea.slug);
  const domain = inferDomain(idea);
  const featureScreens = idea.screens.map((screen, index) => ({
    id: screen.id,
    name: screen.title,
    screen_type: index === 0 ? "dashboard" : screen.id.includes("detail") ? "detail" : "list",
    description: screen.purpose,
    required: index < 3,
    has_manager: true,
    models: [domain.entry],
    depends_on: index === 0 ? [] : ["today"],
    status: "foundation_ready",
    nav_case: index === 0 ? "tab" : "push",
    icon: index === 0 ? "sun.max" : screen.id === "insights" ? "chart.xyaxis.line" : "calendar",
    nav_path: index === 0 ? ["today"] : ["today", screen.id],
    activation_role: screen.id === "today" ? "primary_daily_loop" : "supporting",
    retention_role: screen.id === "insights" ? "pattern_unlock" : screen.id,
  }));

  return {
    kind: "forge.e2e.spec",
    generatedAt: context.generatedAt,
    pipelineVersion: "forge-e2e-bridge-0.1",
    app: {
      name: idea.name,
      slug: idea.slug,
      tagline: idea.tagline,
      platform: idea.platform,
      proofAppPath: context.appPath,
      xcodeProject: context.projectName,
      bundleId: context.bundleId,
      mockScheme: `${context.appName} - Mock`,
    },
    source: {
      ideaPath: context.ideaPath,
      templateMutationAllowed: false,
      marketplaceAlignment: "remote forge-marketplace v5 P0-P7 phase architecture",
      archivedProofPolicy: "Old Forge template-mutating DayRate proof is evidence only.",
    },
    product: {
      problem: idea.problem,
      promise: idea.promise,
      audience: idea.audience,
      differentiators: idea.differentiators,
      metrics: idea.metrics,
      nonGoals: idea.nonGoals,
      constraints: idea.constraints ?? [],
    },
    monetization: {
      model: "freemium",
      placeholderProductIds: [
        `${productPrefix}.pro.monthly`,
        `${productPrefix}.pro.yearly`,
        `${productPrefix}.pro.lifetime`,
      ],
      restoreRequired: true,
      paidValue: [
        "Deeper history",
        "Exports",
        "Reminder controls",
        "Pattern reports",
        "Time Capsule depth",
      ],
    },
    features: featureScreens,
    models: [
      {
        name: domain.entry,
        fields: [
          { name: "id", type: "String" },
          { name: "date", type: "Date" },
          { name: "prediction", type: "Int?" },
          { name: "rating", type: "Int?" },
          { name: "question", type: "String?" },
          { name: "answer", type: "String?" },
          { name: "createdAt", type: "Date" },
        ],
      },
      {
        name: domain.insight,
        fields: [
          { name: "id", type: "String" },
          { name: "text", type: "String" },
          { name: "confidence", type: "Double" },
          { name: "relatedEntryIds", type: "[String]" },
          { name: "createdAt", type: "Date" },
        ],
      },
    ],
    navigation: {
      tabs: ["today"],
      pushes: idea.screens.filter((screen, index) => index > 0).map((screen) => screen.id),
      sheets: ["paywall", "settings", "time-capsule"],
    },
  };
}

function productThesis(idea, context) {
  const domain = inferDomain(idea);
  return `# Product Thesis

## App

${idea.name}: ${idea.tagline}

Generated app path: \`${context.appPath}\`

## Target User

${list(idea.audience)}

## Pain

${sentence(idea.problem)}

## Promise

${sentence(idea.promise)}

## Why This Deserves To Exist

${idea.name} is not another passive ${domain.category} app. It must make the user's ${domain.primaryAction} useful quickly, then wait until there is enough signal before making claims. The product deserves to exist only if it gives users the promised outcome with less effort than current alternatives.

## Must-Have Features

${list([
  "First prediction or simulated first prediction during activation.",
  "Daily Today loop for prediction, rating, and one question.",
  "Pattern readiness state that refuses fake insights before enough data exists.",
  "Insight surface for Micro-Patterns and Day Twins.",
  "Freemium boundary that preserves free daily value.",
])}

## Nice-To-Have Or Later

${list([
  "Full cloud sync.",
  "Advanced exports.",
  "Highly personalized notification schedules.",
  "Share cards and social posting.",
])}

## Explicit Non-Goals

${list(idea.nonGoals)}

## Success Metrics

${list(idea.metrics)}
`;
}

function competitiveNotes(idea) {
  const domain = inferDomain(idea);
  const differentiators = idea.differentiators.map((item) => [item, "Differentiator", "Keep"]).map((row) => row);
  return `# Competitive And Reference Notes

## Category Read

Comparable patterns include adjacent ${domain.category} apps, lightweight utilities, dashboards, and daily ritual products. The app should avoid copying the common failure mode of collecting input before returning value.

## Positioning Gap

Most alternatives ask users to input data and later inspect charts. ${idea.name} should create an immediate loop around its core action and then unlock earned value.

## What To Copy

${list([
  "Daily ritual discipline from one-action-per-day products.",
  "Fast input from lightweight utilities.",
  "Private, calm reflection from journaling products.",
  "Clear earned-progress language from apps that delay claims until enough data exists.",
])}

## What To Avoid

${list([
  "Generic first-obvious input controls.",
  "Traffic-light red/yellow/green palettes.",
  "Template dashboards with equal cards.",
  "Social feeds, public profiles, likes, or public mood sharing.",
  "AI insight claims before enough entries exist.",
])}

## Feature Classification

| Feature | Role | Verdict |
|---|---|---|
${table(differentiators)}

## Design References

Use dark, precise, data-color interfaces as the visual family. References should influence hierarchy, density, and surface treatment, not copy another app's brand.
`;
}

function activationOnboarding(idea) {
  const firstJourney = idea.journeys?.[0];
  return `# Activation And Onboarding

## Activation Event

User completes the first prediction or simulated first prediction.

## First-Session Path

${list(firstJourney?.steps ?? [
  "Show the promise in one screen.",
  "Ask for the first prediction.",
  "Show what the evening rating will close.",
])}

## Aha Moment

The user sees that the app is not asking for a generic mood entry. It is creating a small bet about the day that will be resolved later.

## Minimum Input Before Value

One prediction value. Everything else can wait.

## Onboarding Copy

${list([
  "Predict how today will go.",
  "Rate what actually happened.",
  "Earn patterns after enough real days.",
])}

## States

${list([
  "Fresh install.",
  "Prediction made, evening rating pending.",
  "User skips onboarding.",
  "Notification permission deferred.",
])}

## Permission Timing

Do not request reminders before the user understands the ritual. Ask after the first prediction or on day two.
`;
}

function retentionLoop(idea) {
  return `# Retention Loop

## Core Loop

${list(idea.coreLoop)}

## Trigger Logic

${list([
  "Morning reminder invites a prediction.",
  "Evening reminder closes the prediction with a rating.",
  "Weekly prompt reveals one earned pattern or explains why more data is needed.",
  "Time Capsule reminders surface past expectations at meaningful intervals.",
])}

## Day 1

User makes a prediction, rates the day, answers one question, and sees completion without any fake insight claim.

## Day 3

User sees early continuity: repeated questions, visible history, and a clear count toward first Micro-Pattern readiness.

## Day 7

User unlocks or approaches the first Micro-Pattern. If data is insufficient, the app explains exactly what is missing.

## What Compounds

${list([
  "Prediction accuracy.",
  "Question answers.",
  "Pattern confidence.",
  "Time Capsules.",
  "History/export value.",
])}

## Missed-Day Recovery

The app should avoid shame language. It should let the user fill yesterday or continue today without pretending the streak is the product.
`;
}

function monetization(idea) {
  const productPrefix = slugToProductPrefix(idea.slug);
  return `# Monetization

## Model

Freemium. The proof app uses placeholder product IDs only.

## Free Value

${list([
  "Daily prediction.",
  "Evening rating.",
  "One daily question.",
  "Basic history.",
  "Pattern readiness state.",
])}

## Pro Value

${list([
  "Micro-Pattern reports.",
  "Deeper history.",
  "Exports.",
  "Reminder controls.",
  "Time Capsule depth.",
  "Longer-term pattern summaries.",
])}

## Placeholder Product IDs

${list([
  `${productPrefix}.pro.monthly`,
  `${productPrefix}.pro.yearly`,
  `${productPrefix}.pro.lifetime`,
])}

## Paywall Timing

Show the paywall after the user understands the daily ritual, when they attempt to open deeper pattern history, exports, reminder controls, or Pro reports. Do not block the first prediction or first rating.

## App Store-Safe Claims

${list([
  "Use 'patterns' and 'self-knowledge' language, not diagnosis language.",
  "Avoid claiming clinical, mental-health, or medical outcomes.",
  "Explain that insights require enough entries.",
  "Include restore purchase surface in settings/paywall.",
])}

## When Not To Monetize Yet

Do not force payment before first value. Do not sell Micro-Patterns before the user has seen why delayed insight is trustworthy.
`;
}

function userJourneys(idea) {
  const journeys = idea.journeys.map((journey) => `## ${journey.title}

Intent: ${journey.intent}

Steps:

${list(journey.steps)}

Success: ${journey.success}
`).join("\n");

  return `# User Journeys And States

${journeys}
## Screen Map

${list(idea.screens.map((screen) => `${screen.title}: ${screen.purpose}`))}

## Core States

${list([
  "First-use with no entries.",
  "Morning prediction pending.",
  "Prediction saved and evening rating pending.",
  "Day completed.",
  "Fewer than seven days of data.",
  "First Micro-Pattern unlocked.",
  "Sparse history.",
  "Paywall/pro surface.",
  "Reminder permission denied or deferred.",
  "Missed-day recovery.",
])}

## Edge Cases

${list(idea.edgeCases ?? [])}

## Error Handling

For the proof app, most data can be local/mock. Save failures should show a toast and leave visible content in place. If future backend wiring is added, bad-network states must keep existing entries visible and explain sync status without replacing the screen with an error page.
`;
}

function designMd(idea) {
  const domain = inferDomain(idea);
  const visual = idea.visual ?? {};
  const colorRoles = Object.entries(visual.colorRoles ?? {})
    .map(([key, value]) => `| ${key} | ${value} |`)
    .join("\n");
  const blueprints = idea.screens.map((screen, index) => `## ${index + 1}. ${screen.title}

Design Intent: ${screen.purpose}

Craft Moment: Make the primary ritual state visible at a glance. The user should know whether the day needs a prediction, rating, answer, or earned insight.

Visual Feel: ${visual.mood ?? "Specific, quiet, and app-native."}

Hierarchy:

- Primary: ${index === 0 ? "daily ritual state and action" : screen.components[0]}
- Secondary: ${screen.components.slice(1, 3).join(", ") || "supporting context"}
- Tertiary: history, metadata, or secondary actions.

Density target: Compact but not crowded.

Visual Reference: Private instrument, not wellness poster.

Hero element: ${index === 0 ? "Today ritual state" : screen.components[0]}

Sections:

${list(screen.components)}

States:

${list(screen.states)}

Empty state: ${screen.emptyState}

Entrance animation: restrained fade/slide tied to section order.

Screen-specific Don'ts:

${list(screen.acceptance.map((item) => `Do not violate: ${item}`))}
`).join("\n");

  return `# DESIGN.md

## 1. Design North Star

Mood: ${visual.mood ?? "Quiet, analytical, and intimate."}

${idea.name} should feel specific to its promise. It is precise, calm, and earned. It should avoid wellness cliches, generic cards, ${domain.cliche}, and fake AI insight energy.

Reference apps/patterns:

${list([
  "Daily ritual products for anticipation and cadence.",
  "Minimal data products for precision.",
  "Private journaling products for tone.",
])}

Anti-references:

${list([
  domain.cliche,
  "Traffic-light wellness apps.",
  "Template SaaS dashboards.",
])}

## 2. Color Palette

| Role | Direction |
|---|---|
${colorRoles || "| brand | dark neutral |\n| contrast | data color |\n| surface | near-black layered surfaces |"}

Use semantic colors in Swift. Avoid raw traffic-light colors.

## 3. Typography

- Display: use large numeric or ritual state text only for the core value.
- Titles: confident, compact, not oversized marketing copy.
- Body: calm explanatory copy with short lines.
- Captions: use for readiness, dates, and confidence labels.

## 4. Component Rules

| Component | Verdict | Notes |
|---|---|---|
| DSScreen | KEEP | Required root container. |
| DSButton | KEEP | Use for explicit commands. |
| DSIconButton | KEEP | Use for toolbar actions. |
| DSCard | COMPOSE | Use sparingly; avoid default equal card stacks. |
| DSListRow | COMPOSE | Use for history rows only. |
| EmptyStateView | COMPOSE | Prefer app-specific insufficient-data copy. |
| ErrorStateView | SKIP | Errors should be toasts, not replacement screens. |

## 5. Layout Principles

- One hero per screen.
- The daily loop wins over navigation chrome.
- Use varied spacing rhythm.
- Reserve stable space for controls and skeleton states.
- Avoid tab bars unless a future app has multiple equal top-level modes.

## 6. Depth And Elevation

Use subtle layered surfaces. Depth should separate ritual, data, and secondary action. Avoid glossy generic glass unless it supports the bottom ritual control.

## 7. Do's And Don'ts

DO:

${list([
  "Make prediction and rating feel like one closed loop.",
  "Show pattern readiness before insight claims.",
  "Use muted data color and calm surfaces.",
  "Make the primary state visible in one glance.",
])}

DON'T:

${list([
  "Do not use generic rating circles.",
  "Do not use red/yellow/green traffic-light palettes.",
  "Do not build equal-weight dashboard cards.",
  `Do not put ${idea.name} in a default tab scaffold.`,
  "Do not claim insights before enough data exists.",
  "Do not use raw Button where DSButton or DSIconButton applies.",
  "Do not hide the daily loop behind settings or history.",
])}

## 8. Screen Blueprints

${blueprints}

## 9. Voice And Copy

Tone: precise, private, plain.

| Context | Copy |
|---|---|
| activation headline | Predict today. Rate tonight. Learn after the pattern is earned. |
| first prediction CTA | Make today's prediction |
| evening rating CTA | Close the day |
| insufficient data | Patterns unlock after enough real days. |
| Pro value | Unlock deeper patterns and exports. |
| error save failed | Couldn't save. Try again. |
`;
}

function progressMd(idea, context) {
  return `# Forge Progress

pipeline_version: forge-e2e-bridge-0.1
app_name: ${idea.name}
generated_at: ${context.generatedAt}
generated_app_path: ${context.appPath}
xcode_project: ${context.projectName}
mock_scheme: ${context.appName} - Mock

## Phase Status

- P0 product: completed
- P0.5 competitive/reference: completed
- P1 activation/onboarding: completed
- P2 retention: completed
- P3 monetization: completed
- P4 UX/state: completed
- P5 design: completed
- P6 native build: pending
- P7 verification: pending
- P8 judge/repair: pending
- P9 handoff: pending

## Alignment Notes

- Remote forge-marketplace v5 P0-P7 is the architecture north star.
- This app lives outside the Forge template repo.
- Old template-mutating DayRate proof commits are archived evidence only.
- Native SwiftUI screens are intentionally pending after this foundation pass.
`;
}

async function main() {
  const args = parseArgs(process.argv);
  if (args.help) {
    console.log(usage());
    return;
  }

  if (!args.idea || !args.app_path) {
    throw new Error(usage());
  }

  const ideaPath = path.resolve(args.idea);
  const appPath = path.resolve(args.app_path);
  const projectName = await findProject(appPath);
  const appName = projectName.replace(/\.xcodeproj$/, "");
  const generatedAt = args.generated_at ?? new Date().toISOString();
  const bundleId = inferBundleId(appPath, projectName);
  const idea = await readJson(ideaPath);
  const forgeDir = path.join(appPath, ".forge");
  const evidenceDir = path.join(forgeDir, "evidence");

  if (args.clean) {
    await fs.rm(forgeDir, { recursive: true, force: true });
  }

  await fs.mkdir(evidenceDir, { recursive: true });

  const context = {
    generatedAt,
    ideaPath,
    appPath,
    projectName,
    appName,
    bundleId,
  };

  const spec = buildSpec(idea, context);
  const files = [
    ["spec.json", JSON.stringify(spec, null, 2)],
    ["product-thesis.md", productThesis(idea, context)],
    ["competitive-notes.md", competitiveNotes(idea)],
    ["activation-onboarding.md", activationOnboarding(idea)],
    ["retention-loop.md", retentionLoop(idea)],
    ["monetization.md", monetization(idea)],
    ["user-journeys.md", userJourneys(idea)],
    ["DESIGN.md", designMd(idea)],
    ["progress.md", progressMd(idea, context)],
  ];

  for (const [relativePath, content] of files) {
    await writeText(path.join(forgeDir, relativePath), content);
  }

  const receipt = {
    kind: "forge.e2e.foundation_receipt",
    generatedAt,
    command: process.argv.join(" "),
    sourceIdea: ideaPath,
    appPath,
    xcodeProject: path.join(appPath, projectName),
    mockScheme: `${appName} - Mock`,
    bundleId,
    marketplaceAlignment: "remote forge-marketplace v5 P0-P7",
    templateMutationAllowed: false,
    nativeImplementationStatus: "pending",
    outputs: files.map(([relativePath]) => path.join(forgeDir, relativePath)).concat([
      path.join(evidenceDir, "foundation-receipt.json"),
    ]),
  };

  await writeJson(path.join(evidenceDir, "foundation-receipt.json"), receipt);

  console.log(`Forge E2E foundation written: ${forgeDir}`);
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
