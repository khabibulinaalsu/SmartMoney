import Foundation
import SwiftData

@Model
final class CategoryModel {
    var id: UUID
    var name: String
    var colorHEX: String

    var transactions: [TransactionModel]?
    
    init(id: UUID, name: String, colorHEX: String) {
        self.id = id
        self.name = name
        self.colorHEX = colorHEX
        self.transactions = []
    }
    
    init(name: String, colorHEX: String) {
        self.id = UUID()
        self.name = name
        self.colorHEX = colorHEX
        self.transactions = []
    }
}

@Model
final class Card {
    var id: UUID
    var name: String
    var balance: Double
    var isCash: Bool
    
    init(name: String, balance: Double, isCash: Bool = false) {
        self.id = UUID()
        self.name = name
        self.balance = balance
        self.isCash = isCash
    }
}
