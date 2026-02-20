import Foundation

struct NextSteps {

    /// Print the post-generation next steps guide.
    /// Steps are conditional on the selected features — only shows steps relevant
    /// to what was configured.
    ///
    /// - Parameters:
    ///   - config: The generation config (which features were selected).
    ///   - allManifests: All feature manifests (to check required credentials/xcconfigs).
    ///   - outputDir: Where the project was written.
    static func print(
        config: GenerationConfig,
        allManifests: [FeatureManifest],
        outputDir: URL
    ) {
        let selectedIds = Set(config.resolvedFeatureIds)
        let selectedManifests = allManifests.filter { selectedIds.contains($0.id) }
        let requiredCredentials = selectedManifests.flatMap(\.requiredCredentials)

        // Deduplicate credentials (e.g. GoogleService-Info.plist appears for both
        // firebase-analytics and crashlytics)
        var seen = Set<String>()
        let uniqueCredentials = requiredCredentials.filter { seen.insert($0.name).inserted }

        // All xcconfig keys from selected features
        let allXcconfigs = selectedManifests.flatMap(\.xcconfigs)

        Swift.print()
        Console.printHeader("Next Steps")

        var stepNum = 1

        // Step 1: Always — open in Xcode
        Swift.print("  \(Console.bold("\(stepNum).")) Open \(Console.cyan("\(config.projectName).xcodeproj")) in Xcode")
        stepNum += 1

        // Credential steps (conditional on selected features)
        if !uniqueCredentials.isEmpty {
            Swift.print("  \(Console.bold("\(stepNum).")) Add your credentials:")
            stepNum += 1
            for credential in uniqueCredentials {
                Swift.print("     \(Console.gray("•")) \(Console.bold(credential.name))")
                Swift.print("       \(Console.gray(credential.source))")
            }
        }

        // xcconfig keys (conditional)
        if !allXcconfigs.isEmpty {
            Swift.print("  \(Console.bold("\(stepNum).")) Open \(Console.cyan("Configurations/Secrets.xcconfig.local")) and add:")
            stepNum += 1
            for xcconfig in allXcconfigs {
                Swift.print("     \(Console.gray("•")) \(xcconfig.key) = <your value>  \(Console.gray("// \(xcconfig.description)"))")
            }
        }

        // Always: run Mock build first
        Swift.print("  \(Console.bold("\(stepNum).")) Select the \(Console.cyan("Mock")) scheme and run \(Console.bold("⌘R")) to verify without backend dependencies")
        stepNum += 1

        // Firebase-specific: plist placement guidance
        let firebaseIds: Set<String> = ["firebase-analytics", "crashlytics", "push-notifications"]
        if !selectedIds.isDisjoint(with: firebaseIds) {
            Swift.print("  \(Console.bold("\(stepNum).")) Place your \(Console.cyan("GoogleService-Info-Dev.plist")) and \(Console.cyan("GoogleService-Info-Prod.plist")) in:")
            Swift.print("     \(Console.gray(outputDir.appendingPathComponent("\(config.projectName)/SupportingFiles/GoogleServicePlists/").path))")
            stepNum += 1
        }

        Swift.print()
        Swift.print(Console.gray("  Full setup guide: docs/getting-started.md"))
        Swift.print()
    }
}
