import UIKit

protocol AddTransactionRouterProtocol {
    func dismissScreen()
    func showCategorySelection(completion: @escaping (CategoryModel) -> Void)
}

class AddTransactionRouter: AddTransactionRouterProtocol {
    
    weak var viewController: UIViewController?
    private let dataManager: DataManager = DataManager.shared
    
    func dismissScreen() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func showCategorySelection(completion: @escaping (CategoryModel) -> Void) {
        let categoryModule = CategoryRouter.createModule(selectionCompletion: completion)
        viewController?.navigationController?.pushViewController(categoryModule, animated: true)
    }
    
    static func createModule(transaction: TransactionModel? = nil) -> UIViewController {
        
        let view = AddTransactionViewController()
        let presenter = AddTransactionPresenter(transaction: transaction)
        let interactor = AddTransactionInteractor()
        let router = AddTransactionRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}
