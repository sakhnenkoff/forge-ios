import ArgumentParser
import Foundation

@main
struct GenerateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "forge",
        abstract: "Generate a new iOS app from the Forge template.",
        discussion: """
        Runs an interactive wizard to configure your new app. Provide flags to
        skip individual prompts (hybrid mode — flags fill what they can, prompts
        handle the rest).

        Flag naming uses camelCase: --bundleId, --authProviders, etc.

        Examples:
          forge                                    # fully interactive
          forge --projectName MyApp                # pre-fills name, prompts for rest
          forge --preset standard                  # pre-fills all, review before gen
        """
    )

    // MARK: - All flags (camelCase names explicitly set)

    @Option(name: [.customLong("projectName")], help: "App name (PascalCase, letters/numbers/underscores).")
    var projectName: String?

    @Option(name: [.customLong("bundleId")], help: "Bundle ID (e.g. com.company.myapp).")
    var bundleId: String?

    @Option(
        name: [.customLong("authProviders")],
        help: "Auth providers (comma-separated): apple,google,email,anonymous. At least one required."
    )
    var authProviders: CommaSeparatedList?

    @Option(
        name: [.customLong("monetizationModel")],
        help: "Monetization model: subscription,onetime,free."
    )
    var monetizationModel: String?

    @Option(
        name: [.customLong("analyticsServices")],
        help: "Analytics services (comma-separated): firebase,mixpanel,crashlytics,none."
    )
    var analyticsServices: CommaSeparatedList?

    @Option(
        name: [.customLong("features")],
        help: "Feature modules (comma-separated): onboarding,push,abtesting,imageupload,none."
    )
    var features: CommaSeparatedList?

    @Option(
        name: [.customLong("preset")],
        help: "Preset configuration: minimal, standard, full."
    )
    var preset: String?

    @Option(name: [.customLong("outputDir")], help: "Output directory (default: ../ProjectName).")
    var outputDir: String?

    @Flag(name: [.customLong("programmatic")], help: "Run in programmatic JSON mode (reads JSON from stdin, writes JSON to stdout). No interactive prompts.")
    var programmatic: Bool = false

    // MARK: - Run

    mutating func run() async throws {
        if programmatic {
            try await runProgrammatic()
            return
        }

        // Load feature registry
        let allFeatures: [FeatureManifest]
        do {
            allFeatures = try FeatureRegistry.load()
        } catch {
            Console.printError("Failed to load feature registry: \(error)")
            throw ExitCode(1)
        }

        // Run wizard
        var wizard = WizardFlow(allFeatures: allFeatures, flags: self)
        guard let config = try wizard.collect() else {
            // User cancelled at review step
            print(Console.gray("Generation cancelled."))
            throw ExitCode.success
        }

        // Generation with section progress
        print()
        Console.printHeader("Generating \(config.projectName)")

        let generator = ProjectGenerator()

        do {
            // Section 1: Copy template
            Console.printStep("Copying template")
            let templateRoot = try ProjectGenerator.findTemplateRoot()

            if FileManager.default.fileExists(atPath: config.outputDir.path) {
                Console.printError("Output directory already exists: \(config.outputDir.path)")
                throw ExitCode(1)
            }
            try FileManager.default.createDirectory(at: config.outputDir, withIntermediateDirectories: true)
            var succeeded = false
            defer {
                if !succeeded { try? FileManager.default.removeItem(at: config.outputDir) }
            }

            try generator.copyTemplateFiles(from: templateRoot, to: config.outputDir)
            Console.printDone("Template copied")

            // Section 2: Embed core packages
            Console.printStep("Embedding core packages")
            try generator.copyCorePackages(templateRoot: templateRoot, to: config.outputDir)
            Console.printDone("Core packages embedded")

            // Section 3: Rename project
            Console.printStep("Renaming to \(config.projectName)")
            try TemplateEngine.apply(
                in: config.outputDir,
                oldName: "Forge",
                newName: config.projectName,
                bundleId: config.bundleId
            )
            Console.printDone("Project renamed")

            // Section 4: Fix package references
            Console.printStep("Configuring package references")
            try generator.updateLocalPackageReference(in: config.outputDir, projectName: config.projectName)
            try generator.removeStalePackageResolved(in: config.outputDir, projectName: config.projectName)
            Console.printDone("Package references configured")

            // Section 5: Configure features
            Console.printStep("Configuring features")
            try FeatureFlagWriter.apply(
                selectedFeatureIds: Set(config.resolvedFeatureIds),
                allManifests: allFeatures,
                in: config.outputDir,
                projectName: config.projectName
            )
            Console.printDone("Features configured")

            // Section 6: Write version file
            Console.printStep("Writing .template-version")
            try generator.writeTemplateVersionFile(to: config.outputDir)
            Console.printDone(".template-version written")

            // Section 5: Initialize git repository
            Console.printStep("Initializing git repository")
            do {
                try runGit(["init"], in: config.outputDir)
                try runGit(["add", "-A"], in: config.outputDir)
                try runGit(["commit", "-m", "Initial commit from Forge template"], in: config.outputDir)
                Console.printDone("Git repository initialized")
            } catch {
                print("\u{1B}[1A\u{1B}[2K  \(Console.yellow("⚠")) Git init skipped: \(error.localizedDescription)")
            }

            succeeded = true

        } catch let exitCode as ExitCode {
            throw exitCode
        } catch {
            Console.printError("Generation failed: \(error)")
            throw ExitCode(1)
        }

        // Success summary
        print()
        print("\(Console.checkmark) \(Console.bold(config.projectName)) created at \(Console.cyan(config.outputDir.path))")

        // Optional: create GitHub repo if gh CLI is available
        if isCommandAvailable("gh") {
            let createRepo = Prompts.yesNo(question: "Create GitHub repository?", defaultYes: false)
            if case .value(true) = createRepo {
                let visibilityOptions: [(label: String, value: String)] = [
                    ("Private", "private"),
                    ("Public", "public")
                ]
                let visResult = Prompts.singleSelect(prompt: "Repository visibility", options: visibilityOptions)
                if case .value(let visibility) = visResult {
                    Console.printStep("Creating GitHub repository")
                    do {
                        try runProcess(
                            "/usr/bin/env",
                            args: ["gh", "repo", "create", config.projectName,
                                   "--\(visibility)", "--source", config.outputDir.path,
                                   "--push"],
                            in: config.outputDir
                        )
                        Console.printDone("GitHub repository created and pushed")
                    } catch {
                        print("\u{1B}[1A\u{1B}[2K  \(Console.yellow("⚠")) GitHub repo creation failed: \(error.localizedDescription)")
                        print(Console.gray("  Run manually: gh repo create \(config.projectName) --\(visibility) --source . --push"))
                    }
                }
            }
        }

        // Conditional next steps (based on selected features)
        NextSteps.print(config: config, allManifests: allFeatures, outputDir: config.outputDir)

        // Open in Xcode prompt (always the last interactive item)
        let openResult = Prompts.yesNo(question: "Open in Xcode?", defaultYes: true)
        if case .value(true) = openResult {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xed")
            process.arguments = [config.outputDir.path]
            try? process.run()
            print(Console.gray("Opening \(config.projectName) in Xcode..."))
        }
        print()
    }
}

// MARK: - Git / Process Helpers

private func runGit(_ args: [String], in directory: URL) throws {
    try runProcess("/usr/bin/env", args: ["git"] + args, in: directory)
}

private func runProcess(_ executable: String, args: [String], in directory: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = args
    process.currentDirectoryURL = directory
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
        throw ProcessError.nonZeroExit(process.terminationStatus)
    }
}

private func isCommandAvailable(_ command: String) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["which", command]
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    try? process.run()
    process.waitUntilExit()
    return process.terminationStatus == 0
}

private enum ProcessError: Error, LocalizedError {
    case nonZeroExit(Int32)
    var errorDescription: String? { "Process exited with code \(self)" }
}

// MARK: - CommaSeparatedList

/// Parses comma-separated flag values: --authProviders apple,google,email
struct CommaSeparatedList: ExpressibleByArgument, Sendable {
    let values: [String]

    init?(argument: String) {
        // Allow "none" as explicit empty selection
        if argument.lowercased() == "none" {
            self.values = []
        } else {
            let parsed = argument
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                .filter { !$0.isEmpty && $0 != "none" }
            guard !parsed.isEmpty else { return nil }
            self.values = parsed
        }
    }
}
