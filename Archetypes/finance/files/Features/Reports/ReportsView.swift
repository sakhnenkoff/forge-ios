import SwiftUI
import Charts
import DesignSystem

struct ReportsView: View {
    @State private var manager = FinanceManager()
    @State private var selectedMonth: Date = .now

    private var spendingData: [(category: Category, amount: Double)] {
        manager.spendingByCategory(for: selectedMonth)
    }

    private var monthlyTrendData: [(month: Date, income: Double, expenses: Double)] {
        let calendar = Calendar.current
        return (0..<6).reversed().compactMap { offset in
            guard let month = calendar.date(byAdding: .month, value: -offset, to: .now) else { return nil }
            return (
                month: month,
                income: manager.totalIncome(for: month),
                expenses: manager.totalExpenses(for: month)
            )
        }
    }

    var body: some View {
        DSScreen(title: "Reports") {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                dateRangeSelector
                spendingByCategoryChart
                monthlyTrendChart
            }
        }
        .onAppear {
            manager.loadMockData()
        }
    }

    // MARK: - Date Range Selector

    private var dateRangeSelector: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Text(monthTitle)
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.horizontal, DSSpacing.sm)
    }

    // MARK: - Spending by Category Donut Chart

    private var spendingByCategoryChart: some View {
        DSSection(title: "Spending by Category") {
            DSCard {
                if spendingData.isEmpty {
                    Text("No spending data for this month")
                        .font(.bodyMedium())
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, DSSpacing.xl)
                } else {
                    VStack(spacing: DSSpacing.md) {
                        Chart(spendingData, id: \.category.id) { item in
                            SectorMark(
                                angle: .value("Amount", item.amount),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(item.category.color)
                            .cornerRadius(4)
                        }
                        .frame(height: 200)

                        // Legend
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ],
                            spacing: DSSpacing.sm
                        ) {
                            ForEach(spendingData, id: \.category.id) { item in
                                HStack(spacing: DSSpacing.xs) {
                                    Circle()
                                        .fill(item.category.color)
                                        .frame(width: 8, height: 8)
                                    Text(item.category.name)
                                        .font(.captionLarge())
                                        .foregroundStyle(Color.textSecondary)
                                    Spacer()
                                    Text(formattedAmount(item.amount))
                                        .font(.captionLarge())
                                        .foregroundStyle(Color.textPrimary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Monthly Trend Line Chart

    private var monthlyTrendChart: some View {
        DSSection(title: "Monthly Trend") {
            DSCard {
                if monthlyTrendData.isEmpty {
                    Text("Not enough data to show trends")
                        .font(.bodyMedium())
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, DSSpacing.xl)
                } else {
                    VStack(spacing: DSSpacing.md) {
                        Chart {
                            ForEach(monthlyTrendData, id: \.month) { data in
                                LineMark(
                                    x: .value("Month", data.month, unit: .month),
                                    y: .value("Amount", data.income)
                                )
                                .foregroundStyle(Color.success)
                                .symbol(Circle())
                                .interpolationMethod(.catmullRom)

                                LineMark(
                                    x: .value("Month", data.month, unit: .month),
                                    y: .value("Amount", data.expenses)
                                )
                                .foregroundStyle(Color.error)
                                .symbol(Circle())
                                .interpolationMethod(.catmullRom)
                            }
                        }
                        .chartForegroundStyleScale([
                            "Income": Color.success,
                            "Expenses": Color.error,
                        ])
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .month)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.month(.abbreviated))
                            }
                        }
                        .frame(height: 200)

                        // Legend
                        HStack(spacing: DSSpacing.lg) {
                            legendItem(color: Color.success, label: "Income")
                            legendItem(color: Color.error, label: "Expenses")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: DSSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.captionLarge())
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Helpers

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    private func moveMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation {
                selectedMonth = newMonth
            }
        }
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
        ReportsView()
    }
}
