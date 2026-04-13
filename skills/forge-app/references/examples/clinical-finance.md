# DESIGN.md — Ledgr

## Mood

This app feels like a precision financial instrument — flat numbers, zero ornamentation, absolute confidence in the data.
Reference: Mercury (flat numbers, monospaced confidence), Arc (editorial spacing, restrained palette).

## Color Palette

| Role | Light | Dark | Token | Usage Rule |
|------|-------|------|-------|------------|
| brand | #1A56DB | #6EA8FE | Color.themePrimary | Active tab indicator, primary CTA fill — never backgrounds, never text |
| background | #F8F9FA | #0D0F12 | Color.backgroundPrimary | Root screen background — all screens |
| surface | #FFFFFF | #161A1F | Color.surface | Card fill, transaction rows, sheet backgrounds |
| surfaceVariant | #F1F3F5 | #1C2127 | Color.surfaceVariant | Grouped sections, stats row background, settings groups |
| textPrimary | #0D0F12 | #F0F2F4 | Color.textPrimary | All hero numbers, transaction amounts, section headers |
| textSecondary | #4B5563 | #9CA3AF | Color.textSecondary | Transaction descriptions, subtitles, metadata labels |
| textTertiary | #9CA3AF | #4B5563 | Color.textTertiary | Timestamps, disabled inputs, hint text |
| positive | #0F766E | #34D399 | (custom) | Income amounts, positive deltas, success states |
| negative | #DC2626 | #F87171 | Color.error | Expense amounts, destructive actions, error states |
| border | #D1D5DB | #2D333B | Color.border | Input field borders, card borders in flat mode |
| divider | #E5E7EB | #21262D | Color.divider | Transaction list separators, section dividers |
| brandSubtle | #EBF0FE | #172038 | (custom) | Selected row tint, active filter pill background — never large surfaces |
| chartIncome | #0F766E | #34D399 | (custom) | Income bars and lines in charts only |
| chartExpense | #DC2626 | #F87171 | (custom) | Expense bars and lines in charts only |

## Typography

| Token | Variant | Weight | Tracking | Usage |
|-------|---------|--------|----------|-------|
| .display() | .monospaced | .bold | -1.0 | Hero monthly total on Dashboard — the single largest number on screen |
| .titleLarge() | .default | .semibold | -0.5 | Screen navigation titles (Dashboard, Transactions, Settings) |
| .titleMedium() | .default | .semibold | 0 | Section headers (Recent Transactions, This Month, Categories) |
| .titleSmall() | .default | .medium | 0 | Card titles, transaction merchant name |
| .headlineMedium() | .monospaced | .semibold | 0 | Stats row numbers (income total, expense total, balance) |
| .bodyLarge() | .default | .regular | 0 | Transaction descriptions, settings option labels |
| .bodyMedium() | .default | .regular | 0 | Secondary body text, form field labels, explanatory copy |
| .bodySmall() | .default | .regular | 0 | Fine print, footnotes, legal text on paywall |
| .captionLarge() | .default | .medium | 0.2 | Transaction timestamps, metadata, category tags |
| .buttonMedium() | .default | .semibold | 0.3 | Button labels, action text, CTA copy |
| .captionSmall() | .monospaced | .regular | 0.2 | Transaction IDs, reference numbers |

## Component Rules

| Component | Verdict | Instructions |
|-----------|---------|-------------|
| DSButton | KEEP | Use for all primary and secondary actions — filled variant for CTAs, outlined for secondary |
| DSIconButton | KEEP | Use for toolbar actions (filter, add, more) and inline row actions |
| DSCard | COMPOSE | Remove shadow entirely (shadow: .none), add 1px border using Color.border, corner radius DSRadii.sm (12) — flat and precise |
| DSHeroCard | CREATE | Too decorative — build standalone .display() numbers on the background, no container |
| GlassCard | SKIP | Blur effects conflict with clinical precision — not used anywhere |
| DSSection | KEEP | Use for grouping settings rows and transaction categories |
| DSSegmentedControl | KEEP | Use for time period filters (Week / Month / Year) on Dashboard |
| DSChoiceButton | KEEP | Use for category selection in Add Transaction sheet |
| DSTextField | COMPOSE | Border color: Color.border, corner radius: DSRadii.xs (8), background: Color.surface — no rounded or pill shapes |
| DSInfoCard | COMPOSE | Background: Color.surfaceVariant, border: 1px Color.border, no icon — text-only informational callout |
| DSScreen | KEEP | Wrap every screen body |
| AmbientBackground | SKIP | No gradients or particles — not used anywhere in this app |
| StaggeredVStack | SKIP | No staggered entrance animations anywhere in this app |
| EmptyStateView | COMPOSE | Icon: SF Symbol in Color.textTertiary, title in .titleSmall(), description in .bodyMedium() Color.textSecondary — no large illustrations |
| ErrorStateView | KEEP | Use for network errors and data load failures |
| ToastView | KEEP | Use for confirmation of destructive actions and successful saves |
| DSListCard | SKIP | Too heavy with card styling — not used anywhere |
| DSListRow | KEEP | Use for transaction rows, settings rows — flat with divider separation |

