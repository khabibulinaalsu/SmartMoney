import Foundation
import SwiftData

enum GoalStatus: String, Codable {
    case active = "Active"
    case completed = "Completed"
    case frozen = "Frozen"
}

@Model
class FinancialGoal {
    var id: UUID
    var title: String
    var annotation: String
    var targetAmount: Double
    var savedAmount: Double
    var status: GoalStatus
    var imageData: Data?
    var createdAt: Date
    
    var progress: Double {
        return min(savedAmount / targetAmount, 1.0)
    }
    
    init(id: UUID, title: String, annotation: String, targetAmount: Double, savedAmount: Double = 0, status: GoalStatus = .active, imageData: Data? = nil) {
        self.id = id
        self.title = title
        self.annotation = annotation
        self.targetAmount = targetAmount
        self.savedAmount = savedAmount
        self.status = status
        self.imageData = imageData
        self.createdAt = Date()
    }
}
