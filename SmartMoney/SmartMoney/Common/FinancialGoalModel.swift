import Foundation
import SwiftData

enum GoalStatus: String, Codable {
    case active = "Активные"
    case completed = "Завершенные"
    case frozen = "Неактивные"
}

@Model
final class FinancialGoalModel {
    var id: UUID
    var amount: Double
    var currentAmount: Double
    var title: String
    var annotation: String
    var endDate: Date?
    var status: GoalStatus
    var image: Data?
    var createdAt: Date
    
    var progress: Double {
        return min(currentAmount / amount, 1.0)
    }
    
    init(id: UUID, amount: Double, currentAmount: Double, title: String, annotation: String, endDate: Date? = nil, status: GoalStatus, image: Data?, createdAt: Date = Date()) {
        self.id = id
        self.amount = amount
        self.currentAmount = currentAmount
        self.title = title
        self.annotation = annotation
        self.endDate = endDate
        self.status = status
        self.image = image
        self.createdAt = createdAt
    }
}

