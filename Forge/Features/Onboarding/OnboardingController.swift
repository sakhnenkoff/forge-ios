//
//  OnboardingController.swift
//  Forge
//
//

import Foundation

/// Manages onboarding flow state, collected data, and validation.
/// Extend this controller to add more data fields as needed.
@MainActor
@Observable
final class OnboardingController {
    // MARK: - Step Sequence
    //
    // Modify this computed property to add, remove, or reorder onboarding steps.
    // To enable the permissions step: set FeatureFlags.enablePushNotifications = true
    // in Configurations/FeatureFlags.swift.
    //
    // TODO: Replace this array with your app's onboarding steps.
    var steps: [OnboardingStep] {
        var all: [OnboardingStep] = [.intro1, .intro2, .intro3, .goals, .name]
        if FeatureFlags.enablePushNotifications {
            all.insert(.permissions, at: all.count - 1) // inserts before .name (last step)
        }
        return all
    }

    // MARK: - Flow State

    private(set) var currentStep: OnboardingStep = .intro1
    private(set) var stepStartTime: Date = .now

    // MARK: - Collected Data

    var selectedGoals: Set<String> = []
    var userName: String = ""

    // MARK: - Computed Properties

    private var currentIndex: Int {
        steps.firstIndex(of: currentStep) ?? 0
    }

    var canGoBack: Bool {
        currentIndex > 0
    }

    var canContinue: Bool {
        switch currentStep {
        case .intro1, .intro2, .intro3, .permissions:
            true
        case .goals:
            !selectedGoals.isEmpty
        case .name:
            userName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
        }
    }

    var isLastStep: Bool {
        currentIndex == steps.count - 1
    }

    var progress: Double {
        Double(currentIndex + 1) / Double(steps.count)
    }

    var stepDuration: TimeInterval {
        Date.now.timeIntervalSince(stepStartTime)
    }

    // MARK: - Actions

    func goBack() {
        guard canGoBack else { return }
        currentStep = steps[currentIndex - 1]
        stepStartTime = .now
    }

    /// Advances to next step. Returns true if flow is complete.
    func goNext() -> Bool {
        guard canContinue else { return false }

        if isLastStep {
            return true
        }

        currentStep = steps[currentIndex + 1]
        stepStartTime = .now
        return false
    }

    func toggleGoal(_ id: String) {
        if selectedGoals.contains(id) {
            selectedGoals.remove(id)
        } else {
            selectedGoals.insert(id)
        }
    }

    // MARK: - Analytics Data

    var flowResult: [String: Any] {
        var result: [String: Any] = [
            "goals": Array(selectedGoals).joined(separator: ","),
            "steps_completed": currentIndex + 1
        ]
        if !userName.isEmpty {
            result["user_name"] = userName
        }
        return result
    }

    func stepResult() -> [String: Any] {
        var result: [String: Any] = [
            "step_id": currentStep.analyticsId,
            "step_index": currentIndex,
            "duration": stepDuration
        ]

        switch currentStep {
        case .goals:
            result["selections"] = Array(selectedGoals)
        case .name:
            result["has_name"] = !userName.isEmpty
        case .permissions:
            result["action"] = "permissions_requested"
        default:
            break
        }

        return result
    }
}
