# Settings Screen Guidance

## Hierarchy
- Settings is a utility screen — no hero element needed. "Hero: None" is correct.
- Group related settings with clear section headers.
- Destructive actions (delete account, clear data) are at the very bottom, visually de-emphasized.

## Visual Intent
- This screen is about control, not display. Every row is a toggle, picker, or navigation link.
- Keep it flat and scannable — no cards, no elevation, no visual flourish.
- Use system controls (Toggle, Picker, DatePicker) — don't reinvent settings UI.

## DS Components
- `DSScreen` as root (required)
- `DSListRow` for each setting — consistent row treatment
- `DSSection` with headers for grouping (Account, Preferences, About, Danger Zone)
- System `Toggle`, `Picker`, `DatePicker` for controls

## Anti-Patterns
- Do NOT use DSCard for settings rows — flat rows are correct here
- Do NOT add visual flourish — settings should be invisible infrastructure
- Do NOT put destructive actions in prominent positions — bottom of the last section
- Do NOT use custom toggles or switches — system controls are expected
