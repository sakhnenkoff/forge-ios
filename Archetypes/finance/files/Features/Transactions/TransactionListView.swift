import SwiftUI
import DesignSystem

struct TransactionListView: View {
    @State private var manager = FinanceManager()
    @State private var searchText = ""

    private var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return manager.transactions
        }
        let query = searchText.lowercased()
        return manager.transactions.filter { transaction in
            let categoryName = manager.category(for: transaction.categoryId)?.name ?? ""
            return transaction.notes.lowercased().contains(query)
                || categoryName.lowercased().contains(query)
        }
    }

    private var groupedTransactions: [(date: String, transactions: [Transaction])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            formatter.string(from: transaction.date)
        }

        return grouped
            .map { (date: $0.key, transactions: $0.value) }
            .sorted { first, second in
                guard let d1 = first.transactions.first?.date,
                      let d2 = second.transactions.first?.date else { return false }
                return d1 > d2
            }
    }

    var body: some View {
        DSScreen(title: "Transactions", contentPadding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                searchBar
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.bottom, DSSpacing.sm)

                if filteredTransactions.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Transactions Found",
                        message: searchText.isEmpty
                            ? "Add your first transaction to get started"
                            : "Try a different search term"
                    )
                    .padding(.top, DSSpacing.xl)
                } else {
                    transactionList
                }
            }
        }
        .onAppear {
            manager.loadMockData()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.textSecondary)
            TextField("Search transactions...", text: $searchText)
                .font(.bodyMedium())
                .foregroundStyle(Color.textPrimary)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smd)
        .background(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .fill(Color.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                .stroke(Color.border, lineWidth: 1)
        )
    }

    // MARK: - Transaction List

    private var transactionList: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            ForEach(groupedTransactions, id: \.date) { group in
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text(group.date)
                        .font(.captionLarge())
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, DSSpacing.md)

                    DSListCard {
                        ForEach(Array(group.transactions.enumerated()), id: \.element.id) { index, transaction in
                            if index > 0 {
                                Divider()
                            }
                            transactionRow(transaction: transaction)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            manager.deleteTransaction(id: transaction.id)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                }
            }
        }
        .padding(.top, DSSpacing.sm)
    }

    private func transactionRow(transaction: Transaction) -> some View {
        let category = manager.category(for: transaction.categoryId)
        return DSListRow(
            title: transaction.notes.isEmpty ? (category?.name ?? "Transaction") : transaction.notes,
            subtitle: category?.name,
            leadingIcon: category?.icon ?? "circle",
            leadingTint: category?.color ?? Color.textSecondary
        ) {
            Text(
                (transaction.isExpense ? "-" : "+") +
                formattedAmount(transaction.amount)
            )
            .font(.bodyMedium())
            .foregroundStyle(transaction.isExpense ? Color.textPrimary : Color.success)
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
        TransactionListView()
    }
}
