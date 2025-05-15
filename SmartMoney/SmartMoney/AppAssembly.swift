import UIKit
import SwiftData

enum AppAssembly {
    static func assemble() -> UIViewController {
        let transactionVC = UINavigationController(rootViewController: TransactionsListAssembly.assemble())
        let financialVC = UINavigationController(rootViewController: FinancialAssembly.assemble())
        let cardsVC = UINavigationController(rootViewController: BankCardsAssembly.assemble())
        let goalsVC = UINavigationController(rootViewController: GoalsListAssembly.assemble())
        
        let authVC = AuthAssembly.assemble()
        
        let tabbar = UITabBarController()
        tabbar.viewControllers = [
            transactionVC,
            financialVC,
            cardsVC,
            goalsVC
        ]
        
        transactionVC.tabBarItem = UITabBarItem(title: "Транзакции", image: .transactions, selectedImage: .transactions)
        financialVC.tabBarItem = UITabBarItem(title: "Рекомендации", image: .financial, selectedImage: .financialInverse)
        cardsVC.tabBarItem = UITabBarItem(title: "Карты", image: .cards, selectedImage: .cardsInverse)
        goalsVC.tabBarItem = UITabBarItem(title: "Цели", image: .goals, selectedImage: .goals)
        
        let tabbarNC = UINavigationController(rootViewController: tabbar)
        tabbarNC.pushViewController(authVC, animated: false)
        
        return tabbarNC
    }
}
