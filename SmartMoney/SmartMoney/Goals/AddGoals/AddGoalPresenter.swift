import Foundation

protocol AddGoalPresenterProtocol: AnyObject {
    func presentSuccess()
}

class AddGoalPresenter: AddGoalPresenterProtocol {
    weak var viewController: AddGoalViewProtocol!
    
    init(viewController: AddGoalViewProtocol) {
        self.viewController = viewController
    }
    
    func presentSuccess() {
        viewController.displaySuccess()
    }
}
