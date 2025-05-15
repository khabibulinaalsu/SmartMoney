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

extension Prediction {
    func convertToMessage() -> MessageModel {
        let formattedIncome = String(format: "%.2f", incomeNextMonth)
        let formattedExpenses = String(format: "%.2f", expensesNextMonth)
        let difference = incomeNextMonth - expensesNextMonth
        let formattedDifference = String(format: "%.2f", difference)
        
        var message = "Прогноз нна следующий месяц:\n\n"
        message += "• Доходы: $\(formattedIncome)\n"
        message += "• Расходы: $\(formattedExpenses)\n\n"
        
        if difference > 0 {
            message += "Ты можешь сохранить $\(formattedDifference) в следующем месяце! 👍"
        } else if difference < 0 {
            message += "Кажется твои расходы превысят доходы на $\(abs(difference)) в следующем месяце. Могу предложить пар вариантов сокращения расходов. ⚠️"
        } else {
            message += "Доходы и расходы равны"
        }
        
        
        return MessageModel(text: message, sender: .ai)
    }
}
