# CLI Flag Reference

Complete reference for all `forge` CLI flags. See [CLI Usage Guide](cli-usage.md) for mode-level documentation.

---

## Flag Overview

| Flag | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `--projectName` | String | No* | — | App name |
| `--bundleId` | String | No* | — | Bundle identifier |
| `--authProviders` | Comma list | No* | — | Auth providers (at least one) |
| `--monetizationModel` | String | No* | — | Revenue model |
| `--analyticsServices` | Comma list | No* | — | Analytics integrations |
| `--features` | Comma list | No* | — | Feature modules |
| `--preset` | String | No | — | Pre-fill all fields from preset |
| `--outputDir` | String | No | `../ProjectName` | Output directory |
| `--programmatic` | Bool flag | No | `false` | JSON stdin/stdout mode |

*Required in non-interactive mode (when all fields must be provided via flags or `--preset`). In interactive mode, the wizard prompts for any missing values.

---

## Flag Details

### `--projectName`

**Type:** String
**Required:** No (wizard prompts if absent)
**Default:** None

App name used as the Xcode project name and Swift module name.

**Validation:** Must match `^[a-zA-Z][a-zA-Z0-9_]*$` — starts with a letter, contains only letters, numbers, underscores.

```bash
forge --projectName MyApp
forge --projectName SuperApp2025
```

**Interactions:** Used to derive the default `bundleId` suggestion (e.g. `com.yourcompany.myapp`). Also used as the output directory name when `--outputDir` is not specified.

---

### `--bundleId`

**Type:** String
**Required:** No (wizard prompts if absent)
**Default:** None

iOS bundle identifier for the app.

**Validation:** Reverse-domain format. Minimum 2 dot-separated segments. Each segment: letters, numbers, and hyphens only (no underscores).

```bash
forge --bundleId com.company.myapp
forge --bundleId io.mycompany.MyApp
```

---

### `--authProviders`

**Type:** Comma-separated list
**Required:** No (wizard prompts if absent; at least one value required)
**Default:** None
**Valid values:** `apple`, `google`, `email`, `anonymous`

Authentication providers to include in the generated app. At least one value is required.

```bash
forge --authProviders apple
forge --authProviders apple,google
forge --authProviders apple,google,email,anonymous
```

**Validation:** Each value must be one of the valid options. At least one value is required (not empty).

---

### `--monetizationModel`

**Type:** String
**Required:** No (wizard prompts if absent)
**Default:** None
**Valid values:** `subscription`, `onetime`, `free`

Revenue model for the app.

| Value | Description |
|-------|-------------|
| `subscription` | Monthly/annual subscriptions via RevenueCat |
| `onetime` | Lifetime one-time purchase via RevenueCat |
| `free` | No in-app purchases |

```bash
forge --monetizationModel subscription
forge --monetizationModel free
```

**Interactions:** `subscription` and `onetime` automatically include RevenueCat as a dependency, which in turn requires `firebase-analytics`.

---

### `--analyticsServices`

**Type:** Comma-separated list
**Required:** No (wizard prompts if absent; empty list is valid)
**Default:** None
**Valid values:** `firebase` (or `firebase-analytics`), `mixpanel`, `crashlytics`, `none`

Analytics integrations to include.

```bash
forge --analyticsServices firebase
forge --analyticsServices firebase,mixpanel,crashlytics
forge --analyticsServices none    # explicit empty selection
```

**Value normalization:** Shorthand values are accepted and mapped to registry IDs:
- `firebase` → `firebase-analytics`

**Interactions:** `crashlytics` depends on `firebase-analytics` (auto-included if not present).

---

### `--features`

**Type:** Comma-separated list
**Required:** No (wizard prompts if absent; empty list is valid)
**Default:** None
**Valid values:** `onboarding`, `push` (or `push-notifications`), `abtesting` (or `ab-testing`), `imageupload` (or `image-upload`), `none`

Feature modules to include.

```bash
forge --features onboarding
forge --features onboarding,push,abtesting
forge --features none              # explicit empty selection
```

**Value normalization:** Shorthand values are accepted and mapped to registry IDs:
- `push` → `push-notifications`
- `abtesting` → `ab-testing`
- `imageupload` → `image-upload`

**Interactions:** `push-notifications` and `ab-testing` depend on `firebase-analytics` (auto-included if not present).

---

### `--preset`

**Type:** String
**Required:** No
**Default:** None
**Valid values:** `minimal`, `standard`, `full`

Pre-fills all configuration fields from a named preset. Equivalent to manually specifying all the listed flags.

| Preset | Auth | Monetization | Analytics | Features |
|--------|------|-------------|-----------|----------|
| `minimal` | apple | free | (none) | onboarding |
| `standard` | apple,google | subscription | firebase-analytics | onboarding |
| `full` | apple,google,email,anonymous | subscription | firebase-analytics,mixpanel,crashlytics | onboarding,push-notifications,ab-testing,image-upload |

```bash
# Use preset + provide required identity fields
forge --preset standard --projectName MyApp --bundleId com.company.myapp

# Preset fills feature fields; override a specific one
forge --preset standard --projectName MyApp --bundleId com.company.myapp --monetizationModel free
```

**Interactions:** `--preset` pre-fills auth, monetization, analytics, and features. Individual flag overrides take effect after preset application. `--projectName` and `--bundleId` are never filled by presets.

---

### `--outputDir`

**Type:** String (directory path)
**Required:** No
**Default:** `../ProjectName` — one level up from the current directory, in a folder named after the project

Directory where the generated project will be created.

```bash
forge --projectName MyApp --outputDir ~/Projects/MyApp
forge --projectName MyApp --outputDir /tmp/MyApp
```

**Validation:** The path must not already exist. The CLI creates the directory and cleans up on failure.

---

### `--programmatic`

**Type:** Bool flag (presence = true)
**Required:** No
**Default:** `false`

Run in programmatic JSON mode for AI agent integration. When present:
- Reads one JSON object from stdin
- Suppresses all human-facing output (ANSI colors, progress steps, prompts)
- Writes one JSON result object to stdout
- Never opens Xcode
- Requires all fields to be provided in the JSON input (no wizard fallback)

```bash
echo '{"projectName":"MyApp","bundleId":"com.co.myapp","authProviders":["apple"],"monetizationModel":"free","analyticsServices":[],"features":[]}' | forge --programmatic
```

**Note:** In programmatic mode, flags like `--projectName`, `--bundleId`, etc. are ignored — all input comes from the JSON body on stdin.

For complete programmatic mode documentation including the JSON schema, output format, and error codes, see [AI Agent Integration](ai-agent-integration.md).

---

## Validation Summary

| Field | Rule |
|-------|------|
| `projectName` | `^[a-zA-Z][a-zA-Z0-9_]*$` — letters/numbers/underscores, must start with letter |
| `bundleId` | Reverse-domain: ≥2 dot-separated segments, each segment: letters/numbers/hyphens only |
| `authProviders` | At least one value from: apple, google, email, anonymous |
| `monetizationModel` | One of: subscription, onetime, free |
| `analyticsServices` | Each value from: firebase, mixpanel, crashlytics (empty = no analytics) |
| `features` | Each value from: onboarding, push, abtesting, imageupload (empty = minimal app) |
| `outputDir` | Must not already exist on disk |

---

## See Also

- [CLI Usage Guide](cli-usage.md) — Interactive, hybrid, non-interactive, programmatic modes
- [AI Agent Integration](ai-agent-integration.md) — Full programmatic mode reference
- [Feature Toggle Reference](features.md) — What each feature enables
