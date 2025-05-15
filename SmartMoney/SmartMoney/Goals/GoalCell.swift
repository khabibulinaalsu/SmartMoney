import UIKit

class GoalCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let amountsLabel = UILabel()
    private let goalImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        
        amountsLabel.font = UIFont.systemFont(ofSize: 14)
        amountsLabel.textColor = .secondaryLabel
        
        goalImageView.contentMode = .scaleAspectFill
        goalImageView.clipsToBounds = true
        goalImageView.layer.cornerRadius = 6
        
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, progressView, amountsLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.setCustomSpacing(8, after: descriptionLabel)
        
        goalImageView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(goalImageView)
        contentView.addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            goalImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            goalImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            goalImageView.heightAnchor.constraint(equalToConstant: 60),
            goalImageView.widthAnchor.constraint(equalToConstant: 60),
            
            textStackView.leadingAnchor.constraint(equalTo: goalImageView.trailingAnchor, constant: 12),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with viewModel: GoalsList.FetchGoals.ViewModel.GoalViewModel) {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        progressView.progress = viewModel.progress
        amountsLabel.text = "\(viewModel.savedAmount) / \(viewModel.targetAmount)"
        
        if let image = viewModel.image {
            goalImageView.image = image
            goalImageView.isHidden = false
        } else {
            goalImageView.image = .artframe
        }
        
        switch viewModel.status {
        case .active:
            progressView.progressTintColor = .systemGreen
        case .completed:
            progressView.progressTintColor = .systemBlue
        case .frozen:
            progressView.progressTintColor = .systemGray
        }
    }
}