## Layout Principles

- **Screen padding:** DSSpacing.md (16) horizontal, DSSpacing.lg (24) top
- **Section gap:** DSSpacing.lg (24) between sections, DSSpacing.sm (8) between section header and content
- **Card internal padding:** DSSpacing.md (16) all sides, no shadow, 1px border
- **List row height:** 56pt minimum, DSSpacing.sm (8) vertical padding
- **Touch target:** 44pt minimum for all interactive elements

## Do's and Don'ts

### Do's
1. Use .monospaced variant for all numeric displays (amounts, totals, stats, percentages)
2. Add .contentTransition(.numericText()) to every number that can change
3. Use DSSpacing.md (16) as the standard horizontal padding on every screen
4. Right-align all monetary amounts in transaction rows using .frame(maxWidth: .infinity, alignment: .trailing)
5. Use Color.positive for income amounts and Color.error for expense amounts — never the same color for both

### Don'ts
1. **Don't use AmbientBackground** — no gradients, particles, or decorative backgrounds anywhere
2. **Don't use StaggeredVStack** — content loads instantly, no staggered entrance animations
3. **Don't use DSHeroCard** — hero numbers are standalone, never wrapped in cards
4. **Don't use DSListCard** — all lists use flat DSListRow with dividers
5. **Don't use GlassCard** — no frosted glass or blur effects anywhere in the app
6. **Don't use .rounded font variant** — this app uses .default and .monospaced only
7. **Don't use Color.red or Color.green** — use Color.error and the custom positive semantic color
8. **Don't hardcode padding values** — always use DSSpacing tokens
9. **Don't use "Let's get started" or "Get started"** in empty states — use factual statements from Section 8 (e.g., "No transactions recorded")
10. **Don't use .font(.title)** — use .titleLarge() DS token instead

## Screen Blueprints

### Dashboard

**Hero element:** Monthly total — standalone .display() .monospaced number, left-aligned, with .captionLarge() month label above

**Sections (top to bottom):**
1. Month label + hero total — .captionLarge() "APRIL 2026" label, then .display() "$4,231.89" number, DSSpacing.xs (4) gap between them
2. Stats row — Three inline stats in a horizontal DSSection on Color.surfaceVariant: Income (.headlineMedium() .monospaced, Color.positive), Expenses (.headlineMedium() .monospaced, Color.error), Balance (.headlineMedium() .monospaced, Color.textPrimary). DSSpacing.md (16) between each.
3. Recent transactions — .titleMedium() "Recent" section header, then vertical list of 5 DSListRow items: merchant name (.titleSmall()), amount (.headlineMedium() .monospaced, trailing), timestamp (.captionLarge()), category tag (.captionLarge() Color.textTertiary)

**Empty state:** "No transactions recorded." + "Add Transaction" button

**Entrance animation:** none — content appears immediately, numbers use .contentTransition(.numericText()) when values update

**Don't:**
- Don't wrap the hero number in any card, container, or colored background
- Don't show a chart on the Dashboard — charts belong in a dedicated Analytics screen if added later

### Transactions

**Hero element:** Search field at top — DSTextField (customized), always visible, not collapsible

**Sections (top to bottom):**
1. Search + filter bar — DSTextField for search, DSSegmentedControl for period filter (Week / Month / All), horizontal layout, DSSpacing.sm (8) gap
2. Transaction list — Grouped by date. Date header in .captionLarge() Color.textTertiary, uppercase. Each transaction is a DSListRow: leading category icon (SF Symbol, Color.textSecondary, 20pt), merchant name (.titleSmall()), description (.bodyMedium() Color.textSecondary), trailing amount (.headlineMedium() .monospaced, color based on income/expense), swipe actions: delete (Color.error)

**Empty state:** "No transactions match this filter." + "Clear Filters" button

**Entrance animation:** none

**Don't:**
- Don't use cards for individual transactions — flat DSListRow with dividers only
- Don't group by category — group by date, most recent first

### Settings

**Hero element:** None — settings is a flat utility screen

**Sections (top to bottom):**
1. Account section — DSSection with header "Account". DSListRow items: Name, Email, Currency preference. Each with .titleSmall() label and .bodyMedium() Color.textSecondary value, trailing chevron.
2. Data section — DSSection with header "Data". DSListRow items: Export CSV, Clear All Data. Export is neutral, Clear is Color.error text.
3. About section — DSSection with header "About". DSListRow items: Version (.captionLarge() Color.textTertiary trailing), Privacy Policy, Terms of Service.

**Empty state:** N/A — settings always has content

**Entrance animation:** none

**Don't:**
- Don't use toggle switches for non-boolean settings — use navigation rows with chevrons
- Don't add icons to every settings row — text-only for clinical feel

### AddTransaction (sheet)

**Hero element:** Amount input — large .display() .monospaced number entry field, centered, auto-focused on sheet appearance

