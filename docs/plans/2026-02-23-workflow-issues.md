# Forge Workflow Issues & Improvements Log

**Date:** 2026-02-23
**Purpose:** Track issues encountered during real app building (Ledgr) to optimize the pipeline later.

---

## Issues Found

### 1. Manual copy instead of CLI tool
**When:** First attempt to create Ledgr project
**What happened:** Claude used `cp -R` to copy the template instead of `scripts/new-app.sh`
**Root cause:** forge-app SKILL.md didn't handle the "invoked from template repo" scenario
**Fix applied:** Updated forge-app SKILL.md prerequisites, added `<IMPORTANT>` warnings to AGENTS.md, README.md, getting-started.md, marketplace README
**Status:** Fixed

### 2. rename_project.sh bug — scheme rename fails
**When:** Running `scripts/new-app.sh` and `rename_project.sh` for Ledgr
**What happened:** Step 1 (content update) replaces "Forge" with "Ledgr" in pbxproj, but Step 2 tries to `mv` scheme files using the old `Forge.xcodeproj` path. The xcodeproj directory hasn't been renamed yet at that point, so `mv` fails with "No such file or directory."
**Root cause:** The script renames file contents before renaming directories. Step 2 should use the OLD directory path (Forge.xcodeproj) since it hasn't been renamed yet, but the scheme filenames inside have already been updated by Step 1.
**Fix applied:** Manual directory/file renames after script failure. Script needs a proper fix.
**Status:** OPEN — needs fix in rename_project.sh

### 3. ForgeApp.swift filename not renamed
**When:** After rename_project.sh completed
**What happened:** File contents were updated (references to LedgrApp) but the filename itself stayed as ForgeApp.swift
**Root cause:** rename_project.sh doesn't rename individual Swift files, only directories and xcodeproj-related files
**Fix applied:** Manual `mv ForgeApp.swift LedgrApp.swift`
**Status:** OPEN — needs fix in rename_project.sh

---

## Workflow Observations

### 4. forge-app blueprint doesn't specify brand color implementation
**When:** Blueprint approved
**What happened:** Blueprint says "Muted sapphire (#3D5A80)" but there's no step in the execution engine that updates the DesignSystem brand color
**Potential fix:** forge-app Step 1 (workspace setup) should pass brand color to forge-workspace, or forge-app should update `AdaptiveTheme(brandColor:)` directly after workspace setup
**Status:** OPEN — to evaluate during build

---

## Items to Revisit

- [ ] Fix rename_project.sh scheme rename ordering (Issue #2)
- [ ] Fix rename_project.sh to rename ForgeApp.swift → {AppName}App.swift (Issue #3)
- [ ] Fix new-app.sh which calls rename_project.sh and inherits the same bugs
- [ ] Evaluate whether forge-app should handle brand color configuration directly (Issue #4)
- [ ] Consider adding a post-rename verification step that checks all "Forge" references are gone
