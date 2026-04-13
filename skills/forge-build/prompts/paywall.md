# Paywall Screen Guidance

## Layout Pattern
- Presented as a sheet (`.sheet()`) — must have visible close/dismiss button (top leading or trailing)
- Value proposition section at top: 3-4 feature highlights using SF Symbols + short descriptions
- Pricing tiers: clearly differentiate free vs paid, highlight recommended tier with DSCard + `.themePrimary` border
- If trial available: prominent trial messaging ("Start 7-day free trial") on the primary CTA
- Restore purchases: text button at bottom using `.bodySmall()` + `.textSecondary` — required by App Store
- Subscribe CTA: DSButton(.primary, size: .large), full width

## DS Components to Prefer
- `DSCard` for pricing tiers
- `DSButton` for subscribe CTA
- `DSListRow` for feature comparison
- `DSScreen` as root (required)

## Anti-Patterns
- Do NOT hide the close/dismiss button — App Store will reject
- Do NOT forget "Restore Purchases" — App Store will reject
- Do NOT use aggressive language ("Don't miss out!", "Last chance!") — keep it factual
- Do NOT auto-select the most expensive tier — let the user choose
- Do NOT hide pricing information — always show the price clearly
