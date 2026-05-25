import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const repoRoot = path.resolve(new URL("..", import.meta.url).pathname);
const verifier = path.join(repoRoot, "scripts/forge-vnext-verifier.mjs");
const fixtureRoot = path.join(repoRoot, "docs/forge-vnext/fixtures");

function runVerifier(fixtureName) {
  return spawnSync(process.execPath, [verifier, "--app-path", path.join(fixtureRoot, fixtureName)], {
    cwd: repoRoot,
    encoding: "utf8"
  });
}

function runNewApp(appName, destinationRoot) {
  return spawnSync("bash", [path.join(repoRoot, "scripts/new-app.sh"), appName, destinationRoot, `local.fixture.${appName.toLowerCase()}`, appName], {
    cwd: repoRoot,
    encoding: "utf8"
  });
}

function writeMinimalProofApp(appRoot) {
  fs.mkdirSync(path.join(appRoot, ".forge/evidence"), { recursive: true });
  fs.mkdirSync(path.join(appRoot, ".forge/gates"), { recursive: true });
  fs.mkdirSync(path.join(appRoot, "ProofApp.xcodeproj"), { recursive: true });
  fs.writeFileSync(path.join(appRoot, ".forge/spec.json"), JSON.stringify({ features: [] }, null, 2));
  fs.writeFileSync(path.join(appRoot, ".forge/DESIGN.md"), "# Design\n");
  fs.writeFileSync(path.join(appRoot, ".forge/gates/product.json"), JSON.stringify({ ok: true }, null, 2));
  fs.writeFileSync(path.join(appRoot, ".forge/evidence/evidence-index.json"), JSON.stringify({ schema_version: "forge.evidence-index.v1", slots: [] }, null, 2));
  fs.writeFileSync(path.join(appRoot, ".forge/module-plan.json"), JSON.stringify({
    schema_version: "forge.module-plan.v1",
    app_id: "proof-app",
    generated_app: "ProofApp",
    selected_modules: ["local-proof-shell"],
    rejected_modules: [
      { id: "auth-account", rationale: "Proof fixture has no account/auth module." },
      { id: "paywall-purchases", rationale: "Proof fixture has no payment module." },
      { id: "sync-backend", rationale: "Proof fixture has no backend sync module." },
      { id: "settings-profile", rationale: "Proof fixture has no settings/profile module." },
      { id: "onboarding", rationale: "Proof fixture has no onboarding module." },
      { id: "public-launch", rationale: "Proof fixture has no public launch module." }
    ],
    absence_gate: "strict proof-app absence gates"
  }, null, 2));
  fs.writeFileSync(path.join(appRoot, ".forge/verification-plan.json"), JSON.stringify({
    schema_version: "forge.verification-plan.v1",
    app: {
      id: "proof-app",
      name: "ProofApp",
      repo_root: ".",
      project: "ProofApp.xcodeproj",
      scheme: "ProofApp - Mock",
      platform: "ios"
    },
    sources: {
      spec: ".forge/spec.json",
      design: ".forge/DESIGN.md",
      gate_receipts: [".forge/gates/product.json"]
    },
    policy: {
      strictness: "proof-app",
      allow_substitutes: false
    },
    checks: [],
    evidence_slots: []
  }, null, 2));
}

function runVerifierAt(appRoot) {
  return spawnSync(process.execPath, [verifier, "--app-path", appRoot], {
    cwd: repoRoot,
    encoding: "utf8"
  });
}

