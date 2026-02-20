# AGENTS.md

Guidance for AI coding agents (Codex CLI, Claude, etc.) working in this repository.

## Primary Documentation

Read the main documentation file first:

- CLAUDE.md

## Quick Rules

- Single package manifest: keep one root `Package.swift` at repo root.
- Module boundaries:
  - Domain: entities and repository protocols only.
  - Data: repository implementations, depends on Domain + Networking.
  - Networking: request/response abstractions, no UI.
  - LocalPersistance: Keychain and UserDefaults, no network.
  - DesignSystem: UI-only, resources live under `DesignSystem/Sources/DesignSystem/Resources`.
- Keep public API stable; breaking changes require a major version bump.
- Add files under the correct `Sources/` or `Tests/` folder for each module.
- Avoid committing Xcode user data or `.swiftpm/` artifacts.

## Local Override

If you need to iterate locally, use Xcode: File > Packages > Add Local... and point to a local clone.
