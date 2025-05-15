import UIKit

enum FinancialAssembly {
    static func assemble() -> UIViewController {
        let service = FinancialService()
        let presenter = FinancialPresenter()
        let interactor = FinancialInteractor(service: service, presenter: presenter)
        let viewController = FinancialViewController(interactor: interactor)
        
        presenter.view = viewController
        
        return viewController
    }
}
