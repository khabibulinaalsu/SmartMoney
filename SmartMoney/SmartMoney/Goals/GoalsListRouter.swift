import UIKit
import SwiftData

protocol GoalsListRouterProtocol: AnyObject {
    func routeToAddGoal()
    func routeToGoalDetails(goal: FinancialGoal)
}

class GoalsListRouter: GoalsListRouterProtocol {
    weak var viewController: UIViewController?
    private let modelContext: ModelContext
    
    init(viewController: UIViewController, modelContext: ModelContext) {
        self.viewController = viewController
        self.modelContext = modelContext
    }
    
    func routeToAddGoal() {
        let addGoalVC = AddGoalViewController()
        let presenter = AddGoalPresenter(viewController: addGoalVC)
        let interactor = AddGoalInteractor(modelContext: modelContext)
        let router = AddGoalRouter(viewController: addGoalVC)
        
        addGoalVC.presenter = presenter
        addGoalVC.interactor = interactor
        addGoalVC.router = router
        interactor.presenter = presenter
        
        let navController = UINavigationController(rootViewController: addGoalVC)
        viewController?.present(navController, animated: true)
    }
    
    func routeToGoalDetails(goal: FinancialGoal) {
        // Здесь можно добавить переход к детальному просмотру цели
        // (не реализуем в рамках текущего задания)
    }
}
