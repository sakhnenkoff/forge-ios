import ArgumentParser
import Foundation

// MARK: - Programmatic I/O Types

/// Input schema for --programmatic mode. Mirrors GenerationConfig fields.
/// All fields are Optional at the Decodable level — required fields are validated at runtime.
/// Unknown fields in the JSON input are silently ignored (forward-compatible).
struct ProgrammaticInput: Decodable {
    let projectName: String?
    let bundleId: String?
    /// Auth providers: "apple", "google", "email", "anonymous"
    let authProviders: [String]?
    /// Monetization model: "subscription", "onetime", "free"
    let monetizationModel: String?
    /// Analytics services (CLI shorthand accepted): "firebase", "mixpanel", "crashlytics"
    let analyticsServices: [String]?
    /// Feature modules (CLI shorthand accepted): "onboarding", "push", "abtesting", "imageupload"
    let features: [String]?
    /// Output directory. Default: ../projectName relative to CWD
    let outputDir: String?
}

/// Machine-readable error payload for programmatic mode.
struct ProgrammaticError: Encodable {
    /// String code, e.g. "MISSING_FIELD", "INVALID_BUNDLE_ID". See error code reference.
    let code: String
    /// Human-readable description of what went wrong.
    let message: String
    /// Which input field caused the error, if applicable. Null for pipeline errors.
    let field: String?
}

/// JSON output written to stdout in programmatic mode.
struct ProgrammaticResult: Encodable {
    let success: Bool
    let projectName: String?
    let outputDir: String?
    /// Relative paths of all files created in the output directory. Null on failure.
    let filesWritten: [String]?
    let error: ProgrammaticError?
}

// MARK: - GenerateCommand Extension

extension GenerateCommand {

