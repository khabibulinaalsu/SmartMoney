import Foundation

protocol BankCardsPresenterProtocol {
    var cards: [BankCard] { get }
    var totalBalance: Double { get }
    var cashBalance: Double { get }
    
    func viewDidLoad()
    func addNewCard(_ card: BankCard)
    func updateCard(_ card: BankCard)
    func deleteCard(_ card: BankCard)
}

class BankCardsPresenter: BankCardsPresenterProtocol {
    weak var view: BankCardsViewProtocol?
    private let interactor: BankCardsInteractorProtocol
    private let router: BankCardsRouterProtocol
    
    var cards: [BankCard] = []
    var totalBalance: Double = 0
    var cashBalance: Double = 0
    
    init(view: BankCardsViewProtocol, interactor: BankCardsInteractorProtocol, router: BankCardsRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func viewDidLoad() {
        refreshData()
    }
    
    func addNewCard(_ card: BankCard) {
        interactor.saveCard(card)
        refreshData()
    }
    
    func updateCard(_ card: BankCard) {
        interactor.saveCard(card)
        refreshData()
    }
    
    func deleteCard(_ card: BankCard) {
        interactor.deleteCard(card)
        refreshData()
    }
    
    private func refreshData() {
        cards = interactor.fetchCards()
        totalBalance = interactor.calculateTotalBalance()
        cashBalance = interactor.calculateCashBalance()
        view?.updateView()
    }
}
