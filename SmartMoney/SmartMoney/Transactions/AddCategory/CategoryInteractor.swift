import Foundation

protocol CategoryInteractorProtocol {
    func fetchCategories()
    func addCategory(_ category: CategoryModel)
    func editCategory(_ category: CategoryModel)
    func deleteCategory(_ category: CategoryModel)
}

protocol CategoryInteractorOutputProtocol: AnyObject {
    func categoriesFetched(_ categories: [CategoryModel])
    func categoryOperationCompleted()
    func errorOccurred(_ error: String)
}

class CategoryInteractor: CategoryInteractorProtocol {
    
    weak var output: CategoryInteractorOutputProtocol?
    private let dataManager: DataManager = DataManager.shared
    
    func fetchCategories() {
        let categories = dataManager.fetchCategories()
        output?.categoriesFetched(categories)
    }
    
    func addCategory(_ category: CategoryModel) {
        dataManager.addCategory(category: category)
        output?.categoryOperationCompleted()
    }
    
    func editCategory(_ category: CategoryModel) {
        dataManager.editCategory(new: category)
        output?.categoryOperationCompleted()
    }
    
    func deleteCategory(_ category: CategoryModel) {
        dataManager.deleteCategory(with: category.id)
        output?.categoryOperationCompleted()
    }
}
