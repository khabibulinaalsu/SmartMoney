import Foundation

protocol FinancialInteractorProtocol {
    func getRecommendations(completion: @escaping (Result<[String], Error>) -> Void)
    func getPrediction() -> Prediction
}

class FinancialInteractor: FinancialInteractorProtocol {
    private let service: FinancialServiceProtocol
    private let dataManager = DataManager.shared
    
    init(service: FinancialServiceProtocol) {
        self.service = service
    }
    
    func getRecommendations(completion: @escaping (Result<[String], Error>) -> Void) {
        let request = RecommendationRequest(
            transactions: dataManager.transactions.map(RecommendationRequest.Transaction.convert(from:)),
            financialGoals: dataManager.financialGoals.map(RecommendationRequest.FinancialGoal.convert(from:)),
            creditHistory: dataManager.credits.map(RecommendationRequest.Credit.convert(from:))
        )
        service.getRecommendations(request: request, completion: completion)
    }
    
    func getPrediction() -> Prediction {
        return service.predictFutureFinances(
            transactions: dataManager.transactions.map(RecommendationRequest.Transaction.convert(from:))
        )
    }
}
