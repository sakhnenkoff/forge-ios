import SwiftUI
import DesignSystem

struct AddTransactionView: View {
    var manager: FinanceManager

    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var transactionType: TransactionType = .expense
    @State private var selectedCategoryId: UUID?
    @State private var date: Date = .now
    @State private var notes: String = ""
    @State private var isRecurring: Bool = false
    @State private var recurringInterval: RecurringInterval = .monthly

    private let columns = Array(repeating: GridItem(.flexible(), spacing: DSSpacing.sm), count: 4)

    private var amount: Double {
        Double(amountText) ?? 0
    }

    private var isValid: Bool {
        amount > 0 && selectedCategoryId != nil
    }

    var body: some View {
        NavigationStack {
            DSScreen(title: "Add Transaction", scrollDismissesKeyboard: .interactively) {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    amountInput
                    transactionTypeSelector
                    categoryPicker
                    dateSection
                    notesSection
                    recurringSection
                    addButton
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Amount Input

    private var amountInput: some View {
        VStack(spacing: DSSpacing.sm) {
            Text("$")
                .font(.titleLarge())
                .foregroundStyle(Color.textSecondary)
            +
            Text(amountText.isEmpty ? "0" : amountText)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .overlay {
            TextField("", text: $amountText)
                .keyboardType(.decimalPad)
                .opacity(0.01)
                .frame(width: 1, height: 1)
        }
        .onTapGesture {
            // Focus triggers via the hidden text field overlay
        }
    }

    // MARK: - Transaction Type

    private var transactionTypeSelector: some View {
        DSSegmentedControl(
            items: TransactionType.allCases,
            selection: $transactionType,
            labelProvider: { type in
                switch type {
                case .expense: "Expense"
                case .income: "Income"
                }
            }
        )
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        DSSection(title: "Category") {
            LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                ForEach(manager.categories, id: \.id) { category in
                    categoryCell(category: category)
                }
            }
        }
    }

    private func categoryCell(category: Category) -> some View {
        let isSelected = selectedCategoryId == category.id

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategoryId = category.id
            }
        } label: {
            VStack(spacing: DSSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.textOnPrimary : category.color)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                            .fill(isSelected ? category.color : category.color.opacity(0.12))
                    )

                Text(category.name)
                    .font(.captionLarge())
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Date Picker

    private var dateSection: some View {
        DSSection(title: "Date") {
            DatePicker(
                "Transaction date",
                selection: $date,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        DSSection(title: "Notes") {
            DSTextField(
                placeholder: "Add a note...",
                text: $notes,
                icon: "pencil"
            )
        }
    }

    // MARK: - Recurring

    private var recurringSection: some View {
        DSSection(title: "Recurring") {
            DSListCard {
                Toggle(isOn: $isRecurring) {
                    HStack(spacing: DSSpacing.smd) {
                        Image(systemName: "repeat")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                        Text("Repeat transaction")
                            .font(.bodyMedium())
                            .foregroundStyle(Color.textPrimary)
                    }
                }
                .tint(Color.themePrimary)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.smd)

                if isRecurring {
                    Divider()
                    intervalPicker
                }
            }
        }
    }

    private var intervalPicker: some View {
        VStack(spacing: DSSpacing.sm) {
            ForEach(RecurringInterval.allCases.filter { $0 != .none }, id: \.self) { interval in
                DSChoiceButton(
                    title: interval.rawValue.capitalized,
                    isSelected: recurringInterval == interval
                ) {
                    recurringInterval = interval
                }
            }
        }
        .padding(DSSpacing.md)
    }

    // MARK: - Add Button

    private var addButton: some View {
        DSButton.cta(
            title: "Add Transaction",
            icon: "plus",
            isEnabled: isValid
        ) {
            manager.addTransaction(
                amount: amount,
                categoryId: selectedCategoryId ?? UUID(),
                date: date,
                notes: notes,
                isRecurring: isRecurring,
                recurringInterval: isRecurring ? recurringInterval : .none,
                type: transactionType
            )
            dismiss()
        }
    }
}

#Preview {
    AddTransactionView(manager: FinanceManager())
}
