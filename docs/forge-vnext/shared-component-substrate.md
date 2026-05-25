# Forge vNext Shared Component Substrate

Status: design direction for reusable app-factory building blocks.

## Core idea

Forge should not recreate foundational UI behavior for every generated app.

Instead, Forge needs a shared component substrate: reusable, app-agnostic components and interaction primitives that every generated app can opt into when the product/design plan requires them.

This is different from copying a generic template app.

The goal is not to give every app the same UI. The goal is to give every app reliable primitives that are styled by the app-specific design system.

## Distinction: reusable substrate vs template residue

### Good reusable substrate

Reusable substrate is acceptable when it is:

- app-agnostic;
- capability-based;
- selected explicitly by module/design plan;
- styled through app-specific tokens/components;
- testable in isolation;
- absent when not selected.

Examples:

- toast/notification system;
- alert/banner/snackbar primitives;
- loading skeletons;
- empty-state layout primitives;
- form validation primitives;
- local persistence wrapper;
- navigation primitives;
- button/card/list primitives;
- modal/sheet coordinator;
- haptics/motion helpers;
- accessibility helpers;
- evidence/screenshot hooks for verifier.

### Bad template residue

Template residue is bad when it is product-specific or workflow-specific but appears in every app:

- auth/account flows;
- paywall/purchase flows;
- settings/profile screens;
- sync/backend/Firebase surfaces;
- copied onboarding;
- copied docs/skills/scripts;
- prior app concepts;
- DayRateLab or other proof-app references.

## Toast component example

A toast system is a good shared substrate candidate.

Every app should not reimplement toast plumbing from scratch. But each app should be able to style toast presentation according to its design system.

### Shared behavior

The substrate can own:

- queueing;
- dismissal timing;
- severity levels: info, success, warning, error;
- optional action button;
- accessibility announcement;
- safe-area placement;
- animation hooks;
- View modifier API.

### App-specific styling

The generated app design system should own:

- shape;
- color palette;
- typography;
- icon style;
- motion feel;
- copy tone;
- haptic profile;
- whether toast looks like a receipt, slip, capsule, note, banner, etc.

For example:

- Pantry Rescue toast could feel like a small fridge magnet / receipt slip.
- A finance app toast could feel like a ledger confirmation.
- A meditation app toast could be quiet and ambient.

The behavior is shared. The expression is app-specific.

## Required pipeline model

Forge should add an explicit component/capability planning layer.

Each app should have something like:

`/.forge/module-plan.json`

or:

`/.forge/component-plan.json`

It should declare:

```json
{
  "schema_version": "forge.component-plan.v1",
  "selected_components": [
    {
      "id": "toast",
      "reason": "ViewModels need transient success/error feedback for local rescue actions.",
      "style_contract": ".forge/design/design-system.json#toast",
      "required_states": ["success", "error", "warning"],
      "evidence_slots": ["ui.toast.success", "ui.toast.error"]
    }
  ],
  "rejected_components": [
    {
      "id": "account_settings",
      "reason": "Local proof has no account or sync."
    }
  ]
}
```

## Component package direction

Forge should gradually extract shared primitives into a reusable internal package/layer, not leave them as app-specific leftovers in a copied template.

Potential structure:

```text
Forge substrate
├── ComponentSubstrate
│   ├── Toast
│   ├── LoadingState
│   ├── EmptyState
│   ├── FormValidation
│   ├── Haptics
│   ├── Motion
│   └── Accessibility
├── AppDesignAdapter
│   ├── tokens
│   ├── component styles
│   └── motion/haptics mapping
└── ModulePlanner
    ├── selected components
    ├── rejected components
    └── evidence requirements
```

## Verification requirements

The verifier should check both presence and absence.

### Presence checks

If component is selected:

- required files/types exist;
- required states are implemented;
- app-specific style contract exists;
- screenshot/UI evidence shows at least one relevant state;
- tests cover behavior.

### Absence checks

If component is rejected:

- visible/routable UI absent;
- package/dependency absent if not needed;
- stale docs/copy absent;
- verifier fails if rejected component surfaces remain.

## Design assessment requirements

Shared components must not make every app look identical.

Design judge should ask:

- Does this component express the app’s product metaphor?
- Is it just default rounded rectangle + generic icon?
- Does it use app-specific copy and motion?
- Is it consistent with `.forge/design/design-system.json`?
- Does it add product clarity rather than template noise?

## Pipeline learning rule

When any generated app needs a reusable primitive, ask:

1. Is this app-specific only?
2. Or is this a substrate component Forge should learn once?

If reusable, create/patch a substrate component and add it to the component planner so future apps can opt in without reimplementation.

## Current implication

The Pantry Rescue trial should not only clean template residue. It should also teach Forge which reusable components belong in the shared substrate.

Toast/notification is a strong first candidate because many apps need transient feedback, but the visual expression should come from each app’s design system.
