import UIKit

struct TransactionListItemViewModel {
    let id: UUID
    let title: String
    let description: String
    let amount: Double
    let categoryName: String
    let categoryColor: UIColor
    let dateAndTime: Date
    let isExpense: Bool
}
