import SwiftUI

struct AnalyticsData {
    let overviewData: OverviewData
    let expensesData: ExpensesData
    let incomeData: IncomeData
    let balanceData: BalanceData
}

struct OverviewData {
    let totalIncome: Double
    let totalExpenses: Double
    let balance: Double
    let incomeTrend: Double
    let expensesTrend: Double
    let balanceHistory: [BalancePoint]
}

struct ExpensesData {
    let totalExpenses: Double
    let categoryDistribution: [CategoryDistribution]
    let expensesTrend: Double
}

struct IncomeData {
    let totalIncome: Double
    let incomeTrend: Double
}

struct BalanceData {
    let currentBalance: Double
    let startBalance: Double
    let balanceHistory: [BalancePoint]
}

struct BalancePoint {
    let date: Date
    let amount: Double
}

struct CategoryDistribution {
    let categoryId: UUID
    let categoryName: String
    let icon: String
    let color: Color
    let amount: Double
}

enum AnalyticsPeriod {
    case week, month, quarter, year
}
