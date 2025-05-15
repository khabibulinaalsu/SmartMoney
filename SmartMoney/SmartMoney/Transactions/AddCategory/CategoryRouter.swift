import UIKit

protocol CategoryRouterProtocol {
    func dismissScreen()
}

class CategoryRouter: CategoryRouterProtocol {
    
    weak var viewController: UIViewController?
    
    func dismissScreen() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    static func createModule(
        selectionCompletion: ((CategoryModel) -> Void)? = nil
    ) -> UIViewController {
        let view = CategoryViewController()
        let presenter = CategoryPresenter(selectionCompletion: selectionCompletion)
        let interactor = CategoryInteractor()
        let router = CategoryRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}
