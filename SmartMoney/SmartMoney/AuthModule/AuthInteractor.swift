import Foundation

protocol AuthInteractorInput {
    func isPinSet() -> Bool
    func isBiometryEnabled() -> Bool
    func getBiometryType() -> BiometryType
    func savePin(_ pin: String) -> Bool
    func validatePin(_ pin: String) -> Bool
    func setBiometryEnabled(_ enabled: Bool)
    func authenticateWithBiometry(completion: @escaping (Bool, Error?) -> Void)
}

protocol AuthInteractorOutput: AnyObject {
    func authenticationSucceeded()
    func authenticationFailed(with error: Error?)
}

class AuthInteractor: AuthInteractorInput {
    private let authService: AuthService
    weak var output: AuthInteractorOutput?
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func isPinSet() -> Bool {
        return authService.isPinSet()
    }
    
    func isBiometryEnabled() -> Bool {
        return authService.isBiometryEnabled()
    }
    
    func getBiometryType() -> BiometryType {
        return authService.getBiometryType()
    }
    
    func savePin(_ pin: String) -> Bool {
        return authService.savePin(pin)
    }
    
    func validatePin(_ pin: String) -> Bool {
        return pin == authService.getPin()
    }
    
    func setBiometryEnabled(_ enabled: Bool) {
        authService.setBiometryEnabled(enabled)
    }
    
    func authenticateWithBiometry(completion: @escaping (Bool, Error?) -> Void) {
        authService.authenticateWithBiometry(completion: completion)
    }
}
