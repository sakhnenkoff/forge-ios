#!/bin/bash
set -e

# Create Secrets.xcconfig.local from the example file.
# Usage: ./scripts/setup-secrets.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

EXAMPLE_PATH=$(find "$ROOT_DIR" -path "*/Configurations/Secrets.xcconfig.local.example" -print -quit)

if [ -z "$EXAMPLE_PATH" ]; then
    echo "❌ Error: Secrets.xcconfig.local.example not found."
    exit 1
fi

LOCAL_PATH="${EXAMPLE_PATH%.example}"

if [ -f "$LOCAL_PATH" ]; then
    echo "✅ Secrets file already exists:"
    echo "   $LOCAL_PATH"
    exit 0
fi

cp "$EXAMPLE_PATH" "$LOCAL_PATH"
echo "✅ Created secrets file:"
echo "   $LOCAL_PATH"
echo ""
echo "Next steps:"
echo "  1. Open the file and add your API keys"
echo "  2. Rebuild the project"