    /// Entry point for --programmatic mode.
    /// Reads one JSON object from stdin, generates the project, writes one JSON result to stdout.
    /// Suppresses all human-facing output (ANSI, progress, prompts).
    mutating func runProgrammatic() async throws {

        // Step 1: Read all of stdin
        let inputData = FileHandle.standardInput.readDataToEndOfFile()
        guard !inputData.isEmpty else {
            writeResult(ProgrammaticResult(
                success: false, projectName: nil, outputDir: nil, filesWritten: nil,
                error: ProgrammaticError(
                    code: "STDIN_READ_ERROR",
                    message: "No input received on stdin. Pipe JSON input: echo '{...}' | forge --programmatic",
                    field: nil
                )
            ))
            throw ExitCode(2)
        }

        // Step 2: Decode JSON — Swift Decodable ignores unknown fields by default
        let input: ProgrammaticInput
        do {
            input = try JSONDecoder().decode(ProgrammaticInput.self, from: inputData)
        } catch {
            writeResult(ProgrammaticResult(
                success: false, projectName: nil, outputDir: nil, filesWritten: nil,
                error: ProgrammaticError(
                    code: "INVALID_JSON",
                    message: "Could not parse JSON input: \(error.localizedDescription)",
                    field: nil
                )
            ))
            throw ExitCode(2)
        }

        // Step 3: Validate required fields (all except outputDir are required)
        guard let projectName = input.projectName, !projectName.isEmpty else {
            writeResult(missingField("projectName"))
            throw ExitCode(1)
        }
        guard let bundleId = input.bundleId, !bundleId.isEmpty else {
            writeResult(missingField("bundleId"))
            throw ExitCode(1)
        }
        guard let authProviderStrings = input.authProviders else {
            writeResult(missingField("authProviders"))
            throw ExitCode(1)
        }
        guard let monetizationString = input.monetizationModel, !monetizationString.isEmpty else {
            writeResult(missingField("monetizationModel"))
            throw ExitCode(1)
        }
        guard let analyticsStrings = input.analyticsServices else {
            writeResult(missingField("analyticsServices"))
            throw ExitCode(1)
        }
        guard let featureStrings = input.features else {
            writeResult(missingField("features"))
            throw ExitCode(1)
        }

        // Step 4: Validate projectName format
        guard projectName.range(of: "^[a-zA-Z][a-zA-Z0-9_]*$", options: .regularExpression) != nil else {
            writeResult(ProgrammaticResult(
                success: false, projectName: nil, outputDir: nil, filesWritten: nil,
                error: ProgrammaticError(
                    code: "INVALID_PROJECT_NAME",
                    message: "projectName must start with a letter and contain only letters, numbers, and underscores (e.g. MyApp)",
                    field: "projectName"
                )
            ))
            throw ExitCode(1)
        }

        // Step 5: Validate bundleId — reverse-domain format, ≥2 segments, letters/numbers/hyphens per segment
        let bundleParts = bundleId.split(separator: ".")
        let bundleValid = bundleParts.count >= 2 && bundleParts.allSatisfy { part in
            !part.isEmpty && part.allSatisfy { $0.isLetter || $0.isNumber || $0 == "-" }
        }
        guard bundleValid else {
            writeResult(ProgrammaticResult(
                success: false, projectName: nil, outputDir: nil, filesWritten: nil,
                error: ProgrammaticError(
                    code: "INVALID_BUNDLE_ID",
                    message: "bundleId must be reverse-domain format (e.g. com.company.app). Segments contain only letters, numbers, hyphens.",
                    field: "bundleId"
                )
            ))
            throw ExitCode(1)
        }

        // Step 6: Validate auth providers — at least one required
        guard !authProviderStrings.isEmpty else {
            writeResult(ProgrammaticResult(
                success: false, projectName: nil, outputDir: nil, filesWritten: nil,
                error: ProgrammaticError(
                    code: "AUTH_PROVIDERS_REQUIRED",
                    message: "authProviders must contain at least one provider. Valid: apple, google, email, anonymous",
                    field: "authProviders"
                )
            ))
            throw ExitCode(1)
        }
        var authProviders: [GenerationConfig.AuthProvider] = []
        for s in authProviderStrings {
            guard let p = GenerationConfig.AuthProvider(rawValue: s) else {
                writeResult(ProgrammaticResult(
                    success: false, projectName: nil, outputDir: nil, filesWritten: nil,
                    error: ProgrammaticError(
                        code: "INVALID_AUTH_PROVIDER",
                        message: "Unknown auth provider '\(s)'. Valid values: apple, google, email, anonymous",
                        field: "authProviders"
                    )
                ))
                throw ExitCode(1)
            }
            authProviders.append(p)
        }

        // Step 7: Validate monetization model
        guard let monetization = GenerationConfig.MonetizationModel(rawValue: monetizationString) else {
            writeResult(ProgrammaticResult(
                success: false, projectName: nil, outputDir: nil, filesWritten: nil,
                error: ProgrammaticError(
                    code: "INVALID_MONETIZATION_MODEL",
                    message: "Unknown monetizationModel '\(monetizationString)'. Valid values: subscription, onetime, free",
                    field: "monetizationModel"
                )
            ))
            throw ExitCode(1)
        }

        // Step 8: Load feature registry
        let allFeatures: [FeatureManifest]
        do {
            allFeatures = try FeatureRegistry.load()
        } catch {
            writeResult(ProgrammaticResult(
                success: false, projectName: nil, outputDir: nil, filesWritten: nil,
                error: ProgrammaticError(
                    code: "REGISTRY_LOAD_ERROR",
                    message: "Failed to load feature registry: \(error)",
                    field: nil
                )
            ))
            throw ExitCode(1)
        }

        // Step 9: Normalize shorthand feature IDs → registry IDs, then validate
        let normalizedAnalytics = analyticsStrings.map { Self.normalizeFeatureId($0) }
        let normalizedFeatures = featureStrings.map { Self.normalizeFeatureId($0) }
        let allKnownIds = Set(allFeatures.map(\.id))
        for id in normalizedAnalytics + normalizedFeatures {
            guard allKnownIds.contains(id) else {
                writeResult(ProgrammaticResult(
                    success: false, projectName: nil, outputDir: nil, filesWritten: nil,
                    error: ProgrammaticError(
                        code: "INVALID_FEATURE_ID",
                        message: "Unknown feature ID '\(id)'. Valid analytics: firebase, mixpanel, crashlytics. Valid features: onboarding, push, abtesting, imageupload",
                        field: "features"
                    )
                ))
                throw ExitCode(1)
            }
        }

        // Step 10: Resolve output directory
        let outputDirURL: URL
        if let od = input.outputDir {
            outputDirURL = URL(fileURLWithPath: od)
        } else {
            let parent = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .deletingLastPathComponent()
            outputDirURL = parent.appendingPathComponent(projectName)
        }

        // Step 11: Check output directory does not already exist
        if FileManager.default.fileExists(atPath: outputDirURL.path) {
            writeResult(ProgrammaticResult(
                success: false, projectName: projectName, outputDir: outputDirURL.path, filesWritten: nil,
                error: ProgrammaticError(
                    code: "OUTPUT_DIR_EXISTS",
                    message: "Output directory already exists: \(outputDirURL.path). Choose a different path or remove the existing directory.",
                    field: "outputDir"
                )
            ))
            throw ExitCode(1)
        }

        // Step 12: Resolve feature dependencies
        var allSelectedIds: [String] = normalizedAnalytics + normalizedFeatures
        if monetization.requiresPurchases && !allSelectedIds.contains("revenuecat") {
            allSelectedIds.append("revenuecat")
        }
        let resolution: DependencyResolver.Resolution
        do {
            resolution = try DependencyResolver.resolve(selected: allSelectedIds, all: allFeatures)
        } catch {
            writeResult(ProgrammaticResult(
                success: false, projectName: projectName, outputDir: outputDirURL.path, filesWritten: nil,
                error: ProgrammaticError(
                    code: "GENERATION_FAILED",
                    message: "Dependency resolution failed: \(error)",
                    field: nil
                )
            ))
            throw ExitCode(1)
        }

        let config = GenerationConfig(
            projectName: projectName,
            bundleId: bundleId,
            authProviders: authProviders,
            monetizationModel: monetization,
            analyticsFeatureIds: normalizedAnalytics,
            featureModuleIds: normalizedFeatures,
            resolvedFeatureIds: resolution.resolved,
            outputDir: outputDirURL
        )

        // Step 13: Run generation pipeline (reuses ProjectGenerator.generate())
        do {
            let generator = ProjectGenerator()
            try generator.generate(config: config, allManifests: allFeatures)
        } catch let genError as GeneratorError {
            writeResult(ProgrammaticResult(
                success: false, projectName: projectName, outputDir: outputDirURL.path, filesWritten: nil,
                error: ProgrammaticError(
                    code: "OUTPUT_DIR_EXISTS",
                    message: genError.description,
                    field: "outputDir"
                )
            ))
            throw ExitCode(1)
        } catch let templateError as TemplateError {
            writeResult(ProgrammaticResult(
                success: false, projectName: projectName, outputDir: outputDirURL.path, filesWritten: nil,
                error: ProgrammaticError(
                    code: "TEMPLATE_NOT_FOUND",
                    message: "Template root not found: \(templateError)",
                    field: nil
                )
            ))
            throw ExitCode(1)
        } catch {
            writeResult(ProgrammaticResult(
                success: false, projectName: projectName, outputDir: outputDirURL.path, filesWritten: nil,
                error: ProgrammaticError(
                    code: "GENERATION_FAILED",
                    message: "Generation failed: \(error.localizedDescription)",
                    field: nil
                )
            ))
            throw ExitCode(1)
        }

        // Step 14: Collect files_written by walking the output directory (sync helper avoids async isolation issue)
        let filesWritten = Self.collectFilesWritten(in: outputDirURL).sorted()

        // Step 15: Write success result to stdout
        writeResult(ProgrammaticResult(
            success: true,
            projectName: projectName,
            outputDir: outputDirURL.path,
            filesWritten: filesWritten,
            error: nil
        ))
    }

