# Onboarding Screen Guidance

## Hierarchy
- Each slide has ONE message — a headline and a supporting visual or brief description.
- The page indicator shows progress but doesn't compete with content.
- The CTA button is the clear next step — prominent at the bottom.

## Visual Intent
- Onboarding is about emotion, not information. Each slide should make the user FEEL something about the app.
- Use the `surprise` color from ColorStory for the key visual element on at least one slide.
- Keep text to 3-5 words per headline, 1 sentence per body. If you're writing paragraphs, you're over-explaining.

## DS Components
- `DSScreen` as root (required)
- TabView with `.tabViewStyle(.page)` for slide navigation
- `DSButton(.primary, size: .large)` for CTA — "Get Started" / "Continue"
- Use `.containerRelativeFrame([.horizontal, .vertical])` on TabView when inside DSScreen's ScrollView wrapper (prevents zero-height rendering)

## Anti-Patterns
- Do NOT use more than 3-4 slides — every extra slide increases drop-off
- Do NOT use feature lists or bullet points — this isn't a product page
- Do NOT skip the page indicator — users need to know where they are
- Do NOT auto-advance slides — let the user control their pace
