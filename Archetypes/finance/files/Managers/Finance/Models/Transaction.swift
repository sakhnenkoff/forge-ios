import Foundation
import SwiftData

// MARK: - Transaction Type

enum TransactionType: String, Codable, CaseIterable, Sendable {
    case income
    case expense
}

// MARK: - Recurring Interval

enum RecurringInterval: String, Codable, CaseIterable, Sendable {
    case none
    case daily
    case weekly
    case monthly
    case yearly
}

// MARK: - Transaction Model

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var categoryId: UUID
    var date: Date
    var notes: String
    var isRecurring: Bool
    var recurringIntervalRaw: String
    var typeRaw: String

    var recurringInterval: RecurringInterval {
        get { RecurringInterval(rawValue: recurringIntervalRaw) ?? .none }
        set { recurringIntervalRaw = newValue.rawValue }
    }

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    var isExpense: Bool {
        type == .expense
    }

    init(
        id: UUID = UUID(),
        amount: Double,
        categoryId: UUID,
        date: Date = .now,
        notes: String = "",
        isRecurring: Bool = false,
        recurringInterval: RecurringInterval = .none,
        type: TransactionType = .expense
    ) {
        self.id = id
        self.amount = amount
        self.categoryId = categoryId
        self.date = date
        self.notes = notes
        self.isRecurring = isRecurring
        self.recurringIntervalRaw = recurringInterval.rawValue
        self.typeRaw = type.rawValue
    }
}
