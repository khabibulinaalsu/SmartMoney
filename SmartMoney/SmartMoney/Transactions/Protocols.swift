import Foundation

protocol ViewProtocol: AnyObject {
    func displayData(viewModel: Any)
}

protocol InteractorProtocol {
    func fetchData(request: Any)
    func performAction(request: Any)
}

protocol PresenterProtocol {
    func presentData(response: Any)
}

protocol RouterProtocol {
    func navigateTo(destination: Any)
}
