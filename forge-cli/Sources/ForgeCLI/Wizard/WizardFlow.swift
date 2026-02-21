import Foundation

struct WizardFlow {

    enum Step: Int, CaseIterable {
        case preset          // "Preset or manual?"
        case projectName
        case bundleId
        case authProviders
        case monetization
        case analytics
        case featureModules
        case review          // Summary + Generate?
    }

    private let allFeatures: [FeatureManifest]
    private let prefilledFlags: GenerateCommand

    init(allFeatures: [FeatureManifest], flags: GenerateCommand) {
        self.allFeatures = allFeatures
        self.prefilledFlags = flags
    }

    /// Collect all configuration interactively (or from flags).
    /// Returns nil if user cancels at the review step.
    mutating func collect() throws -> GenerationConfig? {
        // Answers store
        var projectName: String? = prefilledFlags.projectName
        var bundleId: String? = prefilledFlags.bundleId
        var authProviders: [GenerationConfig.AuthProvider]? = prefilledFlags.authProviders.map { list in
            list.values.compactMap { GenerationConfig.AuthProvider(rawValue: $0) }
        }
        var monetizationModel: GenerationConfig.MonetizationModel? = prefilledFlags.monetizationModel.flatMap {
            GenerationConfig.MonetizationModel(rawValue: $0)
        }
        var analyticsIds: [String]? = prefilledFlags.analyticsServices.map { list in
            list.values.map { normalizeFeatureId($0) }
        }
        var featureModuleIds: [String]? = prefilledFlags.features.map { list in
            list.values.map { normalizeFeatureId($0) }
        }
        var resolvedIds: [String]? = nil
        var outputDirURL: URL? = prefilledFlags.outputDir.map { URL(fileURLWithPath: $0) }

        // If a preset flag was provided, pre-fill from it
        if let presetId = prefilledFlags.preset, let preset = Preset.byId(presetId) {
            applyPreset(preset, to: &authProviders, &monetizationModel, &analyticsIds, &featureModuleIds)
        }

        Console.printHeader("New App Setup")

        // Determine starting step
        var currentStep: Step = allFieldsPrefilled(
            projectName: projectName, bundleId: bundleId, authProviders: authProviders,
            monetization: monetizationModel, analytics: analyticsIds, features: featureModuleIds
        ) ? .review : .preset

        // Step loop
        stepLoop: while currentStep != .review {
            switch currentStep {

            case .preset:
                let options: [(label: String, value: String?)] = [
                    ("Minimal — Apple auth, no monetization, no analytics", "minimal"),
                    ("Standard — Apple + Google, subscriptions, Firebase Analytics", "standard"),
                    ("Full — everything enabled", "full"),
                    ("Configure manually", nil)
                ]
                let result = Prompts.singleSelect(prompt: "Start from a preset?", options: options)
                switch result {
                case .back:
                    break // At first step, back is a no-op
                case .value(let presetId):
                    if let pid = presetId, let preset = Preset.byId(pid) {
                        applyPreset(preset, to: &authProviders, &monetizationModel, &analyticsIds, &featureModuleIds)
                        currentStep = .review
                        continue stepLoop
                    } else {
                        currentStep = .projectName
                        continue stepLoop
                    }
                }

            case .projectName:
                if projectName != nil {
                    currentStep = Step(rawValue: currentStep.rawValue + 1)!
                    continue
                }
                let result = Prompts.textInput(
                    prompt: "App name",
                    placeholder: "MyApp",
                    validate: { input in
                        let valid = input.range(of: "^[a-zA-Z][a-zA-Z0-9_]*$", options: .regularExpression) != nil
                        return valid ? nil : "Must start with a letter, letters/numbers/underscores only (e.g. MyApp)"
                    }
                )
                switch result {
                case .back:
                    currentStep = .preset
                case .value(let v):
                    projectName = v
                    currentStep = .bundleId
                }

            case .bundleId:
                if bundleId != nil {
                    currentStep = Step(rawValue: currentStep.rawValue + 1)!
                    continue
                }
                let suggested = projectName.map { "com.yourcompany.\($0.lowercased())" } ?? "com.yourcompany.myapp"
                let result = Prompts.textInput(
                    prompt: "Bundle ID",
                    placeholder: suggested,
                    validate: { input in
                        // Basic reverse-domain check
                        let parts = input.split(separator: ".")
                        guard parts.count >= 2 else {
                            return "Must be reverse-domain format: com.company.app"
                        }
                        let valid = parts.allSatisfy { part in
                            !part.isEmpty && part.allSatisfy { $0.isLetter || $0.isNumber || $0 == "-" }
                        }
                        return valid ? nil : "Bundle ID can only contain letters, numbers, dots, and hyphens"
                    }
                )
                switch result {
                case .back:
                    projectName = nil
                    currentStep = .projectName
                case .value(let v):
                    bundleId = v
                    currentStep = .authProviders
                }

            case .authProviders:
                if authProviders != nil {
                    currentStep = Step(rawValue: currentStep.rawValue + 1)!
                    continue
                }
                let options = GenerationConfig.AuthProvider.allCases.map(\.displayName)
                let result = Prompts.multiSelect(
                    prompt: "Auth providers",
                    options: options,
                    requiresAtLeastOne: true,
                    hint: "↑↓ navigate  Space toggle  Enter confirm  Esc back  (at least one required)"
                )
                switch result {
                case .back:
                    bundleId = nil
                    currentStep = .bundleId
                case .value(let indices):
                    authProviders = indices.sorted().map { GenerationConfig.AuthProvider.allCases[$0] }
                    currentStep = .monetization
                }

            case .monetization:
                if monetizationModel != nil {
                    currentStep = Step(rawValue: currentStep.rawValue + 1)!
                    continue
                }
                let options: [(label: String, value: GenerationConfig.MonetizationModel)] =
                    GenerationConfig.MonetizationModel.allCases.map { ($0.displayName, $0) }
                let result = Prompts.singleSelect(prompt: "Monetization model", options: options)
                switch result {
                case .back:
                    authProviders = nil
                    currentStep = .authProviders
                case .value(let v):
                    monetizationModel = v
                    currentStep = .analytics
                }

            case .analytics:
                if analyticsIds != nil {
                    currentStep = Step(rawValue: currentStep.rawValue + 1)!
                    continue
                }
                let analyticsFeatures = allFeatures.filter { $0.category == .analytics }
                let options = analyticsFeatures.map { "\($0.displayName) — \($0.description)" }
                let result = Prompts.multiSelect(
                    prompt: "Analytics services",
                    options: options,
                    hint: "↑↓ navigate  Space toggle  Enter confirm  Esc back  (none = skip analytics)"
                )
                switch result {
                case .back:
                    monetizationModel = nil
                    currentStep = .monetization
                case .value(let indices):
                    analyticsIds = indices.sorted().map { analyticsFeatures[$0].id }
                    currentStep = .featureModules
                }

            case .featureModules:
                if featureModuleIds != nil {
                    currentStep = Step(rawValue: currentStep.rawValue + 1)!
                    continue
                }
                let moduleFeatures = allFeatures.filter {
                    $0.category == .module || $0.category == .notifications || $0.category == .testing
                }
                let options = moduleFeatures.map { "\($0.displayName) — \($0.description)" }
                let result = Prompts.multiSelect(
                    prompt: "Feature modules",
                    options: options,
                    hint: "↑↓ navigate  Space toggle  Enter confirm  Esc back  (none = minimal app)"
                )
                switch result {
                case .back:
                    analyticsIds = nil
                    currentStep = .analytics
                case .value(let indices):
                    featureModuleIds = indices.sorted().map { moduleFeatures[$0].id }
                    // Resolve dependencies and surface implicit ones for confirmation
                    let allSelectedIds = combineFeatureIds(
                        monetization: monetizationModel,
                        analytics: analyticsIds ?? [],
                        modules: featureModuleIds ?? []
                    )
                    let resolution = try DependencyResolver.resolve(selected: allSelectedIds, all: allFeatures)
                    for (dep, requiredBy) in resolution.addedDependencies {
                        let depName = allFeatures.first { $0.id == dep }?.displayName ?? dep
                        let requiredByName = allFeatures.first { $0.id == requiredBy }?.displayName ?? requiredBy
                        print()
                        Console.printWarning("\(requiredByName) requires \(depName).")
                        let confirm = Prompts.yesNo(question: "Add \(depName)?", defaultYes: true)
                        if case .value(false) = confirm {
                            // User declined — remove the feature that requires this dep
                            featureModuleIds = featureModuleIds?.filter { $0 != requiredBy }
                            analyticsIds = analyticsIds?.filter { $0 != requiredBy }
                        }
                    }
                    // Re-resolve with final selection
                    let finalSelectedIds = combineFeatureIds(
                        monetization: monetizationModel,
                        analytics: analyticsIds ?? [],
                        modules: featureModuleIds ?? []
                    )
                    let finalResolution = try DependencyResolver.resolve(selected: finalSelectedIds, all: allFeatures)
                    resolvedIds = finalResolution.resolved
                    currentStep = .review
                }

            case .review:
                break stepLoop
            }
        }

        // MARK: - Review Step (always shown)

        guard let name = projectName, let bid = bundleId,
              let auth = authProviders, let monetization = monetizationModel
        else {
            Console.printError("Wizard completed with missing required fields.")
            return nil
        }

        // Compute output directory if not explicitly set
        if outputDirURL == nil {
            let parentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .deletingLastPathComponent()
            outputDirURL = parentDir.appendingPathComponent(name)
        }

        let finalAnalytics = analyticsIds ?? []
        let finalModules = featureModuleIds ?? []

        print()
        Console.printHeader("Review Your Configuration")
        print("  App Name:      \(Console.bold(name))")
        print("  Bundle ID:     \(bid)")
        print("  Output:        \(outputDirURL!.path)")
        print("  Auth:          \(auth.map(\.displayName).joined(separator: ", "))")
        print("  Monetization:  \(monetization.displayName)")
        let analyticsDisplay = finalAnalytics.isEmpty ? "none" : finalAnalytics.joined(separator: ", ")
        let modulesDisplay = finalModules.isEmpty ? "none" : finalModules.joined(separator: ", ")
        print("  Analytics:     \(analyticsDisplay)")
        print("  Modules:       \(modulesDisplay)")
        print()

        let confirm = Prompts.yesNo(question: "Generate project?", defaultYes: true)
        if case .value(false) = confirm {
            print(Console.gray("Generation cancelled."))
            return nil
        }

        // Final dependency resolution
        if resolvedIds == nil {
            let allSelectedIds = combineFeatureIds(monetization: monetization, analytics: finalAnalytics, modules: finalModules)
            let resolution = try DependencyResolver.resolve(selected: allSelectedIds, all: allFeatures)
            resolvedIds = resolution.resolved
        }

        return GenerationConfig(
            projectName: name,
            bundleId: bid,
            authProviders: auth,
            monetizationModel: monetization,
            analyticsFeatureIds: finalAnalytics,
            featureModuleIds: finalModules,
            resolvedFeatureIds: resolvedIds ?? [],
            outputDir: outputDirURL!
        )
    }

