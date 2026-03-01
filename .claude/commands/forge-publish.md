# Forge Publish

Sync plugin changes from marketplace to cache, update docs, commit, and push.

## Paths

```
MARKETPLACE=~/.claude/plugins/marketplaces/forge-marketplace/.claude-plugin/plugins
CACHE=~/.claude/plugins/cache/forge-marketplace
```

## Step 1: Detect changes

For each plugin in `$MARKETPLACE/`, compare against `$CACHE/{plugin}/{version}/` using the version from `$MARKETPLACE/{plugin}/claude-code.json`.

Run a diff (ignoring .DS_Store) between marketplace and cache for each plugin. Report which plugins have changes and what files changed.

If nothing changed, say so and stop.

## Step 2: Sync marketplace to cache

For each changed plugin:
1. Read the version from `$MARKETPLACE/{plugin}/claude-code.json`
2. Sync all changed files from `$MARKETPLACE/{plugin}/` to `$CACHE/{plugin}/{version}/`
   - Skills: `skills/{skill_name}/SKILL.md`
   - Agents: `agents/{agent_name}.md`
   - Manifest: `claude-code.json`
3. If a skill was DELETED from marketplace, delete it from cache too
4. If a skill was ADDED to marketplace, create the directory in cache and copy it

Report what was synced.

## Step 3: Update claude-code.json manifests

If skills were added or removed from a plugin, update that plugin's `claude-code.json` in BOTH marketplace and cache:
- Add new skill entries to the `skills` array
- Remove deleted skill entries
- Keep existing entries unchanged

Only do this if the skill list actually changed. Don't touch manifests if only file contents changed.

## Step 4: Ask what else to update

Ask the user (using AskUserQuestion with multiSelect):

**What to update?**
- Update MEMORY.md (reflect the changes in auto-memory)
- Update README.md (reflect new/removed skills in project README)
- Skip docs (just commit and push)

## Step 5: Update docs (if selected)

**MEMORY.md** (`~/.claude/projects/-Users-matvii-Documents-Developer-Templates-forge/memory/MEMORY.md`):
- Find the relevant section for the changes made
- Update it to reflect new state (don't duplicate, update in place)

**README.md** (`/Users/matvii/Documents/Developer/Templates/forge/README.md`):
- Update any skill/agent listings to reflect additions/removals
- Keep existing structure, just update the relevant entries

## Step 6: Commit

Stage all changed files (marketplace + cache + docs). Generate a commit message that describes what changed:
- Which plugins were updated
- What skills were added/removed/modified
- What docs were updated

Format: `feat: {summary}` or `fix: {summary}` or `refactor: {summary}`

## Step 7: Push

Ask confirmation, then push to the current branch.

## Arguments

If invoked with arguments, skip the interactive questions:
- `$ARGUMENTS` can contain: `docs`, `readme`, `both`, `skip-docs`, `no-push`
- `docs` = update MEMORY.md only
- `readme` = update README.md only
- `both` = update MEMORY.md + README.md
- `skip-docs` = skip doc updates
- `no-push` = commit but don't push
