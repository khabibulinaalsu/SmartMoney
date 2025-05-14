import Foundation

protocol AddGoalPresenterProtocol: AnyObject {
    func presentSuccess()
    func presentError(error: Error)
}

class AddGoalPresenter: AddGoalPresenterProtocol {
    weak var viewController: AddGoalViewProtocol!
    
    init(viewController: AddGoalViewProtocol) {
        self.viewController = viewController
    }
    
    func presentSuccess() {
        viewController.displaySuccess()
    }
    
    func presentError(error: Error) {
        viewController.displayError(message: error.localizedDescription)
    }
}
