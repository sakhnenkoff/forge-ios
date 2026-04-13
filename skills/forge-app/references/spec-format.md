> **v3 format — the v4 spec.json schema is defined inline in `skills/forge-app/SKILL.md` Phase 1. This file is retained for reference only.**

# spec.json Format Specification (v3)

The spec.json file is the structured contract between the Planner and the Generator/Judge agents. It defines what features to build, what data models to create, and how navigation connects screens.

**Who reads this file:**
- **Planner (forge-app)** — generates spec.json during Phase 2
- **Generator (forge-build)** — reads the feature entry being built
- **Judge (forge-judge)** — reads the feature entry being evaluated
- **Planner (resume)** — reads feature statuses to resume interrupted builds

---

## JSON Schema

```json
{
  "app_name": "string",
  "pitch": "string — one-sentence app description",
  "target": "string — who the app is for",
  "monetization": "free | freemium | subscription",
  "brand_color": "string — primary brand color name (e.g., Green, Indigo)",
  "references": ["string — app names with aspect to take from each"],

  "features": [
    {
      "id": "string — kebab-case unique identifier (e.g., dashboard, add-habit, onboarding)",
      "type": "complex | simple | skip",
      "screen_type": "primary_surface | detail | settings | onboarding | paywall | sheet | utility",
      "description": "string — what the screen shows and does, specific enough to build from",
      "has_manager": "boolean — true if this feature needs a manager protocol + mock",
      "models": ["string — model names this feature depends on"],
      "depends_on": ["string — feature IDs that must be built before this one"],
      "status": "pending | building | done | failed",
      "nav_case": "string — the enum case name for AppTab/AppRoute/AppSheet (e.g., dashboard, transactionDetail, addTransaction)",
      "icon": "string | null — SF Symbol name for tabs (e.g., chart.bar.fill). Null for non-tab screens.",
      "template_screen": "string | null — which template screen this replaces, if any (e.g., Home, Settings). Null for new screens.",
      "nav_path": "string — how to reach this screen for screenshot (e.g., tab:dashboard, tab:dashboard > tap:first-row, tab:dashboard > button:add)"
    }
  ],

  "models": [
    {
      "name": "string — PascalCase model name",
      "fields": [
        {
          "name": "string — camelCase field name",
          "type": "string — Swift type (String, Int, Date, Bool, [Type], Type?)",
          "optional": "boolean"
        }
      ]
    }
  ],

  "navigation": {
    "tabs": ["string — tab names in display order"],
    "pushes": [
      { "from": "string — source feature ID", "to": "string — destination feature ID" }
    ],
    "sheets": [
      { "from": "string — source feature ID", "to": "string — destination feature ID" }
    ]
  }
}
```

---

## Field Descriptions

### Top-Level Fields

| Field | Required | Description |
|-------|----------|-------------|
| `app_name` | Yes | The app name, used for directory paths and build scheme |
| `pitch` | Yes | One-sentence description of what the app does |
| `target` | Yes | Brief description of who the app is for |
| `monetization` | Yes | One of: `free`, `freemium`, `subscription` |
| `brand_color` | Yes | Primary brand color name |
| `references` | Yes | 1-2 reference apps with what aspect to take from each |

### Feature Fields

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique kebab-case identifier. Used in dispatch prompts and depends_on references. |
| `type` | Yes | Complexity tag that determines how much planning the feature needs. See Complexity Guidelines below. |
| `screen_type` | Yes | Categorization for screen purpose. See Screen Types below. |
| `description` | Yes | What the screen shows and does. Must be specific enough to build from without additional context. |
| `has_manager` | Yes | Whether this feature needs a manager protocol with mock implementation. True for features that manage data (CRUD operations, data fetching). |
| `models` | Yes | Array of model names this feature depends on. Empty array if no models needed. |
| `depends_on` | Yes | Array of feature IDs that must be built before this one. Empty array if independent. |
| `status` | Yes | Current build status. All features start as `"pending"`. |
| `nav_case` | Yes | The enum case name for AppTab/AppRoute/AppSheet (e.g., `dashboard`, `transactionDetail`). |
| `icon` | No | SF Symbol name for tabs (e.g., `chart.bar.fill`). Null for non-tab screens. |
| `template_screen` | No | Which template screen this replaces, if any (e.g., `Home`, `Settings`). Null for new screens. |
| `nav_path` | Yes | How to reach this screen for screenshot (e.g., `tab:dashboard`, `tab:dashboard > tap:first-row`). |

### Model Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | PascalCase model name (e.g., `Habit`, `MealPlanEntry`) |
| `fields` | Yes | Array of field definitions. `id: String` and `createdAt: Date` are implicit and should NOT be listed. |

