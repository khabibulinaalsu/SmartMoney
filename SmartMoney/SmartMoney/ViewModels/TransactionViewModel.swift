import SwiftUI

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categoryDistribution: [(category: Category, amount: Double)] = []
    @Published var dailyExpenses: [BarData] = []
    
    private let dataManager = DataManager.shared
    
    func fetchTransactions(for timeFrame: TimeFrame) {
        // Определяем даты начала и конца для выбранного периода
        let endDate = Date()
        let startDate: Date
        
        switch timeFrame {
        case .week:
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
        case .month:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
        case .year:
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)!
        }
        
        // Загружаем транзакции из CoreData
        transactions = dataManager.fetchTransactions(from: startDate, to: endDate)
        
        // Обновляем данные для диаграмм
        updateCategoryDistribution()
        updateDailyExpenses(from: startDate, to: endDate)
    }
    
    private func updateCategoryDistribution() {
        // Группируем расходы по категориям
        let expenseTransactions = transactions.filter { $0.isExpense }
        var categoryAmounts: [Category: Double] = [:]
        
        for transaction in expenseTransactions {
            let currentAmount = categoryAmounts[transaction.category] ?? 0
            categoryAmounts[transaction.category] = currentAmount + transaction.amount
        }
        
        // Преобразуем в формат для диаграммы
        categoryDistribution = categoryAmounts.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    private func updateDailyExpenses(from startDate: Date, to endDate: Date) {
        // Группируем расходы по дням
        let expenseTransactions = transactions.filter { $0.isExpense }
        var dailyAmounts: [Date: Double] = [:]
        
        // Создаем календарь для группировки по дням
        let calendar = Calendar.current
        
        for transaction in expenseTransactions {
            // Получаем только дату без времени
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: transaction.date)
            let dateKey = calendar.date(from: dateComponents)!
            
            let currentAmount = dailyAmounts[dateKey] ?? 0
            dailyAmounts[dateKey] = currentAmount + transaction.amount
        }
        
        // Создаем последовательность дат для графика
        var currentDate = startDate
        var allDates: [Date] = []
        
        while currentDate <= endDate {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
            let dateKey = calendar.date(from: dateComponents)!
            allDates.append(dateKey)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Формируем данные для графика
        dailyExpenses = allDates.map { date in
            BarData(date: date, amount: dailyAmounts[date] ?? 0)
        }
    }
}
