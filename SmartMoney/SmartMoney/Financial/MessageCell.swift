import UIKit

class MessageCell: UITableViewCell {
    private let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private let senderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(senderLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(dateLabel)
        
        selectionStyle = .none
        
        // Configure constraints with placeholders
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            senderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            senderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            bubbleView.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            
            dateLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -4),
            dateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with sender: Sender, message: String, date: Date) {
        senderLabel.text = sender.rawValue
        messageLabel.text = message
        dateLabel.text = date.time4
        
        switch sender {
        case .ai:
            // AI messages aligned to the left
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
            bubbleView.backgroundColor = .systemBlue
            senderLabel.textAlignment = .left
            senderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        case .user:
            // User messages aligned to the right
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
            bubbleView.backgroundColor = .systemGreen
            senderLabel.textAlignment = .right
            senderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        }
    }
}
