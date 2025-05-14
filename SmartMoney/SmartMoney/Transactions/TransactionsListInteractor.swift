import Foundation
import SwiftData

// MARK: - TransactionsListInteractorProtocol
protocol TransactionsListInteractorProtocol: InteractorProtocol {
    func fetchData(request: TransactionsList.FetchTransactions.Request)
    func performAction(request: TransactionsList.ShowFilters.Request)
    func performAction(request: TransactionsList.ApplyFilters.Request)
    func performAction(request: TransactionsList.ShowPeriodPicker.Request)
    func performAction(request: TransactionsList.ApplyPeriod.Request)
    func performAction(request: TransactionsList.DeleteTransaction.Request)
}

// MARK: - TransactionsListInteractor
class TransactionsListInteractor: TransactionsListInteractorProtocol {
    var presenter: TransactionsListPresenterProtocol?
    var modelContext: ModelContext
    
    private var startDate: Date
    private var endDate: Date
    private var selectedCategories: [CategoryModel] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // По умолчанию установим период - последний месяц
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
        
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func fetchData(request: Any) {
        if let request = request as? TransactionsList.FetchTransactions.Request {
            fetchTransactions(request: request)
        }
    }
    
    func performAction(request: Any) {
        if let request = request as? TransactionsList.ShowFilters.Request {
            showFilters(request: request)
        } else if let request = request as? TransactionsList.ApplyFilters.Request {
            applyFilters(request: request)
        } else if let request = request as? TransactionsList.ShowPeriodPicker.Request {
            showPeriodPicker(request: request)
        } else if let request = request as? TransactionsList.ApplyPeriod.Request {
            applyPeriod(request: request)
        } else if let request = request as? TransactionsList.DeleteTransaction.Request {
            deleteTransaction(request: request)
        }
    }
    
    func fetchData(request: TransactionsList.FetchTransactions.Request) {
        fetchTransactions(request: request)
    }
    
    func performAction(request: TransactionsList.ShowFilters.Request) {
        showFilters(request: request)
    }
    
    func performAction(request: TransactionsList.ApplyFilters.Request) {
        applyFilters(request: request)
    }
    
    func performAction(request: TransactionsList.ShowPeriodPicker.Request) {
        showPeriodPicker(request: request)
    }
    
    func performAction(request: TransactionsList.ApplyPeriod.Request) {
        applyPeriod(request: request)
    }
    
    func performAction(request: TransactionsList.DeleteTransaction.Request) {
        deleteTransaction(request: request)
    }
    
    // MARK: - Private Methods
    private func fetchTransactions(request: TransactionsList.FetchTransactions.Request) {
        do {
            var descriptor = FetchDescriptor<TransactionModel>()
            
            // Применяем фильтр по датам
            let startDate = self.startDate
            let endDate = self.endDate
            let predicate = #Predicate<TransactionModel> { transaction in
                transaction.dateAndTime >= startDate && transaction.dateAndTime <= endDate
            }
            descriptor.predicate = predicate
            
            // Сортировка по дате (сначала новые)
            descriptor.sortBy = [SortDescriptor(\TransactionModel.dateAndTime, order: .reverse)]
            
            let transactions = try modelContext.fetch(descriptor)
            
            // Если выбраны категории для фильтрации
            let filteredTransactions: [TransactionModel]
            if !selectedCategories.isEmpty {
                filteredTransactions = transactions.filter { transaction in
                    guard let category = transaction.category else { return false }
                    return selectedCategories.contains { $0.id == category.id }
                }
            } else {
                filteredTransactions = transactions
            }
            
            // Получаем все категории для фильтров
            let categoriesDescriptor = FetchDescriptor<CategoryModel>()
            let categories = try modelContext.fetch(categoriesDescriptor)
            
            let response = TransactionsList.FetchTransactions.Response(
                transactions: filteredTransactions,
                categories: categories,
                startDate: startDate,
                endDate: endDate,
                selectedCategories: selectedCategories
            )
            
            presenter?.presentData(response: response)
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
    
    private func showFilters(request: TransactionsList.ShowFilters.Request) {
        do {
            let descriptor = FetchDescriptor<CategoryModel>()
            let categories = try modelContext.fetch(descriptor)
            
            let response = TransactionsList.ShowFilters.Response(
                categories: categories,
                selectedCategories: selectedCategories
            )
            
            presenter?.presentData(response: response)
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    private func applyFilters(request: TransactionsList.ApplyFilters.Request) {
        selectedCategories = request.selectedCategories
        fetchData(request: TransactionsList.FetchTransactions.Request())
    }
    
    private func showPeriodPicker(request: TransactionsList.ShowPeriodPicker.Request) {
        // Здесь просто передаем текущий период презентеру,
        // а он уже решит, как отобразить UI для выбора периода
        presenter?.presentData(response: (startDate: startDate, endDate: endDate))
    }
    
    private func applyPeriod(request: TransactionsList.ApplyPeriod.Request) {
        startDate = request.startDate
        endDate = request.endDate
        fetchData(request: TransactionsList.FetchTransactions.Request())
    }
    
    private func deleteTransaction(request: TransactionsList.DeleteTransaction.Request) {
        do {
            let id = request.transactionId
            let descriptor = FetchDescriptor<TransactionModel>(predicate: #Predicate { $0.id == id })
            let transactions = try modelContext.fetch(descriptor)
            
            if let transaction = transactions.first {
                // Обновляем баланс карты/наличных
                if let cardId = transaction.cardId {
                    let cardDescriptor = FetchDescriptor<Card>(predicate: #Predicate { $0.id == cardId })
                    if let card = try modelContext.fetch(cardDescriptor).first {
                        if transaction.isExpense {
                            card.balance += transaction.amount // Возвращаем деньги на счет
                        } else {
                            card.balance -= transaction.amount // Убираем доход
                        }
                    }
                }
                
                modelContext.delete(transaction)
                try modelContext.save()
                
                // Обновляем список транзакций
                fetchData(request: TransactionsList.FetchTransactions.Request())
            }
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
}
