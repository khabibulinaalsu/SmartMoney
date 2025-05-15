import UIKit

enum BankCardsAssembly {
    static func assemble() -> UIViewController {
        let view = BankCardsViewController()
        let service = BankCardsService()
        let interactor = BankCardsInteractor(service: service)
        let router = BankCardsRouter()
        let presenter = BankCardsPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        router.viewController = view
        
        return view
    }
}
