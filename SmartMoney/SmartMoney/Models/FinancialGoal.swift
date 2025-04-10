import SwiftUI

struct FinancialGoal {
    var id: UUID
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date?
    var iconName: String
    var color: Color
}
