import UIKit

protocol BankCardsViewProtocol: AnyObject {
    func updateView()
}

class BankCardsViewController: UIViewController, BankCardsViewProtocol {
    var presenter: BankCardsPresenterProtocol!
    
    private let balanceView = UIView()
    private let totalBalanceLabel = UILabel()
    private let cashBalanceLabel = UILabel()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    func updateView() {
        totalBalanceLabel.text = "Всего: \(presenter.totalBalance)"
        cashBalanceLabel.text = "Наличными: \(presenter.cashBalance)"
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCardTapped))
        navigationItem.rightBarButtonItem = addButton
        
        // Balance view
        balanceView.backgroundColor = .systemBlue
        balanceView.layer.cornerRadius = 12
        view.addSubview(balanceView)
        
        totalBalanceLabel.textColor = .white
        totalBalanceLabel.font = .boldSystemFont(ofSize: 18)
        balanceView.addSubview(totalBalanceLabel)
        
        cashBalanceLabel.textColor = .white
        cashBalanceLabel.font = .systemFont(ofSize: 16)
        balanceView.addSubview(cashBalanceLabel)
        
        // Table view
        tableView.register(CardCell.self, forCellReuseIdentifier: "CardCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        // Layout constraints
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        totalBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        cashBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            balanceView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            balanceView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            balanceView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            balanceView.heightAnchor.constraint(equalToConstant: 80),
            
            totalBalanceLabel.topAnchor.constraint(equalTo: balanceView.topAnchor, constant: 16),
            totalBalanceLabel.leadingAnchor.constraint(equalTo: balanceView.leadingAnchor, constant: 16),
            totalBalanceLabel.trailingAnchor.constraint(equalTo: balanceView.trailingAnchor, constant: -16),
            
            cashBalanceLabel.topAnchor.constraint(equalTo: totalBalanceLabel.bottomAnchor, constant: 8),
            cashBalanceLabel.leadingAnchor.constraint(equalTo: balanceView.leadingAnchor, constant: 16),
            cashBalanceLabel.trailingAnchor.constraint(equalTo: balanceView.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: balanceView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func addCardTapped() {
        let router = presenter as? BankCardsRouter
        router?.showCardDetails(nil)
    }
}

// UITableViewDataSource & UITableViewDelegate
extension BankCardsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
        let card = presenter.cards[indexPath.row]
        cell.configure(with: card)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let card = presenter.cards[indexPath.row]
        let router = presenter as? BankCardsRouter
        router?.showCardDetails(card)
    }
}
