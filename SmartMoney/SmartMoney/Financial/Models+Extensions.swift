import Foundation

extension RecommendationRequest.Transaction {
    static func convert(from model: TransactionModel) -> Self {
        .init(
            amount: model.amount,
            title: model.title,
            annotation: model.annotation,
            dateAndTime: model.dateAndTime,
            isExpense: model.isExpense,
            cardId: model.cardId
        )
    }
}

extension RecommendationRequest.FinancialGoal {
    static func convert(from model: FinancialGoalModel) -> Self {
        .init(
            amount: model.amount,
            currentAmount: model.currentAmount,
            title: model.title,
            annotation: model.annotation,
            endDate: model.endDate
        )
    }
}

extension RecommendationRequest.Credit {
    static func convert(from model: CreditModel) -> Self {
        .init(
            amount: model.amount,
            currentAmount: model.currentAmount,
            bankInstitution: model.bankInstitution,
            title: model.title,
            annotation: model.annotation,
            startDate: model.startDate,
            endDate: model.endDate,
            interestRate: model.interestRate,
            payments: model.payments.map { RecommendationRequest.Payment(status: "", amount: $0, date: nil) }
        )
    }
}
