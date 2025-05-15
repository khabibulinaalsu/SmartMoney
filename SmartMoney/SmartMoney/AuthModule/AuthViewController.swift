import UIKit

enum AuthScreenType {
    case createPin
    case confirmPin
    case enterPin
    
    var label: String {
        switch self {
        case .createPin:
            return "Создайте PIN-код"
        case .confirmPin:
            return "Подтвердите PIN-код"
        case .enterPin:
            return "Введите PIN-код"
        }
    }
}

class AuthViewController: UIViewController {
    private let presenter: AuthPresenterInput
    private var currentScreenType: AuthScreenType = .createPin {
        didSet {
            setupTitleLabel()
            returnToCreatePinButton.isHidden = currentScreenType != .confirmPin
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pinDotsView: PinDotsView = {
        let view = PinDotsView(totalDots: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let keypadView: KeypadView = {
        let view = KeypadView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let biometryButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let returnToCreatePinButton = UIBarButtonItem()
    
    private var enteredPin: String = ""
    
    init(presenter: AuthPresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        
        setupViews()
        setupLayout()
        setupActions()
        setupReturnToCreatePinButton()
        
        presenter.viewDidLoad()
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(pinDotsView)
        view.addSubview(keypadView)
        view.addSubview(biometryButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pinDotsView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            pinDotsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinDotsView.widthAnchor.constraint(equalToConstant: 100),
            pinDotsView.heightAnchor.constraint(equalToConstant: 20),
            
            keypadView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            keypadView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            keypadView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            keypadView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupActions() {
        keypadView.digitTapHandler = { [weak self] digit in
            guard let self = self else { return }
            
            if self.enteredPin.count < 4 {
                self.enteredPin.append(digit)
                self.pinDotsView.fillDot(at: self.enteredPin.count - 1)
                
                if self.enteredPin.count == 4 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        switch self.currentScreenType {
                        case .createPin:
                            self.presenter.didEnterPin(self.enteredPin)
                        case .confirmPin:
                            self.presenter.didConfirmPin(self.enteredPin)
                        case .enterPin:
                            self.presenter.didEnterPin(self.enteredPin)
                        }
                    }
                }
            }
        }
        
        keypadView.deleteTapHandler = { [weak self] in
            guard let self = self, !self.enteredPin.isEmpty else { return }
            
            self.enteredPin.removeLast()
            self.pinDotsView.clearDot(at: self.enteredPin.count)
        }
        
        biometryButton.addTarget(self, action: #selector(biometryTapped), for: .touchUpInside)
    }
    
    @objc private func biometryTapped() {
        presenter.didTapUseBiometry()
    }
    
    @objc private func returnToCreatePinButtonTapped() {
        presenter.didTapReturnToCreatePin()
    }
    
    private func resetPinEntry() {
        enteredPin = ""
        pinDotsView.clearAllDots()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = currentScreenType.label
    }
    
    private func setupReturnToCreatePinButton() {
        returnToCreatePinButton.title = "Изменить PIN-код"
        returnToCreatePinButton.style = UIBarButtonItem.Style.done
        returnToCreatePinButton.target = self
        returnToCreatePinButton.action = #selector(returnToCreatePinButtonTapped)
        returnToCreatePinButton.isHidden = true
        navigationItem.leftBarButtonItem = returnToCreatePinButton
    }
}

extension AuthViewController: AuthPresenterOutput {
    func showCreatePin() {
        currentScreenType = .createPin
        biometryButton.isHidden = true
        resetPinEntry()
    }
    
    func showConfirmPin() {
        currentScreenType = .confirmPin
        resetPinEntry()
    }
    
    func showPinError(message: String) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        
        pinDotsView.layer.add(animation, forKey: "shake")
        
        resetPinEntry()
        
        titleLabel.text = message
        titleLabel.textColor = .systemRed
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.setupTitleLabel()
            self?.titleLabel.textColor = .label
        }
    }
    
    func showPinEntry() {
        currentScreenType = .enterPin
        biometryButton.isHidden = false
        resetPinEntry()
    }

    func showMainScreen() {
        navigationController?.popViewController(animated: true)
    }

    func updateBiometryButtonTitle(with type: BiometryType) {
        switch type {
        case .touchID:
            biometryButton.setImage(.touchid, for: .normal)
        case .faceID:
            biometryButton.setImage(.faceid, for: .normal)
        case .none:
            biometryButton.isHidden = true
        }
        keypadView.setBiometryButton(biometryButton)
    }
}
