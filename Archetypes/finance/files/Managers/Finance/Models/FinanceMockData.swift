import Foundation

enum FinanceMockData {

    static func generateMockTransactions(categories: [Category]) -> [Transaction] {
        var transactions: [Transaction] = []

        guard !categories.isEmpty else { return transactions }

        let foodId = categories.first { $0.name == "Food" }?.id ?? categories[0].id
        let transportId = categories.first { $0.name == "Transport" }?.id ?? categories[0].id
        let entertainmentId = categories.first { $0.name == "Entertainment" }?.id ?? categories[0].id
        let shoppingId = categories.first { $0.name == "Shopping" }?.id ?? categories[0].id
        let billsId = categories.first { $0.name == "Bills" }?.id ?? categories[0].id
        let healthId = categories.first { $0.name == "Health" }?.id ?? categories[0].id
        let educationId = categories.first { $0.name == "Education" }?.id ?? categories[0].id
        let otherId = categories.first { $0.name == "Other" }?.id ?? categories[0].id

        // Income category placeholder (use "Other" for income)
        let incomeId = otherId

        // Generate 3 months of data
        for monthOffset in 0..<3 {
            let baseDay = Double(monthOffset * 30)

            // Monthly salary
            transactions.append(
                Transaction(
                    amount: Double.random(in: 3500...4500),
                    categoryId: incomeId,
                    date: Date.now.addingTimeInterval(-(baseDay + 1) * 86400),
                    notes: "Monthly salary",
                    type: .income
                )
            )

            // Freelance income (some months)
            if monthOffset != 1 {
                transactions.append(
                    Transaction(
                        amount: Double.random(in: 500...1500),
                        categoryId: incomeId,
                        date: Date.now.addingTimeInterval(-(baseDay + 15) * 86400),
                        notes: "Freelance project",
                        type: .income
                    )
                )
            }

            // Food expenses (8-10 per month)
            let foodNotes = ["Grocery store", "Restaurant dinner", "Coffee shop", "Takeout lunch", "Bakery"]
            for i in 0..<Int.random(in: 8...10) {
                transactions.append(
                    Transaction(
                        amount: Double.random(in: 8...85),
                        categoryId: foodId,
                        date: Date.now.addingTimeInterval(-(baseDay + Double(i * 3)) * 86400),
                        notes: foodNotes[i % foodNotes.count],
                        type: .expense
                    )
                )
            }

            // Transport expenses (4-6 per month)
            let transportNotes = ["Gas station", "Uber ride", "Bus pass", "Parking", "Car wash"]
            for i in 0..<Int.random(in: 4...6) {
                transactions.append(
                    Transaction(
                        amount: Double.random(in: 10...60),
                        categoryId: transportId,
                        date: Date.now.addingTimeInterval(-(baseDay + Double(i * 5 + 1)) * 86400),
                        notes: transportNotes[i % transportNotes.count],
                        type: .expense
                    )
                )
            }

            // Entertainment (2-4 per month)
            let entertainmentNotes = ["Movie tickets", "Streaming subscription", "Concert", "Game purchase"]
            for i in 0..<Int.random(in: 2...4) {
                transactions.append(
                    Transaction(
                        amount: Double.random(in: 10...50),
                        categoryId: entertainmentId,
                        date: Date.now.addingTimeInterval(-(baseDay + Double(i * 7 + 2)) * 86400),
                        notes: entertainmentNotes[i % entertainmentNotes.count],
                        type: .expense
                    )
                )
            }

            // Shopping (2-3 per month)
            let shoppingNotes = ["Amazon order", "Clothing store", "Electronics"]
            for i in 0..<Int.random(in: 2...3) {
                transactions.append(
                    Transaction(
                        amount: Double.random(in: 25...200),
                        categoryId: shoppingId,
                        date: Date.now.addingTimeInterval(-(baseDay + Double(i * 10 + 3)) * 86400),
                        notes: shoppingNotes[i % shoppingNotes.count],
                        type: .expense
                    )
                )
            }

            // Bills (2-3 per month)
            let billNotes = ["Electric bill", "Internet", "Phone plan", "Insurance"]
            for i in 0..<Int.random(in: 2...3) {
                transactions.append(
                    Transaction(
                        amount: Double.random(in: 50...200),
                        categoryId: billsId,
                        date: Date.now.addingTimeInterval(-(baseDay + Double(i * 10 + 5)) * 86400),
                        notes: billNotes[i % billNotes.count],
                        isRecurring: true,
                        recurringInterval: .monthly,
                        type: .expense
                    )
                )
            }

            // Health (1-2 per month)
            let healthNotes = ["Pharmacy", "Gym membership", "Doctor visit"]
            for i in 0..<Int.random(in: 1...2) {
                transactions.append(
                    Transaction(
                        amount: Double.random(in: 20...150),
                        categoryId: healthId,
                        date: Date.now.addingTimeInterval(-(baseDay + Double(i * 14 + 4)) * 86400),
                        notes: healthNotes[i % healthNotes.count],
                        type: .expense
                    )
                )
            }

            // Education (0-1 per month)
            if Bool.random() {
                transactions.append(
                    Transaction(
                        amount: Double.random(in: 15...100),
                        categoryId: educationId,
                        date: Date.now.addingTimeInterval(-(baseDay + 12) * 86400),
                        notes: "Online course",
                        type: .expense
                    )
                )
            }
        }

        return transactions.sorted { $0.date > $1.date }
    }
}
