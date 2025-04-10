import SwiftUI

class CardViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var selectedCard: Card?
    
    private let dataManager = DataManager.shared
    
    func fetchCards() {
        cards = dataManager.fetchCards()
        
        // Если есть карты и нет выбранной карты, выбираем первую
        if selectedCard == nil, let firstCard = cards.first {
            selectedCard = firstCard
        }
    }
    
    func addCard(_ card: Card) {
        dataManager.saveCard(card)
        fetchCards()
    }
    
    func deleteCard(_ card: Card) {
        dataManager.deleteCard(card)
        
        // Если удалена выбранная карта, выбираем другую
        if selectedCard?.id == card.id {
            selectedCard = cards.first
        }
        
        fetchCards()
    }
    
    func updateCard(_ card: Card) {
        dataManager.updateCard(card)
        fetchCards()
    }
    
    func selectCard(_ card: Card) {
        selectedCard = card
    }
}
