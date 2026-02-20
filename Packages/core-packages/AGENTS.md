# AGENTS.md

Guidance for AI coding agents working in this repository.

---

## Project Overview

This repo is a single multi-product Swift Package. It provides core modules used by Forge-based apps.

Products:
- Core (Domain + Data + Networking + Local Persistence)
- CoreMock
- DesignSystem

---

## Documentation Structure

- Package layout and rules: `.claude/docs/package-structure.md`
- Release workflow: `.claude/docs/release-workflow.md`

---

## Critical Rules

- Single package manifest: keep one root `Package.swift` at repo root.
- Module boundaries:
  - Domain: entities and repository protocols only.
  - Data: repository implementations, depends on Domain + Networking.
  - Networking: request/response abstractions, no UI.
  - LocalPersistance: Keychain and UserDefaults, no network.
  - DesignSystem: UI-only, resources live under `DesignSystem/Sources/DesignSystem/Resources`.
- Keep public API stable; breaking changes require a major version bump.
- Add files under the correct `Sources/` or `Tests/` folder for each module.
- Do not commit Xcode user data or `.swiftpm/` artifacts.

---

## Local Development

- Use `swift build` and `swift test` from the repo root.
- Xcode local override: File > Packages > Add Local... and select this repo.
