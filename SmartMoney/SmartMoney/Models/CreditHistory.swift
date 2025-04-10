import SwiftUI

struct CreditHistory: Identifiable {
    let id: UUID
    var creditInstitution: String
    var creditAmount: Double
    var remainingAmount: Double
    var interestRate: Double
    var startDate: Date
    var endDate: Date
    var monthlyPayment: Double
    var paymentHistory: [Payment]
}

struct Payment: Identifiable {
    let id: UUID
    var amount: Double
    var date: Date
    var status: PaymentStatus
}

enum PaymentStatus {
    case paid
    case pending
    case late
}

extension PaymentStatus {
    var rawValue: String {
        switch self {
        case .pending: return "pending"
        case .paid: return "paid"
        case .late: return "late"
        }
    }
    
    static func fromRawValue(_ rawValue: String) -> PaymentStatus {
        switch rawValue {
        case "pending": return .pending
        case "late": return .late
        default: return .paid
        }
    }
}

extension PaymentStatus {
    var displayText: String {
        switch self {
        case .paid:
            return "Оплачено"
        case .pending:
            return "Предстоит"
        case .late:
            return "Просрочено"
        }
    }
    
    var color: Color {
        switch self {
        case .paid:
            return .green
        case .pending:
            return .blue
        case .late:
            return .red
        }
    }
}
