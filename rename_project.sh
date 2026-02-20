#!/bin/bash
set -e

# Forge Project Rename Script
# Usage:
#   ./rename_project.sh NewProjectName [--bundle-id com.company.app] [--display-name "My App"]
#
# This script renames the entire project from "Forge" to your chosen name.
# It updates file contents, file names, directory names, and bundle identifiers.

OLD_NAME="Forge"
NEW_NAME=""
BUNDLE_ID=""
DISPLAY_NAME=""

usage() {
    echo "Usage: ./rename_project.sh NewProjectName [--bundle-id com.company.app] [--display-name \"My App\"]"
    echo ""
    echo "Example:"
    echo "  ./rename_project.sh MyAwesomeApp --bundle-id com.company.myapp --display-name \"My App\""
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --bundle-id|-b)
            BUNDLE_ID="$2"
            shift 2
            ;;
        --display-name|-d)
            DISPLAY_NAME="$2"
            shift 2
            ;;
        *)
            if [ -z "$NEW_NAME" ]; then
                NEW_NAME="$1"
                shift
            else
                echo "❌ Error: Unknown argument: $1"
                usage
                exit 1
            fi
            ;;
    esac
done

if [ -z "$NEW_NAME" ]; then
    echo "❌ Error: Please provide a new project name"
    echo ""
    usage
    exit 1
fi

