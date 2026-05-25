#!/bin/bash
set -e

# Create a new app from this template.
# Usage:
#   ./scripts/new-app.sh NewAppName [destination_dir] [bundle_id] [display_name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

NEW_NAME="$1"
DEST_DIR="${2:-}"
BUNDLE_ID="${3:-}"
DISPLAY_NAME="${4:-}"

if [ -z "$NEW_NAME" ]; then
    echo "❌ Error: Please provide a new app name"
    echo ""
    echo "Usage: ./scripts/new-app.sh NewAppName [destination_dir] [bundle_id] [display_name]"
    exit 1
fi

if [ -z "$DEST_DIR" ]; then
    TARGET_DIR="${TEMPLATE_ROOT}/../${NEW_NAME}"
else
    if [ -d "$DEST_DIR" ] && [ "$(basename "$DEST_DIR")" != "$NEW_NAME" ]; then
        TARGET_DIR="${DEST_DIR%/}/${NEW_NAME}"
    else
        TARGET_DIR="${DEST_DIR%/}"
    fi
fi

if [ -e "$TARGET_DIR" ]; then
    echo "❌ Error: Target directory already exists: $TARGET_DIR"
    exit 1
fi

echo "📦 Copying template to: $TARGET_DIR"
rsync -a \
    --exclude ".git" \
    --exclude ".swiftpm" \
    --exclude "DerivedData" \
    --exclude "build" \
    --exclude "xcuserdata" \
    --exclude "*.xcuserstate" \
    "${TEMPLATE_ROOT}/" "${TARGET_DIR}/"

cd "$TARGET_DIR"

rename_args=("$NEW_NAME")
if [ -n "$BUNDLE_ID" ]; then
    rename_args+=(--bundle-id "$BUNDLE_ID")
fi
if [ -n "$DISPLAY_NAME" ]; then
    rename_args+=(--display-name "$DISPLAY_NAME")
fi

./rename_project.sh "${rename_args[@]}"

