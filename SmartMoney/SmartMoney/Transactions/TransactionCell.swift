import UIKit

class TransactionCell: UITableViewCell {
    static let reuseId = "TransactionCell"
    
    private let categoryIconView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(categoryIconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            categoryIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryIconView.widthAnchor.constraint(equalToConstant: 30),
            categoryIconView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: categoryIconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: categoryIconView.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
        ])
    }
    
    func configure(with viewModel: TransactionListItemViewModel) {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        
        let formattedAmount = String(format: "%.2f ₽", viewModel.amount)
        amountLabel.text = formattedAmount
        
        if viewModel.isExpense {
            amountLabel.textColor = .systemRed
        } else {
            amountLabel.textColor = .systemGreen
        }
        
        categoryIconView.backgroundColor = viewModel.categoryColor
    }
}