Each field has:
- `name` — camelCase field name
- `type` — Swift type. Use `[Type]` for arrays, `Type?` for optionals.
- `optional` — boolean, whether the field is optional

### Navigation Fields

| Field | Required | Description |
|-------|----------|-------------|
| `tabs` | Yes | Tab names in display order. Maps to `AppTab` enum cases. |
| `pushes` | Yes | Push navigation connections. Each has `from` and `to` feature IDs. |
| `sheets` | Yes | Sheet presentation connections. Each has `from` and `to` feature IDs. |

---

## Feature Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not yet built. Next in queue. |
| `building` | Currently being built by the Generator. |
| `done` | Built, passed Judge, approved by human. |
| `failed` | Failed after max retries. Logged in `.forge/issues.md`. |

---

## Screen Types

| Screen Type | Description | Examples |
|-------------|-------------|----------|
| `primary_surface` | Main tab screen, the app's primary interaction surface | Dashboard, Feed, Recipe List, Meal Plan |
| `detail` | Detail view pushed from a primary surface | Habit Detail, Recipe Detail, Transaction Detail |
| `settings` | Settings/preferences screen | Settings, Preferences |
| `onboarding` | First-run onboarding flow | Onboarding slides |
| `paywall` | Premium upgrade / subscription screen | Paywall, Upgrade |
| `sheet` | Modal sheet presented from another screen | Add Habit, Add Recipe, Edit Profile |
| `utility` | Supporting utility screen | Search, Filter, Export |

---

## Complexity Guidelines

Every feature gets exactly one complexity tag. The tag determines how the Generator approaches the build.

### Tag Definitions

| Tag | Criteria | Rationale |
|-----|----------|-----------|
| `complex` | Charts, custom layouts, multi-component interactions, real-time data, drag-and-drop, grid layouts, custom animations | Non-standard patterns that benefit from careful implementation |
| `simple` | Standard list/detail/form, onboarding, paywall, single-purpose screens, basic CRUD | Well-scoped, blueprint provides enough context |
| `skip` | Already exists in template, just needs minor config changes | No Generator invocation needed |

### Decision Flowchart

Ask these questions in order. Stop at the first "yes":

1. **Does the screen already exist in the Forge template?** -> `skip`
2. **Does the screen require charts, custom layouts, drag-and-drop, complex animations, or multi-component interactions?** -> `complex`
3. **Everything else** -> `simple`

---

## Common App Archetypes

These archetypes help the Planner propose screens from a one-sentence pitch. Match the app idea to the closest archetype and use its typical screens as a starting point.

| Archetype | Typical Screens | Common Models | Tab Structure |
|-----------|----------------|---------------|---------------|
| **Tracker** (habits, expenses, workouts, mood) | Dashboard, Detail, Add/Edit, Stats/History | Entry, Category, Goal | Home, Stats, Settings |
| **Social/Feed** (posts, photos, reviews) | Feed, Profile, Create Post, Detail, Search | Post, User, Comment, Like | Feed, Search, Profile, Settings |
| **Utility** (converter, calculator, timer) | Main, Settings, History | Conversion, Result | (single tab or no tabs) |
| **Education** (courses, flashcards, quizzes) | Library, Lesson, Progress, Quiz | Course, Lesson, Quiz, Progress | Learn, Progress, Settings |
| **E-commerce** (products, cart, orders) | Browse, Product Detail, Cart, Checkout | Product, CartItem, Order | Shop, Cart, Orders, Settings |
| **Journal/Notes** (diary, notes, ideas) | List, Editor, Tags/Search | Entry, Tag | Notes, Tags, Settings |
| **Health/Fitness** (workouts, meals, sleep) | Dashboard, Log Entry, History, Stats | Workout, Exercise, Entry | Home, Log, History, Settings |
| **Planner** (meals, travel, projects) | Calendar/Plan, Detail, Add Entry, List | PlanEntry, Item, Category | Plan, Items, Settings |

### Archetype Matching Rules

1. **Match on the primary user action.** "Track my expenses" -> Tracker. "Plan my meals" -> Planner.
2. **Hybrid apps take the dominant archetype.** A habit tracker with social features is still a Tracker.
3. **When no archetype fits**, build from first principles: identify the core data entity and derive screens from CRUD + visualization needs.
4. **Always add Onboarding and Paywall** unless the developer explicitly says "free" or "no onboarding."
5. **Always include Settings as skip** unless the developer wants to rebuild it.

### Screen Count Guidance

