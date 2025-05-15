import Foundation
import SwiftData

final class DataManager {
    static let shared: DataManager = DataManager()!
    
    private let schema = Schema([
        TransactionModel.self,
        CategoryModel.self,
        MessageModel.self,
        FinancialGoalModel.self,
        CreditModel.self
    ])
    
    private let context: ModelContext
    
    private init?() {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        guard let modelContainer = try? ModelContainer(for: schema, configurations: [modelConfiguration]) else { return nil }
        context = ModelContext(modelContainer)
    }
    
    private func save() {
        try? context.save()
    }
}

// MARK: - Transactions

extension DataManager: TransactionDataSource {
    func fetchTransactions(startDate: Date, endDate: Date, selectedCategories: [CategoryModel]) -> [TransactionModel] {
        var descriptor = FetchDescriptor<TransactionModel>()
        let predicate = #Predicate<TransactionModel> { transaction in
            transaction.dateAndTime >= startDate && transaction.dateAndTime <= endDate
        }
        descriptor.predicate = predicate
        descriptor.sortBy = [SortDescriptor(\TransactionModel.dateAndTime, order: .reverse)]
        
        let transactions = (try? context.fetch(descriptor)) ?? []
        
        let filteredTransactions: [TransactionModel]
        if !selectedCategories.isEmpty {
            filteredTransactions = transactions.filter { transaction in
                guard let category = transaction.category else { return false }
                return selectedCategories.contains { $0.id == category.id }
            }
        } else {
            filteredTransactions = transactions
        }
        
        return filteredTransactions
    }
    
    func fetchTransaction(by id: UUID) -> TransactionModel? {
        try? context.fetch(FetchDescriptor<TransactionModel>(predicate: #Predicate { $0.id == id })).first
    }
    
    func addTransaction(transaction: TransactionModel) {
        if fetchTransaction(by: transaction.id) != nil {
            return
        }
        context.insert(transaction)
        save()
    }
    
    func editTransaction(new: TransactionModel) {
        save()
    }
    
    func deleteTransaction(with id: UUID) {
        if let transaction = fetchTransaction(by: id) {
            context.delete(transaction)
            save()
        }
    }
}

// MARK: - Categories

extension DataManager: CategoriesDataSource {
    func fetchCategories() -> [CategoryModel] {
        let categoryDescriptor = FetchDescriptor<CategoryModel>()
        var categories = (try? context.fetch(categoryDescriptor)) ?? []
        
        if categories.isEmpty {
            for category in getInitialCategories() {
                context.insert(category)
            }
            save()
        }
        
        categories = (try? context.fetch(categoryDescriptor)) ?? []
        return categories
    }
    
    func addCategory(category: CategoryModel) {
        if fetchCategories().first(where: { $0.id == category.id }) != nil {
            return
        }
        context.insert(category)
        save()
    }
    
    func editCategory(new: CategoryModel) {
        if let category = fetchCategories().first(where: { $0.id == new.id }) {
            category.name = new.name
            category.colorHEX = new.colorHEX
        }
        save()
    }
    
    func deleteCategory(with id: UUID) {
        if let category = fetchCategories().first(where: { $0.id == id }) {
            context.delete(category)
            save()
        }
    }
    
    private func getInitialCategories() -> [CategoryModel] {
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
}

// MARK: - Messages

extension DataManager: MessagesDataSource {
    func fetchMessages() -> [MessageModel] {
        var descriptor = FetchDescriptor<MessageModel>()
        descriptor.sortBy = [SortDescriptor(\MessageModel.date)]
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func addMessage(message: MessageModel) {
        if fetchMessages().first(where: { $0.id == message.id }) != nil {
            return
        }
        context.insert(message)
        save()
    }
}

// MARK: - Financial Goals

extension DataManager: FinancialGoalsDataSource {
    func fetchFinancialGoals(with status: GoalStatus) -> [FinancialGoalModel] {
        var descriptor = FetchDescriptor<FinancialGoalModel>()
        descriptor.sortBy = [SortDescriptor(\FinancialGoalModel.createdAt, order: .reverse)]
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func fetchFinancialGoal(by id: UUID) -> FinancialGoalModel? {
        try? context.fetch(FetchDescriptor<FinancialGoalModel>(predicate: #Predicate { $0.id == id })).first
    }
    
    func addFinancialGoal(goal: FinancialGoalModel) {
        if fetchFinancialGoal(by: goal.id) != nil {
            return
        }
        context.insert(goal)
        save()
    }
    
    func editFinancialGoal(new: FinancialGoalModel) {
        save()
    }
    
    func deleteFinancialGoal(with id: UUID) {
        if let goal = fetchFinancialGoal(by: id) {
            context.delete(goal)
            save()
        }
    }
}

// MARK: - Credits

extension DataManager: CreditsDataSource {
    func fetchCredits() -> [CreditModel] {
        let descriptor = FetchDescriptor<CreditModel>()
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func fetchCredit(by id: UUID) -> CreditModel? {
        try? context.fetch(FetchDescriptor<CreditModel>(predicate: #Predicate { $0.id == id })).first
    }
    
    func addCredit(credit: CreditModel) {
        if fetchCredit(by: credit.id) != nil {
            return
        }
        context.insert(credit)
        save()
    }
    
    func editCredit(new: CreditModel) {
        save()
    }
    
    func deleteCredit(with id: UUID) {
        if let credit = fetchCredit(by: id) {
            context.delete(credit)
            save()
        }
    }
}
