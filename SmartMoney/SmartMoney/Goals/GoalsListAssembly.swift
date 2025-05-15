import UIKit
import SwiftData

enum GoalsListAssembly {
    static func assemble() -> UIViewController {
        let viewController = GoalsListViewController()
        let interactor = GoalsListInteractor()
        let presenter = GoalsListPresenter(viewController: viewController)
        let router = GoalsListRouter(viewController: viewController)
        
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        
        return viewController
    }
}