    // MARK: - Private Helpers

    /// Emit a MISSING_FIELD error result (does not throw — caller throws after).
    private func missingField(_ field: String) -> ProgrammaticResult {
        ProgrammaticResult(
            success: false, projectName: nil, outputDir: nil, filesWritten: nil,
            error: ProgrammaticError(
                code: "MISSING_FIELD",
                message: "Required field '\(field)' is missing or null",
                field: field
            )
        )
    }

    /// Write a ProgrammaticResult as pretty-printed JSON to stdout.
    private func writeResult(_ result: ProgrammaticResult) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(result),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        }
    }

    /// Collect all file paths under outputDir as paths relative to outputDir.
    /// Uses FileManager.subpaths(atPath:) which is synchronous and non-async.
    private static func collectFilesWritten(in outputDir: URL) -> [String] {
        let fm = FileManager.default
        let dirPath = outputDir.path
        guard let subpaths = fm.subpaths(atPath: dirPath) else { return [] }
        // Filter to regular files only (exclude directories)
        return subpaths.filter { rel in
            var isDir: ObjCBool = false
            fm.fileExists(atPath: (dirPath as NSString).appendingPathComponent(rel), isDirectory: &isDir)
            return !isDir.boolValue
        }
    }

    /// Map CLI shorthand feature IDs to registry IDs.
    /// Matches WizardFlow.normalizeFeatureId(_:) — keep in sync.
    private static func normalizeFeatureId(_ id: String) -> String {
        switch id {
        case "firebase":    return "firebase-analytics"
        case "push":        return "push-notifications"
        case "abtesting":   return "ab-testing"
        case "imageupload": return "image-upload"
        default:            return id
        }
    }
}
