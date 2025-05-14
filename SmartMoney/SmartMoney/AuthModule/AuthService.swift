import Foundation
import LocalAuthentication

enum BiometryType {
    case none
    case touchID
    case faceID
}

class AuthService {
    private let keychainService = "com.myapp.auth"
    private let pinKey = "userPin"
    private let biometryEnabledKey = "biometryEnabled"
    
    func savePin(_ pin: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: pinKey,
            kSecValueData as String: pin.data(using: .utf8)!
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getPin() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: pinKey,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let pin = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return pin
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
