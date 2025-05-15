import Foundation

protocol FinancialInteractorProtocol {
    func getRecommendations()
    func getPrediction()
    func getMessages()
    func addMessage(_: MessageModel)
}

class FinancialInteractor: FinancialInteractorProtocol {
    private let service: FinancialServiceProtocol
    private let presenter: FinancialPresenterProtocol
    private let dataManager = DataManager.shared
    
    init(service: FinancialServiceProtocol, presenter: FinancialPresenterProtocol) {
        self.service = service
        self.presenter = presenter
    }
    
    func getRecommendations() {
        presenter.showLoading()
        
        service.getRecommendations { [weak self] res in
            DispatchQueue.main.async {
                switch res {
                case let .success(recommendations):
                    var formattedMessage = "Опираясь на твои транзации, могу предложить:\n\n"
                    
                    for (index, recommendation) in recommendations.enumerated() {
                        formattedMessage += "\(index + 1). \(recommendation)\n"
                    }
                    
                    let message = MessageModel(text: formattedMessage, sender: .ai)
                    self?.addMessage(message)
                default:
                    break
                }
                
                self?.presenter.hideLoading()
            }
        }
    }
    
    func getPrediction() {
        let prediction = service.predictFutureFinances()
        addMessage(prediction.convertToMessage())
        
    }
    
    func getMessages() {
        let messages = service.getPreviousMessages()
        presenter.presentMessages(messages)
    }
    
    func addMessage(_ message: MessageModel) {
        service.saveMessage(message)
        presenter.addMessage(message)
    }
}
