import SwiftData
import SwiftUI

// MARK: - Transaction
@Model
final class TransactionModel {
    var id: UUID
    var amount: Double
    var title: String
    var transactionDescription: String
    var date: Date
    var isExpense: Bool
    
    @Relationship(deleteRule: .cascade)
    var category: CategoryModel?
    
    @Relationship(deleteRule: .nullify)
    var card: CardModel?
    
    init(
        id: UUID = UUID(),
        amount: Double,
        title: String,
        description: String,
        date: Date,
        isExpense: Bool,
        category: CategoryModel? = nil,
        card: CardModel? = nil
    ) {
        self.id = id
        self.amount = amount
        self.title = title
        self.transactionDescription = description
        self.date = date
        self.isExpense = isExpense
        self.category = category
        self.card = card
    }
}

// MARK: - Category
@Model
final class CategoryModel {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isExpenseCategory: Bool
    
    @Relationship(inverse: \TransactionModel.category)
    var transactions: [TransactionModel]? = []
    
    @Relationship(inverse: \BudgetModel.category)
    var budgets: [BudgetModel]? = []
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        isExpenseCategory: Bool
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isExpenseCategory = isExpenseCategory
    }
}

// MARK: - Card
@Model
final class CardModel {
    var id: UUID
    var cardNumber: String
    var cardHolderName: String
    var expiryDate: Date
    var bank: String
    var cardType: String
    var balance: Double
    var currency: String
    var colorHex: String
    
    @Relationship(inverse: \TransactionModel.card)
    var transactions: [TransactionModel]? = []
    
    init(
        id: UUID = UUID(),
        cardNumber: String,
        cardHolderName: String,
        expiryDate: Date,
        bank: String,
        cardType: String,
        balance: Double,
        currency: String,
        colorHex: String
    ) {
        self.id = id
        self.cardNumber = cardNumber
        self.cardHolderName = cardHolderName
        self.expiryDate = expiryDate
        self.bank = bank
        self.cardType = cardType
        self.balance = balance
        self.currency = currency
        self.colorHex = colorHex
    }
}

// MARK: - Budget
@Model
final class BudgetModel {
    var id: UUID
    var amount: Double
    var currentSpent: Double
    var period: String
    var startDate: Date
    
    @Relationship(deleteRule: .nullify)
    var category: CategoryModel?
    
    init(
        id: UUID = UUID(),
        amount: Double,
        currentSpent: Double,
        period: String,
        startDate: Date,
        category: CategoryModel? = nil
    ) {
        self.id = id
        self.amount = amount
        self.currentSpent = currentSpent
        self.period = period
        self.startDate = startDate
        self.category = category
    }
}

// MARK: - Financial Goal
@Model
final class FinancialGoalModel {
    var id: UUID
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date?
    var iconName: String
    var colorHex: String
    
    init(
        id: UUID = UUID(),
        title: String,
        targetAmount: Double,
        currentAmount: Double,
        targetDate: Date?,
        iconName: String,
        colorHex: String
    ) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.iconName = iconName
        self.colorHex = colorHex
    }
}

// MARK: - Credit History
@Model
final class CreditHistoryModel {
    var id: UUID
    var creditInstitution: String
    var creditAmount: Double
    var remainingAmount: Double
    var interestRate: Double
    var startDate: Date
    var endDate: Date
    var monthlyPayment: Double
    
    @Relationship(deleteRule: .cascade)
    var payments: [PaymentModel]? = []
    
    init(
        id: UUID = UUID(),
        creditInstitution: String,
        creditAmount: Double,
        remainingAmount: Double,
        interestRate: Double,
        startDate: Date,
        endDate: Date,
        monthlyPayment: Double
    ) {
        self.id = id
        self.creditInstitution = creditInstitution
        self.creditAmount = creditAmount
        self.remainingAmount = remainingAmount
        self.interestRate = interestRate
        self.startDate = startDate
        self.endDate = endDate
        self.monthlyPayment = monthlyPayment
    }
}

// MARK: - Payment
@Model
final class PaymentModel {
    var id: UUID
    var amount: Double
    var date: Date
    var status: String
    
    @Relationship(deleteRule: .cascade)
    var credit: CreditHistoryModel?
    
    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date,
        status: String,
        credit: CreditHistoryModel? = nil
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.status = status
        self.credit = credit
    }
}

