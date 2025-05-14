import UIKit

protocol FinancialViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func displayRecommendations(_ recommendations: [String])
    func displayPrediction(_ prediction: Prediction)
    func displayError(_ message: String)
}

struct Message {
    let sender: Sender
    let text: String
}

extension Message {
    enum Sender: String {
        case ai
        case user
    }
}

class FinancialViewController: UIViewController {
    private var presenter: FinancialPresenterProtocol!
    private var messages: [Message] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var recommendationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Получить рекомендации", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(recommendationsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var predictionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Получить финансовый прогноз", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(predictionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()
    
    init(presenter: FinancialPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addWelcomeMessage()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Финансовый ИИ консультант"
        
        view.addSubview(tableView)
        view.addSubview(buttonStack)
        view.addSubview(activityIndicator)
        
        buttonStack.addArrangedSubview(recommendationsButton)
        buttonStack.addArrangedSubview(predictionButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -16),
            
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func addWelcomeMessage() {
        let message = "Hello! I'm your financial AI assistant. I can provide recommendations to improve your financial situation or forecast your future income and expenses. What would you like to know?"
        messages.append(Message(sender: .ai, text: message))
        tableView.reloadData()
    }
    
    @objc private func recommendationsButtonTapped() {
        messages.append(Message(sender: .user, text: "Получить рекомендации"))
        
        presenter.requestRecommendations()
        tableView.reloadData()
        scrollToBottom()
        
    }
    
    @objc private func predictionButtonTapped() {
        messages.append(Message(sender: .user, text: "Получить прогноз расходов и доходов"))
        
        presenter.requestPrediction()
        tableView.reloadData()
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        let lastRow = messages.count - 1
        if lastRow >= 0 {
            let indexPath = IndexPath(row: lastRow, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension FinancialViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.configure(with: message.sender.rawValue, message: message.text)
        return cell
    }
}

extension FinancialViewController: FinancialViewProtocol {
    func showLoading() {
        activityIndicator.startAnimating()
        buttonStack.isUserInteractionEnabled = false
        recommendationsButton.alpha = 0.5
        predictionButton.alpha = 0.5
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        buttonStack.isUserInteractionEnabled = true
        recommendationsButton.alpha = 1.0
        predictionButton.alpha = 1.0
    }
    
    func displayRecommendations(_ recommendations: [String]) {
        var formattedMessage = "Based on your financial data, here are my recommendations:\n\n"
        
        for (index, recommendation) in recommendations.enumerated() {
            formattedMessage += "\(index + 1). \(recommendation)\n"
        }
        
        messages.append(Message(sender: .ai, text: formattedMessage))
        tableView.reloadData()
        scrollToBottom()
    }
    
    func displayPrediction(_ prediction: Prediction) {
        let formattedIncome = String(format: "%.2f", prediction.incomeNextMonth)
        let formattedExpenses = String(format: "%.2f", prediction.expensesNextMonth)
        let difference = prediction.incomeNextMonth - prediction.expensesNextMonth
        let formattedDifference = String(format: "%.2f", difference)
        
        var message = "Based on your historical data, here's my forecast for next month:\n\n"
        message += "• Predicted income: $\(formattedIncome)\n"
        message += "• Predicted expenses: $\(formattedExpenses)\n\n"
        
        if difference > 0 {
            message += "You're projected to save $\(formattedDifference) next month! 👍"
        } else if difference < 0 {
            message += "Warning: You're projected to have a deficit of $\(abs(difference)) next month. Consider reducing expenses. ⚠️"
        } else {
            message += "You're projected to break even next month."
        }
        
        messages.append(Message(sender: .ai, text: message))
        tableView.reloadData()
        scrollToBottom()
    }
    
    func displayError(_ message: String) {
        let errorMessage = "Sorry, I encountered an error: \(message). Please try again."
        messages.append(Message(sender: .ai, text: errorMessage))
        tableView.reloadData()
        scrollToBottom()
    }
}
