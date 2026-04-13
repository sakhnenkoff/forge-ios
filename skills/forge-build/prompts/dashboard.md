# Dashboard Screen Guidance

## Layout Pattern
- Hero section at top with time-based greeting: use `HomeViewModel.greeting(for:)` pattern
- Current date string below greeting using `.bodyMedium()` + `.textSecondary`
- Stats or metrics section using DSCard with numeric emphasis (`.display()` or `.titleLarge()` for numbers)
- Quick action shortcuts: horizontal ScrollView of DSButton or icon+label tiles
- Activity feed or recent items below using DSListRow in a VStack or List

## DS Components to Prefer
- `DSCard` for metric/stat tiles
- `DSListRow` for activity feed items
- `DSButton(.secondary)` for quick actions
- `DSScreen` as root (required)

## Anti-Patterns
- Do NOT cram everything above the fold — let the user scroll
- Do NOT use equal-weight cards in a grid — create visual hierarchy with one dominant element
- Do NOT use a TabView inside the dashboard — tabs belong at the app level
- Do NOT hardcode greeting strings — use the time-based greeting pattern
