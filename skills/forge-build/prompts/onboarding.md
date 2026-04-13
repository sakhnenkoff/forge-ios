# Onboarding Screen Guidance

## Layout Pattern
- TabView with `.tabViewStyle(.page)` for swipeable steps
- Each step: large SF Symbol or illustration at top, title (`.titleLarge()`), subtitle (`.bodyMedium()` + `.textSecondary`), centered vertically
- Progress indicator: `.indexViewStyle(.page(backgroundDisplayMode: .always))` or custom dot indicator
- Skip button: top trailing, using `.bodyMedium()` + `.textSecondary`, always visible except on last step
- Final step: primary CTA using DSButton(.primary, size: .large) — text should be the app's key action, not "Next" or "Done"
- Max 4-5 steps — respect the user's time

## DS Components to Prefer
- `DSButton` for final CTA
- `DSScreen` as root (required)

## Anti-Patterns
- Do NOT use more than 5 onboarding steps — users will skip
- Do NOT use walls of text — one title + one subtitle per step
- Do NOT hide the skip button — users must always be able to skip
- Do NOT use "Next" on the final step — use the app's primary action verb
- Do NOT auto-advance steps — let the user control the pace
