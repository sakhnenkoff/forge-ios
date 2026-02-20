import Foundation
import SwiftUI
import SwiftData
import DesignSystem

@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isDefault: Bool
    var budgetAmount: Double?

    var color: Color {
        Color(hex: colorHex)
    }

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        isDefault: Bool = false,
        budgetAmount: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.budgetAmount = budgetAmount
    }

    static var defaults: [Category] {
        [
            Category(
                name: "Food",
                icon: "fork.knife",
                colorHex: "#FF6B6B",
                isDefault: true,
                budgetAmount: 500
            ),
            Category(
                name: "Transport",
                icon: "car.fill",
                colorHex: "#4ECDC4",
                isDefault: true,
                budgetAmount: 200
            ),
            Category(
                name: "Entertainment",
                icon: "tv.fill",
                colorHex: "#45B7D1",
                isDefault: true,
                budgetAmount: 150
            ),
            Category(
                name: "Shopping",
                icon: "bag.fill",
                colorHex: "#F7DC6F",
                isDefault: true,
                budgetAmount: 300
            ),
            Category(
                name: "Bills",
                icon: "doc.text.fill",
                colorHex: "#BB8FCE",
                isDefault: true,
                budgetAmount: 800
            ),
            Category(
                name: "Health",
                icon: "heart.fill",
                colorHex: "#E74C3C",
                isDefault: true,
                budgetAmount: 200
            ),
            Category(
                name: "Education",
                icon: "book.fill",
                colorHex: "#3498DB",
                isDefault: true,
                budgetAmount: 100
            ),
            Category(
                name: "Other",
                icon: "ellipsis.circle.fill",
                colorHex: "#95A5A6",
                isDefault: true
            ),
        ]
    }
}
