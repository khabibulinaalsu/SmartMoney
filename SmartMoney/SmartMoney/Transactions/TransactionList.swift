import Foundation

enum TransactionsList {
    // MARK: - UseCase: FetchTransactions
    enum FetchTransactions {
        struct Request {}
        
        struct Response {
            let transactions: [TransactionModel]
            let categories: [CategoryModel]
            let startDate: Date
            let endDate: Date
            let selectedCategories: [CategoryModel]
        }
        
        struct ViewModel {
            struct Section {
                let dateTitle: String
                let transactions: [TransactionListItemViewModel]
            }
            
            let transactionsByDays: [Section]
            let totalIncome: Double
            let totalExpense: Double
        }
    }
    
    // MARK: - UseCase: ShowFilters
    enum ShowFilters {
        struct Request {}
        
        struct Response {
            let categories: [CategoryModel]
            let selectedCategories: [CategoryModel]
        }
        
        struct ViewModel {
            let categories: [(category: CategoryModel, isSelected: Bool)]
        }
    }
    
    // MARK: - UseCase: ApplyFilters
    enum ApplyFilters {
        struct Request {
            let selectedCategories: [CategoryModel]
        }
    }
    
    // MARK: - UseCase: ShowPeriodPicker
    enum ShowPeriodPicker {
        struct Request {}
    }
    
    // MARK: - UseCase: ApplyPeriod
    enum ApplyPeriod {
        struct Request {
            let startDate: Date
            let endDate: Date
        }
    }
    
    // MARK: - UseCase: DeleteTransaction
    enum DeleteTransaction {
        struct Request {
            let transactionId: UUID
        }
    }
    
    // MARK: - Navigation
    enum Destination {
        case addTransaction(transaction: TransactionModel?)
        case transactionDetails(transaction: TransactionListItemViewModel)
        case statistics
        case scanQRCode
        case selectQRCodeImage
    }
}
