import UIKit

protocol BankCardsRouterProtocol {
    func showCardDetails(_ card: BankCard?)
}

class BankCardsRouter: BankCardsRouterProtocol {
    weak var viewController: UIViewController?
    
    func showCardDetails(_ card: BankCard?) {
        let detailVC = CardDetailViewController(card: card)
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}