    // MARK: - Helpers

    private func applyPreset(
        _ preset: Preset,
        to authProviders: inout [GenerationConfig.AuthProvider]?,
        _ monetization: inout GenerationConfig.MonetizationModel?,
        _ analytics: inout [String]?,
        _ modules: inout [String]?
    ) {
        authProviders = preset.authProviders
        monetization = preset.monetizationModel
        analytics = preset.analyticsFeatureIds
        modules = preset.featureModuleIds
    }

    private func combineFeatureIds(
        monetization: GenerationConfig.MonetizationModel?,
        analytics: [String],
        modules: [String]
    ) -> [String] {
        var ids = analytics + modules
        if monetization?.requiresPurchases == true && !ids.contains("revenuecat") {
            ids.append("revenuecat")
        }
        return ids
    }

    /// Map shorthand CLI flag values to registry IDs.
    /// e.g. "firebase" → "firebase-analytics", "push" → "push-notifications", "abtesting" → "ab-testing"
    private func normalizeFeatureId(_ id: String) -> String {
        switch id {
        case "firebase":    return "firebase-analytics"
        case "push":        return "push-notifications"
        case "abtesting":   return "ab-testing"
        case "imageupload": return "image-upload"
        default:            return id  // already in correct form (e.g. "crashlytics", "mixpanel", "revenuecat", "onboarding")
        }
    }

    private func allFieldsPrefilled(
        projectName: String?, bundleId: String?,
        authProviders: [GenerationConfig.AuthProvider]?,
        monetization: GenerationConfig.MonetizationModel?,
        analytics: [String]?, features: [String]?
    ) -> Bool {
        return projectName != nil && bundleId != nil && authProviders != nil
            && monetization != nil && analytics != nil && features != nil
    }
}
