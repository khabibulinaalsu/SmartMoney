import UIKit
  
// MARK: - QRScannerDelegate
extension TransactionsListViewController: QRScannerDelegate {
    func didScanReceiptQR(_ receiptData: ReceiptQRParser.ReceiptData) {
        // Создаем модель транзакции
        let transaction = TransactionModel(
            amount: receiptData.amount,
            title: receiptData.merchant,
            annotation: "Чек от \(DateFormatter.localizedString(from: receiptData.date, dateStyle: .short, timeStyle: .short))",
            dateAndTime: receiptData.date,
            isExpense: true, // Чеки обычно расходы
            category: nil // Можно добавить логику определения категории
        )
        
        // Создаем и представляем экран AddTransactionViewController
        let addTransactionVC = AddTransactionAssembly.assemble(transaction: transaction)
        
        navigationController?.pushViewController(addTransactionVC, animated: true)

    }
    
    func didFailToScanQR(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка сканирования",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
