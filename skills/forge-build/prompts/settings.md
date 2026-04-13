# Settings Screen Guidance

## Layout Pattern
- List with grouped sections using `Section(header:)` blocks
- Section headers using `.headlineSmall()` + `.textSecondary` + uppercase
- Toggle rows: DSListRow with Toggle for boolean preferences
- Navigation rows: DSListRow with chevron accessory for sub-screens (push navigation)
- Account section at top: user name/email, avatar if available
- Preferences section: notification toggles, appearance settings
- Support section: help, feedback, privacy policy, terms
- Destructive section at bottom: "Sign Out" (`.error` color), "Delete Account" (`.error` color, with confirmation alert)
- App version at very bottom: `.captionLarge()` + `.textTertiary`, centered

## DS Components to Prefer
- `DSListRow` for all rows
- `DSScreen` as root (required)
- Toggle (SwiftUI native) inside DSListRow for boolean settings

## Anti-Patterns
- Do NOT put destructive actions at the top — always at bottom
- Do NOT mix action buttons with navigation rows — be consistent
- Do NOT forget confirmation for destructive actions — always use `.alert()` before sign out or delete
- Do NOT use red for non-destructive actions — reserve `.error` color for sign out and delete only
