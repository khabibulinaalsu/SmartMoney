import Foundation
import SwiftData

class DataManager {
    static let shared = DataManager()
    
    var transactions: [TransactionModel] = []
    var financialGoals: [FinancialGoalModel] = []
    var credits: [CreditModel] = []
    
    private init() {}
    
    func getInitialCategories() -> [CategoryModel] {
        return [
            CategoryModel(name: "Продукты", colorHEX: "#4CAF50"),
            CategoryModel(name: "Транспорт", colorHEX: "#2196F3"),
            CategoryModel(name: "Развлечения", colorHEX: "#9C27B0"),
            CategoryModel(name: "Кафе и рестораны", colorHEX: "#FF9800"),
            CategoryModel(name: "Здоровье", colorHEX: "#F44336"),
            CategoryModel(name: "Зарплата", colorHEX: "#00BCD4"),
            CategoryModel(name: "Подарки", colorHEX: "#E91E63")
        ]
    }
    
    func setupDefaultData(modelContext: ModelContext) {
        // Проверяем существуют ли уже категории
        let categoryDescriptor = FetchDescriptor<CategoryModel>()
        guard (try? modelContext.fetch(categoryDescriptor))?.isEmpty ?? true else { return }
        
        // Добавляем дефолтные категории
        for category in getInitialCategories() {
            modelContext.insert(category)
        }
        
        // Добавляем карту и наличные по умолчанию
        let card = Card(name: "Основная карта", balance: 0)
        let cash = Card(name: "Наличные", balance: 0, isCash: true)
        modelContext.insert(card)
        modelContext.insert(cash)
    }
}