| App Size | Screen Count | Typical Complexity Mix |
|----------|-------------|------------------------|
| Small | 3-4 custom + Onboarding + Paywall + Settings | 0-1 complex, 2-3 simple, 1 skip |
| Medium | 5-7 custom + Onboarding + Paywall + Settings | 1-2 complex, 3-5 simple, 1 skip |
| Large | 8-12 custom + Onboarding + Paywall + Settings | 2-4 complex, 4-8 simple, 1-2 skip |

---

## Example spec.json

```json
{
  "app_name": "HabitFlow",
  "pitch": "Daily habit tracker with streaks, reminders, and weekly stats",
  "target": "Health-conscious millennials building daily routines",
  "monetization": "freemium",
  "brand_color": "Green",
  "references": [
    "Streaks — single-color discipline, satisfying completion",
    "Things 3 — clean task management, clear hierarchy"
  ],

  "features": [
    {
      "id": "dashboard",
      "type": "complex",
      "screen_type": "primary_surface",
      "description": "Grid of today's habits with completion toggles, streak counts, progress ring",
      "has_manager": true,
      "models": ["Habit", "HabitEntry"],
      "depends_on": [],
      "status": "pending",
      "nav_case": "dashboard",
      "icon": "checkmark.circle.fill",
      "template_screen": "Home",
      "nav_path": "tab:dashboard"
    },
    {
      "id": "habit-detail",
      "type": "simple",
      "screen_type": "detail",
      "description": "Streak calendar, completion history, edit button",
      "has_manager": false,
      "models": ["Habit", "HabitEntry"],
      "depends_on": ["dashboard"],
      "status": "pending",
      "nav_case": "habitDetail",
      "icon": null,
      "template_screen": null,
      "nav_path": "tab:dashboard > tap:first-row"
    },
    {
      "id": "add-habit",
      "type": "simple",
      "screen_type": "sheet",
      "description": "Name, icon picker, color, frequency, reminder time",
      "has_manager": false,
      "models": ["Habit"],
      "depends_on": [],
      "status": "pending",
      "nav_case": "addHabit",
      "icon": null,
      "template_screen": null,
      "nav_path": "tab:dashboard > button:add"
    },
    {
      "id": "stats",
      "type": "complex",
      "screen_type": "primary_surface",
      "description": "Weekly/monthly completion charts (Swift Charts), best streaks, trends",
      "has_manager": false,
      "models": ["Habit", "HabitEntry"],
      "depends_on": ["dashboard"],
      "status": "pending",
      "nav_case": "stats",
      "icon": "chart.bar.fill",
      "template_screen": null,
      "nav_path": "tab:stats"
    },
    {
      "id": "onboarding",
      "type": "simple",
      "screen_type": "onboarding",
      "description": "3 slides: track habits, build streaks, see progress",
      "has_manager": false,
      "models": [],
      "depends_on": [],
      "status": "pending",
      "nav_case": "onboarding",
      "icon": null,
      "template_screen": null,
      "nav_path": "launch:fresh-install"
    },
    {
      "id": "paywall",
      "type": "simple",
      "screen_type": "paywall",
      "description": "Premium features: unlimited habits, stats export, widgets",
      "has_manager": false,
      "models": [],
      "depends_on": [],
      "status": "pending",
      "nav_case": "paywall",
      "icon": null,
      "template_screen": null,
      "nav_path": "tab:settings > button:upgrade"
    },
    {
      "id": "settings",
      "type": "skip",
      "screen_type": "settings",
      "description": "Already exists — add reminder preferences, data export",
      "has_manager": false,
      "models": [],
      "depends_on": [],
      "status": "pending",
      "nav_case": "settings",
      "icon": "gearshape",
      "template_screen": "Settings",
      "nav_path": "tab:settings"
    }
  ],

  "models": [
    {
      "name": "Habit",
      "fields": [
        { "name": "name", "type": "String", "optional": false },
        { "name": "icon", "type": "String", "optional": false },
        { "name": "color", "type": "String", "optional": false },
        { "name": "frequency", "type": "HabitFrequency", "optional": false },
        { "name": "reminderTime", "type": "Date", "optional": true },
        { "name": "isArchived", "type": "Bool", "optional": false }
      ]
    },
    {
      "name": "HabitEntry",
      "fields": [
        { "name": "habitId", "type": "String", "optional": false },
        { "name": "date", "type": "Date", "optional": false },
        { "name": "completed", "type": "Bool", "optional": false }
      ]
    }
  ],

  "navigation": {
    "tabs": ["Dashboard", "Stats", "Settings"],
    "pushes": [
      { "from": "dashboard", "to": "habit-detail" }
    ],
    "sheets": [
      { "from": "dashboard", "to": "add-habit" },
      { "from": "habit-detail", "to": "add-habit" },
      { "from": "settings", "to": "paywall" }
    ]
  }
}
```
