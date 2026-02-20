import SwiftUI
import DesignSystem

struct BudgetsView: View {
    @State private var manager = FinanceManager()
    @State private var showAddBudget = false

    var body: some View {
        DSScreen(title: "Budgets") {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                overviewCard
                budgetListSection
            }
        }
        .onAppear {
            manager.loadMockData()
        }
        .sheet(isPresented: $showAddBudget) {
            addBudgetSheet
        }
    }

    // MARK: - Overview Card

    private var overviewCard: some View {
        let totalBudget = manager.budgets.reduce(0) { $0 + $1.monthlyLimit }
        let totalSpent = manager.budgets.reduce(0) { $0 + $1.currentSpent }
        let overallProgress = totalBudget > 0 ? min(totalSpent / totalBudget, 1) : 0

        return DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                Text("Monthly Overview")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)

                HStack {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Total Spent")
                            .font(.captionLarge())
                            .foregroundStyle(Color.textSecondary)
                        Text(formattedAmount(totalSpent))
                            .font(.titleSmall())
                            .foregroundStyle(Color.textPrimary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: DSSpacing.xs) {
                        Text("Total Budget")
                            .font(.captionLarge())
                            .foregroundStyle(Color.textSecondary)
                        Text(formattedAmount(totalBudget))
                            .font(.titleSmall())
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                ProgressView(value: overallProgress)
                    .tint(overallProgress > 0.9 ? Color.error : (overallProgress > 0.7 ? Color.warning : Color.success))

                Text(formattedAmount(max(totalBudget - totalSpent, 0)) + " remaining")
                    .font(.captionLarge())
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    // MARK: - Budget List

    private var budgetListSection: some View {
        DSSection(title: "Category Budgets") {
            if manager.budgets.isEmpty {
                EmptyStateView(
                    icon: "chart.bar",
                    title: "No Budgets",
                    message: "Create budgets to track your spending by category",
                    actionTitle: "Add Budget",
                    action: { showAddBudget = true }
                )
            } else {
                DSListCard {
                    ForEach(Array(manager.budgets.enumerated()), id: \.element.id) { index, budget in
                        if index > 0 {
                            Divider()
                        }
                        budgetRow(budget: budget)
                    }
                }

                DSButton(
                    title: "Add Budget",
                    icon: "plus",
                    style: .secondary,
                    isFullWidth: true
                ) {
                    showAddBudget = true
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
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(category.color)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadii.sm, style: .continuous)
                                .fill(category.color.opacity(0.12))
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(category?.name ?? "Unknown")
                        .font(.bodyMedium())
                        .foregroundStyle(Color.textPrimary)
                    Text(budget.period.rawValue.capitalized)
                        .font(.captionLarge())
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formattedAmount(budget.currentSpent))
                        .font(.bodyMedium())
                        .foregroundStyle(budget.progress > 0.9 ? Color.error : Color.textPrimary)
                    Text("of " + formattedAmount(budget.monthlyLimit))
                        .font(.captionLarge())
                        .foregroundStyle(Color.textSecondary)
                }
            }

            ProgressView(value: budget.progress)
                .tint(progressColor(for: budget.progress))

            if budget.progress > 0.9 {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.warning)
                    Text(budget.progress >= 1.0 ? "Over budget!" : "Almost at limit")
                        .font(.captionLarge())
                        .foregroundStyle(Color.warning)
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smd)
    }

    // MARK: - Add Budget Sheet

    private var addBudgetSheet: some View {
        NavigationStack {
            DSScreen(title: "Add Budget") {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    Text("Select a category and set a monthly spending limit.")
                        .font(.bodyMedium())
                        .foregroundStyle(Color.textSecondary)

                    ForEach(manager.categories, id: \.id) { category in
                        let hasBudget = manager.budgets.contains { $0.categoryId == category.id }
                        DSListRow(
                            title: category.name,
                            subtitle: hasBudget ? "Budget set" : nil,
                            leadingIcon: category.icon,
                            leadingTint: category.color
                        ) {
                            if hasBudget {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.success)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showAddBudget = false }
                }
            }
        }
    }

    // MARK: - Helpers

    private func progressColor(for progress: Double) -> Color {
        if progress > 0.9 { return Color.error }
        if progress > 0.7 { return Color.warning }
        return Color.success
    }

    private func formattedAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

#Preview {
    NavigationStack {
        BudgetsView()
    }
}
