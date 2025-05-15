import Foundation

protocol BankCardsServiceProtocol {
    func loadCards() -> [BankCard]
    func saveCard(_ card: BankCard)
    func deleteCard(_ card: BankCard)
    func getCash() -> Double
    func updateCash(_: Double)
}

class BankCardsService: BankCardsServiceProtocol {
    private let keychainKey: String = "bankCards"
    private let udKey: String = "udCashKey"
    private let ud = UserDefaults.standard
    
    func loadCards() -> [BankCard] {
        return KeychainService.get([BankCard].self, for: keychainKey) ?? []
    }
    
    func saveCard(_ card: BankCard) {
        var cards = loadCards()
        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
            cards[idx].number = card.number
            cards[idx].holderName = card.holderName
            cards[idx].cvc = card.cvc
            cards[idx].expiryDate = card.expiryDate
            cards[idx].balance = card.balance
        } else {
            cards += [card]
        }
        _ = KeychainService.save(cards, for: keychainKey)
    }
    
    func deleteCard(_ card: BankCard) {
        var cards = loadCards()
        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
            cards.remove(at: idx)
            _ = KeychainService.save(cards, for: keychainKey)
        }
    }
    
    func getCash() -> Double {
        ud.double(forKey: udKey)
    }
    
    func updateCash(_ cash: Double) {
        ud.set(cash, forKey: udKey)
    }
}
