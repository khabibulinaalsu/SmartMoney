import Foundation
    
struct RecommendationRequest: Codable {
    let transactions: [Transaction]
    let financialGoals: [FinancialGoal]
    let creditHistory: [Credit]
}

extension RecommendationRequest {
    struct Transaction: Codable {
        let amount: Double
        let title: String
        let annotation: String
        let dateAndTime: Date
        let isExpense: Bool
        let cardId: UUID?
    }

    struct FinancialGoal: Codable {
        let amount: Double
        let currentAmount: Double
        let title: String
        let annotation: String
        let endDate: Date?
    }

    struct Credit: Codable {
        let amount: Double
        let currentAmount: Double
        let bankInstitution: String
        let title: String
        let annotation: String
        let startDate: Date?
        let endDate: Date?
        let interestRate: Double
        let payments: [Payment]
    }
    
    struct Payment: Codable {
        let status: String
        let amount: Double
        let date: Date?
    }
}

struct RecommendationResponse: Codable {
    let recommendations: [String]
}

struct Prediction {
    let incomeNextMonth: Double
    let expensesNextMonth: Double
}

