# AI Agent Integration

`forge --programmatic` enables AI agents to generate Forge projects without interactive prompts. It reads one JSON object from stdin, writes one JSON object to stdout, and exits with a machine-readable exit code. No interactive state, no partial output — one shot.

---

## Quick Start

```bash
echo '{
  "projectName": "MyApp",
  "bundleId": "com.yourcompany.myapp",
  "authProviders": ["apple"],
  "monetizationModel": "free",
  "analyticsServices": [],
  "features": [],
  "outputDir": "/tmp/MyApp"
}' | forge --programmatic
```

---

## Input Schema

All fields except `outputDir` are required. Unknown fields are ignored (forward-compatible schema).

| Field | Type | Required | Valid Values | Description |
|---|---|---|---|---|
| `projectName` | string | Yes | Letters, numbers, underscores; must start with a letter | App name used as the Xcode project name |
| `bundleId` | string | Yes | Reverse-domain format: `com.company.app` | Bundle identifier for the app target |
| `authProviders` | string[] | Yes (min 1) | `"apple"`, `"google"`, `"email"`, `"anonymous"` | Authentication providers to include |
| `monetizationModel` | string | Yes | `"subscription"`, `"onetime"`, `"free"` | Revenue model — determines paywall type |
| `analyticsServices` | string[] | Yes (can be `[]`) | `"firebase"`, `"mixpanel"`, `"crashlytics"` | Analytics and crash reporting integrations |
| `features` | string[] | Yes (can be `[]`) | `"onboarding"`, `"push"`, `"abtesting"`, `"imageupload"` | Optional feature modules to include |
| `outputDir` | string | No | Any valid absolute path | Output directory; default: `../ProjectName` relative to CLI binary location |

**Notes:**
- `analyticsServices` dependencies are resolved automatically. Selecting `crashlytics` without `firebase` will prompt the resolver to include Firebase; in programmatic mode this happens silently.
- Feature ID aliases are normalized: `push` → `push-notifications`, `abtesting` → `ab-testing`, `imageupload` → `image-upload`.

---

## Output Schema

### Success

```json
{
  "success": true,
  "projectName": "MyApp",
  "outputDir": "/tmp/MyApp",
  "filesWritten": [
    "MyApp.xcodeproj/project.pbxproj",
    "MyApp/App/ForgeApp.swift",
    "MyApp/App/AppDelegate.swift",
    "MyApp/App/AppSession.swift",
    "MyApp/App/AppServices.swift",
    "MyApp/Utilities/FeatureFlags.swift",
    "..."
  ],
  "error": null
}
```

`filesWritten` lists all files written relative to `outputDir`. Use this to know exactly what was created without scanning the output directory.

### Error

```json
{
  "success": false,
  "projectName": null,
  "outputDir": null,
  "filesWritten": null,
  "error": {
    "code": "INVALID_BUNDLE_ID",
    "message": "bundleId must be reverse-domain format (e.g. com.company.app)",
    "field": "bundleId"
  }
}
```

`error.field` identifies which input field caused the error. It is `null` for non-field errors (stdin read failures, registry errors, generation errors).

---

## Error Codes

| Code | Exit | Field | Meaning |
|---|---|---|---|
| `STDIN_READ_ERROR` | 2 | — | Could not read from stdin |
| `INVALID_JSON` | 2 | — | stdin was not valid JSON |
| `MISSING_FIELD` | 1 | affected field name | Required field absent or null |
| `INVALID_PROJECT_NAME` | 1 | `projectName` | Name fails format validation (letters/numbers/underscores, starts with letter) |
| `INVALID_BUNDLE_ID` | 1 | `bundleId` | Fails reverse-domain format validation |
| `AUTH_PROVIDERS_REQUIRED` | 1 | `authProviders` | Empty array — at least one provider is required |
| `INVALID_AUTH_PROVIDER` | 1 | `authProviders` | Unknown provider value |
| `INVALID_MONETIZATION_MODEL` | 1 | `monetizationModel` | Unknown monetization model value |
| `INVALID_FEATURE_ID` | 1 | `features` | Unknown feature ID after normalization |
| `REGISTRY_LOAD_ERROR` | 1 | — | CLI internal error loading feature manifests |
| `OUTPUT_DIR_EXISTS` | 1 | `outputDir` | Target directory already exists — will not overwrite |
| `TEMPLATE_NOT_FOUND` | 1 | — | CLI installation issue — template source missing |
| `GENERATION_FAILED` | 1 | — | Error during project generation |

