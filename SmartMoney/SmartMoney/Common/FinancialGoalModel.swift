import Foundation
import SwiftData

@Model
final class FinancialGoalModel {
    var id: UUID
    var amount: Double
    var currentAmount: Double
    var title: String
    var annotation: String
    var endDate: Date?
    var status: String
    var image: Data?
    
    init(id: UUID, amount: Double, currentAmount: Double, title: String, annotation: String, endDate: Date? = nil, status: String) {
        self.id = id
        self.amount = amount
        self.currentAmount = currentAmount
        self.title = title
        self.annotation = annotation
        self.endDate = endDate
        self.status = status
    }
}
