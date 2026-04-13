# Form Screen Guidance

## Layout Pattern
- ScrollView as container (inside DSScreen) — forms can exceed screen height
- Grouped sections with clear section headers using `.headlineSmall()`
- DSTextField for every input field, with label and placeholder
- Inline validation: show error text below the field using `.captionLarge()` + `.error` color
- Keyboard handling: use `@FocusState` to manage field focus, `.submitLabel(.next)` between fields, `.submitLabel(.done)` on last field
- Primary submit button: DSButton(.primary, size: .large) at bottom, disabled until form is valid

## DS Components to Prefer
- `DSTextField` for all inputs
- `DSButton` for submit
- `DSScreen` as root (required)
- `DSChoiceButton` for single-select options

## Anti-Patterns
- Do NOT show more than 4-5 fields without scrolling — group into sections
- Do NOT forget error states — every field that can fail validation needs inline error
- Do NOT use alerts for validation errors — inline is better
- Do NOT forget keyboard dismiss — tap outside should dismiss keyboard
