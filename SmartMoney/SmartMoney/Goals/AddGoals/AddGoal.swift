import Foundation

enum AddGoal {
    enum CreateGoal {
        struct Request {
            var title: String
            var description: String
            var targetAmount: Double
            var initialAmount: Double
            var imageData: Data?
        }
    }
}
