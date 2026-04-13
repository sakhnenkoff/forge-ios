# List Screen Guidance

## Hierarchy
- Each row has ONE primary label. Secondary info (date, count, status) is visually subordinate.
- The list itself is the content — don't wrap it in cards or add unnecessary chrome.
- Search/filter controls (if any) are compact and above the list, not competing with content.

## Visual Intent
- This screen is about scanning and selecting. The user is looking for ONE item — make scanning fast.
- Row density should match the content: tight for settings-like lists, airy for content browsing.
- Use consistent row heights — visual rhythm matters in lists more than anywhere else.

## DS Components
- `DSScreen` as root (required)
- `DSListRow` for each item — use the same component consistently
- `DSSection` if the list has logical groups (but don't over-section)
- `ContentUnavailableView` for empty state

## Anti-Patterns
- Do NOT use DSCard for every list item — rows are for lists, cards are for featured content
- Do NOT mix row styles within the same list — consistency creates scannability
- Do NOT put action buttons on every row — use swipe actions or context menus
