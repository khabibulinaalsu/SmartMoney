import UIKit

enum AuthAssembly {
    static func assemble() -> UIViewController {
        let authService = AuthService()
        let interactor = AuthInteractor(authService: authService)
        let presenter = AuthPresenter(interactor: interactor)
        let viewController = AuthViewController(presenter: presenter)
        
        presenter.output = viewController
        interactor.output = presenter
        
        return viewController
    }
}
