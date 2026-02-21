//
//  OnboardingStep.swift
//  Forge
//
//

import Foundation

/// Defines the steps in the onboarding flow.
/// Add, remove, or reorder cases to customize the flow.
enum OnboardingStep: Int, CaseIterable {
    case intro1
    case intro2
    case intro3
    case goals
    case permissions
    case name

    /// Whether this step is a text-only intro screen (no cards, centered text)
    var isTextIntro: Bool {
        switch self {
        case .intro1, .intro2, .intro3:
            return true
        case .goals, .permissions, .name:
            return false
        }
    }

    /// Analytics identifier for this step
    var analyticsId: String {
        switch self {
        case .intro1: "intro_1"
        case .intro2: "intro_2"
        case .intro3: "intro_3"
        case .goals: "goals"
        case .permissions: "permissions"
        case .name: "name"
        }
    }

    /// Title shown for progress indicators
    var title: String {
        switch self {
        case .intro1: "Welcome"
        case .intro2: "Track"
        case .intro3: "Control"
        case .goals: "Goals"
        case .permissions: "Notifications"
        case .name: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .intro1:
            return "banknote"
        case .intro2:
            return "chart.line.uptrend.xyaxis"
        case .intro3:
            return "lock.shield"
        case .goals:
            return "target"
        case .permissions:
            return "bell.badge"
        case .name:
            return "person.crop.circle"
        }
    }

    /// For text-intro screens: The main headline (multi-line, centered)
    var introHeadline: String {
        switch self {
        case .intro1:
            return "Your money,\nclear as day"
        case .intro2:
            return "Track every dollar,\neffortlessly"
        case .intro3:
            return "Take control of\nyour spending"
        case .goals, .permissions, .name:
            return ""
        }
    }

    /// For data-gathering screens: Leading text before highlight
    var headlineLeading: String {
        switch self {
        case .intro1, .intro2, .intro3:
            return ""
        case .goals:
            return "what do you want to "
        case .permissions:
            return "never miss a "
        case .name:
            return "tell us your "
        }
    }

    /// For data-gathering screens: Highlighted text
    var headlineHighlight: String {
        switch self {
        case .intro1, .intro2, .intro3:
            return ""
        case .goals:
            return "achieve"
        case .permissions:
            return "bill"
        case .name:
            return "name"
        }
    }

    /// For data-gathering screens: Trailing text after highlight
    var headlineTrailing: String {
        switch self {
        case .intro1, .intro2, .intro3:
            return ""
        case .goals:
            return " first?"
        case .permissions:
            return " again."
        case .name:
            return "."
        }
    }

    var subtitle: String {
        switch self {
        case .intro1:
            return ""
        case .intro2:
            return ""
        case .intro3:
            return ""
        case .goals:
            return "Pick a goal to personalize your dashboard."
        case .permissions:
            return "Get alerts for bills, budgets, and spending limits."
        case .name:
            return "Short, sweet, and personal."
        }
    }

    var ctaTitle: String {
        switch self {
        case .intro1:
            return "Continue"
        case .intro2:
            return "Continue"
        case .intro3:
            return "Let's go"
        case .goals:
            return "Continue"
        case .permissions:
            return "Enable alerts"
        case .name:
            return "Get started"
        }
    }
}
