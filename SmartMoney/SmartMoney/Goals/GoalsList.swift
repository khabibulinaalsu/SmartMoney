import UIKit

enum GoalsList {
    enum FetchGoals {
        struct Request {
            var status: GoalStatus
        }
        
        struct Response {
            var goals: [FinancialGoalModel]
        }
        
        struct ViewModel {
            var sections: [GoalSection]
            
            struct GoalSection {
                var title: String
                var goals: [GoalViewModel]
            }
            
            struct GoalViewModel {
                var id: UUID
                var title: String
                var description: String
                var targetAmount: String
                var savedAmount: String
                var progress: Float
                var status: GoalStatus
                var image: UIImage?
            }
        }
    }
    
    enum FetchGoal {
        struct Request {
            var goalId: UUID
        }
        
        struct Response {
            var goal: FinancialGoalModel
        }
    }
    
    enum DeleteGoal {
        struct Request {
            var goal: FinancialGoalModel
        }
    }
    
    enum EditGoal {
        struct Request {
            var goal: FinancialGoalModel
        }
    }
    
    enum AddGoal {
        struct Request {
            var title: String
            var description: String
            var targetAmount: Double
            var initialAmount: Double
            var imageData: Data?
        }
    }
}
