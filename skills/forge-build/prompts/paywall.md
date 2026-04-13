# Paywall Screen Guidance

## Hierarchy
- The value proposition headline dominates — this is the ONE reason to upgrade.
- Feature list is secondary — supporting evidence, not the main argument.
- The CTA button is unmissable — large, brand-colored, fixed at the bottom.

## Visual Intent
- This screen sells a feeling, not a feature list. The headline should create desire.
- Use the `brand` color generously here — this is the one screen where brand saturation is welcome.
- Price should be clear but not the focal point — value first, price second.

## DS Components
- `DSScreen` as root (required)
- `DSButton(.primary, size: .large)` for CTA — full width, brand color
- `DSListRow` or checkmark list for feature comparison
- Use `.presentationDetents([.large])` if presented as a sheet

## Anti-Patterns
- Do NOT lead with the price — lead with what the user gets
- Do NOT list more than 5 features — pick the 3 that matter most
- Do NOT use "Premium" or "Pro" in the headline — use benefit-driven language
- Do NOT hide the close/dismiss button — that gets App Store rejections
