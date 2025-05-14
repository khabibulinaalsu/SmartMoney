import Foundation

protocol FinancialPresenterProtocol {
    func requestRecommendations()
    func requestPrediction()
}

class FinancialPresenter: FinancialPresenterProtocol {
    weak var view: FinancialViewProtocol?
    private let interactor: FinancialInteractorProtocol
    
    init(interactor: FinancialInteractorProtocol) {
        self.interactor = interactor
    }
    
    func requestRecommendations() {
        view?.showLoading()
        
        interactor.getRecommendations() { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                
                switch result {
                case .success(let recommendations):
                    self?.view?.displayRecommendations(recommendations)
                case .failure(let error):
                    self?.view?.displayError(error.localizedDescription)
                }
            }
        }
    }
    
    func requestPrediction() {
        view?.showLoading()
        
        // Simulate some processing time for ML
        DispatchQueue.global().async { [weak self] in
            let prediction = self?.interactor.getPrediction()
            
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                if let prediction = prediction {
                    self?.view?.displayPrediction(prediction)
                } else {
                    self?.view?.displayError("Failed to generate prediction")
                }
            }
        }
    }
}
