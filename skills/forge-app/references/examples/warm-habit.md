# DESIGN.md — HabitFlow

## Mood

This app feels like a warm, encouraging friend who remembers your wins — soft shapes, generous spacing, quiet celebration.
Reference: Gentler Streak (empathetic data presentation, warm tones), Streaks (single-purpose focus, satisfying completion).

## Color Palette

| Role | Light | Dark | Token | Usage Rule |
|------|-------|------|-------|------------|
| brand | #E8634A | #F0816C | Color.themePrimary | Streak flame icon, primary CTA fill, active habit checkmark — never large backgrounds |
| background | #FBF7F3 | #1A1614 | Color.backgroundPrimary | Root screen background — warm cream in light, warm dark in dark mode |
| surface | #FFFFFF | #231F1C | Color.surface | Card fill, sheet backgrounds, habit row containers |
| surfaceVariant | #F5EEEA | #2A2421 | Color.surfaceVariant | Stats card background, grouped sections, checklist area |
| textPrimary | #2C1E14 | #F5EEEA | Color.textPrimary | Headlines, habit names, streak counts |
| textSecondary | #7A6B5D | #A89888 | Color.textSecondary | Subtitles, habit time labels, description text |
| textTertiary | #B0A090 | #6B5D50 | Color.textTertiary | Timestamps, disabled states, hint text |
| positive | #5B9A6F | #7BC48E | (custom) | Completed habits, streak milestones, success states |
| negative | #C94B4B | #E87070 | Color.error | Missed days, destructive actions, error states |
| border | #E8DDD4 | #3A322C | Color.border | Input field borders, card borders when needed |
| divider | #F0E6DE | #2E2822 | Color.divider | Section separators, list dividers |
| brandSubtle | #FDF0EC | #2E1E18 | (custom) | Tinted background for active streak cards, selected state fills |
| streakGlow | #F5A623 | #F5C04A | (custom) | Streak flame gradient accent, milestone badge fill — small elements only |
| restDay | #A8C5D6 | #5A8BA0 | (custom) | Rest day indicator, gentle blue for scheduled breaks |

## Typography

