import Foundation

protocol AuthPresenterInput {
    func viewDidLoad()
    func didEnterPin(_ pin: String)
    func didConfirmPin(_ pin: String)
    func didSelectBiometry(_ enabled: Bool)
    func didTapUseBiometry()
    func didTapReturnToCreatePin()
}

protocol AuthPresenterOutput: AnyObject {
    func showCreatePin()
    func showConfirmPin()
    func showPinError(message: String)
//    func showBiometryRequest()
    func showPinEntry()
    func showMainScreen()
    func updateBiometryButtonTitle(with type: BiometryType)
}

class AuthPresenter: AuthPresenterInput, AuthInteractorOutput {
    private let interactor: AuthInteractorInput
    weak var output: AuthPresenterOutput?
    private var enteredPin: String?
    
    init(interactor: AuthInteractorInput) {
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        if interactor.isPinSet() {
            if interactor.isBiometryEnabled() {
                output?.updateBiometryButtonTitle(with: interactor.getBiometryType())
                didTapUseBiometry()
            } else {
                output?.showPinEntry()
            }
        } else {
            output?.showCreatePin()
        }
    }
    
    func didEnterPin(_ pin: String) {
        if interactor.isPinSet() {
            if interactor.validatePin(pin) {
                output?.showMainScreen()
            } else {
                output?.showPinError(message: "Неверный PIN-код")
            }
        } else {
            enteredPin = pin
            output?.showConfirmPin()
        }
    }
    
    func didConfirmPin(_ pin: String) {
        guard let enteredPin = enteredPin else { return }
        
        if enteredPin == pin {
            if interactor.savePin(pin) {
                let biometryType = interactor.getBiometryType()
                if biometryType != .none {
                    output?.updateBiometryButtonTitle(with: biometryType)
                    didSelectBiometry(true)
                    didTapUseBiometry()
                } else {
                    output?.showMainScreen()
                    didSelectBiometry(false)
                }
            } else {
                output?.showPinError(message: "Ошибка сохранения PIN-кода")
            }
        } else {
            output?.showPinError(message: "PIN-коды не совпадают")
            output?.showConfirmPin()
        }
    }
    
    func didSelectBiometry(_ enabled: Bool) {
        interactor.setBiometryEnabled(enabled)
    }
    
    func didTapUseBiometry() {
        interactor.authenticateWithBiometry { [weak self] success, error in
            if success {
                self?.authenticationSucceeded()
            } else {
                self?.authenticationFailed(with: error)
            }
        }
    }
    
    func authenticationSucceeded() {
        output?.showMainScreen()
    }
    
    func authenticationFailed(with error: Error?) {
        output?.showPinEntry()
        output?.updateBiometryButtonTitle(with: interactor.getBiometryType())
    }
    
    func didTapReturnToCreatePin() {
        output?.showCreatePin()
    }
}