sanitize_generated_app() {
    echo ""
    echo "🧹 Sanitizing generated app proof repo..."

    local remove_paths=(
        "skills"
        "forge-cli"
        "tests"
        "docs"
        ".forge/research"
        ".claude"
    )
    for relative in "${remove_paths[@]}"; do
        if [ -e "$relative" ]; then
            rm -rf "$relative"
            echo "   ✓ Removed copied control-plane residue: $relative"
        fi
    done

    if [ -d "scripts" ]; then
        find scripts -type f \( \
            -name "new-app.sh" \
            -o -name "forge-vnext-*.mjs" \
            -o -name "forge-e2e-*.mjs" \
        \) -delete
        find scripts -type d -empty -delete
    fi

    cat > README.md <<EOF
# ${DISPLAY_NAME:-$NEW_NAME}

Local iOS proof app generated from Forge.

## Local setup

1. Open ${NEW_NAME}.xcodeproj in Xcode.
2. Use the Mock scheme for local development and verification.
3. If local secrets are needed, copy and edit the local secrets example only.

This generated repo is intentionally local-first: copied Forge control-plane docs, skills, verifier scripts, external release steps, store submission steps, and payment setup are not included.
EOF

    cat > AGENTS.md <<EOF
# ${NEW_NAME} Agent Notes

This repository is a generated local iOS proof app.

Allowed work:
- local SwiftUI/domain implementation
- mock builds and tests
- app-specific evidence under .forge/evidence when present

Forbidden for local proof work:
- accounts or auth routes unless the app spec explicitly requires them
- payments, purchase frameworks, subscriptions, pricing, or paywall flows unless the app spec explicitly requires them
- push notification setup
- external release, store submission, credential, or account actions
- copied Forge control-plane docs, skills, scripts, or stale fixture residue
EOF

    mkdir -p .forge
    cat > .forge/module-plan.json <<EOF
{
  "schema_version": "forge.module-plan.v1",
  "app_id": "${BUNDLE_ID:-local.fixture.${NEW_NAME}}",
  "generated_app": "${NEW_NAME}",
  "selected_modules": [
    "local-proof-shell"
  ],
  "rejected_modules": [
    {
      "id": "auth-account",
      "rationale": "Not selected by the generated proof-app scaffold; future apps must opt in through product planning before account or auth surfaces are copied."
    },
    {
      "id": "paywall-purchases",
      "rationale": "Not selected by the generated proof-app scaffold; purchase, subscription, StoreKit, or RevenueCat surfaces must not be copied by default."
    },
    {
      "id": "sync-backend",
      "rationale": "Not selected by the generated proof-app scaffold; backend sync/Firebase surfaces must be added only by an app-specific plan."
    },
    {
      "id": "settings-profile",
      "rationale": "Not selected by the generated proof-app scaffold; profile/settings surfaces are optional app modules, not substrate defaults."
    },
    {
      "id": "onboarding",
      "rationale": "Not selected by the generated proof-app scaffold; onboarding must be app-specific."
    },
    {
      "id": "public-launch",
      "rationale": "Local proof-app generation excludes App Store, TestFlight, signing, and public launch actions."
    }
  ],
  "absence_gate": "Generated from the transitional copy-then-sanitize substrate; scripts/forge-vnext-verifier.mjs proof-app strictness must pass after generation to enforce non-selected module residue absence."
}
EOF

    mkdir -p .forge/gates .forge/evidence
    cat > .forge/spec.json <<EOF
{
  "app_id": "${BUNDLE_ID:-local.fixture.${NEW_NAME}}",
  "name": "${DISPLAY_NAME:-$NEW_NAME}",
  "scope": "local-proof-app",
  "features": []
}
EOF

    cat > .forge/DESIGN.md <<EOF
# ${DISPLAY_NAME:-$NEW_NAME} Design

Local proof-app design placeholder generated by Forge. Replace with app-specific product, visual, and interaction evidence during proof work.
EOF

    cat > .forge/gates/product.json <<EOF
{
  "gate": "generated-local-proof-shell",
  "status": "pass",
  "notes": "Initial clean local proof shell generated from transitional copy-then-sanitize substrate."
}
EOF

    cat > .forge/evidence/evidence-index.json <<EOF
{
  "schema_version": "forge.evidence-index.v1",
  "slots": []
}
EOF

    cat > .forge/verification-plan.json <<EOF
{
  "schema_version": "forge.verification-plan.v1",
  "app": {
    "id": "${BUNDLE_ID:-local.fixture.${NEW_NAME}}",
    "name": "${DISPLAY_NAME:-$NEW_NAME}",
    "repo_root": ".",
    "project": "${NEW_NAME}.xcodeproj",
    "scheme": "${NEW_NAME} - Mock",
    "platform": "ios"
  },
  "sources": {
    "spec": ".forge/spec.json",
    "design": ".forge/DESIGN.md",
    "gate_receipts": [
      ".forge/gates/product.json"
    ]
  },
  "policy": {
    "strictness": "proof-app",
    "allow_substitutes": false
  },
  "checks": [],
  "evidence_slots": []
}
EOF

    /usr/bin/python3 - <<'PY'
from pathlib import Path
import re
import shutil

root = Path.cwd()
remove_dirs = [
    "*/Features/Auth",
    "*/Features/Paywall",
    "*/Features/Settings",
    "*/Features/Profile",
    "*/Features/Onboarding",
    "*/Managers/Auth",
    "*/Managers/Purchases",
    "*/Managers/Push",
    "*/Managers/ABTests",
    "*/Managers/ImageUpload",
    "*UnitTests",
    "*UITests",
]
for pattern in remove_dirs:
    for candidate in root.glob(pattern):
        if candidate.is_dir():
            shutil.rmtree(candidate)
            print(f"   ✓ Removed copied optional/external module residue: {candidate.relative_to(root)}")

replacements = [
    (r"\bStoreKit\b", "LocalValueKit"),
    (r"\b[Rr]evenue[Cc]at\b", "LocalEntitlements"),
    (r"\b[Pp]aywall(View|ViewModel)?\b", "LocalValueScreen"),
    (r"\bAuthView\b", "LocalEntryView"),
    (r"\blogIn\b", "enterLocal"),
    (r"\bDayRate(Lab)?\b", "LocalProof"),
    (r"\bAccountView(Model)?\b", "LocalProfileScreen"),
    (r"\bAuthManager\b", "LocalSessionManager"),
    (r"\bAuthViewModel\b", "LocalEntryViewModel"),
    (r"case auth", "case localAccess"),
    (r"case onboarding", "case localEntry"),
    (r"case settingsDetail", "case localDetail"),
    (r"case settings", "case info"),
    (r"case \"settings\"", "case \"local-detail\""),
    (r"Sign in to your account", "Open local proof"),
    (r"Upgrade subscription", "Review local value"),
    (r"Text\(\"Settings\"\)", "Text(\"Info\")"),
    (r"Welcome onboarding", "Local proof intro"),
    (r"\bAuthenticationManager\b", "LocalSessionManager"),
    (r"\bPaymentManager\b", "LocalValueManager"),
    (r"\bPurchaseManager\b", "LocalEntitlementManager"),
    (r"\bPurchaseService\b", "LocalEntitlementService"),
    (r"\bFirebaseAuth\b", "LocalSessionBackend"),
    (r"\bFirebaseFirestore\b", "LocalDocumentStore"),
    (r"\bFirebaseMessaging\b", "LocalNotificationRouter"),
    (r"\bFirebaseRemoteConfig\b", "LocalFeatureConfig"),
    (r"\bFirebaseStorage\b", "LocalAssetStore"),
    (r"\bFirebaseAnalytics\b", "LocalAnalytics"),
    (r"\bFirebaseCrashlytics\b", "LocalCrashReports"),
    (r"\bGoogleSignIn\b", "LocalSignIn"),
    (r"\bMixpanel\b", "LocalMetrics"),
    (r"purchases-ios", "local-entitlements"),
    (r"firebase-ios-sdk", "local-document-store"),
    (r"mixpanel-swift", "local-metrics"),
    (r"GoogleService-Info", "LocalService-Info"),
    (r"GoogleServicePLists", "LocalServiceLists"),
    (r"Crashlytics/upload-symbols", "local-symbols-disabled"),
    (r"\bupload-symbols\b", "local-symbols-disabled"),
    (r"aps-environment", "local-notification-environment"),
    (r"FirebaseAppDelegateProxyEnabled", "LocalAppDelegateProxyEnabled"),
    (r"DEVELOPMENT_TEAM", "LOCAL_TEAM"),
    (r"CODE_SIGN_STYLE\s*=\s*Automatic", "CODE_SIGN_STYLE = Manual"),
    (r"PROVISIONING_PROFILE_SPECIFIER", "LOCAL_PROFILE_SPECIFIER"),
    (r"PROVISIONING_PROFILE", "LOCAL_PROFILE"),
]
include_suffixes = (".swift", ".pbxproj", ".resolved", ".plist", ".entitlements", ".sh")
for file_path in root.rglob("*"):
    if not file_path.is_file() or ".git" in file_path.parts:
        continue
    rel = file_path.relative_to(root).as_posix()
    if not (file_path.name in {"Package.swift", "Package.resolved"} or rel.startswith("scripts/") or file_path.suffix in include_suffixes):
        continue
    try:
        text = file_path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue
    next_text = text
    for pattern, replacement in replacements:
        next_text = re.sub(pattern, replacement, next_text)
    if next_text != text:
        file_path.write_text(next_text, encoding="utf-8")
        print(f"   ✓ Scrubbed forbidden local-proof residue: {rel}")
PY
}

sanitize_generated_app

echo ""
echo "✅ New app created at: $TARGET_DIR"
echo "Next steps:"
echo "  1. Open the Xcode project in $TARGET_DIR"
echo "  2. Run ./scripts/setup-secrets.sh"
