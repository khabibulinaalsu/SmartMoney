import UIKit

class KeypadView: UIView {
    var digitTapHandler: ((String) -> Void)?
    var deleteTapHandler: (() -> Void)?
    
    private let buttons: [UIButton] = (1...9).map { digit in
        let button = UIButton(type: .system)
        button.setTitle("\(digit)", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }
    
    private let zeroButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("0", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "delete.left"), for: .normal)
        return button
    }()
    
    private var biometryButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setBiometryButton(_ biometryButton: UIButton) {
        self.biometryButton = biometryButton
        addSubview(biometryButton)
    }
    
    private func setupButtons() {
        // Добавляем цифровые кнопки
        for button in buttons {
            addSubview(button)
            button.addTarget(self, action: #selector(digitButtonTapped(_:)), for: .touchUpInside)
        }
        
        // Добавляем кнопку биометрии, 0 и кнопку удаления
        addSubview(zeroButton)
        addSubview(deleteButton)
        
        zeroButton.addTarget(self, action: #selector(digitButtonTapped(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonSize: CGFloat = 70
        let horizontalSpacing = (bounds.width - 3 * buttonSize) / 2
        let verticalSpacing = (bounds.height - 4 * buttonSize) / 3
        
        // Размещаем цифры 1-9
        for i in 0..<9 {
            let row = i / 3
            let column = i % 3
            let x = CGFloat(column) * (buttonSize + horizontalSpacing)
            let y = CGFloat(row) * (buttonSize + verticalSpacing)
            buttons[i].frame = CGRect(x: x, y: y, width: buttonSize, height: buttonSize)
        }
        
        // Размещаем кнопку биометрии, 0 и кнопку удаления
        let lastRowY = 3 * (buttonSize + verticalSpacing)
        
        biometryButton.frame = CGRect(x: 0, y: lastRowY, width: buttonSize, height: buttonSize)
        zeroButton.frame = CGRect(x: buttonSize + horizontalSpacing, y: lastRowY, width: buttonSize, height: buttonSize)
        deleteButton.frame = CGRect(x: 2 * (buttonSize + horizontalSpacing), y: lastRowY, width: buttonSize, height: buttonSize)
    }
    
    @objc private func digitButtonTapped(_ sender: UIButton) {
        guard let digit = sender.title(for: .normal) else { return }
        digitTapHandler?(digit)
    }
    
    @objc private func deleteButtonTapped() {
        deleteTapHandler?()
    }
}
