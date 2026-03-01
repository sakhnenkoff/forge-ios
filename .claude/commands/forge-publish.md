# Forge Publish

Sync plugin changes from marketplace to cache, update docs, commit and push BOTH repos.

## Repos

There are TWO separate git repos to manage:

1. **Marketplace repo** (`~/.claude/plugins/marketplaces/forge-marketplace/`) — the source of truth for all plugin skills and agents. This is a standalone git repo pushed to its own remote.
2. **Forge repo** (current working directory) — the template repo with README.md, AGENTS.md, CLAUDE.md, and `.claude/commands/`.

Both may have changes that need committing and pushing.

## Paths

```
MARKETPLACE_REPO=~/.claude/plugins/marketplaces/forge-marketplace
MARKETPLACE=$MARKETPLACE_REPO/.claude-plugin/plugins
CACHE=~/.claude/plugins/cache/forge-marketplace
```

## Step 1: Detect changes in BOTH repos

### 1a. Marketplace repo git status

Run `git -C $MARKETPLACE_REPO status` to see what's changed in the marketplace repo. This catches:
- Modified skills/agents
- New/deleted skill directories
- Modified manifests (claude-code.json)

Report all changes.

### 1b. Marketplace vs cache diff

For each plugin in `$MARKETPLACE/`, compare against `$CACHE/{plugin}/{version}/` using the version from `$MARKETPLACE/{plugin}/claude-code.json`. Report which plugins are out of sync with cache.

### 1c. Forge repo git status

Run `git status` in the current working directory (forge repo). Report any changes to README.md, AGENTS.md, `.claude/commands/`, etc.

If NOTHING changed in either repo, say so and stop.

## Step 2: Sync marketplace to cache

For each plugin where marketplace differs from cache:
1. Read the version from `$MARKETPLACE/{plugin}/claude-code.json`
2. Sync all changed files from `$MARKETPLACE/{plugin}/` to `$CACHE/{plugin}/{version}/`
   - Skills: `skills/{skill_name}/SKILL.md`
   - Agents: `agents/{agent_name}.md`
   - Manifest: `claude-code.json`
3. If a skill was DELETED from marketplace, delete it from cache too
4. If a skill was ADDED to marketplace, create the directory in cache and copy it

Report what was synced.

## Step 3: Update claude-code.json manifests

If skills were added or removed from a plugin (new/deleted skill directories), update that plugin's `claude-code.json` in BOTH marketplace and cache:
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

## Step 6: Commit BOTH repos

### 6a. Commit marketplace repo

Run `git -C $MARKETPLACE_REPO add` + `git -C $MARKETPLACE_REPO commit` with a descriptive message covering:
- Which plugins were updated
- What skills were added/removed/modified

### 6b. Commit forge repo

If the forge repo has changes (README, AGENTS.md, commands, etc.), stage and commit with a message covering what docs changed.

Use the same commit message format for both: `feat: {summary}` or `fix: {summary}` or `refactor: {summary}`

## Step 7: Push BOTH repos

Ask confirmation once, then push both:
1. `git -C $MARKETPLACE_REPO push origin main`
2. `git push origin main` (forge repo, only if it had changes)

Report both push results.

## Arguments

If invoked with arguments, skip the interactive questions:
- `$ARGUMENTS` can contain: `docs`, `readme`, `both`, `skip-docs`, `no-push`
- `docs` = update MEMORY.md only
- `readme` = update README.md only
- `both` = update MEMORY.md + README.md
- `skip-docs` = skip doc updates
- `no-push` = commit but don't push
