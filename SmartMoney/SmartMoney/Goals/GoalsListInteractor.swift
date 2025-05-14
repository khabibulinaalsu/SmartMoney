import Foundation
import SwiftData

protocol GoalsListInteractorProtocol: AnyObject {
    func fetchGoals(request: GoalsList.FetchGoals.Request)
    func deleteGoal(request: GoalsList.DeleteGoal.Request)
    func updateGoalStatus(request: GoalsList.UpdateGoalStatus.Request)
}

class GoalsListInteractor: GoalsListInteractorProtocol {
    private let modelContext: ModelContext
    var presenter: GoalsListPresenterProtocol!
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchGoals(request: GoalsList.FetchGoals.Request) {
        do {
            var descriptor = FetchDescriptor<FinancialGoal>()
            
            if let status = request.status {
                descriptor.predicate = #Predicate { goal in
                    goal.status == status
                }
            }
            
            descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
            let goals = try modelContext.fetch(descriptor)
            let response = GoalsList.FetchGoals.Response(goals: goals)
            presenter.presentGoals(response: response)
        } catch {
            presenter.presentError(error: error)
        }
    }
    
    func deleteGoal(request: GoalsList.DeleteGoal.Request) {
        do {
            modelContext.delete(request.goal)
            try modelContext.save()
            
            // Обновляем список после удаления
            let fetchRequest = GoalsList.FetchGoals.Request(status: request.goal.status)
            fetchGoals(request: fetchRequest)
        } catch {
            presenter.presentError(error: error)
        }
    }
    
    func updateGoalStatus(request: GoalsList.UpdateGoalStatus.Request) {
        do {
            let oldStatus = request.goal.status
            request.goal.status = request.newStatus
            try modelContext.save()
            
            // Обновляем список для текущего статуса
            let fetchRequest = GoalsList.FetchGoals.Request(status: oldStatus)
            fetchGoals(request: fetchRequest)
        } catch {
            presenter.presentError(error: error)
        }
    }
}