**Exit codes:** 0 = success, 1 = input or generation error, 2 = usage error (bad JSON or unreadable stdin).

---

## Shell Script Pattern

Capture stdout before checking exit code. The JSON is written to stdout regardless of success or failure.

```bash
#!/usr/bin/env bash
set -euo pipefail

INPUT='{
  "projectName": "MyApp",
  "bundleId": "com.yourcompany.myapp",
  "authProviders": ["apple"],
  "monetizationModel": "free",
  "analyticsServices": [],
  "features": []
}'

RESULT=$(echo "$INPUT" | forge --programmatic)
EXIT_CODE=$?

if [ "$EXIT_CODE" -ne 0 ] || [ "$(echo "$RESULT" | jq -r '.success')" != "true" ]; then
  ERROR_CODE=$(echo "$RESULT" | jq -r '.error.code // "UNKNOWN"')
  ERROR_MSG=$(echo "$RESULT" | jq -r '.error.message // "Unknown error"')
  echo "Generation failed: [$ERROR_CODE] $ERROR_MSG" >&2
  exit 1
fi

OUTPUT_DIR=$(echo "$RESULT" | jq -r '.outputDir')
FILE_COUNT=$(echo "$RESULT" | jq '.filesWritten | length')
echo "Generated $FILE_COUNT files at: $OUTPUT_DIR"
```

**Why `RESULT=$(...)` before checking `$?`:** When `set -e` is active and you check `$?` separately, you must capture in a subshell first so that `set -e` doesn't exit before you can read the error output.

---

## Claude Code CLAUDE.md Snippet

Copy this section into your project's `CLAUDE.md` to give Claude Code the context needed to generate Forge apps:

````markdown
## Generating a New Forge App

Use `forge` in programmatic mode. The CLI must be built first:

```bash
# Build once
cd forge-cli && swift build -c release && cd ..
ESSENTIA="$PWD/forge-cli/.build/release/forge"
```

Generate a project:

```bash
echo '{
  "projectName": "MyApp",
  "bundleId": "com.yourcompany.myapp",
  "authProviders": ["apple"],
  "monetizationModel": "free",
  "analyticsServices": ["firebase", "crashlytics"],
  "features": ["onboarding"]
}' | "$ESSENTIA" --programmatic
```

Check the result:

```bash
RESULT=$(echo "$INPUT" | "$ESSENTIA" --programmatic)
if [ "$(echo "$RESULT" | jq -r '.success')" = "true" ]; then
  echo "Generated at: $(echo "$RESULT" | jq -r '.outputDir')"
else
  echo "Error: $(echo "$RESULT" | jq -r '.error.message')" >&2
fi
```

Valid values:
- `authProviders`: `apple`, `google`, `email`, `anonymous` — array, at least one required
- `monetizationModel`: `subscription`, `onetime`, `free`
- `analyticsServices`: `firebase`, `mixpanel`, `crashlytics` — array, can be empty
- `features`: `onboarding`, `push`, `abtesting`, `imageupload` — array, can be empty

The `outputDir` field is optional. If omitted, output goes to `../ProjectName` relative to the CLI binary.

On error, `success` is `false` and `.error.code` contains a machine-readable error code. See [docs/ai-agent-integration.md](docs/ai-agent-integration.md) for the full error code table.
````

---

## See Also

- [CLI Usage Guide](cli-usage.md) — Interactive, hybrid, non-interactive, and programmatic modes
- [CLI Flag Reference](cli-flags.md) — All 9 flags with valid values and interactions
- [Feature Toggle Reference](features.md) — What each feature enables and the manifest schema for adding new features
