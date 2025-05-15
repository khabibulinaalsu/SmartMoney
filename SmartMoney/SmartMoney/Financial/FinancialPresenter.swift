import Foundation

protocol FinancialPresenterProtocol {
    func showLoading()
    func hideLoading()
    func presentMessages(_: [MessageModel])
    func addMessage(_: MessageModel)
}

class FinancialPresenter: FinancialPresenterProtocol {
    weak var view: FinancialViewProtocol?
        
    func showLoading() {
        view?.showLoading()
    }
    
    func hideLoading() {
        view?.hideLoading()
    }
    
    func presentMessages(_ messages: [MessageModel]) {
        view?.display(messages)
    }
    
    func addMessage(_ message: MessageModel) {
        view?.display(message)
    }
}
