import Foundation
import SwiftData

@Model
final class TransactionModel {
    var id: UUID
    var amount: Double
    var title: String
    var annotation: String
    var dateAndTime: Date
    var isExpense: Bool
    var cardId: UUID?
    
    @Relationship(inverse: \CategoryModel.transactions)
    var category: CategoryModel?
    
    init(amount: Double, title: String, annotation: String, dateAndTime: Date, isExpense: Bool, cardId: UUID? = nil, category: CategoryModel?) {
        self.id = UUID()
        self.amount = amount
        self.title = title
        self.annotation = annotation
        self.dateAndTime = dateAndTime
        self.isExpense = isExpense
        self.cardId = cardId
        self.category = category
    }
    
    init(id: UUID, amount: Double, title: String, annotation: String, dateAndTime: Date, isExpense: Bool, cardId: UUID? = nil, category: CategoryModel?) {
        self.id = id
        self.amount = amount
        self.title = title
        self.annotation = annotation
        self.dateAndTime = dateAndTime
        self.isExpense = isExpense
        self.cardId = cardId
        self.category = category
    }
}
