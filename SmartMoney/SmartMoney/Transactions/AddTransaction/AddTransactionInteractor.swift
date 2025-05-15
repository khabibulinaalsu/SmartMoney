import Foundation

protocol AddTransactionInteractorProtocol {
    func fetchCategories()
    func fetchCategoriesForType(isExpense: Bool)
    func addTransaction(_ transaction: TransactionModel)
    func editTransaction(_ transaction: TransactionModel)
}

protocol AddTransactionInteractorOutputProtocol: AnyObject {
    func categoriesFetched(_ categories: [CategoryModel])
    func transactionSaved()
    func errorOccurred(_ error: String)
}

class AddTransactionInteractor: AddTransactionInteractorProtocol {
    weak var output: AddTransactionInteractorOutputProtocol?
    private let dataManager: DataManager = DataManager.shared
    
    func fetchCategories() {
        let categories = dataManager.fetchCategories()
        output?.categoriesFetched(categories)
    }
    
    func fetchCategoriesForType(isExpense: Bool) {
        let categories = dataManager.fetchCategories()
        // Можно добавить фильтрацию по типу если нужно
        output?.categoriesFetched(categories)
    }
    
    func addTransaction(_ transaction: TransactionModel) {
        dataManager.addTransaction(transaction: transaction)
        output?.transactionSaved()
    }
    
    func editTransaction(_ transaction: TransactionModel) {
        dataManager.editTransaction(new: transaction)
        output?.transactionSaved()
    }
}
