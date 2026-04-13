# Forge Build — Codex Code Generation Prompt

<task>
Build the {feature_name} screen for this iOS app.
Write complete, compilable Swift files: View + ViewModel + Manager (if needed) + Model + Navigation wiring.
Do NOT build, run, screenshot, or navigate — only write code files.

Feature spec:
{{FEATURE_SPEC}}

Files to create:

1. **View** (`{App}/Features/{FeatureName}/{FeatureName}View.swift`)
   - Root container: `DSScreen`
   - Must include: `.toast(toast: $viewModel.toast)`, `.onAppear { viewModel.onAppear(services: services, session: session) }`
   - Use `@State private var viewModel = {FeatureName}ViewModel()`
   - Never use `@StateObject`, `AsyncImage`
   - Use DS components: DSButton, DSCard, DSListRow, DSScreen, DSTextField, etc.
   - Use DS typography: `.display()`, `.titleLarge()`, `.bodyMedium()`, etc.
   - Use semantic colors: `.themePrimary`, `.textPrimary`, `.textSecondary`, etc.
   - Use DS spacing tokens: `DSSpacing.xs`, `.sm`, `.smd`, `.md`, `.mlg`, `.lg`, `.xl`, `.xxlg`, `.xxl` (concrete values provided in `<preset_tokens>` below — they vary by preset)
   - Use DS radii tokens: `DSRadii.xs`, `.sm`, `.md`, `.lg`, `.xl`, `.pill` (concrete values provided in `<preset_tokens>` below — they vary by preset)
   - Read the <visual_feel> section — this describes how the screen should FEEL to use. Match the experience described, not just the tokens.
   - If a <mockup> is provided, build to match its layout and visual hierarchy. The mockup is the visual target.
   - If <visual_references> contains reference app screenshots, study them. Your output should evoke the same feeling — same density, surface treatment, and typography confidence.
   - If this is a retry after a judge FAIL, <visual_references> includes the failing screenshot. Compare your changes against it.

2. **ViewModel** (`{App}/Features/{FeatureName}/{FeatureName}ViewModel.swift`)
   - `@MainActor @Observable final class {FeatureName}ViewModel`
   - Must include: `var toast: Toast?`, `private var hasLoaded = false`
   - `onAppear(services:session:)` with `guard !hasLoaded else { return }` pattern
   - `enum Event: LoggableEvent` for analytics

3. **Manager** (only if `has_manager: true` in spec)
   - Protocol + Mock implementation
   - Register in AppServices

4. **Model** (only if models listed in spec)
   - `static let placeholders: [ModelName]`
   - `static let mockList: [ModelName]`
   - `StringIdentifiable` conformance

5. **Navigation** — add route to AppRoute/AppSheet/AppTab as specified
</task>

<design_contract>
{{DESIGN_BLUEPRINT}}
</design_contract>

<architecture_rules>
{{AGENTS_RULES}}
</architecture_rules>

<preset_tokens>
{{PRESET_TOKENS}}
</preset_tokens>

<shared_files>
{{SHARED_FILES}}
</shared_files>

<screen_type_guidance>
{{SCREEN_TYPE_FRAGMENT}}
</screen_type_guidance>

<visual_feel>
{{VISUAL_FEEL}}
</visual_feel>

<visual_references>
{{VISUAL_REFERENCES}}
</visual_references>

<mockup>
{{MOCKUP_PATH}}
</mockup>

<skill_context>
{{SKILL_CONTEXT}}
</skill_context>

<action_safety>
Keep changes tightly scoped to this feature.
Do not refactor, rename, or restructure existing code unless the feature requires it.
Append to shared files (AppRoute, AppServices) — do not reorganize them.
</action_safety>

<final_check>
Before finishing, check the files you just wrote ONCE.
Replace {ViewFile} and {VMFile} with the actual file paths you created.

View file:
- grep -q "DSScreen" {ViewFile} || fix it
- grep -q "\.toast(" {ViewFile} || fix it
- grep -q "\.onAppear" {ViewFile} || fix it
- grep -q "AsyncImage" {ViewFile} && remove it
- grep -q "@StateObject" {ViewFile} && replace with @State

ViewModel file:
- grep -q "@Observable" {VMFile} || fix it
- grep -q "var toast: Toast?" {VMFile} || add it
- grep -q "hasLoaded" {VMFile} || add the guard pattern

Fix any violations. Do NOT re-check after fixing. Return your final files regardless.
</final_check>
