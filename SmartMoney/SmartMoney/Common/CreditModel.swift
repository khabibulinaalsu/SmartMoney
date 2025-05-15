import Foundation
import SwiftData

@Model
final class CreditModel {
    var id: UUID
    var amount: Double
    var currentAmount: Double
    var title: String
    var annotation: String
    var bankInstitution: String
    var interestRate: Double
    var startDate: Date?
    var endDate: Date?
    var payments: [Double]
    
    init(id: UUID, amount: Double, currentAmount: Double, title: String, annotation: String, bankInstitution: String, interestRate: Double, startDate: Date? = nil, endDate: Date? = nil, payments: [Double]) {
        self.id = id
        self.amount = amount
        self.currentAmount = currentAmount
        self.title = title
        self.annotation = annotation
        self.bankInstitution = bankInstitution
        self.interestRate = interestRate
        self.startDate = startDate
        self.endDate = endDate
        self.payments = payments
    }
}
