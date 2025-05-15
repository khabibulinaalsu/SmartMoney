import UIKit

// MARK: - TransactionsListPresenterProtocolv
protocol TransactionsListPresenterProtocol: PresenterProtocol {
    func presentData(response: TransactionsList.FetchTransactions.Response)
    func presentData(response: TransactionsList.ShowFilters.Response)
    func presentData(response: (startDate: Date, endDate: Date))
}

// MARK: - TransactionsListPresenter
class TransactionsListPresenter: TransactionsListPresenterProtocol {
    weak var viewController: (ViewProtocol & UIViewController)?
    
    func presentData(response: TransactionsList.FetchTransactions.Response) {
        presentTransactions(response: response)
    }
    
    func presentData(response: TransactionsList.ShowFilters.Response) {
        presentFilters(response: response)
    }
    
    func presentData(response: (startDate: Date, endDate: Date)) {
        presentPeriodPickerData(startDate: response.startDate, endDate: response.endDate)
    }
    
    func presentData(response: Any) {
        if let response = response as? TransactionsList.FetchTransactions.Response {
            presentTransactions(response: response)
        } else if let response = response as? TransactionsList.ShowFilters.Response {
            presentFilters(response: response)
        } else if let periodData = response as? (startDate: Date, endDate: Date) {
            presentPeriodPickerData(startDate: periodData.startDate, endDate: periodData.endDate)
        }
    }
    
    private func presentTransactions(response: TransactionsList.FetchTransactions.Response) {
        // Группируем транзакции по дням
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: response.transactions) { transaction in
            calendar.startOfDay(for: transaction.dateAndTime)
        }
        
        // Сортируем дни в обратном порядке (сначала новые)
        let sortedDays = grouped.keys.sorted(by: >)
        
        // Вычисляем доходы и расходы
        var totalIncome: Double = 0
        var totalExpense: Double = 0
        
        for transaction in response.transactions {
            if transaction.isExpense {
                totalExpense += transaction.amount
            } else {
                totalIncome += transaction.amount
            }
        }
        
        // Форматируем данные для отображения
        let sections = sortedDays.map { day -> TransactionsList.FetchTransactions.ViewModel.Section in
            let dayTransactions = grouped[day] ?? []
            
            // Форматируем дату
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM yyyy"
            dateFormatter.locale = Locale(identifier: "ru_RU")
            let dateTitle = dateFormatter.string(from: day)
            
            // Преобразуем транзакции в ViewModel
            let transactionViewModels = dayTransactions.map { transaction -> TransactionListItemViewModel in
                let categoryName = transaction.category?.name ?? "Без категории"
                let categoryColor = UIColor(hex: transaction.category?.colorHEX ?? "#888888") ?? .gray
                
                return TransactionListItemViewModel(
                    id: transaction.id,
                    title: transaction.title,
                    description: transaction.annotation,
                    amount: transaction.amount,
                    categoryName: categoryName,
                    categoryColor: categoryColor,
                    dateAndTime: transaction.dateAndTime,
                    isExpense: transaction.isExpense
                )
            }
            
            return TransactionsList.FetchTransactions.ViewModel.Section(
                dateTitle: dateTitle,
                transactions: transactionViewModels
            )
        }
        
        let viewModel = TransactionsList.FetchTransactions.ViewModel(
            transactionsByDays: sections,
            totalIncome: totalIncome,
            totalExpense: totalExpense
        )
        
        DispatchQueue.main.async {
            guard let transactionsViewController = self.viewController as? TransactionsListViewController else { return }
            transactionsViewController.displayData(viewModel: viewModel)
        }
    }
    
    private func presentFilters(response: TransactionsList.ShowFilters.Response) {
        let categories = response.categories.map { category -> (CategoryModel, Bool) in
            let isSelected = response.selectedCategories.contains { $0.id == category.id }
            return (category, isSelected)
        }
        
        let viewModel = TransactionsList.ShowFilters.ViewModel(categories: categories)
        
        DispatchQueue.main.async {
            guard let transactionsViewController = self.viewController as? TransactionsListViewController else { return }
            transactionsViewController.displayData(viewModel: viewModel)
        }
    }
    
    private func presentPeriodPickerData(startDate: Date, endDate: Date) {
        DispatchQueue.main.async {
            guard let transactionsViewController = self.viewController as? TransactionsListViewController else { return }
            //transactionsViewController.displayPeriodPicker(startDate: startDate, endDate: endDate)
        }
    }
}
