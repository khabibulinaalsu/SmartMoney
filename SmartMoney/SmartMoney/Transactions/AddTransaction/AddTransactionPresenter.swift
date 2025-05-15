import Foundation

protocol AddTransactionPresenterProtocol {
    var isEditMode: Bool { get }
    func viewDidLoad()
    func viewWillAppear()
    func saveTransaction(_ data: AddTransactionInputData)
    func cancelTapped()
    func categorySelectionTapped()
    func typeChanged(isExpense: Bool)
}

struct AddTransactionInputData {
    let amount: Double
    let title: String
    let annotation: String
    let dateAndTime: Date
    let isExpense: Bool
}

final class AddTransactionPresenter: AddTransactionPresenterProtocol {
    weak var view: AddTransactionViewProtocol?
    var interactor: AddTransactionInteractorProtocol!
    var router: AddTransactionRouterProtocol!
    
    private var transaction: TransactionModel?
    private var selectedCategory: CategoryModel?
    private var currentType: Bool = true // true = expense
    
    var isEditMode: Bool {
        return transaction != nil
    }
    
    init(transaction: TransactionModel? = nil) {
        self.transaction = transaction
    }
    
    func viewDidLoad() {
        view?.setupUI()
        loadInitialData()
    }
    
    func viewWillAppear() {
        interactor.fetchCategories()
    }
    
    func saveTransaction(_ data: AddTransactionInputData) {
        guard data.amount > 0, !data.title.isEmpty else {
            view?.showError("Заполните все обязательные поля")
            return
        }
        
        guard let category = selectedCategory else {
            view?.showError("Выберите категорию")
            return
        }
        
        let transactionModel: TransactionModel
        
        if let existingTransaction = transaction {
            // Редактирование
            existingTransaction.amount = data.amount
            existingTransaction.title = data.title
            existingTransaction.annotation = data.annotation
            existingTransaction.dateAndTime = data.dateAndTime
            existingTransaction.isExpense = data.isExpense
            existingTransaction.category = category
            transactionModel = existingTransaction
        } else {
            // Создание новой
            transactionModel = TransactionModel(
                amount: data.amount,
                title: data.title,
                annotation: data.annotation,
                dateAndTime: data.dateAndTime,
                isExpense: data.isExpense,
                category: category
            )
        }
        
        if isEditMode {
            interactor.editTransaction(transactionModel)
        } else {
            interactor.addTransaction(transactionModel)
        }
    }
    
    func cancelTapped() {
        router.dismissScreen()
    }
    
    func categorySelectionTapped() {
        router.showCategorySelection { [weak self] selectedCategory in
            self?.selectedCategory = selectedCategory
            self?.view?.updateCategorySelection(selectedCategory)
        }
    }
    
    func typeChanged(isExpense: Bool) {
        currentType = isExpense
        interactor.fetchCategoriesForType(isExpense: isExpense)
    }
    
    private func loadInitialData() {
        if let transaction = transaction {
            selectedCategory = transaction.category
            currentType = transaction.isExpense
        }
    }
}

extension AddTransactionPresenter: AddTransactionInteractorOutputProtocol {
    
    func categoriesFetched(_ categories: [CategoryModel]) {
        view?.updateCategories(categories)
    }
    
    func transactionSaved() {
        view?.dismissScreen()
    }
    
    func errorOccurred(_ error: String) {
        view?.showError(error)
    }
}
