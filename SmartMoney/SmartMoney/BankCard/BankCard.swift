import Foundation

struct BankCard: Codable {
    let id: UUID
    var number: String
    var holderName: String
    var cvc: String
    var expiryDate: String
    var balance: Double
    
    init(id: UUID = UUID(), number: String, holderName: String, cvc: String, expiryDate: String, balance: Double) {
        self.id = id
        self.number = number
        self.holderName = holderName
        self.cvc = cvc
        self.expiryDate = expiryDate
        self.balance = balance
    }
}
