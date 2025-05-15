import Foundation

protocol FinancialServiceProtocol {
    func getPreviousMessages() -> [MessageModel]
    func saveMessage(_ message: MessageModel)
    func getRecommendations(completion: @escaping (Result<[String], Error>) -> Void)
    func predictFutureFinances() -> Prediction
}

class FinancialService: FinancialServiceProtocol {
    private let dataManager = DataManager.shared
    
    func getPreviousMessages() -> [MessageModel] {
        dataManager.fetchMessages()
    }
    
    func saveMessage(_ message: MessageModel) {
        dataManager.addMessage(message: message)
    }
    
    func getRecommendations(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: "http://80.90.186.34:8888/recomendations") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }
        
        let transactionModels = dataManager.fetchTransactions(
            startDate: Date(timeIntervalSince1970: 0),
            endDate: Date(),
            selectedCategories: []
        )
        
        var goals = dataManager.fetchFinancialGoals(with: .active)
        goals += dataManager.fetchFinancialGoals(with: .completed)
        goals += dataManager.fetchFinancialGoals(with: .frozen)
        
        let request = RecommendationRequest(
            transactions: transactionModels.map(RecommendationRequest.Transaction.convert(from:)),
            financialGoals: goals.map(RecommendationRequest.FinancialGoal.convert(from:)),
            creditHistory: dataManager.fetchCredits().map(RecommendationRequest.Credit.convert(from:))
        )
        
        guard let jsonData = try? JSONEncoder().encode(request) else {
            completion(.failure(NSError(domain: "JSONEncodingError", code: 1)))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data else { return }
            
            let decoder = JSONDecoder()
            do {
                let stringData = try decoder.decode([String].self, from: data)
                completion(.success(stringData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func predictFutureFinances() -> Prediction {
        let transactions = dataManager.fetchTransactions(
            startDate: Date(timeIntervalSince1970: 0),
            endDate: Date(),
            selectedCategories: []
        )
        
        let calendar = Calendar.current
        var monthlyIncome: [Int: Double] = [:]
        var monthlyExpenses: [Int: Double] = [:]
        
        for transaction in transactions {
            let components = calendar.dateComponents([.year, .month], from: transaction.dateAndTime)
            let monthKey = components.year! * 100 + components.month!
            
            if transaction.isExpense {
                monthlyExpenses[monthKey, default: 0] += transaction.amount
            } else {
                monthlyIncome[monthKey, default: 0] += transaction.amount
            }
        }
        
        // Simple linear regression for prediction
        let incomeData = monthlyIncome.sorted { $0.key < $1.key }
        let expenseData = monthlyExpenses.sorted { $0.key < $1.key }
        
        // X values are just the indices (months)
        let incomeX = Array(0..<incomeData.count).map { Double($0) }
        let incomeY = incomeData.map { $0.value }
        
        let expenseX = Array(0..<expenseData.count).map { Double($0) }
        let expenseY = expenseData.map { $0.value }
        
        // Predict next month
        let nextIncomeMonth = Double(incomeData.count)
        let nextExpenseMonth = Double(expenseData.count)
        
        let predictedIncome = linearRegression(x: incomeX, y: incomeY, predict: nextIncomeMonth)
        let predictedExpense = linearRegression(x: expenseX, y: expenseY, predict: nextExpenseMonth)
        
        return Prediction(incomeNextMonth: predictedIncome, expensesNextMonth: predictedExpense)
    }
    
    private func linearRegression(x: [Double], y: [Double], predict xPrediction: Double) -> Double {
        guard x.count == y.count, x.count > 1 else { return 0 }
        
        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map { $0 * $1 }.reduce(0, +)
        let sumXX = x.map { $0 * $0 }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n
        
        return slope * xPrediction + intercept
    }
}
