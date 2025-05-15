import UIKit

class CardCell: UITableViewCell {
    private let cardView = UIView()
    private let numberLabel = UILabel()
    private let holderNameLabel = UILabel()
    private let expiryDateLabel = UILabel()
    private let cvcLabel = UILabel()
    private let balanceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        cardView.backgroundColor = .systemBlue
        cardView.layer.cornerRadius = 16
        contentView.addSubview(cardView)
        
        // Labels
        numberLabel.textColor = .white
        numberLabel.font = .systemFont(ofSize: 18)
        cardView.addSubview(numberLabel)
        
        holderNameLabel.textColor = .white
        holderNameLabel.font = .systemFont(ofSize: 16)
        cardView.addSubview(holderNameLabel)
        
        expiryDateLabel.textColor = .white
        expiryDateLabel.font = .systemFont(ofSize: 14)
        cardView.addSubview(expiryDateLabel)
        
        cvcLabel.textColor = .white
        cvcLabel.font = .systemFont(ofSize: 14)
        cardView.addSubview(cvcLabel)
        
        balanceLabel.textColor = .white
        balanceLabel.font = .boldSystemFont(ofSize: 18)
        cardView.addSubview(balanceLabel)
        
        // Layout
        cardView.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        holderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        expiryDateLabel.translatesAutoresizingMaskIntoConstraints = false
        cvcLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            numberLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            numberLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            numberLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            holderNameLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 12),
            holderNameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            expiryDateLabel.topAnchor.constraint(equalTo: holderNameLabel.bottomAnchor, constant: 12),
            expiryDateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            cvcLabel.topAnchor.constraint(equalTo: holderNameLabel.bottomAnchor, constant: 12),
            cvcLabel.leadingAnchor.constraint(equalTo: expiryDateLabel.trailingAnchor, constant: 16),
            
            balanceLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            balanceLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with card: BankCard) {
        numberLabel.text = formatCardNumber(card.number)
        holderNameLabel.text = card.holderName
        expiryDateLabel.text = "Exp: \(card.expiryDate)"
        cvcLabel.text = "CVC: \(card.cvc)"
        balanceLabel.text = "$\(card.balance)"
    }
    
    private func formatCardNumber(_ number: String) -> String {
        var formatted = ""
        for (index, char) in number.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(char)
        }
        return formatted
    }
}
