import UIKit

class TransactionsListViewController: UIViewController {
    var interactor: TransactionsListInteractorProtocol?
    var router: TransactionsListRouterProtocol?
    
    // MARK: - UI Components
    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(showFilters))
        return button
    }()
    
    private lazy var statisticsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chart.bar"), style: .plain, target: self, action: #selector(showStatistics))
        return button
    }()
    
    private lazy var periodButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "За месяц", style: .plain, target: self, action: #selector(showPeriodPicker))
        return button
    }()
    
    private lazy var incomeProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = .systemGray5
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private lazy var expenseProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = .systemRed
        progressView.trackTintColor = .systemGray5
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private lazy var incomeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGreen
        label.text = "Доходы: 0 ₽"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var expenseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.text = "Расходы: 0 ₽"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addTransactionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(addTransactionTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var qrScanner: ReceiptQRScannerModule?
    
    // MARK: - Data
    var viewModel: TransactionsList.FetchTransactions.ViewModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        interactor?.fetchData(request: TransactionsList.FetchTransactions.Request())
        tableView.reloadData()
        setupQRScanner()
    }
    
    override func viewWillAppear(_ bool: Bool) {
        super.viewWillAppear(bool)
        interactor?.fetchData(request: TransactionsList.FetchTransactions.Request())
        tableView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItems = [filterButton, periodButton]
        navigationItem.rightBarButtonItem = statisticsButton
        
        view.addSubview(incomeProgressView)
        view.addSubview(expenseProgressView)
        view.addSubview(incomeLabel)
        view.addSubview(expenseLabel)
        view.addSubview(tableView)
        view.addSubview(addTransactionButton)
        
        NSLayoutConstraint.activate([
            incomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            incomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            incomeProgressView.topAnchor.constraint(equalTo: incomeLabel.bottomAnchor, constant: 4),
            incomeProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            incomeProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            incomeProgressView.heightAnchor.constraint(equalToConstant: 6),
            
            expenseLabel.topAnchor.constraint(equalTo: incomeProgressView.bottomAnchor, constant: 8),
            expenseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            expenseProgressView.topAnchor.constraint(equalTo: expenseLabel.bottomAnchor, constant: 4),
            expenseProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            expenseProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            expenseProgressView.heightAnchor.constraint(equalToConstant: 6),
            
            tableView.topAnchor.constraint(equalTo: expenseProgressView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            addTransactionButton.widthAnchor.constraint(equalToConstant: 60),
            addTransactionButton.heightAnchor.constraint(equalToConstant: 60),
            addTransactionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addTransactionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupQRScanner() {
        qrScanner = ReceiptQRScannerModule(presentingViewController: self)
        qrScanner?.delegate = self
    }
    
    // MARK: - Actions
    @objc private func showFilters() {
        interactor?.performAction(request: TransactionsList.ShowFilters.Request())
    }
    
    @objc private func showPeriodPicker() {
        interactor?.performAction(request: TransactionsList.ShowPeriodPicker.Request())
    }
    
    @objc private func showStatistics() {
        router?.navigateTo(destination: TransactionsList.Destination.statistics)
    }
    
    @objc private func addTransactionTapped() {
        let actionSheet = UIAlertController(title: "Добавить транзакцию", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Вручную", style: .default) { [weak self] _ in
            self?.router?.navigateTo(destination: TransactionsList.Destination.addTransaction(transaction: nil))
        })
        
        actionSheet.addAction(UIAlertAction(title: "Сканировать QR код чека", style: .default) { [weak self] _ in
            self?.router?.navigateTo(destination: TransactionsList.Destination.scanQRCode)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Выбрать фото с QR кодом", style: .default) { [weak self] _ in
            self?.router?.navigateTo(destination: TransactionsList.Destination.selectQRCodeImage)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = addTransactionButton
            popoverController.sourceRect = addTransactionButton.bounds
        }
        
        present(actionSheet, animated: true)
    }
}

// MARK: - TransactionsListViewProtocol
extension TransactionsListViewController: ViewProtocol {
    func displayData(viewModel: Any) {
        if let viewModel = viewModel as? TransactionsList.FetchTransactions.ViewModel {
            self.viewModel = viewModel
            
            // Обновить шкалу прогресса
            if viewModel.totalExpense > 0 {
                expenseProgressView.progress = 1.0
                expenseLabel.text = "Расходы: \(String(format: "%.2f", viewModel.totalExpense)) ₽"
            }
            
            if viewModel.totalIncome > 0 {
                incomeProgressView.progress = 1.0
                incomeLabel.text = "Доходы: \(String(format: "%.2f", viewModel.totalIncome)) ₽"
            }
            
            if viewModel.totalExpense > 0 && viewModel.totalIncome > 0 {
                if viewModel.totalExpense > viewModel.totalIncome {
                    incomeProgressView.progress = Float(viewModel.totalIncome / viewModel.totalExpense)
                } else {
                    expenseProgressView.progress = Float(viewModel.totalExpense / viewModel.totalIncome)
                }
            }
            
            // Обновить данные в таблице
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TransactionsListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.transactionsByDays.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.transactionsByDays[section].transactions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let daySection = viewModel?.transactionsByDays[section] else { return nil }
        return daySection.dateTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseId, for: indexPath) as? TransactionCell,
              let transaction = viewModel?.transactionsByDays[indexPath.section].transactions[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let transaction = viewModel?.transactionsByDays[indexPath.section].transactions[indexPath.row] else { return }
        router?.navigateTo(destination: TransactionsList.Destination.transactionDetails(transaction: transaction))
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (_, _, completion) in
            guard let transaction = self?.viewModel?.transactionsByDays[indexPath.section].transactions[indexPath.row] else {
                completion(false)
                return
            }
            
            self?.interactor?.performAction(request: TransactionsList.DeleteTransaction.Request(transactionId: transaction.id))
            completion(true)

        }
        
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
