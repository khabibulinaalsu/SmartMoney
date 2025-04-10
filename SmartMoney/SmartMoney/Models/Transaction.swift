import Foundation

struct Transaction: Identifiable {
    let id: UUID
    var amount: Double
    var title: String
    var description: String
    var category: Category
    var date: Date
    var cardId: UUID?
    var isExpense: Bool
}
