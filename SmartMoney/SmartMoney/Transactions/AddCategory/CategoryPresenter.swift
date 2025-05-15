import Foundation

protocol CategoryPresenterProtocol {
    var isSelectionMode: Bool { get }
    func viewDidLoad()
    func viewWillAppear()
    func addCategoryTapped()
    func editCategory(_ category: CategoryModel)
    func deleteCategory(_ category: CategoryModel)
    func saveCategory(id: UUID?, name: String, colorHEX: String)
    func categorySelected(_ category: CategoryModel)
}

class CategoryPresenter: CategoryPresenterProtocol {
    weak var view: CategoryViewProtocol?
    var interactor: CategoryInteractorProtocol!
    var router: CategoryRouterProtocol!
    
    private let selectionCompletion: ((CategoryModel) -> Void)?
    
    var isSelectionMode: Bool {
        return selectionCompletion != nil
    }
    
    init(selectionCompletion: ((CategoryModel) -> Void)? = nil) {
        self.selectionCompletion = selectionCompletion
    }
    
    func viewDidLoad() {
        view?.setupUI()
    }
    
    func viewWillAppear() {
        interactor.fetchCategories()
    }
    
    func addCategoryTapped() {
        view?.showCategoryForm(category: nil)
    }
    
    func editCategory(_ category: CategoryModel) {
        view?.showCategoryForm(category: category)
    }
    
    func deleteCategory(_ category: CategoryModel) {
        interactor.deleteCategory(category)
    }
    
    func saveCategory(id: UUID?, name: String, colorHEX: String) {
        if let id = id {
            // Редактирование существующей категории
            let updatedCategory = CategoryModel(id: id, name: name, colorHEX: colorHEX)
            interactor.editCategory(updatedCategory)
        } else {
            // Создание новой категории
            let newCategory = CategoryModel(name: name, colorHEX: colorHEX)
            interactor.addCategory(newCategory)
        }
    }
    
    func categorySelected(_ category: CategoryModel) {
        if isSelectionMode {
            selectionCompletion?(category)
            router.dismissScreen()
        }
    }
}

extension CategoryPresenter: CategoryInteractorOutputProtocol {
    
    func categoriesFetched(_ categories: [CategoryModel]) {
        view?.updateCategories(categories)
    }
    
    func categoryOperationCompleted() {
        interactor.fetchCategories() // Обновляем список
    }
    
    func errorOccurred(_ error: String) {
        view?.showError(error)
    }
}
