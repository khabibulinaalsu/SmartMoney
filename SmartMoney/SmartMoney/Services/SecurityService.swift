import Foundation
import LocalAuthentication

class SecurityService {
    static let shared = SecurityService()
    
    private let biometricAuthentication = BiometricAuthentication()
    private let keychain = KeychainService()
    
    // Проверка, установлен ли пин-код
    var isPinCodeSet: Bool {
        return keychain.getPinCode() != nil
    }
    
    // Проверка, включена ли биометрическая аутентификация
    var isBiometricEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "useBiometricAuth")
    }
    
    // Проверка, доступна ли биометрическая аутентификация
    var isBiometricAvailable: Bool {
        return biometricAuthentication.canEvaluate
    }
    
    // Установка пин-кода
    func setPinCode(_ pinCode: String) -> Bool {
        return keychain.savePinCode(pinCode)
    }
    
    // Проверка пин-кода
    func verifyPinCode(_ pinCode: String) -> Bool {
        guard let savedPinCode = keychain.getPinCode() else {
            return false
        }
        return savedPinCode == pinCode
    }
    
    // Включение/выключение биометрической аутентификации
    func toggleBiometricAuthentication(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "useBiometricAuth")
    }
    
    // Биометрическая аутентификация
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        biometricAuthentication.authenticate { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}

class BiometricAuthentication {
    let context = LAContext()
    var error: NSError?
    
    var biometricType: BiometricType {
        guard canEvaluate else { return .none }
        return context.biometryType == .faceID ? .faceID : .touchID
    }
    
    var canEvaluate: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate(completion: @escaping (Bool, Error?) -> Void) {
        guard canEvaluate else {
            completion(false, error)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Войдите для доступа к вашим финансовым данным") { success, error in
            completion(success, error)
        }
    }
}

enum BiometricType {
    case none
    case touchID
    case faceID
}

class KeychainService {
    private let service = "com.financeapp.pincode"
    private let account = "financeAppPinCode"
    
    func savePinCode(_ pinCode: String) -> Bool {
        // Удаляем предыдущий пин-код, если он есть
        deletePinCode()
        
        // Создаем запрос для добавления нового пин-кода
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: pinCode.data(using: .utf8)!
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getPinCode() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func deletePinCode() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
