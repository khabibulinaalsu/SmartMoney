import Foundation

protocol BankCardsInteractorProtocol {
    func fetchCards() -> [BankCard]
    func saveCard(_ card: BankCard)
    func deleteCard(_ card: BankCard)
    func calculateTotalBalance() -> Double
    func calculateCashBalance() -> Double
}

class BankCardsInteractor: BankCardsInteractorProtocol {
    private let service: BankCardsServiceProtocol
    
    init(service: BankCardsServiceProtocol) {
        self.service = service
    }
    
    func fetchCards() -> [BankCard] {
        return service.loadCards()
    }
    
    func saveCard(_ card: BankCard) {
        service.saveCard(card)
    }
    
    func deleteCard(_ card: BankCard) {
        service.deleteCard(card)
    }
    
    func calculateTotalBalance() -> Double {
        return fetchCards().reduce(0) { $0 + $1.balance }
    }
    
    func calculateCashBalance() -> Double {
        // Assuming we have some cash balance stored
        return service.getCash()
    }
}