**Sections (top to bottom):**
1. Amount entry — .display() .monospaced centered number with currency symbol, tappable to edit, Color.textPrimary
2. Details form — DSTextField (customized) for merchant name, DSTextField for description (optional). DSSpacing.smd (12) gap between fields.
3. Category picker — .titleMedium() "Category" header, horizontal scroll of DSChoiceButton items (Food, Transport, Bills, Shopping, Income, Other)
4. Date picker — .titleMedium() "Date" header, native DatePicker, defaults to today
5. Action bar — DSButton filled "Save Transaction" full-width, DSSpacing.md (16) bottom padding

**Empty state:** N/A — form screen

**Entrance animation:** none — sheet presentation handles entrance

**Don't:**
- Don't use a number pad custom keyboard — use the system decimal pad keyboard type
- Don't auto-dismiss on save — show ToastView "Transaction saved." then dismiss after 0.5s delay

### Onboarding

**Hero element:** App icon centered with app name "Ledgr" in .display() .monospaced below

**Sections (top to bottom):**
1. Slide 1 — Icon + title "Track every dollar" (.titleLarge()), body "See exactly where your money goes, no guesswork." (.bodyLarge() Color.textSecondary)
2. Slide 2 — Icon + title "Instant clarity" (.titleLarge()), body "Monthly totals, category breakdowns, one glance." (.bodyLarge() Color.textSecondary)
3. Slide 3 — Icon + title "Private by design" (.titleLarge()), body "Your data stays on your device. Period." (.bodyLarge() Color.textSecondary)
4. CTA — DSButton filled "Get Started" full-width

**Empty state:** N/A

**Entrance animation:** .opacity per slide on swipe, 0.2s duration

**Don't:**
- Don't use illustrations or decorative images — icon + text only
- Don't add a skip button — three slides are fast enough

### Paywall

**Hero element:** Headline "Unlimited tracking" in .titleLarge(), centered

**Sections (top to bottom):**
1. Headline — .titleLarge() "Unlimited tracking" centered, .bodyLarge() Color.textSecondary "Remove all limits and export your data anytime." below
2. Feature list — 3 DSListRow items with SF Symbol checkmark.circle.fill (Color.themePrimary) leading: "Unlimited transactions", "CSV & PDF export", "Category insights". Each in .bodyMedium().
3. Price — .headlineMedium() .monospaced "$2.99/month" or "$19.99/year" with DSSegmentedControl toggle
4. CTA — DSButton filled "Start Free Trial" full-width, .captionLarge() Color.textTertiary "Cancel anytime. Terms apply." below
5. Restore — DSButton text variant "Restore Purchase" centered, .bodyMedium()

**Empty state:** N/A

**Entrance animation:** .opacity, 0.3s duration

**Don't:**
- Don't use gradients or decorative backgrounds on the paywall
- Don't use urgency language ("Limited time!") — keep it factual

## Voice & Copy

| Screen | Context | Copy |
|--------|---------|------|
| Dashboard | empty state title | No transactions recorded. |
| Dashboard | empty state description | Tap + to add your first transaction. |
| Dashboard | empty state CTA | Add Transaction |
| Dashboard | month label format | APRIL 2026 |
| Transactions | empty state title | No transactions match this filter. |
| Transactions | empty state description | Adjust the date range or clear your search. |
| Transactions | empty state CTA | Clear Filters |
| Transactions | swipe delete label | Delete |
| AddTransaction | placeholder: merchant | Merchant name |
| AddTransaction | placeholder: description | Description (optional) |
| AddTransaction | placeholder: amount | 0.00 |
| AddTransaction | save button | Save Transaction |
| AddTransaction | success toast | Transaction saved. |
| Settings | section: account | Account |
| Settings | section: data | Data |
| Settings | section: about | About |
| Settings | export row | Export CSV |
| Settings | clear data row | Clear All Data |
| Settings | destructive confirm | Delete all transactions? This cannot be undone. |
| Onboarding | slide 1 title | Track every dollar |
| Onboarding | slide 1 body | See exactly where your money goes, no guesswork. |
| Onboarding | slide 2 title | Instant clarity |
| Onboarding | slide 2 body | Monthly totals, category breakdowns, one glance. |
| Onboarding | slide 3 title | Private by design |
| Onboarding | slide 3 body | Your data stays on your device. Period. |
| Onboarding | CTA | Get Started |
| Paywall | headline | Unlimited tracking |
| Paywall | description | Remove all limits and export your data anytime. |
| Paywall | feature 1 | Unlimited transactions |
| Paywall | feature 2 | CSV & PDF export |
| Paywall | feature 3 | Category insights |
| Paywall | CTA | Start Free Trial |
| Paywall | terms | Cancel anytime. Terms apply. |
| Paywall | restore | Restore Purchase |
| Global | error toast | Something went wrong. Try again. |
| Global | success toast | Done. |
| Global | destructive confirm | Delete this? This action is permanent. |
| Global | network error | No connection. Check your network and retry. |
