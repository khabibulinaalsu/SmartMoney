import Foundation
import SwiftData
import SwiftUI

class DataManager {
    static let shared = DataManager()
    
    // MARK: - SwiftData Stack
    
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext
    
    private init() {
        do {
            // Создаем схему для всех моделей данных
            let schema = Schema([
                TransactionModel.self,
                CategoryModel.self,
                CardModel.self,
                BudgetModel.self,
                FinancialGoalModel.self,
                CreditHistoryModel.self,
                PaymentModel.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer)
            
            // Создаем базовые категории при первом запуске
            if UserDefaults.standard.bool(forKey: "didSetupInitialData") == false {
                setupInitialData()
                UserDefaults.standard.set(true, forKey: "didSetupInitialData")
            }
        } catch {
            fatalError("Не удалось создать контейнер модели: \(error)")
        }
    }
    
    // MARK: - Initial Setup
    
    private func setupInitialData() {
        // Создаем базовые категории расходов
        let expenseCategories = [
            ("Продукты", "cart.fill", UIColor.systemGreen),
            ("Кафе и рестораны", "fork.knife", UIColor.systemOrange),
            ("Транспорт", "car.fill", UIColor.systemBlue),
            ("Развлечения", "film.fill", UIColor.systemPurple),
            ("Здоровье", "heart.fill", UIColor.systemRed),
            ("Одежда", "tshirt.fill", UIColor.systemPink),
            ("Коммунальные платежи", "house.fill", UIColor.systemBrown),
            ("Связь", "antenna.radiowaves.left.and.right", UIColor.systemTeal)
        ]
        
        // Создаем базовые категории доходов
        let incomeCategories = [
            ("Зарплата", "dollarsign.circle.fill", UIColor.systemGreen),
            ("Подработка", "briefcase.fill", UIColor.systemOrange),
            ("Инвестиции", "chart.line.uptrend.xyaxis", UIColor.systemPurple),
            ("Подарки", "gift.fill", UIColor.systemRed)
        ]
        
        // Добавляем категории расходов
        for (name, icon, color) in expenseCategories {
            let category = CategoryModel(
                name: name,
                icon: icon,
                colorHex: color.toHex() ?? "#00FF00",
                isExpenseCategory: true
            )
            modelContext.insert(category)
        }
        
        // Добавляем категории доходов
        for (name, icon, color) in incomeCategories {
            let category = CategoryModel(
                name: name,
                icon: icon,
                colorHex: color.toHex() ?? "#00FF00",
                isExpenseCategory: false
            )
            modelContext.insert(category)
        }
        
        // Сохраняем изменения
        try? modelContext.save()
    }
    
    // MARK: - Transactions
    
    func saveTransaction(_ transaction: Transaction) {
        // Сначала получаем модель категории
        var categoryModel: CategoryModel?
        
        if let category = fetchCategoryModel(withId: transaction.category.id) {
            categoryModel = category
        } else {
            // Создаем новую категорию, если не существует
            categoryModel = CategoryModel(
                id: transaction.category.id,
                name: transaction.category.name,
                icon: transaction.category.icon,
                colorHex: transaction.category.color.toHex() ?? "#CCCCCC",
                isExpenseCategory: transaction.isExpense
            )
            modelContext.insert(categoryModel!)
        }
        
        // Получаем модель карты, если указана
        var cardModel: CardModel?
        if let cardId = transaction.cardId, let card = fetchCardModel(withId: cardId) {
            cardModel = card
            
            // Обновляем баланс карты
            if transaction.isExpense {
                cardModel!.balance -= transaction.amount
            } else {
                cardModel!.balance += transaction.amount
            }
        }
        
        // Создаем транзакцию
        let transactionModel = TransactionModel(
            id: transaction.id,
            amount: transaction.amount,
            title: transaction.title,
            description: transaction.description,
            date: transaction.date,
            isExpense: transaction.isExpense,
            category: categoryModel,
            card: cardModel
        )
        
        modelContext.insert(transactionModel)
        try? modelContext.save()
        
        // Обновляем бюджеты, если это расход
        if transaction.isExpense {
            updateBudgets(with: transaction)
        }
    }
    
    func updateTransaction(_ transaction: Transaction) {
        // Находим существующую транзакцию
        guard let transactionModel = fetchTransactionModel(withId: transaction.id) else {
            return
        }
        
        // Сохраняем текущие данные для обновления карты
        let originalCardId = transactionModel.card?.id
        let originalAmount = transactionModel.amount
        let originalIsExpense = transactionModel.isExpense
        
        // Откатываем влияние старой транзакции на баланс карты
        if let originalCard = transactionModel.card {
            if originalIsExpense {
                originalCard.balance += originalAmount
            } else {
                originalCard.balance -= originalAmount
            }
        }
        
        // Обновляем основные данные транзакции
        transactionModel.amount = transaction.amount
        transactionModel.title = transaction.title
        transactionModel.transactionDescription = transaction.description
        transactionModel.date = transaction.date
        transactionModel.isExpense = transaction.isExpense
        
        // Обновляем категорию
        if let category = fetchCategoryModel(withId: transaction.category.id) {
            transactionModel.category = category
        } else {
            // Создаем новую категорию, если не существует
            let newCategory = CategoryModel(
                id: transaction.category.id,
                name: transaction.category.name,
                icon: transaction.category.icon,
                colorHex: transaction.category.color.toHex() ?? "#CCCCCC",
                isExpenseCategory: transaction.isExpense
            )
            modelContext.insert(newCategory)
            transactionModel.category = newCategory
        }
        
        // Обновляем карту
        transactionModel.card = nil
        if let cardId = transaction.cardId, let card = fetchCardModel(withId: cardId) {
            transactionModel.card = card
            
            // Применяем новую транзакцию к балансу карты
            if transaction.isExpense {
                card.balance -= transaction.amount
            } else {
                card.balance += transaction.amount
            }
        }
        
        try? modelContext.save()
        
        // Проверяем, нужно ли обновить бюджеты
        if transaction.isExpense {
            updateBudgets(with: transaction)
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        guard let transactionModel = fetchTransactionModel(withId: transaction.id) else {
            return
        }
        
        // Если транзакция связана с картой, обновляем баланс карты
        if let card = transactionModel.card {
            if transactionModel.isExpense {
                card.balance += transactionModel.amount
            } else {
                card.balance -= transactionModel.amount
            }
        }
        
        modelContext.delete(transactionModel)
        try? modelContext.save()
    }
    
    func fetchTransactions(from startDate: Date, to endDate: Date) -> [Transaction] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
        
        let predicate = #Predicate<TransactionModel> { transaction in
            transaction.date >= startOfDay && transaction.date <= endOfDay
        }
        
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let transactionModels = try modelContext.fetch(descriptor)
            return transactionModels.map { convertToTransaction($0) }
        } catch {
            print("Ошибка при получении транзакций: \(error)")
            return []
        }
    }
    
    func fetchAllTransactions() -> [Transaction] {
        let descriptor = FetchDescriptor<TransactionModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let transactionModels = try modelContext.fetch(descriptor)
            return transactionModels.map { convertToTransaction($0) }
        } catch {
            print("Ошибка при получении всех транзакций: \(error)")
            return []
        }
    }
    
    // MARK: - Cards
    
    func saveCard(_ card: Card) {
        let cardModel = CardModel(
            id: card.id,
            cardNumber: card.cardNumber,
            cardHolderName: card.cardHolderName,
            expiryDate: card.expiryDate,
            bank: card.bank,
            cardType: card.cardType == .credit ? "credit" : "debit",
            balance: card.balance,
            currency: card.currency.rawValue,
            colorHex: card.color.toHex() ?? "#0000FF"
        )
        
        modelContext.insert(cardModel)
        try? modelContext.save()
    }
    
    func updateCard(_ card: Card) {
        guard let cardModel = fetchCardModel(withId: card.id) else {
            return
        }
        
        cardModel.cardNumber = card.cardNumber
        cardModel.cardHolderName = card.cardHolderName
        cardModel.expiryDate = card.expiryDate
        cardModel.bank = card.bank
        cardModel.cardType = card.cardType == .credit ? "credit" : "debit"
        cardModel.balance = card.balance
        cardModel.currency = card.currency.rawValue
        cardModel.colorHex = card.color.toHex() ?? "#0000FF"
        
        try? modelContext.save()
    }
    
    func deleteCard(_ card: Card) {
        guard let cardModel = fetchCardModel(withId: card.id) else {
            return
        }
        
        // Отвязываем карту от транзакций, но не удаляем сами транзакции
        if let transactions = cardModel.transactions {
            for transaction in transactions {
                transaction.card = nil
            }
        }
        
        modelContext.delete(cardModel)
        try? modelContext.save()
    }
    
    func fetchCards() -> [Card] {
        let descriptor = FetchDescriptor<CardModel>()
        
        do {
            let cardModels = try modelContext.fetch(descriptor)
            return cardModels.map { convertToCard($0) }
        } catch {
            print("Ошибка при получении карт: \(error)")
            return []
        }
    }
    
    // MARK: - Categories
    
    func saveCategory(_ category: Category) {
        let categoryModel = CategoryModel(
            id: category.id,
            name: category.name,
            icon: category.icon,
            colorHex: category.color.toHex() ?? "#CCCCCC",
            isExpenseCategory: category.isExpenseCategory
        )
        
        modelContext.insert(categoryModel)
        try? modelContext.save()
    }
    
    func updateCategory(_ category: Category) {
        guard let categoryModel = fetchCategoryModel(withId: category.id) else {
            return
        }
        
        categoryModel.name = category.name
        categoryModel.icon = category.icon
        categoryModel.colorHex = category.color.toHex() ?? "#CCCCCC"
        categoryModel.isExpenseCategory = category.isExpenseCategory
        
        try? modelContext.save()
    }
    
    func deleteCategory(_ category: Category) {
        guard let categoryModel = fetchCategoryModel(withId: category.id) else {
            return
        }
        
        // Проверяем, есть ли транзакции, использующие эту категорию
        if let transactions = categoryModel.transactions, !transactions.isEmpty {
            // Находим категорию "Другое" или создаем ее, если не существует
            var otherCategory = fetchCategoryByName("Другое", isExpense: category.isExpenseCategory)
            
            if otherCategory == nil {
                // Создаем категорию "Другое"
                let otherCategoryModel = CategoryModel(
                    name: "Другое",
                    icon: "questionmark.circle",
                    colorHex: UIColor.gray.toHex() ?? "#CCCCCC",
                    isExpenseCategory: category.isExpenseCategory
                )
                modelContext.insert(otherCategoryModel)
                otherCategory = otherCategoryModel
            }
            
            // Перемещаем все транзакции в категорию "Другое"
            for transaction in transactions {
                transaction.category = otherCategory
            }
        }
        
        modelContext.delete(categoryModel)
        try? modelContext.save()
    }
    
    func fetchCategories() -> [Category] {
        let descriptor = FetchDescriptor<CategoryModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            let categoryModels = try modelContext.fetch(descriptor)
            return categoryModels.map { convertToCategory($0) }
        } catch {
            print("Ошибка при получении категорий: \(error)")
            return []
        }
    }
    
    // MARK: - Credit History
    
    func saveCredit(_ credit: CreditHistory) {
        let creditModel = CreditHistoryModel(
            id: credit.id,
            creditInstitution: credit.creditInstitution,
            creditAmount: credit.creditAmount,
            remainingAmount: credit.remainingAmount,
            interestRate: credit.interestRate,
            startDate: credit.startDate,
            endDate: credit.endDate,
            monthlyPayment: credit.monthlyPayment
        )
        
        modelContext.insert(creditModel)
        
        // Добавляем историю платежей
        for payment in credit.paymentHistory {
            let paymentModel = PaymentModel(
                id: payment.id,
                amount: payment.amount,
                date: payment.date,
                status: payment.status.rawValue,
                credit: creditModel
            )
            modelContext.insert(paymentModel)
        }
        
        try? modelContext.save()
    }
    
    func updateCredit(_ credit: CreditHistory) {
        guard let creditModel = fetchCreditModel(withId: credit.id) else {
            return
        }
        
        creditModel.creditInstitution = credit.creditInstitution
        creditModel.creditAmount = credit.creditAmount
        creditModel.remainingAmount = credit.remainingAmount
        creditModel.interestRate = credit.interestRate
        creditModel.startDate = credit.startDate
        creditModel.endDate = credit.endDate
        creditModel.monthlyPayment = credit.monthlyPayment
        
        // Удаляем существующие платежи
        if let payments = creditModel.payments {
            for payment in payments {
                modelContext.delete(payment)
            }
        }
        
        // Добавляем новые платежи
        for payment in credit.paymentHistory {
            let paymentModel = PaymentModel(
                id: payment.id,
                amount: payment.amount,
                date: payment.date,
                status: payment.status.rawValue,
                credit: creditModel
            )
            modelContext.insert(paymentModel)
        }
        
        try? modelContext.save()
    }
    
    func deleteCredit(_ credit: CreditHistory) {
        guard let creditModel = fetchCreditModel(withId: credit.id) else {
            return
        }
        
        // SwiftData автоматически удалит связанные платежи благодаря правилу каскадного удаления
        modelContext.delete(creditModel)
        try? modelContext.save()
    }
    
    func fetchCreditHistory() -> [CreditHistory] {
        let descriptor = FetchDescriptor<CreditHistoryModel>()
        
        do {
            let creditModels = try modelContext.fetch(descriptor)
            return creditModels.map { convertToCreditHistory($0) }
        } catch {
            print("Ошибка при получении кредитной истории: \(error)")
            return []
        }
    }
    
    // MARK: - Budgets
    
    func saveBudget(_ budget: Budget) {
        var categoryModel: CategoryModel? = nil
        
        // Связываем с категорией, если указана
        if let category = budget.category {
            categoryModel = fetchCategoryModel(withId: category.id)
        }
        
        let budgetModel = BudgetModel(
            id: budget.id,
            amount: budget.amount,
            currentSpent: budget.currentSpent,
            period: budget.period.rawValue,
            startDate: budget.startDate,
            category: categoryModel
        )
        
        modelContext.insert(budgetModel)
        try? modelContext.save()
    }
    
    func updateBudget(_ budget: Budget) {
        guard let budgetModel = fetchBudgetModel(withId: budget.id) else {
            return
        }
        
        budgetModel.amount = budget.amount
        budgetModel.currentSpent = budget.currentSpent
        budgetModel.period = budget.period.rawValue
        budgetModel.startDate = budget.startDate
        
        // Обновляем связь с категорией
        budgetModel.category = nil
        if let category = budget.category {
            if let categoryModel = fetchCategoryModel(withId: category.id) {
                budgetModel.category = categoryModel
            }
        }
        
        try? modelContext.save()
    }
    
    func deleteBudget(_ budget: Budget) {
        guard let budgetModel = fetchBudgetModel(withId: budget.id) else {
            return
        }
        
        modelContext.delete(budgetModel)
        try? modelContext.save()
    }
    
    func fetchBudgets() -> [Budget] {
        let descriptor = FetchDescriptor<BudgetModel>()
        
        do {
            let budgetModels = try modelContext.fetch(descriptor)
            return budgetModels.map { convertToBudget($0) }
        } catch {
            print("Ошибка при получении бюджетов: \(error)")
            return []
        }
    }
    
    // MARK: - Financial Goals
    
    func saveFinancialGoal(_ goal: FinancialGoal) {
        let goalModel = FinancialGoalModel(
            id: goal.id,
            title: goal.title,
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            targetDate: goal.targetDate,
            iconName: goal.iconName,
            colorHex: goal.color.toHex() ?? "#0000FF"
        )
        
        modelContext.insert(goalModel)
        try? modelContext.save()
    }
    
    func updateFinancialGoal(_ goal: FinancialGoal) {
        guard let goalModel = fetchFinancialGoalModel(withId: goal.id) else {
            return
        }
        
        goalModel.title = goal.title
        goalModel.targetAmount = goal.targetAmount
        goalModel.currentAmount = goal.currentAmount
        goalModel.targetDate = goal.targetDate
        goalModel.iconName = goal.iconName
        goalModel.colorHex = goal.color.toHex() ?? "#0000FF"
        
        try? modelContext.save()
    }
    
    func deleteFinancialGoal(_ goal: FinancialGoal) {
        guard let goalModel = fetchFinancialGoalModel(withId: goal.id) else {
            return
        }
        
        modelContext.delete(goalModel)
        try? modelContext.save()
    }
    
    func fetchFinancialGoals() -> [FinancialGoal] {
        let descriptor = FetchDescriptor<FinancialGoalModel>()
        
        do {
            let goalModels = try modelContext.fetch(descriptor)
            return goalModels.map { convertToFinancialGoal($0) }
        } catch {
            print("Ошибка при получении финансовых целей: \(error)")
            return []
        }
    }
    
    // MARK: - Analytics (продолжение)
        
        func getAnalyticsData(for period: AnalyticsPeriod) -> AnalyticsData {
            let endDate = Date()
            let startDate: Date
            
            // Определяем начальную дату периода
            switch period {
            case .week:
                startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
            case .month:
                startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
            case .quarter:
                startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate)!
            case .year:
                startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)!
            }
            
            // Определяем даты для сравнения с предыдущим периодом
            let prevPeriodStartDate: Date
            let prevPeriodEndDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate)!
            
            switch period {
            case .week:
                prevPeriodStartDate = Calendar.current.date(byAdding: .day, value: -7, to: startDate)!
            case .month:
                prevPeriodStartDate = Calendar.current.date(byAdding: .month, value: -1, to: startDate)!
            case .quarter:
                prevPeriodStartDate = Calendar.current.date(byAdding: .month, value: -3, to: startDate)!
            case .year:
                prevPeriodStartDate = Calendar.current.date(byAdding: .year, value: -1, to: startDate)!
            }
            
            // Получаем транзакции текущего периода
            let currentPeriodTransactions = fetchTransactions(from: startDate, to: endDate)
            
            // Получаем транзакции предыдущего периода
            let prevPeriodTransactions = fetchTransactions(from: prevPeriodStartDate, to: prevPeriodEndDate)
            
            // Общая сумма доходов и расходов за текущий период
            let currentIncome = currentPeriodTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
            let currentExpenses = currentPeriodTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
            
            // Общая сумма доходов и расходов за предыдущий период
            let prevIncome = prevPeriodTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
            let prevExpenses = prevPeriodTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
            
            // Расчет трендов (процентная разница)
            let incomeTrend = prevIncome > 0 ? ((currentIncome - prevIncome) / prevIncome) * 100 : 0
            let expensesTrend = prevExpenses > 0 ? ((currentExpenses - prevExpenses) / prevExpenses) * 100 : 0
            
            // Группировка расходов по категориям
            var categoryExpenses: [UUID: Double] = [:]
            for transaction in currentPeriodTransactions where transaction.isExpense {
                let categoryId = transaction.category.id
                categoryExpenses[categoryId] = (categoryExpenses[categoryId] ?? 0) + transaction.amount
            }
            
            // Создаем данные о распределении по категориям
            let categoryDistribution = categoryExpenses.map { (categoryId, amount) in
                let transaction = currentPeriodTransactions.first { $0.category.id == categoryId }!
                return CategoryDistribution(
                    categoryId: categoryId,
                    categoryName: transaction.category.name,
                    icon: transaction.category.icon,
                    color: transaction.category.color,
                    amount: amount
                )
            }.sorted { $0.amount > $1.amount }
            
            // Создаем историю баланса по дням
            var balanceHistory: [BalancePoint] = []
            
            // Сортируем транзакции по дате
            let sortedTransactions = currentPeriodTransactions.sorted { $0.date < $1.date }
            
            // Получаем начальный баланс (сумма всех карт на начало периода)
            let cards = fetchCards()
            let startBalance = cards.reduce(0) { $0 + $1.balance }
            
            // Рассчитываем баланс на каждый день
            var currentBalance = startBalance
            let calendar = Calendar.current
            
            var currentDate = startDate
            while currentDate <= endDate {
                let dayStart = calendar.startOfDay(for: currentDate)
                let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart)!
                
                // Находим все транзакции за текущий день
                let dayTransactions = sortedTransactions.filter {
                    $0.date >= dayStart && $0.date < nextDay
                }
                
                // Обновляем баланс
                for transaction in dayTransactions {
                    if transaction.isExpense {
                        currentBalance -= transaction.amount
                    } else {
                        currentBalance += transaction.amount
                    }
                }
                
                // Добавляем точку баланса
                balanceHistory.append(BalancePoint(date: currentDate, amount: currentBalance))
                
                // Переходим к следующему дню
                currentDate = nextDay
            }
            
            // Создаем и возвращаем аналитические данные
            return AnalyticsData(
                overviewData: OverviewData(
                    totalIncome: currentIncome,
                    totalExpenses: currentExpenses,
                    balance: currentIncome - currentExpenses,
                    incomeTrend: incomeTrend,
                    expensesTrend: expensesTrend,
                    balanceHistory: balanceHistory
                ),
                expensesData: ExpensesData(
                    totalExpenses: currentExpenses,
                    categoryDistribution: categoryDistribution,
                    expensesTrend: expensesTrend
                ),
                incomeData: IncomeData(
                    totalIncome: currentIncome,
                    incomeTrend: incomeTrend
                ),
                balanceData: BalanceData(
                    currentBalance: currentIncome - currentExpenses,
                    startBalance: startBalance,
                    balanceHistory: balanceHistory
                )
            )
        }
        
        // MARK: - Settings
        
        func getPinCode() -> String? {
            return KeychainService().getPinCode()
        }
        
        func setPinCode(_ pinCode: String) {
            KeychainService().savePinCode(pinCode)
        }
        
        func removePinCode() {
            KeychainService().deletePinCode()
        }
        
        // MARK: - Data Management
        
        func clearAllData() {
            // Удаляем все сущности
            clearEntityData(for: TransactionModel.self)
            clearEntityData(for: CardModel.self)
            clearEntityData(for: CategoryModel.self)
            clearEntityData(for: CreditHistoryModel.self)
            clearEntityData(for: PaymentModel.self)
            clearEntityData(for: BudgetModel.self)
            clearEntityData(for: FinancialGoalModel.self)
            
            // Удаляем пин-код
            removePinCode()
            
            // Сбрасываем флаг настройки начальных данных
            UserDefaults.standard.set(false, forKey: "didSetupInitialData")
            
            // Создаем базовые категории заново
            setupInitialData()
        }
        
        private func clearEntityData<T: PersistentModel>(for entityType: T.Type) {
            do {
                let descriptor = FetchDescriptor<T>()
                let items = try modelContext.fetch(descriptor)
                
                for item in items {
                    modelContext.delete(item)
                }
                
                try modelContext.save()
            } catch {
                print("Ошибка при удалении данных для \(String(describing: entityType)): \(error)")
            }
        }
        
        // MARK: - Import/Export
        
        func importTransactions(_ transactions: [Transaction]) {
            for transaction in transactions {
                saveTransaction(transaction)
            }
        }
        
        func importCategories(_ categories: [Category]) {
            for category in categories {
                // Проверяем, существует ли уже такая категория
                if fetchCategoryByName(category.name, isExpense: category.isExpenseCategory) == nil {
                    saveCategory(category)
                }
            }
        }
        
        func importCards(_ cards: [Card]) {
            for card in cards {
                // Проверяем, существует ли уже такая карта
                if !cardExists(withNumber: card.cardNumber) {
                    saveCard(card)
                }
            }
        }
        
        // MARK: - Helper Methods
        
        // Обновляет баланс бюджетов на основе новых транзакций
        func updateBudgets(with transaction: Transaction) {
            // Пропускаем, если это доход
            if !transaction.isExpense {
                return
            }
            
            let currentDate = Date()
            let budgets = fetchBudgets()
            
            for var budget in budgets {
                let endDate = calculateBudgetEndDate(budget)
                
                // Проверяем, попадает ли транзакция в текущий период бюджета
                if transaction.date >= budget.startDate && transaction.date <= endDate {
                    // Если бюджет для категории и категория совпадает, или если общий бюджет
                    if (budget.category != nil && budget.category?.id == transaction.category.id) ||
                       budget.category == nil {
                        // Увеличиваем текущие расходы
                        budget.currentSpent += transaction.amount
                        updateBudget(budget)
                        
                        // Проверяем, не превышен ли бюджет, и отправляем уведомление
                        if budget.currentSpent >= budget.amount * 0.8 && budget.currentSpent < budget.amount {
                            NotificationService.shared.scheduleBudgetAlert(for: budget, percentThreshold: 0.8)
                        } else if budget.currentSpent >= budget.amount {
                            NotificationService.shared.scheduleBudgetAlert(for: budget, percentThreshold: 1.0)
                        }
                    }
                }
            }
        }
        
        private func calculateBudgetEndDate(_ budget: Budget) -> Date {
            let calendar = Calendar.current
            switch budget.period {
            case .weekly:
                return calendar.date(byAdding: .day, value: 7, to: budget.startDate)!
            case .monthly:
                return calendar.date(byAdding: .month, value: 1, to: budget.startDate)!
            case .yearly:
                return calendar.date(byAdding: .year, value: 1, to: budget.startDate)!
            }
        }
        
        // Проверяет, нужно ли обновить бюджеты (например, при новом периоде)
        func checkAndUpdateBudgetPeriods() {
            let budgets = fetchBudgets()
            let currentDate = Date()
            
            for var budget in budgets {
                let endDate = calculateBudgetEndDate(budget)
                
                // Если текущий период бюджета закончился, начинаем новый
                if currentDate > endDate {
                    // Создаем новый период бюджета
                    let newStartDate: Date
                    
                    switch budget.period {
                    case .weekly:
                        // Новый период начинается с понедельника текущей недели
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
                        newStartDate = calendar.date(from: components)!
                    case .monthly:
                        // Новый период начинается с первого числа текущего месяца
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month], from: currentDate)
                        newStartDate = calendar.date(from: components)!
                    case .yearly:
                        // Новый период начинается с первого дня текущего года
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year], from: currentDate)
                        newStartDate = calendar.date(from: components)!
                    }
                    
                    // Обновляем бюджет
                    budget.startDate = newStartDate
                    budget.currentSpent = 0 // Сбрасываем текущие расходы
                    updateBudget(budget)
                }
            }
        }
        
        // Возвращает транзакции для указанной карты
        func fetchTransactionsForCard(_ cardId: UUID) -> [Transaction] {
            let predicate = #Predicate<TransactionModel> { transaction in
                transaction.card?.id == cardId
            }
            
            let descriptor = FetchDescriptor<TransactionModel>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            
            do {
                let transactionModels = try modelContext.fetch(descriptor)
                return transactionModels.map { convertToTransaction($0) }
            } catch {
                print("Ошибка при получении транзакций для карты: \(error)")
                return []
            }
        }
        
        // MARK: - Private Helpers
        
        private func fetchTransactionModel(withId id: UUID) -> TransactionModel? {
            let predicate = #Predicate<TransactionModel> { transaction in
                transaction.id == id
            }
            
            let descriptor = FetchDescriptor<TransactionModel>(predicate: predicate)
            
            do {
                let results = try modelContext.fetch(descriptor)
                return results.first
            } catch {
                print("Ошибка при поиске транзакции: \(error)")
                return nil
            }
        }
        
        private func fetchCategoryModel(withId id: UUID) -> CategoryModel? {
            let predicate = #Predicate<CategoryModel> { category in
                category.id == id
            }
            
            let descriptor = FetchDescriptor<CategoryModel>(predicate: predicate)
            
            do {
                let results = try modelContext.fetch(descriptor)
                return results.first
            } catch {
                print("Ошибка при поиске категории: \(error)")
                return nil
            }
        }
        
        private func fetchCategoryByName(_ name: String, isExpense: Bool) -> CategoryModel? {
            let predicate = #Predicate<CategoryModel> { category in
                category.name == name && category.isExpenseCategory == isExpense
            }
            
            let descriptor = FetchDescriptor<CategoryModel>(predicate: predicate)
            
            do {
                let results = try modelContext.fetch(descriptor)
                return results.first
            } catch {
                print("Ошибка при поиске категории по имени: \(error)")
                return nil
            }
        }
        
        private func fetchCardModel(withId id: UUID) -> CardModel? {
            let predicate = #Predicate<CardModel> { card in
                card.id == id
            }
            
            let descriptor = FetchDescriptor<CardModel>(predicate: predicate)
            
            do {
                let results = try modelContext.fetch(descriptor)
                return results.first
            } catch {
                print("Ошибка при поиске карты: \(error)")
                return nil
            }
        }
        
        private func cardExists(withNumber number: String) -> Bool {
            let predicate = #Predicate<CardModel> { card in
                card.cardNumber == number
            }
            
            let descriptor = FetchDescriptor<CardModel>(predicate: predicate)
            
            do {
                let results = try modelContext.fetch(descriptor)
                return !results.isEmpty
            } catch {
                print("Ошибка при проверке существования карты: \(error)")
                return false
            }
        }
        
        private func fetchBudgetModel(withId id: UUID) -> BudgetModel? {
            let predicate = #Predicate<BudgetModel> { budget in
                budget.id == id
            }
            
            let descriptor = FetchDescriptor<BudgetModel>(predicate: predicate)
            
            do {
                let results = try modelContext.fetch(descriptor)
                return results.first
            } catch {
                print("Ошибка при поиске бюджета: \(error)")
                return nil
            }
        }
        
        private func fetchFinancialGoalModel(withId id: UUID) -> FinancialGoalModel? {
            let predicate = #Predicate<FinancialGoalModel> { goal in
                goal.id == id
            }
            
            let descriptor = FetchDescriptor<FinancialGoalModel>(predicate: predicate)
            
            do {
                let results = try modelContext.fetch(descriptor)
                return results.first
            } catch {
                print("Ошибка при поиске финансовой цели: \(error)")
                return nil
            }
        }
        
        private func fetchCreditModel(withId id: UUID) -> CreditHistoryModel? {
            let predicate = #Predicate<CreditHistoryModel> { credit in
                credit.id == id
            }
            
            let descriptor = FetchDescriptor<CreditHistoryModel>(predicate: predicate)
            
            do {
                let results = try modelContext.fetch(descriptor)
                return results.first
            } catch {
                print("Ошибка при поиске кредитной истории: \(error)")
                return nil
            }
        }
        
        // MARK: - Model Conversion Helpers
        
        private func convertToTransaction(_ model: TransactionModel) -> Transaction {
            let category = model.category != nil ? convertToCategory(model.category!) : Category(
                id: UUID(),
                name: "Без категории",
                icon: "questionmark.circle",
                color: .gray,
                isExpenseCategory: model.isExpense
            )
            
            return Transaction(
                id: model.id,
                amount: model.amount,
                title: model.title,
                description: model.transactionDescription,
                category: category,
                date: model.date,
                cardId: model.card?.id,
                isExpense: model.isExpense
            )
        }
        
        private func convertToCategory(_ model: CategoryModel) -> Category {
            Category(
                id: model.id,
                name: model.name,
                icon: model.icon,
                color: Color(hex: model.colorHex) ?? .gray,
                isExpenseCategory: model.isExpenseCategory
            )
        }
        
        private func convertToCard(_ model: CardModel) -> Card {
            Card(
                id: model.id,
                cardNumber: model.cardNumber,
                cardHolderName: model.cardHolderName,
                expiryDate: model.expiryDate,
                bank: model.bank,
                cardType: model.cardType == "credit" ? .credit : .debit,
                balance: model.balance,
                currency: Currency(rawValue: model.currency) ?? .rub,
                color: Color(hex: model.colorHex) ?? .blue
            )
        }
        
        private func convertToBudget(_ model: BudgetModel) -> Budget {
            let category = model.category != nil ? convertToCategory(model.category!) : nil
            
            return Budget(
                id: model.id,
                category: category,
                amount: model.amount,
                currentSpent: model.currentSpent,
                period: BudgetPeriod.fromRawValue(model.period),
                startDate: model.startDate
            )
        }
        
        private func convertToFinancialGoal(_ model: FinancialGoalModel) -> FinancialGoal {
            FinancialGoal(
                id: model.id,
                title: model.title,
                targetAmount: model.targetAmount,
                currentAmount: model.currentAmount,
                targetDate: model.targetDate,
                iconName: model.iconName,
                color: Color(hex: model.colorHex) ?? .blue
            )
        }
        
        private func convertToCreditHistory(_ model: CreditHistoryModel) -> CreditHistory {
            let payments: [Payment] = (model.payments ?? []).map { paymentModel in
                Payment(
                    id: paymentModel.id,
                    amount: paymentModel.amount,
                    date: paymentModel.date,
                    status: PaymentStatus.fromRawValue(paymentModel.status)
                )
            }
            
            return CreditHistory(
                id: model.id,
                creditInstitution: model.creditInstitution,
                creditAmount: model.creditAmount,
                remainingAmount: model.remainingAmount,
                interestRate: model.interestRate,
                startDate: model.startDate,
                endDate: model.endDate,
                monthlyPayment: model.monthlyPayment,
                paymentHistory: payments
            )
        }
    }
