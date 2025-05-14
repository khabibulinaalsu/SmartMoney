import UIKit
import SwiftData

enum TransactionsListAssembly{
    static func buildTransactionsListModule(modelContext: ModelContext) -> UIViewController {
        let viewController = TransactionsListViewController()
        let interactor = TransactionsListInteractor(modelContext: modelContext)
        let presenter = TransactionsListPresenter()
        let router = TransactionsListRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        
        return viewController
    }
}
