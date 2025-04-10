import SwiftUI

class AddTransactionViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var cards: [Card] = []
    
    private let dataManager = DataManager.shared
    
    func fetchCategories() {
        categories = dataManager.fetchCategories()
        
        // Если категорий нет, создаем стандартные
        if categories.isEmpty {
            createDefaultCategories()
        }
    }
    
    func fetchCards() {
        cards = dataManager.fetchCards()
    }
    
    func saveTransaction(_ transaction: Transaction) {
        dataManager.saveTransaction(transaction)
        
        // Если транзакция связана с картой, обновляем баланс карты
        if let cardId = transaction.cardId, let card = cards.first(where: { $0.id == cardId }) {
            var updatedCard = card
            if transaction.isExpense {
                updatedCard.balance -= transaction.amount
            } else {
                updatedCard.balance += transaction.amount
            }
            dataManager.updateCard(updatedCard)
        }
    }
    
    private func createDefaultCategories() {
        // Категории расходов
        let expenseCategories: [(name: String, icon: String, color: Color)] = [
            ("Продукты", "cart.fill", .green),
            ("Транспорт", "car.fill", .blue),
            ("Развлечения", "film.fill", .purple),
            ("Рестораны", "fork.knife", .orange),
            ("Здоровье", "heart.fill", .red),
            ("Одежда", "tshirt.fill", .pink),
            ("Коммунальные платежи", "house.fill", .brown),
            ("Образование", "book.fill", .cyan)
        ]
        
        // Категории доходов
        let incomeCategories: [(name: String, icon: String, color: Color)] = [
            ("Зарплата", "dollarsign.circle.fill", .green),
            ("Подработка", "briefcase.fill", .orange),
            ("Инвестиции", "chart.line.uptrend.xyaxis", .purple),
            ("Подарки", "gift.fill", .red)
        ]
        
        // Создаем категории расходов
        for category in expenseCategories {
            let newCategory = Category(
                id: UUID(),
                name: category.name,
                icon: category.icon,
                color: category.color,
                isExpenseCategory: true
            )
            dataManager.saveCategory(newCategory)
        }
        
        // Создаем категории доходов
        for category in incomeCategories {
            let newCategory = Category(
                id: UUID(),
                name: category.name,
                icon: category.icon,
                color: category.color,
                isExpenseCategory: false
            )
            dataManager.saveCategory(newCategory)
        }
        
        // Обновляем список категорий
        categories = dataManager.fetchCategories()
    }
}
