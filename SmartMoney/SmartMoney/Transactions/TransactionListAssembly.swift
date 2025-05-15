import UIKit
import SwiftData

enum TransactionsListAssembly{
    static func assemble() -> UIViewController {
        let viewController = TransactionsListViewController()
        let interactor = TransactionsListInteractor()
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
