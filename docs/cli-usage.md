# CLI Usage Guide

The `forge` CLI generates a new iOS app from the Forge template. It supports four modes: interactive (wizard), hybrid (some flags), non-interactive (all flags), and programmatic (JSON stdin/stdout for AI agents).

## Installation

Build the CLI from source:

```bash
cd forge-cli
swift build -c release
# Binary: .build/release/forge
```

Add to PATH or use directly:

```bash
forge-cli/.build/release/forge --help
```

For full setup instructions see [Getting Started](getting-started.md).

---

## Modes

### Interactive Mode (default)

Running `forge` with no flags starts the full wizard. Navigate each prompt with arrow keys, Space to toggle, Enter to confirm, Esc to go back.

```bash
forge
```

**Wizard steps:**

1. **Preset or manual?** — Choose a preset to pre-fill all fields, or configure manually
2. **App name** — PascalCase project name (e.g. `MyApp`)
3. **Bundle ID** — Reverse-domain format (e.g. `com.company.myapp`)
4. **Auth providers** — Multi-select: Apple, Google, Email/Password, Anonymous (at least one required)
5. **Monetization model** — Single select: Subscription, One-Time Purchase, Free
6. **Analytics services** — Multi-select: Firebase Analytics, Mixpanel, Crashlytics (none = skip)
7. **Feature modules** — Multi-select: Onboarding, Push Notifications, A/B Testing, Image Upload (none = skip)
8. **Review** — Confirm configuration before generation
9. **Generate?** — Final confirmation
10. **Open in Xcode?** — Optional: opens `xed <outputDir>` after generation

Back-navigation is supported at every step (Esc).

---

### Hybrid Mode (some flags provided)

Provide any subset of flags. The wizard skips prompts for pre-filled values and still prompts for the rest. Any combination of flags is valid.

```bash
# Pre-fill app name, wizard prompts for everything else
forge --projectName MyApp

# Pre-fill multiple flags
forge --projectName MyApp --monetizationModel free --features onboarding,push
```

---

### Non-Interactive Mode (all required flags provided)

When all required fields are provided via flags, the wizard skips directly to the review step.

Required flags (or use `--preset` to provide all at once):

```bash
forge \
  --projectName MyApp \
  --bundleId com.company.myapp \
  --authProviders apple,google \
  --monetizationModel subscription \
  --analyticsServices firebase \
  --features onboarding,push
```

Or with a preset (pre-fills auth, monetization, analytics, features):

```bash
forge \
  --preset standard \
  --projectName MyApp \
  --bundleId com.company.myapp
```

---

### Programmatic Mode (--programmatic)

For AI agents and scripts. Reads one JSON object from stdin, generates the project, writes one JSON result to stdout. No interactive prompts. No ANSI output.

```bash
echo '{
  "projectName": "MyApp",
  "bundleId": "com.company.myapp",
  "authProviders": ["apple"],
  "monetizationModel": "free",
  "analyticsServices": [],
  "features": [],
  "outputDir": "/tmp/MyApp"
}' | forge --programmatic
```

**Success output:**

```json
{
  "success": true,
  "projectName": "MyApp",
  "outputDir": "/tmp/MyApp",
  "filesWritten": ["MyApp.xcodeproj/project.pbxproj", "..."]
}
```

**Error output:**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_BUNDLE_ID",
    "message": "bundleId must be reverse-domain format (e.g. com.company.app).",
    "field": "bundleId"
  }
}
```

Exit codes: `0` = success, `1` = validation/generation error, `2` = stdin/JSON error.

For full AI agent integration details and shell scripting patterns, see [AI Agent Integration](ai-agent-integration.md).

---

## Presets

Three built-in presets pre-fill all configuration fields:

| Preset | Auth | Monetization | Analytics | Modules |
|--------|------|-------------|-----------|---------|
| `minimal` | Apple | free | none | onboarding |
| `standard` | Apple + Google | subscription | firebase-analytics | onboarding |
| `full` | Apple + Google + Email + Anonymous | subscription | firebase-analytics + mixpanel + crashlytics | onboarding + push-notifications + ab-testing + image-upload |

Use `--preset` with `--projectName` and `--bundleId` for the fastest non-interactive setup.

---

## Output

On success, forge creates the output directory (default: `../ProjectName` relative to where you run the command). The directory contains:

- `ProjectName.xcodeproj` — Xcode project with Dev and Prod targets
- `ProjectName/` — Swift source files, organized by feature
- `ProjectName.xcworkspace/` — Workspace for SPM dependencies (if any)
- `Configurations/` — xcconfig files (including `Secrets.xcconfig.local.example`)
- `.template-version` — CLI version used to generate

After generation, forge displays conditional next steps based on which features you selected — listing required credentials and xcconfig keys.

---

## See Also

- [CLI Flag Reference](cli-flags.md)
- [AI Agent Integration](ai-agent-integration.md)
- [Feature Toggle Reference](features.md)
- [Getting Started](getting-started.md)
- [Architecture](architecture.md)
