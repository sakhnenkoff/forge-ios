import Foundation
import SwiftUI

@MainActor
@Observable
final class FinanceManager {

    var transactions: [Transaction] = []
    var categories: [Category] = []
    var budgets: [Budget] = []

    // MARK: - Data Loading

    func loadMockData() {
        categories = Category.defaults
        transactions = FinanceMockData.generateMockTransactions(categories: categories)

        // Create budgets for categories that have a budget amount
        budgets = categories.compactMap { category in
            guard let budgetAmount = category.budgetAmount else { return nil }
            let spent = transactions
                .filter { $0.categoryId == category.id && $0.isExpense && isCurrentMonth($0.date) }
                .reduce(0) { $0 + $1.amount }
            return Budget(
                categoryId: category.id,
                monthlyLimit: budgetAmount,
                currentSpent: spent
            )
        }
    }

    // MARK: - Transaction Operations

    func addTransaction(
        amount: Double,
        categoryId: UUID,
        date: Date = .now,
        notes: String = "",
        isRecurring: Bool = false,
        recurringInterval: RecurringInterval = .none,
        type: TransactionType = .expense
    ) {
        let transaction = Transaction(
            amount: amount,
            categoryId: categoryId,
            date: date,
            notes: notes,
            isRecurring: isRecurring,
            recurringInterval: recurringInterval,
            type: type
        )
        transactions.insert(transaction, at: 0)

        // Update budget if this is an expense in the current month
        if type == .expense && isCurrentMonth(date) {
            if let index = budgets.firstIndex(where: { $0.categoryId == categoryId }) {
                budgets[index].currentSpent += amount
            }
        }
    }

    func deleteTransaction(id: UUID) {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else { return }
        let transaction = transactions[index]

        // Update budget if deleting a current month expense
        if transaction.isExpense && isCurrentMonth(transaction.date) {
            if let budgetIndex = budgets.firstIndex(where: { $0.categoryId == transaction.categoryId }) {
                budgets[budgetIndex].currentSpent = max(0, budgets[budgetIndex].currentSpent - transaction.amount)
            }
        }

        transactions.remove(at: index)
    }

    // MARK: - Aggregations

    func totalIncome(for month: Date) -> Double {
        transactions(for: month)
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    func totalExpenses(for month: Date) -> Double {
        transactions(for: month)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    func netIncome(for month: Date) -> Double {
        totalIncome(for: month) - totalExpenses(for: month)
    }

    func transactions(for month: Date) -> [Transaction] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        return transactions.filter {
            let txComponents = calendar.dateComponents([.year, .month], from: $0.date)
            return txComponents.year == components.year && txComponents.month == components.month
        }
    }

    func spendingByCategory(for month: Date) -> [(category: Category, amount: Double)] {
        let monthTransactions = transactions(for: month).filter { $0.isExpense }

        var spending: [UUID: Double] = [:]
        for transaction in monthTransactions {
            spending[transaction.categoryId, default: 0] += transaction.amount
        }

        return spending.compactMap { categoryId, amount in
            guard let category = categories.first(where: { $0.id == categoryId }) else { return nil }
            return (category: category, amount: amount)
        }
        .sorted { $0.amount > $1.amount }
    }

    // MARK: - Helpers

    func category(for id: UUID) -> Category? {
        categories.first { $0.id == id }
    }

    private func isCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.year, .month], from: .now)
        let target = calendar.dateComponents([.year, .month], from: date)
        return now.year == target.year && now.month == target.month
    }
}
