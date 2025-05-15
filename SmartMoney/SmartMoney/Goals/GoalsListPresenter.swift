import UIKit

protocol GoalsListPresenterProtocol: AnyObject {
    func presentGoals(response: GoalsList.FetchGoals.Response)
    func presentError(error: Error)
}

class GoalsListPresenter: GoalsListPresenterProtocol {
    weak var viewController: GoalsListViewProtocol!
    
    init(viewController: GoalsListViewProtocol) {
        self.viewController = viewController
    }
    
    func presentGoals(response: GoalsList.FetchGoals.Response) {
        // Преобразуем модель данных в модель представления
        let goalViewModels = response.goals.map { goal -> GoalsList.FetchGoals.ViewModel.GoalViewModel in
            let targetAmount = String(format: "%.2f", goal.amount)
            let savedAmount = String(format: "%.2f", goal.currentAmount)
            var image: UIImage? = nil
            
            if let imageData = goal.image {
                image = UIImage(data: imageData)
            }
            
            return GoalsList.FetchGoals.ViewModel.GoalViewModel(
                id: goal.id,
                title: goal.title,
                description: goal.annotation,
                targetAmount: targetAmount,
                savedAmount: savedAmount,
                progress: Float(goal.progress),
                status: goal.status,
                image: image
            )
        }
        
        // Группируем по статусу
        let activeGoals = goalViewModels.filter { $0.status == .active }
        let completedGoals = goalViewModels.filter { $0.status == .completed }
        let frozenGoals = goalViewModels.filter { $0.status == .frozen }
        
        var sections: [GoalsList.FetchGoals.ViewModel.GoalSection] = []
        
        if !activeGoals.isEmpty {
            sections.append(GoalsList.FetchGoals.ViewModel.GoalSection(title: "Активные", goals: activeGoals))
        }
        
        if !completedGoals.isEmpty {
            sections.append(GoalsList.FetchGoals.ViewModel.GoalSection(title: "Завершенные", goals: completedGoals))
        }
        
        if !frozenGoals.isEmpty {
            sections.append(GoalsList.FetchGoals.ViewModel.GoalSection(title: "Неактивные", goals: frozenGoals))
        }
        
        let viewModel = GoalsList.FetchGoals.ViewModel(sections: sections)
        viewController.displayGoals(viewModel: viewModel)
    }
    
    func presentError(error: Error) {
        viewController.displayError(message: error.localizedDescription)
    }
}
