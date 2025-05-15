import Foundation
import LocalAuthentication

enum BiometryType {
    case none
    case touchID
    case faceID
}

final class AuthService {
    private let pinKey = "userPin"
    private let biometryEnabledKey = "biometryEnabled"
    
    func savePin(_ pin: String) -> Bool {
        KeychainService.save(pin, for: pinKey)
    }
    
    func getPin() -> String? {
        KeychainService.get(String.self, for: pinKey)
    }
    
    func setBiometryEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: biometryEnabledKey)
    }
    
    func isBiometryEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: biometryEnabledKey)
    }
    
    func isPinSet() -> Bool {
        return getPin() != nil
    }
    
    func getBiometryType() -> BiometryType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            default:
                return .none
            }
        } else {
            return .touchID
        }
    }
    
    func authenticateWithBiometry(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false, error)
            return
        }
        
        let reason = "Войти в приложение"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