describe("generated app sanitizer and absence gates", () => {
  it("rejects proof repos with copied control-plane residue, release instructions, or forbidden compiled surfaces", () => {
    const result = runVerifier("generated-residue-fail");

    assert.notEqual(result.status, 0, `expected generated-residue-fail to be rejected\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
    assert.match(result.stderr, /no-copied-skills: forbidden path exists: skills/);
    assert.match(result.stderr, /no-forge-cli: forbidden path exists: forge-cli/);
    assert.match(result.stderr, /no-vnext-scripts: forbidden path exists: scripts\/forge-vnext-verifier\.mjs/);
    assert.match(result.stderr, /no-forbidden-compiled-surfaces: forbidden pattern matched .*StoreKit/);
    assert.match(result.stderr, /no-public-release-instructions: forbidden pattern matched .*App Store/);
  });

  it("rejects generic account auth payment and subscription instructions in proof app docs", () => {
    const appRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-proof-doc-residue-"));
    writeMinimalProofApp(appRoot);
    fs.mkdirSync(path.join(appRoot, "docs"), { recursive: true });
    fs.writeFileSync(path.join(appRoot, "README.md"), "Set up an account, authentication route, and payment setup before local proof.\n");
    fs.writeFileSync(path.join(appRoot, "docs/onboarding.md"), "Configure subscriptions and purchase flows for users.\n");

    const result = runVerifierAt(appRoot);

    assert.notEqual(result.status, 0, `expected proof doc residue to be rejected\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
    assert.match(result.stderr, /mandatory-generated-proof-no-public-release-instructions: forbidden pattern matched .*README\.md/);
    assert.match(result.stderr, /account|auth|payment/i);
    assert.match(result.stderr, /subscription|purchase/i);
  });

  it("rejects generic account payment auth Swift surfaces and dependency residue", () => {
    const appRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-proof-compiled-residue-"));
    writeMinimalProofApp(appRoot);
    fs.mkdirSync(path.join(appRoot, "ProofApp/Features/Account"), { recursive: true });
    fs.writeFileSync(path.join(appRoot, "ProofApp/Features/Account/AccountView.swift"), `
import SwiftUI
struct AccountView: View { var body: some View { Text("Account") } }
final class AccountViewModel {}
final class AuthenticationManager {}
final class PaymentManager {}
final class PurchaseService {}
`);
    fs.writeFileSync(path.join(appRoot, "Package.swift"), `
// swift-tools-version: 6.0
import PackageDescription
let package = Package(
  name: "ProofAppDeps",
  dependencies: [
    .package(url: "https://github.com/revenuecat/purchases-ios", from: "5.0.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
    .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "8.0.0")
  ],
  targets: [.target(name: "ProofAppDeps", dependencies: ["FirebaseAuth", "GoogleSignIn"])]
)
`);

    const result = runVerifierAt(appRoot);

    assert.notEqual(result.status, 0, `expected proof compiled residue to be rejected\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
    assert.match(result.stderr, /mandatory-generated-proof-no-forbidden-compiled-surfaces: forbidden pattern matched .*AccountView/);
    assert.match(result.stderr, /PaymentManager/);
    assert.match(result.stderr, /AuthenticationManager/);
    assert.match(result.stderr, /purchases-ios/);
    assert.match(result.stderr, /FirebaseAuth/);
    assert.match(result.stderr, /GoogleSignIn/);
  });

  it("rejects visible and routable rejected-module residue even without copied module files", () => {
    const appRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-proof-visible-route-residue-"));
    writeMinimalProofApp(appRoot);
    fs.mkdirSync(path.join(appRoot, "ProofApp/App"), { recursive: true });
    fs.writeFileSync(path.join(appRoot, "ProofApp/App/RouteResidue.swift"), `
import SwiftUI

enum AppRoute {
  case auth
  case account
  case paywall
  case settings
  case onboarding
}

struct RouteResidueView: View {
  var body: some View {
    VStack {
      Text("Sign in to your account")
      Text("Upgrade subscription")
      Text("Settings")
      Text("Welcome onboarding")
    }
  }
}
`);

    const result = runVerifierAt(appRoot);

    assert.notEqual(result.status, 0, `expected visible/routable residue to be rejected\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
    assert.match(result.stderr, /case auth/);
    assert.match(result.stderr, /case paywall/);
    assert.match(result.stderr, /Sign in to your account/);
    assert.match(result.stderr, /Upgrade subscription/);
    assert.match(result.stderr, /Welcome onboarding/);
  });

  it("rejects external service, push notification, and public signing residue", () => {
    const appRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-proof-external-push-signing-residue-"));
    writeMinimalProofApp(appRoot);
    fs.mkdirSync(path.join(appRoot, "ProofApp/App"), { recursive: true });
    fs.mkdirSync(path.join(appRoot, "ProofApp.xcodeproj"), { recursive: true });
    fs.mkdirSync(path.join(appRoot, "scripts"), { recursive: true });

    fs.writeFileSync(path.join(appRoot, "ProofApp/App/PushAndAnalyticsResidue.swift"), `
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseMessaging
import FirebaseRemoteConfig
import FirebaseStorage
import Mixpanel

enum PushAndAnalyticsResidue {
  static let services = ["FirebaseAppDelegateProxyEnabled", "Mixpanel"]
}
`);
    fs.writeFileSync(path.join(appRoot, "Package.swift"), `
// swift-tools-version: 6.0
import PackageDescription
let package = Package(
  name: "ProofAppDeps",
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
    .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "4.0.0")
  ],
  targets: [.target(name: "ProofAppDeps", dependencies: ["FirebaseMessaging", "FirebaseRemoteConfig", "FirebaseStorage", "FirebaseAnalytics", "FirebaseCrashlytics", "Mixpanel"])]
)
`);
    fs.writeFileSync(path.join(appRoot, "Package.resolved"), "firebase-ios-sdk mixpanel-swift\n");
    fs.writeFileSync(path.join(appRoot, "GoogleService-Info.plist"), "<plist><dict><key>GOOGLE_APP_ID</key><string>residue</string></dict></plist>\n");
    fs.writeFileSync(path.join(appRoot, "ProofApp/GoogleServicePLists.swift"), "let googleServicePLists = [\"GoogleService-Info.plist\"]\n");
    fs.writeFileSync(path.join(appRoot, "ProofApp/ProofApp.entitlements"), "<plist><dict><key>aps-environment</key><string>development</string></dict></plist>\n");
    fs.writeFileSync(path.join(appRoot, "ProofApp.xcodeproj/project.pbxproj"), "DEVELOPMENT_TEAM = ABC123; CODE_SIGN_STYLE = Automatic; PROVISIONING_PROFILE_SPECIFIER = LocalProof; GoogleService-Info.plist; Crashlytics/upload-symbols;\n");
    fs.writeFileSync(path.join(appRoot, "scripts/upload-symbols.sh"), "./Crashlytics/upload-symbols -gsp GoogleService-Info.plist\n");

    const result = runVerifierAt(appRoot);

    assert.notEqual(result.status, 0, `expected external/push/signing residue to be rejected\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
    assert.match(result.stderr, /FirebaseMessaging/);
    assert.match(result.stderr, /FirebaseRemoteConfig/);
    assert.match(result.stderr, /FirebaseStorage/);
    assert.match(result.stderr, /FirebaseAnalytics/);
    assert.match(result.stderr, /FirebaseCrashlytics/);
    assert.match(result.stderr, /Mixpanel/);
    assert.match(result.stderr, /firebase-ios-sdk/);
    assert.match(result.stderr, /mixpanel-swift/);
    assert.match(result.stderr, /GoogleService-Info|GoogleServicePLists/);
    assert.match(result.stderr, /Crashlytics\/upload-symbols|upload-symbols/);
    assert.match(result.stderr, /aps-environment/);
    assert.match(result.stderr, /FirebaseAppDelegateProxyEnabled/);
    assert.match(result.stderr, /DEVELOPMENT_TEAM/);
    assert.match(result.stderr, /CODE_SIGN_STYLE/);
    assert.match(result.stderr, /PROVISIONING_PROFILE_SPECIFIER/);
  });

  it("requires proof apps to carry an explicit module plan that selects and rejects substrate modules", () => {
    const appRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-proof-missing-module-plan-"));
    writeMinimalProofApp(appRoot);
    fs.rmSync(path.join(appRoot, ".forge/module-plan.json"));

    const missing = runVerifierAt(appRoot);
    assert.notEqual(missing.status, 0, `expected missing module plan to be rejected\nstdout:\n${missing.stdout}\nstderr:\n${missing.stderr}`);
    assert.match(missing.stderr, /module plan/i);

    writeMinimalProofApp(appRoot);
    const planPath = path.join(appRoot, ".forge/module-plan.json");
    const incompletePlan = JSON.parse(fs.readFileSync(planPath, "utf8"));
    incompletePlan.selected_modules = [];
    incompletePlan.rejected_modules = incompletePlan.rejected_modules.filter((module) => module.id !== "auth-account");
    fs.writeFileSync(planPath, JSON.stringify(incompletePlan, null, 2));

    const incomplete = runVerifierAt(appRoot);
    assert.notEqual(incomplete.status, 0, `expected incomplete module plan to be rejected\nstdout:\n${incomplete.stdout}\nstderr:\n${incomplete.stderr}`);
    assert.match(incomplete.stderr, /local-proof-shell/);
    assert.match(incomplete.stderr, /auth-account/);
  });

  it("rejects stale DayRate residue and preserves documented local-boundary negative copy", () => {
    const staleAppRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-proof-dayrate-residue-"));
    writeMinimalProofApp(staleAppRoot);
    fs.writeFileSync(path.join(staleAppRoot, "README.md"), "DayRateLab setup notes copied from an earlier proof app.\n");

    const stale = runVerifierAt(staleAppRoot);
    assert.notEqual(stale.status, 0, `expected DayRate residue to be rejected\nstdout:\n${stale.stdout}\nstderr:\n${stale.stderr}`);
    assert.match(stale.stderr, /DayRate/);

    const boundaryAppRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-proof-boundary-copy-"));
    writeMinimalProofApp(boundaryAppRoot);
    fs.writeFileSync(path.join(boundaryAppRoot, "README.md"), "Local proof boundary: no account creation, no auth routes, no payment setup, no subscription or purchase flows.\n");

    const boundary = runVerifierAt(boundaryAppRoot);
    assert.equal(boundary.status, 0, `expected local-boundary negative copy to pass\nstdout:\n${boundary.stdout}\nstderr:\n${boundary.stderr}`);
  });

  it("new-app writes a module plan that rejects unselected substrate modules", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-new-app-module-plan-"));
    const appName = "ModulePlanProof";
    const result = runNewApp(appName, tempRoot);
    const appRoot = path.join(tempRoot, appName);

    assert.equal(result.status, 0, `new-app failed\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
    const modulePlan = JSON.parse(fs.readFileSync(path.join(appRoot, ".forge/module-plan.json"), "utf8"));
    assert.equal(modulePlan.schema_version, "forge.module-plan.v1");
    assert.deepEqual(modulePlan.selected_modules, ["local-proof-shell"]);
    assert.deepEqual(modulePlan.rejected_modules.map((module) => module.id), ["auth-account", "paywall-purchases", "sync-backend", "settings-profile", "onboarding", "public-launch"]);
  });

  it("new-app writes a strict self-verification plan that passes for the clean local proof repo", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-new-app-self-verify-"));
    const appName = "SelfVerifyingProof";
    const result = runNewApp(appName, tempRoot);
    const appRoot = path.join(tempRoot, appName);

    assert.equal(result.status, 0, `new-app failed\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
    const verificationPlanPath = path.join(appRoot, ".forge/verification-plan.json");
    assert.equal(fs.existsSync(verificationPlanPath), true, "generated apps should include .forge/verification-plan.json");
    const plan = JSON.parse(fs.readFileSync(verificationPlanPath, "utf8"));
    assert.equal(plan.schema_version, "forge.verification-plan.v1");
    assert.equal(plan.policy.strictness, "proof-app");
    assert.equal(plan.policy.allow_substitutes, false);

    const verify = runVerifierAt(appRoot);
    assert.equal(verify.status, 0, `generated app should self-verify with the repo verifier\nstdout:\n${verify.stdout}\nstderr:\n${verify.stderr}`);
    assert.equal(JSON.parse(verify.stdout).status, "pass");
  });

  it("new-app outputs a product proof repo without Forge control-plane residue", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "forge-new-app-sanitize-"));
    const appName = "SanitizedProof";
    const result = runNewApp(appName, tempRoot);
    const appRoot = path.join(tempRoot, appName);

    assert.equal(result.status, 0, `new-app failed\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
    for (const relative of [
      "skills",
      "forge-cli",
      "tests",
      "docs/superpowers",
      "docs/goals",
      "docs/plans",
      ".forge/research",
      "scripts/new-app.sh",
      "scripts/forge-vnext-verifier.mjs",
      "scripts/forge-vnext-gate-validate.mjs",
      "scripts/forge-e2e-native-verify.mjs"
    ]) {
      assert.equal(fs.existsSync(path.join(appRoot, relative)), false, `${relative} should be removed from generated apps`);
    }
    assert.equal(fs.existsSync(path.join(appRoot, "scripts/setup-secrets.sh")), true, "local setup-secrets helper should remain");
    assert.equal(fs.readFileSync(path.join(appRoot, "README.md"), "utf8").includes("Forge template"), false, "README should be product-local, not template/control-plane prose");
  });
});
