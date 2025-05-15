import Foundation
import SwiftData

protocol TransactionDataSource {
    func fetchTransactions(startDate: Date, endDate: Date, selectedCategories: [CategoryModel]) -> [TransactionModel]
    func fetchTransaction(by: UUID) -> TransactionModel?
    func addTransaction(transaction: TransactionModel)
    func editTransaction(new: TransactionModel)
    func deleteTransaction(with: UUID)
}

protocol CategoriesDataSource {
    func fetchCategories() -> [CategoryModel]
    func addCategory(category: CategoryModel)
    func editCategory(new: CategoryModel)
    func deleteCategory(with: UUID)
}

protocol MessagesDataSource {
    func fetchMessages() -> [MessageModel]
    func addMessage(message: MessageModel)
}

protocol FinancialGoalsDataSource {
    func fetchFinancialGoals(with status: GoalStatus) -> [FinancialGoalModel]
    func fetchFinancialGoal(by: UUID) -> FinancialGoalModel?
    func addFinancialGoal(goal: FinancialGoalModel)
    func editFinancialGoal(new: FinancialGoalModel)
    func deleteFinancialGoal(with: UUID)
}

protocol CreditsDataSource {
    func fetchCredits() -> [CreditModel]
    func fetchCredit(by: UUID) -> CreditModel?
    func addCredit(credit: CreditModel)
    func editCredit(new: CreditModel)
    func deleteCredit(with: UUID)
}
