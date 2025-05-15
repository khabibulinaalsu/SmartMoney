import UIKit

protocol GoalsListRouterProtocol: AnyObject {
    func routeToAddGoal()
    func routeToGoalDetails(goal: FinancialGoalModel)
}

final class GoalsListRouter: GoalsListRouterProtocol {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func routeToAddGoal() {
        let addGoalVC = AddGoalViewController()
        let presenter = AddGoalPresenter(viewController: addGoalVC)
        let interactor = AddGoalInteractor()
        let router = AddGoalRouter(viewController: addGoalVC)
        
        addGoalVC.presenter = presenter
        addGoalVC.interactor = interactor
        addGoalVC.router = router
        interactor.presenter = presenter
        
        viewController?.navigationController?.pushViewController(addGoalVC, animated: true)
    }
    
    func routeToGoalDetails(goal: FinancialGoalModel) {
        // TODO: %)
        // Здесь можно добавить переход к детальному просмотру цели
        // (не реализуем в рамках текущего задания)
    }
}
