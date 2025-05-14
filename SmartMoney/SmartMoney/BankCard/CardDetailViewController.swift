import UIKit

class CardDetailViewController: UIViewController {
    private var card: BankCard?
    
    private let cardNumberTextField = UITextField()
    private let holderNameTextField = UITextField()
    private let expiryDateTextField = UITextField()
    private let cvcTextField = UITextField()
    private let balanceTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    
    init(card: BankCard?) {
        self.card = card
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fillData()
    }
    
    private func setupUI() {
        title = card == nil ? "Add Card" : "Edit Card"
        view.backgroundColor = .white
        
        // Set up text fields
        setupTextField(cardNumberTextField, placeholder: "Card Number")
        setupTextField(holderNameTextField, placeholder: "Card Holder Name")
        setupTextField(expiryDateTextField, placeholder: "Expiry Date (MM/YY)")
        setupTextField(cvcTextField, placeholder: "CVC")
        setupTextField(balanceTextField, placeholder: "Balance")
        
        // Save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        
        // Layout
        cardNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        holderNameTextField.translatesAutoresizingMaskIntoConstraints = false
        expiryDateTextField.translatesAutoresizingMaskIntoConstraints = false
        cvcTextField.translatesAutoresizingMaskIntoConstraints = false
        balanceTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardNumberTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardNumberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardNumberTextField.heightAnchor.constraint(equalToConstant: 50),
            
            holderNameTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: 20),
            holderNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            holderNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            holderNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            expiryDateTextField.topAnchor.constraint(equalTo: holderNameTextField.bottomAnchor, constant: 20),
            expiryDateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            expiryDateTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -30),
            expiryDateTextField.heightAnchor.constraint(equalToConstant: 50),
            
            cvcTextField.topAnchor.constraint(equalTo: holderNameTextField.bottomAnchor, constant: 20),
            cvcTextField.leadingAnchor.constraint(equalTo: expiryDateTextField.trailingAnchor, constant: 20),
            cvcTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cvcTextField.heightAnchor.constraint(equalToConstant: 50),
            
            balanceTextField.topAnchor.constraint(equalTo: expiryDateTextField.bottomAnchor, constant: 20),
            balanceTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            balanceTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            balanceTextField.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: balanceTextField.bottomAnchor, constant: 40),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6
        view.addSubview(textField)
    }
    
    private func fillData() {
        guard let card = card else { return }
        cardNumberTextField.text = card.number
        holderNameTextField.text = card.holderName
        expiryDateTextField.text = card.expiryDate
        cvcTextField.text = card.cvc
        balanceTextField.text = String(card.balance)
    }
    
    @objc private func saveButtonTapped() {
        guard
            let number = cardNumberTextField.text, !number.isEmpty,
            let holderName = holderNameTextField.text, !holderName.isEmpty,
            let expiryDate = expiryDateTextField.text, !expiryDate.isEmpty,
            let cvc = cvcTextField.text, !cvc.isEmpty,
            let balanceText = balanceTextField.text, !balanceText.isEmpty,
            let balance = Double(balanceText)
        else {
            showAlert(message: "Please fill all fields correctly")
            return
        }
        
        let newCard = BankCard(
            id: card?.id ?? UUID(),
            number: number,
            holderName: holderName,
            cvc: cvc,
            expiryDate: expiryDate,
            balance: balance
        )
        
        if let presentingVC = navigationController?.viewControllers.first as? BankCardsViewController {
            if card == nil {
                presentingVC.presenter.addNewCard(newCard)
            } else {
                presentingVC.presenter.updateCard(newCard)
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
