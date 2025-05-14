import Foundation
import SwiftData

protocol AddGoalInteractorProtocol: AnyObject {
    func createGoal(request: AddGoal.CreateGoal.Request)
}

class AddGoalInteractor: AddGoalInteractorProtocol {
    private let modelContext: ModelContext
    var presenter: AddGoalPresenterProtocol!
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createGoal(request: AddGoal.CreateGoal.Request) {
        let newGoal = FinancialGoal(
            id: UUID(),
            title: request.title,
            annotation: request.description,
            targetAmount: request.targetAmount,
            savedAmount: request.initialAmount,
            status: .active,
            imageData: request.imageData
        )
        
        do {
            modelContext.insert(newGoal)
            try modelContext.save()
            presenter.presentSuccess()
        } catch {
            presenter.presentError(error: error)
        }
    }
}
