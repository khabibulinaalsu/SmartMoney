import UIKit
import SwiftData

// MARK: - TransactionsListRouterProtocol
protocol TransactionsListRouterProtocol: RouterProtocol {
    func navigateTo(destination: TransactionsList.Destination)
}

// MARK: - TransactionsListRouter
class TransactionsListRouter: TransactionsListRouterProtocol {
    weak var viewController: UIViewController?
    weak var tabBarController: UITabBarController?
    
    func navigateTo(destination: Any) {
        guard let destination = destination as? TransactionsList.Destination else { return }
        navigateToDestination(destination)
    }
    
    func navigateTo(destination: TransactionsList.Destination) {
        navigateToDestination(destination)
    }
    
    private func navigateToDestination(_ destination: TransactionsList.Destination) {
        switch destination {
        case .addTransaction(let transaction):
            navigateToAddTransaction(transaction)
        case .transactionDetails(let transaction):
            navigateToTransactionDetails(transaction)
        case .statistics:
            navigateToStatistics()
        case .scanQRCode:
            navigateToScanQRCode()
        case .selectQRCodeImage:
            navigateToSelectQRCodeImage()
        }
    }
    
    private func navigateToAddTransaction(_ transaction: TransactionModel?) {
//        let modelContext = viewController?.appModelContext() ?? ModelContext(AppDataController.shared.container)
//        let addTransactionVC = AddTransactionBuilder.buildAddTransactionModule(modelContext: modelContext, transaction: transaction)
//        
//        let navigationController = UINavigationController(rootViewController: addTransactionVC)
//        viewController?.present(navigationController, animated: true)
    }
    
    private func navigateToTransactionDetails(_ transaction: TransactionListItemViewModel) {
//        let modelContext = viewController?.appModelContext() ?? ModelContext(AppDataController.shared.container)
//        let detailsVC = TransactionDetailsBuilder.buildTransactionDetailsModule(
//            modelContext: modelContext,
//            transactionId: transaction.id
//        )
//        
//        viewController?.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    private func navigateToStatistics() {
        // Используем TabBarController для перехода на вкладку Статистики (обычно вкладка с индексом 2)
        tabBarController?.selectedIndex = 2
    }
    
    private func navigateToScanQRCode() {
//        let qrScannerVC = QRScannerViewController()
//        qrScannerVC.delegate = viewController as? QRScannerDelegate
//        
//        let navigationController = UINavigationController(rootViewController: qrScannerVC)
//        viewController?.present(navigationController, animated: true)
    }
    
    private func navigateToSelectQRCodeImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        viewController?.present(imagePicker, animated: true)
    }
}