if [[ ! "$NEW_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
    echo "❌ Error: Project name must start with a letter and contain only letters, numbers, and underscores"
    exit 1
fi

if [ -n "$BUNDLE_ID" ] && [[ ! "$BUNDLE_ID" =~ ^[A-Za-z0-9.-]+$ ]]; then
    echo "❌ Error: Bundle ID must contain only letters, numbers, dots, and hyphens"
    exit 1
fi

if [ -n "$DISPLAY_NAME" ] && [[ "$DISPLAY_NAME" == *"\""* ]]; then
    echo "❌ Error: Display name cannot include double quotes"
    exit 1
fi

if [ ! -d "${OLD_NAME}.xcodeproj" ]; then
    echo "❌ Error: This script must be run from the Forge root directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected to find: ${OLD_NAME}.xcodeproj"
    exit 1
fi

update_display_names() {
    local app_dir="$1"
    local display_name="$2"
    local pbxproj="$3"

    local mock_name="${display_name} - Mock"
    local dev_name="${display_name} - Dev"
    local prod_name="${display_name}"

    if [ -f "${app_dir}/Configurations/Mock.xcconfig" ]; then
        sed -i '' "s|^INFOPLIST_KEY_CFBundleDisplayName = .*|INFOPLIST_KEY_CFBundleDisplayName = ${mock_name}|" "${app_dir}/Configurations/Mock.xcconfig"
    fi
    if [ -f "${app_dir}/Configurations/Development.xcconfig" ]; then
        sed -i '' "s|^INFOPLIST_KEY_CFBundleDisplayName = .*|INFOPLIST_KEY_CFBundleDisplayName = ${dev_name}|" "${app_dir}/Configurations/Development.xcconfig"
    fi
    if [ -f "${app_dir}/Configurations/Production.xcconfig" ]; then
        sed -i '' "s|^INFOPLIST_KEY_CFBundleDisplayName = .*|INFOPLIST_KEY_CFBundleDisplayName = ${prod_name}|" "${app_dir}/Configurations/Production.xcconfig"
    fi

    if [ -f "$pbxproj" ]; then
        perl -i '' -pe '
            if (/baseConfigurationReferenceRelativePath = Configurations\/(Mock|Development|Production)\.xcconfig;/) {
                $config = $1;
            }
            if (/INFOPLIST_KEY_CFBundleDisplayName = .*;/ && $config) {
                my $suffix = $config eq "Mock" ? " - Mock" : $config eq "Development" ? " - Dev" : "";
                my $name = "'"$display_name"'" . $suffix;
                s/INFOPLIST_KEY_CFBundleDisplayName = .*;/INFOPLIST_KEY_CFBundleDisplayName = "$name";/;
            }
        ' "$pbxproj"
    fi
}

update_bundle_ids() {
    local app_dir="$1"
    local bundle_id="$2"
    local pbxproj="$3"

    local mock_id="${bundle_id}.mock"
    local dev_id="${bundle_id}.dev"
    local prod_id="${bundle_id}"
    local ui_tests_id="${bundle_id}.UITests"
    local unit_tests_id="${bundle_id}.UnitTests"

    if [ -f "${app_dir}/Configurations/Mock.xcconfig" ]; then
        sed -i '' "s|^PRODUCT_BUNDLE_IDENTIFIER = .*|PRODUCT_BUNDLE_IDENTIFIER = ${mock_id}|" "${app_dir}/Configurations/Mock.xcconfig"
    fi
    if [ -f "${app_dir}/Configurations/Development.xcconfig" ]; then
        sed -i '' "s|^PRODUCT_BUNDLE_IDENTIFIER = .*|PRODUCT_BUNDLE_IDENTIFIER = ${dev_id}|" "${app_dir}/Configurations/Development.xcconfig"
    fi
    if [ -f "${app_dir}/Configurations/Production.xcconfig" ]; then
        sed -i '' "s|^PRODUCT_BUNDLE_IDENTIFIER = .*|PRODUCT_BUNDLE_IDENTIFIER = ${prod_id}|" "${app_dir}/Configurations/Production.xcconfig"
    fi

    if [ -f "$pbxproj" ]; then
        perl -i '' -pe '
            if (/PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);/) {
                $value = $1;
                my $new;
                if ($value =~ /UITests/) { $new = "'"$ui_tests_id"'"; }
                elsif ($value =~ /UnitTests/) { $new = "'"$unit_tests_id"'"; }
                elsif ($value =~ /\.mock$/) { $new = "'"$mock_id"'"; }
                elsif ($value =~ /\.dev$/) { $new = "'"$dev_id"'"; }
                else { $new = "'"$prod_id"'"; }
                s/PRODUCT_BUNDLE_IDENTIFIER = [^;]+;/PRODUCT_BUNDLE_IDENTIFIER = $new;/;
            }
        ' "$pbxproj"
    fi
}

echo "🔄 Renaming project from '${OLD_NAME}' to '${NEW_NAME}'..."
echo ""

echo "📝 Step 1/5: Updating file contents..."

find . -type f \( \
    -name "*.swift" \
    -o -name "*.pbxproj" \
    -o -name "*.xcscheme" \
    -o -name "*.xcconfig" \
    -o -name "*.plist" \
    -o -name "*.md" \
    -o -name "*.entitlements" \
    -o -name "*.storyboard" \
    -o -name "*.xib" \
    -o -name "*.strings" \
    -o -name "Contents.json" \
\) ! -path "./.git/*" ! -path "./rename_project.sh" -print0 | while IFS= read -r -d '' file; do
    if grep -q "${OLD_NAME}" "$file" 2>/dev/null; then
        sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" "$file"
        echo "   ✓ Updated: $file"
    fi
done

echo ""
echo "📋 Step 2/5: Renaming scheme files..."

SCHEMES_DIR="${OLD_NAME}.xcodeproj/xcshareddata/xcschemes"
if [ -d "$SCHEMES_DIR" ]; then
    for scheme in "$SCHEMES_DIR"/*"${OLD_NAME}"*; do
        if [ -f "$scheme" ]; then
            new_scheme=$(echo "$scheme" | sed "s/${OLD_NAME}/${NEW_NAME}/g")
            mv "$scheme" "$new_scheme"
            echo "   ✓ Renamed: $(basename "$scheme") → $(basename "$new_scheme")"
        fi
    done
fi

echo ""
echo "🗂️ Step 3/5: Renaming files..."

find . -type f -name "*${OLD_NAME}*" ! -path "./.git/*" ! -path "./rename_project.sh" ! -path "./${OLD_NAME}.xcodeproj/*" -print0 | while IFS= read -r -d '' file; do
    new_file=$(echo "$file" | sed "s/${OLD_NAME}/${NEW_NAME}/g")
    mv "$file" "$new_file"
    echo "   ✓ Renamed: $file → $new_file"
done

echo ""
echo "📁 Step 4/5: Renaming directories..."

if [ -d "${OLD_NAME}UITests" ]; then
    mv "${OLD_NAME}UITests" "${NEW_NAME}UITests"
    echo "   ✓ Renamed: ${OLD_NAME}UITests → ${NEW_NAME}UITests"
fi

if [ -d "${OLD_NAME}UnitTests" ]; then
    mv "${OLD_NAME}UnitTests" "${NEW_NAME}UnitTests"
    echo "   ✓ Renamed: ${OLD_NAME}UnitTests → ${NEW_NAME}UnitTests"
fi

if [ -d "${OLD_NAME}" ]; then
    mv "${OLD_NAME}" "${NEW_NAME}"
    echo "   ✓ Renamed: ${OLD_NAME} → ${NEW_NAME}"
fi

echo ""
echo "📦 Step 5/5: Renaming Xcode project..."

if [ -d "${OLD_NAME}.xcodeproj" ]; then
    mv "${OLD_NAME}.xcodeproj" "${NEW_NAME}.xcodeproj"
    echo "   ✓ Renamed: ${OLD_NAME}.xcodeproj → ${NEW_NAME}.xcodeproj"
fi

if [ -d "${OLD_NAME}.xcworkspace" ]; then
    mv "${OLD_NAME}.xcworkspace" "${NEW_NAME}.xcworkspace"
    echo "   ✓ Renamed: ${OLD_NAME}.xcworkspace → ${NEW_NAME}.xcworkspace"
fi

if [ -n "$DISPLAY_NAME" ]; then
    update_display_names "$NEW_NAME" "$DISPLAY_NAME" "${NEW_NAME}.xcodeproj/project.pbxproj"
fi

if [ -n "$BUNDLE_ID" ]; then
    update_bundle_ids "$NEW_NAME" "$BUNDLE_ID" "${NEW_NAME}.xcodeproj/project.pbxproj"
fi

echo ""
echo "✅ Project successfully renamed to '${NEW_NAME}'!"
if [ -n "$BUNDLE_ID" ]; then
    echo "   • Bundle ID: ${BUNDLE_ID}"
fi
if [ -n "$DISPLAY_NAME" ]; then
    echo "   • Display Name: ${DISPLAY_NAME}"
fi
echo ""
echo "Next steps:"
echo "   1. Open ${NEW_NAME}.xcodeproj in Xcode"
echo "   2. Clean build folder (Cmd+Shift+K)"
echo "   3. Build the project (Cmd+B)"
echo "   4. Configure your secrets in Configurations/Secrets.xcconfig.local"
echo ""
echo "📖 See README.md for full setup instructions"
