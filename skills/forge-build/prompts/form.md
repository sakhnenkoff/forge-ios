# Form Screen Guidance

## Hierarchy
- The form title tells the user what they're creating/editing — prominent but not overwhelming.
- Input fields are the primary interaction — each gets enough vertical space to feel comfortable.
- The submit button is the clear endpoint — fixed at the bottom or after the last field.

## Visual Intent
- This screen is about input, not display. Every element serves the user's task of entering data.
- Group related fields with `DSSection`. Keep groups to 3-4 fields max before a visual break.
- Placeholder text should be examples, not instructions ("e.g., Morning run" not "Enter habit name").

## DS Components
- `DSScreen` as root (required)
- `DSTextField` for text input with label and validation
- `DSSection` for field grouping
- `DSButton(.primary, size: .large)` for submit — full width

## Anti-Patterns
- Do NOT use a ScrollView of TextFields without section breaks — it feels like a government form
- Do NOT put validation errors only in a toast — show inline under the field
- Do NOT auto-advance focus to the next field — let the user control their pace
