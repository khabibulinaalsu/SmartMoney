import UIKit

enum AddTransactionAssembly {
    static func assemble(transaction: TransactionModel? = nil) -> UIViewController {
        return AddTransactionRouter.createModule(transaction: transaction)
    }
}

