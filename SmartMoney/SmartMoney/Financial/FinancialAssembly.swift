import UIKit

enum FinancialAssembly {
    static func assemble() -> UIViewController {
        let service = FinancialService()
        let interactor = FinancialInteractor(service: service)
        let presenter = FinancialPresenter(interactor: interactor)
        let viewController = FinancialViewController(presenter: presenter)
        
        presenter.view = viewController
        
        return viewController
    }
}
