# Detail Screen Guidance

## Hierarchy
- The title/header anchors the top — clear, bold, immediately readable.
- Primary content fills the middle — the data or content the user came to see.
- Actions (edit, delete, share) are secondary — toolbar or bottom, never competing with content.

## Visual Intent
- This screen is about ONE thing in depth. The user tapped to learn more — reward that intent with focused content.
- Use generous spacing between sections — the user is reading, not scanning.
- If there's a hero image or chart, let it breathe — don't crowd it with labels.

## DS Components
- `DSScreen` as root (required)
- `DSSection` for grouping related fields
- `DSListRow` for metadata pairs (label: value)
- `DSButton` for primary actions — one per screen, placed clearly

## Anti-Patterns
- Do NOT pack every detail above the fold — scrolling is expected and welcome
- Do NOT use multiple card styles on one detail screen — consistency within the screen
- Do NOT place destructive actions prominently — use `.confirmationDialog()` behind a secondary button
