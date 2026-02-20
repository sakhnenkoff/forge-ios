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

echo ""
echo "✅ New app created at: $TARGET_DIR"
echo "Next steps:"
echo "  1. Open the Xcode project in $TARGET_DIR"
echo "  2. Run ./scripts/setup-secrets.sh"