| Token | Variant | Weight | Tracking | Usage |
|-------|---------|--------|----------|-------|
| .display() | .rounded | .bold | -0.5 | Hero streak count on Today screen — the single biggest number |
| .titleLarge() | .rounded | .semibold | -0.3 | Screen navigation titles (Today, Stats, Settings) |
| .titleMedium() | .rounded | .semibold | 0 | Section headers (Today's Habits, This Week, Milestones) |
| .titleSmall() | .rounded | .medium | 0 | Card titles, habit names in list rows |
| .headlineMedium() | .rounded | .semibold | 0 | Stats numbers (weekly count, best streak), secondary metrics |
| .bodyLarge() | .default | .regular | 0 | Habit descriptions, onboarding body text, settings explanations |
| .bodyMedium() | .default | .regular | 0 | Secondary body text, form field labels, supporting copy |
| .bodySmall() | .default | .regular | 0 | Fine print, footnotes, legal text on paywall |
| .captionLarge() | .default | .medium | 0.2 | Timestamps, habit schedule labels, metadata |
| .buttonMedium() | .rounded | .semibold | 0.3 | Button labels, CTA copy |
| .captionSmall() | .default | .regular | 0.2 | Streak day count labels, chart axis labels |

## Component Rules

| Component | Verdict | Instructions |
|-----------|---------|-------------|
| DSButton | COMPOSE | Corner radius: DSRadii.xl (20) for pill shape, use .rounded font variant for button text |
| DSIconButton | KEEP | Use for toolbar actions (add, settings) and habit row quick actions |
| DSCard | COMPOSE | Corner radius: DSRadii.lg (16), shadow: DSShadows.soft, background: Color.surface — warm and lifted |
| DSHeroCard | COMPOSE | Corner radius: DSRadii.xl (20), background tint: Color.brandSubtle, no gradient — use as Today's streak card only |
| GlassCard | SKIP | Glass effect is too cold for this mood — not used anywhere |
| DSSection | KEEP | Use for grouping habits by time of day and settings categories |
| DSSegmentedControl | KEEP | Use for time range picker in Stats (Week / Month / All Time) |
| DSChoiceButton | COMPOSE | Corner radius: DSRadii.lg (16), selected state: Color.brandSubtle background with Color.themePrimary text |
| DSTextField | COMPOSE | Corner radius: DSRadii.sm (12), border: Color.border, background: Color.surface, use .rounded variant for placeholder text |
| DSInfoCard | COMPOSE | Background: Color.brandSubtle, corner radius: DSRadii.lg (16), no border — warm encouraging callout |
| DSScreen | KEEP | Wrap every screen body |
| AmbientBackground | COMPOSE | Use only on Today screen — single soft radial gradient from Color.brandSubtle center to Color.backgroundPrimary edge, opacity 0.4 |
| StaggeredVStack | KEEP | Use for Today habit checklist entrance and Stats card grid — 0.08s delay per item |
| EmptyStateView | COMPOSE | Use a friendly illustration-style SF Symbol (e.g., leaf.fill) in Color.themePrimary at 48pt, title in .titleSmall() .rounded, description in .bodyMedium() Color.textSecondary |
| ErrorStateView | KEEP | Use for network errors and data load failures |
| ToastView | COMPOSE | Corner radius: DSRadii.lg (16), background: Color.surface, leading icon: checkmark.circle.fill in Color.positive for success |
| DSListCard | KEEP | Use for habit rows in the Today checklist — each habit is a tappable card |
| DSListRow | KEEP | Use for settings rows and flat lists without card emphasis |

## Layout Principles

- **Screen padding:** DSSpacing.mlg (20) horizontal, DSSpacing.lg (24) top — generous and breathable
- **Section gap:** DSSpacing.xl (32) between sections for airy feel
- **Card internal padding:** DSSpacing.md (16) horizontal, DSSpacing.smd (12) vertical
- **Habit card height:** 64pt minimum, DSSpacing.sm (8) gap between habit cards
- **Touch target:** 48pt minimum for all interactive elements — slightly larger than standard for comfortable tapping

## Do's and Don'ts

### Do's
1. Use .rounded font variant for all headings, titles, and buttons — it carries the warm personality
2. Add .contentTransition(.numericText()) to streak counts and stat numbers
3. Use StaggeredVStack with 0.08s delay for habit list entrances on the Today screen
4. Wrap the Today screen body in DSScreen { AmbientBackground() } with the customized warm gradient
5. Use DSShadows.soft on all DSCard instances — cards should feel gently lifted, never flat

### Don'ts
1. **Don't use .monospaced font variant** for any non-data text — .monospaced is only for chart axis labels (.captionSmall())
2. **Don't use AmbientBackground on any screen except Today** — Stats, Settings, and sheets use flat Color.backgroundPrimary
3. **Don't use GlassCard** — no frosted glass or blur effects anywhere in the app
4. **Don't use flat/borderless cards** — every card must have DSShadows.soft and DSRadii.lg (16) minimum corner radius
5. **Don't use Color.red or Color.green** — use Color.error and the custom positive semantic color
6. **Don't hardcode padding values** — always use DSSpacing tokens
7. **Don't use "No habits found" or "No items"** in empty states — use warm, encouraging language from Section 9 (e.g., "Your fresh start")
8. **Don't use .font(.title)** — use .titleLarge() DS token instead
9. **Don't use sharp corners (DSRadii.xs)** on any visible card — minimum DSRadii.sm (12) for all card surfaces

## Screen Blueprints

### Today

**Hero element:** Current streak count — .display() .rounded number inside a DSHeroCard (customized) with Color.brandSubtle tint, streak flame icon (SF Symbol flame.fill, Color.streakGlow) beside it

**Sections (top to bottom):**
1. Greeting + streak hero — .titleLarge() "Good morning" (time-aware), then DSHeroCard (customized) with .display() streak number, .captionLarge() "day streak" label, flame icon. DSSpacing.sm (8) gap between greeting and card.
2. Today's habits — .titleMedium() "Today" section header, StaggeredVStack of DSListCard items: each with leading circle checkbox (Color.themePrimary when checked, Color.border when unchecked), habit name (.titleSmall()), scheduled time (.captionLarge() Color.textSecondary), trailing streak mini-count (.captionSmall() Color.textTertiary). Completed habits show checkmark.circle.fill in Color.positive.
3. Encouragement — DSInfoCard (customized, Color.brandSubtle) with contextual message: shows progress ("3 of 5 done — keep going!") or celebration ("All done for today!") based on completion state

**Empty state:** "Your fresh start" + "Create your first habit and begin building streaks." + "Add Habit" button

**Entrance animation:** StaggeredVStack with 0.08s delay per habit card, .opacity + .offset(y: 8)

**Don't:**
- Don't show weekly chart on Today — Today is about action, not analysis
- Don't collapse the habit list behind a "Show All" button — show every habit

### Stats

**Hero element:** Weekly completion ring — circular progress in Color.themePrimary, .headlineMedium() .rounded percentage centered inside, 120pt diameter

**Sections (top to bottom):**
1. Period selector — DSSegmentedControl (Week / Month / All Time), full-width, DSSpacing.md (16) bottom padding
2. Completion ring — Centered circular progress ring (120pt), .headlineMedium() percentage inside, .captionLarge() "completed" label below ring. Color.themePrimary fill, Color.surfaceVariant track.
3. Habit breakdown — .titleMedium() "By Habit" header, vertical list of DSCard (customized) items: habit name (.titleSmall()), completion bar (horizontal, Color.themePrimary fill on Color.surfaceVariant track), fraction (.captionLarge() .monospaced "18/21")
4. Best streak — DSCard (customized) with .headlineMedium() best streak number, .captionLarge() "best streak" label, flame.fill icon (Color.streakGlow)

**Empty state:** "Nothing to chart yet" + "Complete a few days of habits to see your trends here." + "Go to Today" button

**Entrance animation:** .opacity per section, 0.15s stagger delay

**Don't:**
- Don't use AmbientBackground on Stats — flat Color.backgroundPrimary only
- Don't show more than 7 habits in the breakdown — show top 7 with "See All" if more exist

### Settings

**Hero element:** None — settings is a utility screen with flat background

**Sections (top to bottom):**
1. Habits section — DSSection with header "Habits". DSListRow items: Edit Habits (chevron), Reminder Time (trailing .captionLarge() time value + chevron), Rest Days (trailing .captionLarge() "Sat, Sun" + chevron).
2. Appearance section — DSSection with header "Appearance". DSListRow items: App Icon (chevron), Theme (trailing .captionLarge() "System" + chevron).
3. Data section — DSSection with header "Data". DSListRow items: Export Data, Delete All Habits. Export is neutral, Delete is Color.error text.
4. About section — DSSection with header "About". DSListRow items: Version (.captionLarge() Color.textTertiary trailing), Share HabitFlow, Rate on App Store, Privacy Policy.

**Empty state:** N/A — settings always has content

**Entrance animation:** none

**Don't:**
- Don't use cards for individual settings rows — flat DSListRow with dividers
- Don't add the AmbientBackground to Settings — flat background only

### AddHabit (sheet)

**Hero element:** Habit name input — large DSTextField (customized) with .titleSmall() .rounded placeholder, auto-focused on sheet appearance

**Sections (top to bottom):**
1. Name input — DSTextField (customized), .titleSmall() placeholder "What habit are you building?", DSSpacing.md (16) bottom padding
2. Icon picker — .titleMedium() "Choose an Icon" header, horizontal scroll of DSChoiceButton (customized) items with SF Symbols (figure.run, book.fill, drop.fill, moon.fill, heart.fill, leaf.fill, plus 6 more). Selected state uses Color.brandSubtle background.
3. Frequency — .titleMedium() "How often?" header, DSChoiceButton group: Daily, Weekdays, Custom. Custom reveals day-of-week multi-select.
4. Reminder — .titleMedium() "Reminder" header, toggle switch + time picker. Default off.
5. Action bar — DSButton (customized, pill shape) filled "Create Habit" full-width, DSSpacing.md (16) bottom padding

**Empty state:** N/A — form screen

**Entrance animation:** none — sheet presentation handles entrance

**Don't:**
- Don't use a color picker for habits — the icon carries enough identity
- Don't auto-dismiss on save — show ToastView (customized) "Habit created!" then dismiss after 0.6s delay

### Onboarding

**Hero element:** App logo with friendly leaf.circle.fill icon (Color.themePrimary, 64pt) and "HabitFlow" in .titleLarge() .rounded below

**Sections (top to bottom):**
1. Slide 1 — Icon (flame.fill, Color.streakGlow, 40pt) + title "Build streaks" (.titleLarge() .rounded), body "Small daily habits add up to big changes." (.bodyLarge() Color.textSecondary)
2. Slide 2 — Icon (chart.bar.fill, Color.themePrimary, 40pt) + title "See your progress" (.titleLarge() .rounded), body "Watch your consistency grow week by week." (.bodyLarge() Color.textSecondary)
3. Slide 3 — Icon (bell.badge.fill, Color.themePrimary, 40pt) + title "Gentle reminders" (.titleLarge() .rounded), body "A friendly nudge at the right time, never pushy." (.bodyLarge() Color.textSecondary)
4. CTA — DSButton (customized, pill shape) filled "Let's Go" full-width

**Empty state:** N/A

**Entrance animation:** .opacity per slide on swipe, 0.25s duration

**Don't:**
- Don't use stock photos or complex illustrations — SF Symbol icons + text only
- Don't add a skip button — three short slides are worth completing

### Paywall

**Hero element:** Headline "Your habits, unlocked" in .titleLarge() .rounded, centered

**Sections (top to bottom):**
1. Headline — .titleLarge() .rounded "Your habits, unlocked" centered, .bodyLarge() Color.textSecondary "Everything you need to build lasting habits." below
2. Feature list — 3 DSListCard items with SF Symbol icons in Color.themePrimary leading: flame.fill "Unlimited habits", chart.bar.fill "Detailed insights", bell.badge.fill "Smart reminders". Each title in .titleSmall() .rounded, description in .bodyMedium() Color.textSecondary.
3. Price — DSCard (customized) with .headlineMedium() .rounded "$1.99/month" or "$14.99/year" with DSSegmentedControl toggle inside
4. CTA — DSButton (customized, pill shape) filled "Start Free Trial" full-width, .captionLarge() Color.textTertiary "7 days free. Cancel anytime." below
5. Restore — DSButton text variant "Restore Purchase" centered, .bodyMedium()

**Empty state:** N/A

**Entrance animation:** .opacity, 0.3s duration

**Don't:**
- Don't use urgency tactics ("Last chance!") — keep it warm and honest
- Don't use AmbientBackground on the paywall — flat Color.backgroundPrimary

## Voice & Copy

| Screen | Context | Copy |
|--------|---------|------|
| Today | greeting morning | Good morning |
| Today | greeting afternoon | Good afternoon |
| Today | greeting evening | Good evening |
| Today | empty state title | Your fresh start |
| Today | empty state description | Create your first habit and begin building streaks. |
| Today | empty state CTA | Add Habit |
| Today | progress message partial | 3 of 5 done — keep going! |
| Today | progress message complete | All done for today! |
| Today | streak label | day streak |
| Stats | empty state title | Nothing to chart yet |
| Stats | empty state description | Complete a few days of habits to see your trends here. |
| Stats | empty state CTA | Go to Today |
| Stats | completion label | completed |
| Stats | best streak label | best streak |
| Stats | see all link | See All |
| AddHabit | placeholder: name | What habit are you building? |
| AddHabit | frequency: daily | Daily |
| AddHabit | frequency: weekdays | Weekdays |
| AddHabit | frequency: custom | Custom |
| AddHabit | reminder toggle | Reminder |
| AddHabit | save button | Create Habit |
| AddHabit | success toast | Habit created! |
| Settings | section: habits | Habits |
| Settings | section: appearance | Appearance |
| Settings | section: data | Data |
| Settings | section: about | About |
| Settings | edit habits row | Edit Habits |
| Settings | reminder time row | Reminder Time |
| Settings | rest days row | Rest Days |
| Settings | export row | Export Data |
| Settings | delete all row | Delete All Habits |
| Settings | destructive confirm | Delete all your habits and streaks? This can't be undone. |
| Onboarding | slide 1 title | Build streaks |
| Onboarding | slide 1 body | Small daily habits add up to big changes. |
| Onboarding | slide 2 title | See your progress |
| Onboarding | slide 2 body | Watch your consistency grow week by week. |
| Onboarding | slide 3 title | Gentle reminders |
| Onboarding | slide 3 body | A friendly nudge at the right time, never pushy. |
| Onboarding | CTA | Let's Go |
| Paywall | headline | Your habits, unlocked |
| Paywall | description | Everything you need to build lasting habits. |
| Paywall | feature 1 | Unlimited habits |
| Paywall | feature 2 | Detailed insights |
| Paywall | feature 3 | Smart reminders |
| Paywall | CTA | Start Free Trial |
| Paywall | terms | 7 days free. Cancel anytime. |
| Paywall | restore | Restore Purchase |
| Global | error toast | Something went wrong. Give it another try. |
| Global | success toast | Done! |
| Global | destructive confirm | Are you sure? This can't be undone. |
| Global | network error | Looks like you're offline. Reconnect and try again. |
