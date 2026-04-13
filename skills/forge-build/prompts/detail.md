# Detail Screen Guidance

## Layout Pattern
- ScrollView as container (inside DSScreen)
- Hero image or header area at top (use AsyncImage alternative: load via manager, display with Image)
- Title using `.titleLarge()`, subtitle using `.bodyMedium()` + `.textSecondary`
- Metadata row (date, author, category) using `.captionLarge()` + `.textTertiary`
- Body content using `.bodyMedium()`
- Primary action button: DSButton(.primary, size: .large) — sticky at bottom or inline based on blueprint
- Related items section at bottom using horizontal ScrollView of DSCard

## DS Components to Prefer
- `DSScreen` as root (required)
- `DSCard` for related items
- `DSButton` for primary action
- `TagBadge` for categories/tags

## Anti-Patterns
- Do NOT have multiple competing primary CTAs — one primary, rest secondary/ghost
- Do NOT forget back navigation — NavigationStack handles this, don't add a custom back button
- Do NOT put metadata above the title — title first, metadata second
