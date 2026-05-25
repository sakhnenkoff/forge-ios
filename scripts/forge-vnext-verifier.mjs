#!/usr/bin/env node
import fs from "node:fs/promises";
import crypto from "node:crypto";
import path from "node:path";
import process from "node:process";

const PLAN_VERSION = "forge.verification-plan.v1";
const INDEX_VERSION = "forge.evidence-index.v1";
const SUBSTITUTE_VERSION = "forge.substitute-evidence.v1";
const MODULE_PLAN_VERSION = "forge.module-plan.v1";
const DEFAULT_REJECTED_PROOF_MODULES = [
  "auth-account",
  "paywall-purchases",
  "sync-backend",
  "settings-profile",
  "onboarding",
  "public-launch"
];

function usage() {
  return `Usage:\n  node scripts/forge-vnext-verifier.mjs --app-path <app-or-fixture-path> [--plan .forge/verification-plan.json] [--write-index]\n\nRuns the generic Forge vNext verification/evidence contract. App-specific paths, markers, screenshots, and substitutions must live in the app-local .forge plan and evidence index.`;
}

function parseArgs(argv) {
  const args = { plan: ".forge/verification-plan.json", writeIndex: false };
  for (let index = 2; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") args.help = true;
    else if (arg === "--write-index") args.writeIndex = true;
    else if (arg === "--app-path" || arg === "--plan") {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) throw new Error(`Missing value for ${arg}`);
      if (arg === "--app-path") args.appPath = value;
      else args.plan = value;
      index += 1;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

async function exists(filePath) {
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

async function readText(filePath) {
  return fs.readFile(filePath, "utf8");
}

async function sha256File(filePath) {
  return crypto.createHash("sha256").update(await fs.readFile(filePath)).digest("hex");
}

function normalizeArtifactPath(value) {
  return value.split(path.sep).join("/");
}

function relPath(base, value) {
  return path.resolve(base, value);
}

function requireString(value, label, errors) {
  if (typeof value !== "string" || value.trim() === "") errors.push(`${label} must be a non-empty string`);
}

function validatePlanShape(plan, errors) {
  if (!plan || typeof plan !== "object") {
    errors.push("verification plan must be an object");
    return;
  }
  if (plan.schema_version !== PLAN_VERSION) errors.push(`verification plan schema_version must be ${PLAN_VERSION}`);
  for (const [value, label] of [
    [plan.app?.id, "app.id"],
    [plan.app?.name, "app.name"],
    [plan.app?.project, "app.project"],
    [plan.app?.scheme, "app.scheme"],
    [plan.sources?.spec, "sources.spec"],
    [plan.sources?.design, "sources.design"]
  ]) requireString(value, label, errors);
  if (!Array.isArray(plan.sources?.gate_receipts)) errors.push("sources.gate_receipts must be an array");
  if (!Array.isArray(plan.checks)) errors.push("checks must be an array");
  if (typeof plan.policy?.allow_substitutes !== "boolean") errors.push("policy.allow_substitutes must be boolean");
}

async function walkFiles(root) {
  const out = [];
  if (!await exists(root)) return out;
  const entries = await fs.readdir(root, { withFileTypes: true });
  for (const entry of entries) {
    if ([".git", "node_modules"].includes(entry.name)) continue;
    const full = path.join(root, entry.name);
    if (entry.isDirectory()) out.push(...await walkFiles(full));
    else out.push(full);
  }
  return out;
}

function normalizeForMatch(filePath) {
  return filePath.split(path.sep).join("/");
}

function includeMatches(relative, include) {
  if (!Array.isArray(include) || include.length === 0) return true;
  return include.some((pattern) => {
    const p = pattern.replaceAll("\\", "/");
    if (p === "**/*") return true;
    if (p.startsWith("**/*.")) return relative.endsWith(p.slice(4));
    if (p.includes("/**/")) {
      const [prefix, suffix] = p.split("/**/");
      return relative.startsWith(prefix + "/") && relative.endsWith(suffix.replace("*", ""));
    }
    if (p.includes("**")) {
      const [prefix, suffix = ""] = p.split("**");
      return relative.startsWith(prefix) && relative.endsWith(suffix.replace("*", ""));
    }
    if (p.includes("*")) {
      const escaped = p.replace(/[.+?^${}()|[\]\\]/g, "\\$&").replaceAll("*", ".*");
      return new RegExp(`^${escaped}$`).test(relative);
    }
    return relative === p || relative.endsWith("/" + p);
  });
}

function severitySink(check, errors, warnings) {
  return check.severity === "warning" ? warnings : errors;
}

function getPointer(doc, pointer) {
  if (!pointer || pointer === "#" || pointer === "") return doc;
  const clean = pointer.startsWith("#") ? pointer.slice(1) : pointer;
  if (!clean.startsWith("/")) return undefined;
  return clean.slice(1).split("/").reduce((value, part) => {
    if (value === undefined || value === null) return undefined;
    const key = part.replaceAll("~1", "/").replaceAll("~0", "~");
    return value[key];
  }, doc);
}

async function evaluateModulePlan(appPath, plan, errors) {
  if (plan.policy?.strictness !== "proof-app") return;

  const modulePlanPath = relPath(appPath, ".forge/module-plan.json");
  const modulePlan = await readJson(modulePlanPath).catch((error) => {
    errors.push(`proof-app module plan missing or invalid at .forge/module-plan.json: ${error.message}`);
    return null;
  });
  if (!modulePlan) return;

  if (modulePlan.schema_version !== MODULE_PLAN_VERSION) errors.push(`module plan schema_version must be ${MODULE_PLAN_VERSION}`);
  if (!Array.isArray(modulePlan.selected_modules) || modulePlan.selected_modules.length === 0) errors.push("module plan selected_modules must explicitly select at least one module");
  if (!modulePlan.selected_modules?.includes("local-proof-shell")) errors.push("module plan for generated proof apps must select local-proof-shell");
  if (!Array.isArray(modulePlan.rejected_modules)) {
    errors.push("module plan rejected_modules must be an array");
    return;
  }

  const rejectedById = new Map(modulePlan.rejected_modules.map((module) => [module?.id, module]));
  for (const moduleId of DEFAULT_REJECTED_PROOF_MODULES) {
    const rejected = rejectedById.get(moduleId);
    if (!rejected) {
      errors.push(`module plan must explicitly reject non-selected proof module ${moduleId}`);
      continue;
    }
    if (typeof rejected.rationale !== "string" || rejected.rationale.trim() === "") errors.push(`module plan rejection ${moduleId} must include rationale`);
  }
  if (typeof modulePlan.absence_gate !== "string" || modulePlan.absence_gate.trim() === "") errors.push("module plan must declare the absence_gate enforcing rejected modules");
}

function mandatoryGeneratedProofChecks(plan) {
  if (plan.policy?.strictness !== "proof-app") return [];
  return [
    ...[
      "skills",
      "forge-cli",
      "docs/superpowers",
      "docs/goals",
      "docs/plans",
      ".forge/research",
      "scripts/new-app.sh",
      "scripts/forge-vnext-verifier.mjs",
      "scripts/forge-vnext-gate-validate.mjs",
      "scripts/forge-e2e-native-verify.mjs",
      "tests"
    ].map((forbiddenPath) => ({
      id: `mandatory-generated-proof-no-${forbiddenPath.replaceAll("/", "-").replaceAll(".", "-")}`,
      type: "path_absent",
      severity: "blocker",
      path: forbiddenPath,
      rationale: "Generated proof repos must not contain copied Forge control-plane residue."
    })),
    {
      id: "mandatory-generated-proof-no-forbidden-compiled-surfaces",
      type: "repo_forbid_regex",
      severity: "blocker",
      include: ["**/*.swift", "**/*.pbxproj", "Package.swift", "Package.resolved"],
      patterns: [
        "\\bStoreKit\\b",
        "\\b[Rr]evenue[Cc]at\\b",
        "\\b[Pp]aywall(View|ViewModel)?\\b",
        "\\bAuthView\\b",
        "\\blogIn\\b",
        "\\bDayRate(Lab)?\\b",
        "\\bAccountView(Model)?\\b",
        "\\bAuth(Manager|ViewModel)\\b",
        "\\bAuthenticationManager\\b",
        "\\bPaymentManager\\b",
        "\\bPurchase(Manager|Service)\\b",
        "case auth",
        "case account",
        "case paywall",
        "case settings",
        "case onboarding",
        "Sign in to your account",
        "Upgrade subscription",
        "Text\\(\\\"Settings\\\"\\)",
        "Welcome onboarding",
        "\\bFirebaseAuth\\b",
        "\\bFirebaseFirestore\\b",
        "\\bFirebaseMessaging\\b",
        "\\bFirebaseRemoteConfig\\b",
        "\\bFirebaseStorage\\b",
        "\\bFirebaseAnalytics\\b",
        "\\bFirebaseCrashlytics\\b",
        "\\bGoogleSignIn\\b",
        "\\bMixpanel\\b",
        "purchases-ios",
        "firebase-ios-sdk",
        "mixpanel-swift"
      ],
      rationale: "Generated local proof apps must not compile copied money, account, auth, payment, analytics, push, external SDK dependency, or old fixture-domain surfaces."
    },
    {
      id: "mandatory-generated-proof-no-push-external-signing-residue",
      type: "repo_forbid_regex",
      severity: "blocker",
      include: ["**/*.swift", "**/*.pbxproj", "Package.swift", "Package.resolved", "**/*.plist", "**/*.entitlements", "scripts/**/*.sh"],
      patterns: [
        "GoogleService-Info",
        "GoogleServicePLists",
        "Crashlytics/upload-symbols",
        "\\bupload-symbols\\b",
        "aps-environment",
        "FirebaseAppDelegateProxyEnabled",
        "DEVELOPMENT_TEAM",
        "CODE_SIGN_STYLE\\s*=\\s*Automatic",
        "PROVISIONING_PROFILE",
        "PROVISIONING_PROFILE_SPECIFIER"
      ],
      rationale: "Generated local proof apps must not carry copied Firebase plist, Crashlytics, push entitlement, public signing, team, or provisioning residue."
    },
    {
      id: "mandatory-generated-proof-no-public-release-instructions",
      type: "repo_forbid_regex",
      severity: "blocker",
      include: ["README.md", "AGENTS.md", "docs/**/*.md", "scripts/**/*.sh"],
      patterns: [
        "App Store",
        "TestFlight",
        "StoreKit",
        "[Rr]evenue[Cc]at",
        "signing",
        "provisioning profile",
        "public launch",
        "DayRate(Lab)?",
        "\\b(?:[Ss]et up|[Cc]onfigure|[Ee]nable|[Aa]dd|[Ii]mplement|[Cc]reate|[Ww]ire|[Ii]ntegrate)\\b.{0,80}\\b(?:accounts?|auth(?:entication)?|payments?|paywalls?|subscriptions?|purchases?)\\b"
      ],
      rationale: "Generated local proof apps must not carry copied public release, store, payment, account, auth, subscription, purchase, or stale fixture instructions."
    }
  ];
}

async function resolveMarkerSource(appPath, descriptor, plan) {
  if (Array.isArray(descriptor.markers)) return descriptor.markers;
  if (typeof descriptor.markers_from !== "string") return [];
  const [filePart, pointer = "#"] = descriptor.markers_from.split("#");
  const targetPath = filePart === ".forge/verification-plan.json" ? null : relPath(appPath, filePart);
  const doc = targetPath ? await readJson(targetPath) : plan;
  const value = getPointer(doc, `#${pointer}`);
  return Array.isArray(value) ? value : [];
}

async function runCheck(check, ctx) {
  const sink = severitySink(check, ctx.errors, ctx.warnings);
  const fail = (message) => sink.push(`${check.id}: ${message}`);
  if (!check.id || !check.type) {
    ctx.errors.push("check entries require id and type");
    return;
  }
  if (check.type === "file_exists") {
    if (!await exists(relPath(ctx.appPath, check.path))) fail(`missing file ${check.path}`);
    return;
  }
  if (check.type === "json_schema_valid") {
    try { await readJson(relPath(ctx.appPath, check.path)); }
    catch (error) { fail(`invalid JSON ${check.path}: ${error.message}`); }
    return;
  }
  if (check.type === "path_absent") {
    if (!check.path) return fail("path_absent requires path");
    if (await exists(relPath(ctx.appPath, check.path))) fail(`forbidden path exists: ${check.path}`);
    return;
  }
  if (check.type === "markdown_contains_sections") {
    const text = await readText(relPath(ctx.appPath, check.path)).catch(() => null);
    if (text === null) return fail(`missing markdown ${check.path}`);
    for (const section of check.sections ?? []) if (!text.includes(section)) fail(`missing section ${section}`);
    return;
  }
  if (check.type === "swift_contains_all" || check.type === "swift_contains_any") {
    const text = await readText(relPath(ctx.appPath, check.path)).catch(() => null);
    if (text === null) return fail(`missing Swift file ${check.path}`);
    const markers = await resolveMarkerSource(ctx.appPath, check, ctx.plan);
    const hits = markers.filter((marker) => text.includes(marker));
    if (check.type === "swift_contains_all" && hits.length !== markers.length) {
      const missing = markers.filter((marker) => !text.includes(marker));
      fail(`missing markers in ${check.path}: ${missing.join(", ")}`);
    }
    if (check.type === "swift_contains_any" && hits.length === 0) fail(`none of the configured markers appeared in ${check.path}`);
    return;
  }
  if (check.type === "repo_contains_any" || check.type === "repo_forbid_regex") {
    const files = await walkFiles(ctx.appPath);
    const selected = files.filter((file) => includeMatches(normalizeForMatch(path.relative(ctx.appPath, file)), check.include));
    const texts = await Promise.all(selected.map(async (file) => [file, await readText(file).catch(() => "")]));
    const terms = check.markers ?? check.patterns ?? [];
    if (check.type === "repo_contains_any") {
      const found = texts.some(([, text]) => terms.some((term) => text.includes(term) || new RegExp(term).test(text)));
      if (!found) fail("none of the configured repo markers appeared");
    } else {
      for (const [file, text] of texts) {
        for (const term of terms) if (new RegExp(term).test(text)) fail(`forbidden pattern matched in ${path.relative(ctx.appPath, file)}: ${term}`);
      }
    }
    return;
  }
  if (check.type === "spec_feature_statuses") {
    const spec = await readJson(relPath(ctx.appPath, check.spec));
    const features = new Map((spec.features ?? []).map((feature) => [feature.id, feature.status]));
    for (const id of check.feature_ids ?? []) {
      if (features.get(id) !== check.required_status) fail(`feature ${id} status is ${features.get(id) ?? "missing"}, expected ${check.required_status}`);
    }
    return;
  }
  if (check.type === "gate_assertion") {
    const doc = await readJson(relPath(ctx.appPath, check.receipt));
    const actual = getPointer(doc, check.json_pointer);
    if (JSON.stringify(actual) !== JSON.stringify(check.expected)) fail(`gate assertion ${check.json_pointer} expected ${JSON.stringify(check.expected)} got ${JSON.stringify(actual)}`);
    return;
  }
  if (check.type === "evidence_slot_present") {
    if (!ctx.slotById.has(check.slot_id)) fail(`unknown evidence slot ${check.slot_id}`);
    return;
  }
  fail(`unsupported generic check type ${check.type}`);
}

function collectSlots(plan) {
  const slots = new Map();
  for (const collection of [plan.evidence_slots, plan.screenshot_slots, plan.video_slots]) {
    for (const slot of collection ?? []) {
      if (slot?.id) slots.set(slot.id, { ...slot, required: slot.required !== false });
    }
  }
  return slots;
}

function validateIndexShape(index, errors) {
  if (index.schema_version !== INDEX_VERSION) errors.push(`evidence index schema_version must be ${INDEX_VERSION}`);
  if (!Array.isArray(index.slots)) errors.push("evidence index slots must be an array");
}

async function validateAcceptedEvidenceSourceHashes(appPath, indexSlot, errors) {
  if (typeof indexSlot.artifact !== "string") return;
  const artifact = normalizeArtifactPath(indexSlot.artifact);
  if (!artifact.startsWith(".forge/evidence/") || !artifact.endsWith(".json")) return;

  const transcript = await readJson(relPath(appPath, indexSlot.artifact)).catch(() => null);
  if (!transcript || !Array.isArray(transcript.sources)) return;

  for (const source of transcript.sources) {
    if (typeof source?.path !== "string" || typeof source?.sha256 !== "string") continue;
    const sourcePath = relPath(appPath, source.path);
    if (!await exists(sourcePath)) {
      errors.push(`missing evidence source in ${artifact} for ${source.path}`);
      continue;
    }
    const actual = await sha256File(sourcePath);
    if (actual !== source.sha256) {
      errors.push(`stale evidence source hash in ${artifact} for ${source.path}: expected ${source.sha256}, got ${actual}`);
    }
  }
}

async function validateSubstitute(appPath, indexSlot, slot, errors, warnings) {
  if (!indexSlot.owner || !indexSlot.rationale) errors.push(`approved substitute for ${slot.id} must include rationale and owner in evidence index`);
  if (!indexSlot.artifact) {
    errors.push(`approved substitute for ${slot.id} must link a substitute artifact`);
    return;
  }
  const substitutePath = relPath(appPath, indexSlot.artifact);
  const substitute = await readJson(substitutePath).catch((error) => {
    errors.push(`approved substitute for ${slot.id} could not be read: ${error.message}`);
    return null;
  });
  if (!substitute) return;
  if (substitute.schema_version !== SUBSTITUTE_VERSION) errors.push(`approved substitute for ${slot.id} has wrong schema_version`);
  for (const key of ["slot_id", "rationale", "owner", "approved_by", "approved_at", "limits"]) {
    if (typeof substitute[key] !== "string" || substitute[key].trim() === "") errors.push(`approved substitute for ${slot.id} missing ${key}`);
  }
  if (substitute.slot_id !== slot.id) errors.push(`approved substitute for ${slot.id} names ${substitute.slot_id}`);
  if (substitute.status !== "approved") errors.push(`approved substitute for ${slot.id} must have status approved`);
  if (!Array.isArray(substitute.substitute_artifacts) || substitute.substitute_artifacts.length === 0) errors.push(`approved substitute for ${slot.id} must list substitute artifacts`);
  for (const artifact of substitute.substitute_artifacts ?? []) {
    if (!await exists(relPath(appPath, artifact))) errors.push(`approved substitute for ${slot.id} references missing artifact ${artifact}`);
  }
  warnings.push(`approved substitute accepted for ${slot.id}: ${substitute.limits}`);
}

async function evaluateEvidence(appPath, plan, slotById, errors, warnings) {
  const indexPath = relPath(appPath, ".forge/evidence/evidence-index.json");
  const index = await readJson(indexPath).catch((error) => {
    errors.push(`missing or invalid evidence index: ${error.message}`);
    return null;
  });
  if (!index) return { status: "fail", indexPath, slots: [] };
  validateIndexShape(index, errors);
  const indexSlots = new Map((index.slots ?? []).map((slot) => [slot.id, slot]));
  let hasSubstitute = false;
  const outputSlots = [];
  for (const [id, slot] of slotById) {
    if (!slot.required) continue;
    const indexSlot = indexSlots.get(id);
    if (!indexSlot) {
      errors.push(`missing required evidence index slot: ${id}`);
      continue;
    }
    outputSlots.push(indexSlot);
    if (indexSlot.status === "accepted") {
      if (!indexSlot.artifact || !await exists(relPath(appPath, indexSlot.artifact))) {
        errors.push(`missing required evidence artifact for ${id}: ${indexSlot.artifact ?? "<none>"}`);
      } else {
        await validateAcceptedEvidenceSourceHashes(appPath, indexSlot, errors);
      }
      continue;
    }
    if (indexSlot.status === "substituted_approved") {
      hasSubstitute = true;
      if (!plan.policy?.allow_substitutes || slot.substitute_allowed === false) errors.push(`substitute is not allowed for ${id}`);
      await validateSubstitute(appPath, indexSlot, slot, errors, warnings);
      continue;
    }
    errors.push(`missing required evidence for ${id}: status ${indexSlot.status}`);
  }
  return { status: errors.length > 0 ? "fail" : (hasSubstitute ? "pass_with_substitutions" : "pass"), indexPath, slots: outputSlots };
}

async function main() {
  const args = parseArgs(process.argv);
  if (args.help) {
    console.log(usage());
    return;
  }
  if (!args.appPath) throw new Error("Missing required --app-path");

  const appPath = path.resolve(args.appPath);
  const planPath = relPath(appPath, args.plan);
  const errors = [];
  const warnings = [];

  const plan = await readJson(planPath);
  validatePlanShape(plan, errors);

  if (plan.app?.project && !await exists(relPath(appPath, plan.app.project))) errors.push(`project from plan does not exist: ${plan.app.project}`);
  for (const source of [plan.sources?.spec, plan.sources?.design, ...(plan.sources?.gate_receipts ?? [])].filter(Boolean)) {
    if (!await exists(relPath(appPath, source))) errors.push(`referenced source artifact does not exist: ${source}`);
  }
  await evaluateModulePlan(appPath, plan, errors);

  const slotById = collectSlots(plan);
  const ctx = { appPath, plan, errors, warnings, slotById };
  for (const check of [...mandatoryGeneratedProofChecks(plan), ...(plan.checks ?? [])]) await runCheck(check, ctx);
  const evidence = await evaluateEvidence(appPath, plan, slotById, errors, warnings);

  const result = {
    status: errors.length > 0 ? "fail" : evidence.status,
    app_id: plan.app?.id,
    app_path: appPath,
    plan_path: planPath,
    evidence_index: evidence.indexPath,
    screenshot_slots: [...slotById.values()].filter((slot) => slot.class === "screenshot").map((slot) => slot.id),
    blockers: errors,
    warnings
  };

  if (args.writeIndex) {
    const nextIndex = {
      schema_version: INDEX_VERSION,
      app_id: plan.app?.id ?? "unknown",
      generated_at: new Date().toISOString(),
      verification_plan: args.plan,
      overall_status: result.status,
      slots: evidence.slots,
      blockers: errors,
      warnings
    };
    await fs.mkdir(path.dirname(evidence.indexPath), { recursive: true });
    await fs.writeFile(evidence.indexPath, `${JSON.stringify(nextIndex, null, 2)}\n`);
  }

  if (errors.length > 0) {
    console.error(`FORGE_VNEXT_VERIFY_FAILED for ${appPath}`);
    for (const error of errors) console.error(`- ${error}`);
    process.exitCode = 1;
    return;
  }
  console.log(JSON.stringify(result, null, 2));
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
