import Foundation

class KeychainService {
    private let service = "com.bankapp.cards"
    
    func loadCards() -> [BankCard] {
        guard let data = try? KeychainItem.readData(service: service, account: "cards") else {
            return []
        }
        
        return (try? JSONDecoder().decode([BankCard].self, from: data)) ?? []
    }
    
    func saveCard(_ card: BankCard) {
        var cards = loadCards()
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
        } else {
            cards.append(card)
        }
        
        if let data = try? JSONEncoder().encode(cards) {
            try? KeychainItem.saveData(data, service: service, account: "cards")
        }
    }
    
    func deleteCard(_ card: BankCard) {
        var cards = loadCards()
        cards.removeAll { $0.id == card.id }
        
        if let data = try? JSONEncoder().encode(cards) {
            try? KeychainItem.saveData(data, service: service, account: "cards")
        }
    }
}
