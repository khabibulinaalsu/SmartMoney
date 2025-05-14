import UIKit

protocol AddGoalRouterProtocol: AnyObject {
    func dismiss()
}

class AddGoalRouter: AddGoalRouterProtocol {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
