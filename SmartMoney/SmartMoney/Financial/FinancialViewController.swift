import UIKit

protocol FinancialViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func display(_ messages: [MessageModel])
    func display(_ message: MessageModel)
}

class FinancialViewController: UIViewController {
    private var interactor: FinancialInteractorProtocol
    private var messages: [MessageModel] = []
    
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
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()
    
    init(interactor: FinancialInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        
        interactor.getMessages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if messages.isEmpty {
            addWelcomeMessage()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
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
        let message = MessageModel(text: "Я твой финансовый ИИ-консультант :)", sender: .ai)
        interactor.addMessage(message)
    }
    
    @objc private func recommendationsButtonTapped() {
        let message = MessageModel(text: "Получить рекомендации", sender: .user)
        
        interactor.addMessage(message)
        interactor.getRecommendations()
    }
    
    @objc private func predictionButtonTapped() {
        let message = MessageModel(text: "Получить прогноз расходов и доходов", sender: .user)
        interactor.addMessage(message)
        interactor.getPrediction()
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
        cell.configure(with: message.sender, message: message.text, date: message.date)
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
    
    func display(_ messages: [MessageModel]) {
        self.messages = messages
        tableView.reloadData()
        scrollToBottom()
    }
    
    func display(_ message: MessageModel) {
        messages.append(message)
        tableView.reloadData()
        scrollToBottom()
    }
}
