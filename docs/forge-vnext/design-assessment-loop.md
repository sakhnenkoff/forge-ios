# Forge vNext Design Assessment Loop

Status: required operating loop for generated-app trials.

## Problem this fixes

A generated app can pass mechanical build/test/verifier checks while Matvii still has no idea what it looks like, what inspired it, or whether it is converging toward the intended product taste.

That is not acceptable for Forge vNext.

## Rule

Every native proof app must produce a visual review packet before any claim of credible app-factory proof.

The packet must be sent or linked in Telegram when the pipeline reaches a human-visible design gate.

## Required visual packet

For each generated app trial, produce:

1. Current simulator screenshot(s)
   - first-use / activation screen;
   - core-loop after one meaningful action;
   - returning-user/progress state;
   - money/deferred boundary if relevant.

2. Accessibility snapshot summary
   - key visible labels;
   - key controls;
   - whether the UI is app-specific or generic.

3. Inspiration / provenance disclosure
   - product sources used;
   - design references used;
   - explicit statement that DayRateLab was not used as inspiration;
   - if references are missing or weak, say so.

4. Design judge verdict
   - app-specific? yes/no;
   - generic card dashboard? yes/no;
   - token reskin? yes/no;
   - emotional/taste direction;
   - concrete repair requests.

5. Human-facing action
   - if good enough: ask for narrow approval to continue;
   - if not good enough: create repair cards and keep running;
   - do not ask fake options.

## Pipeline placement

The design assessment loop runs after native app build/run/screenshot evidence exists and before final proof acceptance.

Implementation worker should not block for generic human review. It should hand off screenshots/evidence to verifier/judge. The judge or orchestrator then sends the compact visual packet to Telegram only when there is a real human-visible design gate.

## Current Pantry Rescue status

A screenshot was captured from the current simulator state and copied to:

`/Users/matvii/.hermes/media/pantry-rescue-current-screenshot.jpg`

Current visible labels include:

- `LOCAL PROOF. NO ACCOUNT, SCANNER, OR PAYMENTS.`
- `What needs rescuing?`
- `Food to rescue`
- `WHERE IS IT HIDING?`

This proves the app is not completely invisible, but it does not yet prove that the full visual design/taste bar is met. The downstream verifier/judge must still assess whether it is app-specific and not scaffold bullshit.
