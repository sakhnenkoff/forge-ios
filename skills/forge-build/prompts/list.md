# List Screen Guidance

## Layout Pattern
- List or LazyVStack as container (inside DSScreen)
- DSListRow as the primary repeating component
- Search bar: use `.searchable(text:)` modifier on the NavigationStack if search is specified
- Section headers using `.headlineSmall()` + `.textSecondary` if grouped
- Empty state: centered VStack with SF Symbol (`.font(.display())`), title (`.titleSmall()`), subtitle (`.bodyMedium()` + `.textSecondary`), and CTA DSButton
- Pull-to-refresh: `.refreshable { }` modifier if data is dynamic

## DS Components to Prefer
- `DSListRow` for each item
- `DSScreen` as root (required)
- `DSButton` for empty state CTA

## Anti-Patterns
- Do NOT mix DSCard and DSListRow in the same list — pick one style
- Do NOT forget empty state — every list must handle zero items
- Do NOT forget loading state — show placeholder/skeleton while loading
- Do NOT use a plain Text for list items — always use DSListRow
