import SwiftUI
import DesignSystem

struct DashboardView: View {
    @State private var manager = FinanceManager()
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            DSScreen(title: "Dashboard") {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    monthlySummaryCard
                    budgetProgressSection
                    recentTransactionsSection
                }
            }

            addTransactionButton
        }
        .onAppear {
            manager.loadMockData()
        }
        .sheet(isPresented: $viewModel.showAddTransaction) {
            AddTransactionView(manager: manager)
        }
    }

    // MARK: - Monthly Summary

    private var monthlySummaryCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text(viewModel.monthTitle(for: viewModel.selectedMonth))
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)

                HStack(spacing: DSSpacing.lg) {
                    summaryItem(
                        title: "Income",
                        amount: manager.totalIncome(for: viewModel.selectedMonth),
                        color: Color.success
                    )

                    summaryItem(
                        title: "Expenses",
                        amount: manager.totalExpenses(for: viewModel.selectedMonth),
                        color: Color.error
                    )
                }

                Divider()

                HStack {
                    Text("Net Income")
                        .font(.bodyMedium())
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    let net = manager.netIncome(for: viewModel.selectedMonth)
                    Text(viewModel.formattedAmount(net))
                        .font(.headlineMedium())
                        .foregroundStyle(net >= 0 ? Color.success : Color.error)
                }
            }
        }
    }

    private func summaryItem(title: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(.captionLarge())
                .foregroundStyle(Color.textSecondary)
            Text(viewModel.formattedAmount(amount))
                .font(.headlineMedium())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Budget Progress

    @ViewBuilder
    private var budgetProgressSection: some View {
        let topBudgets = Array(manager.budgets.prefix(4))
        if !topBudgets.isEmpty {
            DSSection(title: "Budget Progress") {
                DSListCard {
                    ForEach(Array(topBudgets.enumerated()), id: \.element.id) { index, budget in
                        if index > 0 {
                            Divider()
                        }
                        budgetRow(budget: budget)
                    }
                }
            }
        }
    }

    private func budgetRow(budget: Budget) -> some View {
        let category = manager.category(for: budget.categoryId)
        return VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                if let category {
                    Image(systemName: category.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(category.color)
                }
                Text(category?.name ?? "Unknown")
                    .font(.bodyMedium())
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text(viewModel.formattedAmount(budget.currentSpent) + " / " + viewModel.formattedAmount(budget.monthlyLimit))
                    .font(.captionLarge())
                    .foregroundStyle(Color.textSecondary)
            }

            ProgressView(value: budget.progress)
                .tint(budget.progress > 0.9 ? Color.error : (budget.progress > 0.7 ? Color.warning : Color.success))
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smd)
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        let recent = Array(manager.transactions(for: viewModel.selectedMonth).prefix(5))
        return DSSection(title: "Recent Transactions") {
            if recent.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No Transactions",
                    message: "Add your first transaction to get started"
                )
            } else {
                DSListCard {
                    ForEach(Array(recent.enumerated()), id: \.element.id) { index, transaction in
                        if index > 0 {
                            Divider()
                        }
                        transactionRow(transaction: transaction)
                    }
                }
            }
        }
    }

    private func transactionRow(transaction: Transaction) -> some View {
        let category = manager.category(for: transaction.categoryId)
        return DSListRow(
            title: transaction.notes.isEmpty ? (category?.name ?? "Transaction") : transaction.notes,
            subtitle: transaction.date.formatted(date: .abbreviated, time: .omitted),
            leadingIcon: category?.icon ?? "circle",
            leadingTint: category?.color ?? Color.textSecondary
        ) {
            Text(
                (transaction.isExpense ? "-" : "+") +
                viewModel.formattedAmount(transaction.amount)
            )
            .font(.bodyMedium())
            .foregroundStyle(transaction.isExpense ? Color.textPrimary : Color.success)
        }
    }

    // MARK: - FAB

    private var addTransactionButton: some View {
        Button {
            viewModel.showAddTransaction = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.textOnPrimary)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.themePrimary))
                .shadow(color: Color.themePrimary.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.trailing, DSSpacing.lg)
        .padding(.bottom, DSSpacing.lg)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
