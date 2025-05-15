import Foundation
import SwiftData

protocol GoalsListInteractorProtocol: AnyObject {
    func fetchGoals(request: GoalsList.FetchGoals.Request)
    func fetchGoal(request: GoalsList.FetchGoal.Request) -> FinancialGoalModel?
    func deleteGoal(request: GoalsList.DeleteGoal.Request)
    func updateGoal(request: GoalsList.EditGoal.Request)
}

class GoalsListInteractor: GoalsListInteractorProtocol {
    private let dataManager: FinancialGoalsDataSource = DataManager.shared
    var presenter: GoalsListPresenterProtocol!
    
    func fetchGoals(request: GoalsList.FetchGoals.Request) {
        let goals = dataManager.fetchFinancialGoals(with: request.status)
        let response = GoalsList.FetchGoals.Response(goals: goals)
        presenter.presentGoals(response: response)
    }
    
    func fetchGoal(request: GoalsList.FetchGoal.Request) -> FinancialGoalModel? {
        dataManager.fetchFinancialGoal(by: request.goalId)
    }
    
    func deleteGoal(request: GoalsList.DeleteGoal.Request) {
        dataManager.deleteFinancialGoal(with: request.goal.id)
        fetchGoals(request: GoalsList.FetchGoals.Request(status: request.goal.status))
    }
    
    func updateGoal(request: GoalsList.EditGoal.Request) {
        dataManager.editFinancialGoal(new: request.goal)
        fetchGoals(request: GoalsList.FetchGoals.Request(status: request.goal.status))
    }
}
