import UIKit

enum GoalsList {
    enum FetchGoals {
        struct Request {
            var status: GoalStatus?
        }
        
        struct Response {
            var goals: [FinancialGoal]
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
    
    enum DeleteGoal {
        struct Request {
            var goal: FinancialGoal
        }
    }
    
    enum UpdateGoalStatus {
        struct Request {
            var goal: FinancialGoal
            var newStatus: GoalStatus
        }
    }
}
