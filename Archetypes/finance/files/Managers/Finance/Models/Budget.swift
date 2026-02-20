import Foundation
import SwiftData

// MARK: - Budget Period

enum BudgetPeriod: String, Codable, CaseIterable, Sendable {
    case monthly
    case weekly
}

// MARK: - Budget Model

@Model
final class Budget {
    var id: UUID
    var categoryId: UUID
    var monthlyLimit: Double
    var currentSpent: Double
    var periodRaw: String

    var period: BudgetPeriod {
        get { BudgetPeriod(rawValue: periodRaw) ?? .monthly }
        set { periodRaw = newValue.rawValue }
    }

    var progress: Double {
        guard monthlyLimit > 0 else { return 0 }
        return min(max(currentSpent / monthlyLimit, 0), 1)
    }

    var remaining: Double {
        max(monthlyLimit - currentSpent, 0)
    }

    init(
        id: UUID = UUID(),
        categoryId: UUID,
        monthlyLimit: Double,
        currentSpent: Double = 0,
        period: BudgetPeriod = .monthly
    ) {
        self.id = id
        self.categoryId = categoryId
        self.monthlyLimit = monthlyLimit
        self.currentSpent = currentSpent
        self.periodRaw = period.rawValue
    }
}
