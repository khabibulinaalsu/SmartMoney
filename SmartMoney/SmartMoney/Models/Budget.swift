import Foundation

struct Budget {
    var id: UUID
    var category: Category?
    var amount: Double
    var currentSpent: Double
    var period: BudgetPeriod
    var startDate: Date
}

enum BudgetPeriod {
    case weekly, monthly, yearly
}

extension BudgetPeriod {
    var rawValue: String {
        switch self {
        case .weekly: return "weekly"
        case .monthly: return "monthly"
        case .yearly: return "yearly"
        }
    }
    
    static func fromRawValue(_ rawValue: String) -> BudgetPeriod {
        switch rawValue {
        case "weekly": return .weekly
        case "yearly": return .yearly
        default: return .monthly
        }
    }
}
