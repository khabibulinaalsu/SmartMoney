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
    var dataManager: TransactionDataSource & CategoriesDataSource = DataManager.shared
    
    private var startDate: Date
    private var endDate: Date
    private var selectedCategories: [CategoryModel] = []
    
    init() {
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
        fetchData(request: TransactionsList.FetchTransactions.Request())
    }
    
    func performAction(request: TransactionsList.ApplyFilters.Request) {
        applyFilters(request: request)
        fetchData(request: TransactionsList.FetchTransactions.Request())
    }
    
    func performAction(request: TransactionsList.ShowPeriodPicker.Request) {
        showPeriodPicker(request: request)
        fetchData(request: TransactionsList.FetchTransactions.Request())
    }
    
    func performAction(request: TransactionsList.ApplyPeriod.Request) {
        applyPeriod(request: request)
        fetchData(request: TransactionsList.FetchTransactions.Request())
    }
    
    func performAction(request: TransactionsList.DeleteTransaction.Request) {
        deleteTransaction(request: request)
        fetchData(request: TransactionsList.FetchTransactions.Request())
    }
    
    // MARK: - Private Methods
    private func fetchTransactions(request: TransactionsList.FetchTransactions.Request) {
        let filteredTransactions = dataManager.fetchTransactions(
            startDate: startDate,
            endDate: endDate,
            selectedCategories: selectedCategories
        )
        let categories = dataManager.fetchCategories()
        
        let response = TransactionsList.FetchTransactions.Response(
            transactions: filteredTransactions,
            categories: categories,
            startDate: startDate,
            endDate: endDate,
            selectedCategories: selectedCategories
        )
        
        presenter?.presentData(response: response)
    }
    
    private func showFilters(request: TransactionsList.ShowFilters.Request) {
        let categories = dataManager.fetchCategories()
        let response = TransactionsList.ShowFilters.Response(
            categories: categories,
            selectedCategories: selectedCategories
        )
        
        presenter?.presentData(response: response)
    }
    
    private func applyFilters(request: TransactionsList.ApplyFilters.Request) {
        selectedCategories = request.selectedCategories
        fetchData(request: TransactionsList.FetchTransactions.Request())
    }
    
    private func showPeriodPicker(request: TransactionsList.ShowPeriodPicker.Request) {
        presenter?.presentData(response: (startDate: startDate, endDate: endDate))
    }
    
    private func applyPeriod(request: TransactionsList.ApplyPeriod.Request) {
        startDate = request.startDate
        endDate = request.endDate
        fetchData(request: TransactionsList.FetchTransactions.Request())
    }
    
    private func deleteTransaction(request: TransactionsList.DeleteTransaction.Request) {
        dataManager.deleteTransaction(with: request.transactionId)
    }
}
