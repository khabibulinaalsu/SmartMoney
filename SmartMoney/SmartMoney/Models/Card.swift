import SwiftUI

struct Card: Identifiable {
    let id: UUID
    var cardNumber: String
    var cardHolderName: String
    var expiryDate: Date
    var bank: String
    var cardType: CardType
    var balance: Double
    var currency: Currency
    var color: Color
}

enum CardType {
    case credit
    case debit
}

enum Currency: String {
    case usd = "USD"
    case eur = "EUR"
    case rub = "RUB"
    // другие валюты
}
