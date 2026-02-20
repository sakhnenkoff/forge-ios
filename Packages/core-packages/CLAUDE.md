# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

---

## Documentation Structure

- Package layout and rules: `.claude/docs/package-structure.md`
- Release workflow: `.claude/docs/release-workflow.md`

---

## Project Overview

This repo is a single multi-product Swift Package. It provides core modules used by CleanTemplate-based apps.

Products:
- Domain
- DomainMock
- Data
- DataMock
- Networking
- LocalPersistance
- LocalPersistanceMock
- DesignSystem

---

## Critical Rules

- Keep one root `Package.swift` at repo root (no nested packages).
- Preserve module boundaries (Domain should not depend on Data or UI).
- Keep public API stable; breaking changes require a major version bump.
- Add new files to the correct `Sources/` or `Tests/` folder for each module.
- Do not commit Xcode user data or `.swiftpm/` artifacts.

---

## Local Development

- Use `swift build` and `swift test` from the repo root.
- Xcode local override: File > Packages > Add Local... and select this repo.
