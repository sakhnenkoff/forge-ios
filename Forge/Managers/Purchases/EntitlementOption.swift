//
//  EntitlementOption.swift
//
//
//
//

// TODO: Configure your product IDs here. Delete cases you don't use.
// Product IDs must match what you've set up in App Store Connect and RevenueCat.
enum EntitlementOption: Codable, CaseIterable {
    case monthly
    case annual
    case lifetime

    var productId: String {
        switch self {
        case .monthly:
            return "organization.app.monthly"   // TODO: Replace with your monthly product ID
        case .annual:
            return "organization.app.annual"    // TODO: Replace with your annual product ID
        case .lifetime:
            return "organization.app.lifetime"  // TODO: Replace with your lifetime product ID
        }
    }

    var isSubscription: Bool {
        switch self {
        case .monthly, .annual: return true
        case .lifetime: return false
        }
    }

    static var allProductIds: [String] {
        EntitlementOption.allCases.map { $0.productId }
    }
}
