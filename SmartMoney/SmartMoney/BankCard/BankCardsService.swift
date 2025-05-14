import Foundation

protocol BankCardsServiceProtocol {
    func loadCards() -> [BankCard]
    func saveCard(_ card: BankCard)
    func deleteCard(_ card: BankCard)
}

class BankCardsService: BankCardsServiceProtocol {
    private let keychainService = KeychainService()
    
    func loadCards() -> [BankCard] {
        return keychainService.loadCards()
    }
    
    func saveCard(_ card: BankCard) {
        keychainService.saveCard(card)
    }
    
    func deleteCard(_ card: BankCard) {
        keychainService.deleteCard(card)
    }
}
