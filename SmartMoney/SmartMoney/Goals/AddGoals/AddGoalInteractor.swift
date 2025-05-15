import Foundation
import SwiftData

protocol AddGoalInteractorProtocol: AnyObject {
    func createGoal(request: GoalsList.AddGoal.Request)
}

class AddGoalInteractor: AddGoalInteractorProtocol {
    private let dataManager: FinancialGoalsDataSource = DataManager.shared
    var presenter: AddGoalPresenterProtocol!
    
    func createGoal(request: GoalsList.AddGoal.Request) {
        let goal = FinancialGoalModel(
            id: UUID(),
            amount: request.targetAmount,
            currentAmount: request.initialAmount,
            title: request.title,
            annotation: request.description,
            status: .active,
            image: request.imageData
        )
        dataManager.addFinancialGoal(goal: goal)
        
        presenter.presentSuccess()
    }
}
