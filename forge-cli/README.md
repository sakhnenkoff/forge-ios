# forge CLI

CLI wizard that generates a new iOS app from the Forge template — with interactive prompts or fully non-interactive via flags.

## Install

```bash
swift build -c release
# Binary: .build/release/forge
```

## Quick Start

**Interactive wizard (prompts for everything):**

```bash
forge
```

**Non-interactive (all flags provided, no prompts):**

```bash
forge \
  --preset standard \
  --projectName MyApp \
  --bundleId com.company.myapp
```

**Programmatic (JSON stdin/stdout for AI agents):**

```bash
echo '{
  "projectName": "MyApp",
  "bundleId": "com.company.myapp",
  "authProviders": ["apple"],
  "monetizationModel": "free",
  "analyticsServices": [],
  "features": []
}' | forge --programmatic
```

## Documentation

- [CLI Usage Guide](../docs/cli-usage.md) — All four modes explained with examples
- [CLI Flag Reference](../docs/cli-flags.md) — Every flag with valid values and interactions
- [AI Agent Integration](../docs/ai-agent-integration.md) — JSON schema, error codes, shell patterns, Claude Code examples
- [Feature Toggle Reference](../docs/features.md) — What each feature enables and the manifest schema

## Flags

| Flag | Purpose |
|------|---------|
| `--projectName` | App name (letters/numbers/underscores) |
| `--bundleId` | Bundle ID (reverse-domain: com.co.app) |
| `--authProviders` | Comma list: apple, google, email, anonymous |
| `--monetizationModel` | subscription, onetime, free |
| `--analyticsServices` | Comma list: firebase, mixpanel, crashlytics |
| `--features` | Comma list: onboarding, push, abtesting, imageupload |
| `--preset` | minimal, standard, full |
| `--outputDir` | Output path (default: ../ProjectName) |
| `--programmatic` | JSON stdin/stdout mode (no prompts) |
