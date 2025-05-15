import Foundation
import Security

public enum KeychainService {
    private static let key = "ru.Khabibulina.SmartMoney."
    
    public static func save<T: Codable>(_ model: T, for key: String) -> Bool {
        if hasSomeItemSaved(T.self, for: key) {
            _ = delete(for: key)
        }
        
        let encoder = JSONEncoder()
        guard let modelData = try? encoder.encode(model) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.key + key,
            kSecValueData as String: modelData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    public static func get<T: Codable>(_ model: T.Type, for key: String) -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.key + key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?

        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess else {
            return nil
        }
        
        guard let existingItem = item as? [String: Any],
              let modelData = existingItem[kSecValueData as String] as? Data else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(model, from: modelData)
    }
    
    public static func delete(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.key + key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }

    private static func hasSomeItemSaved<T: Codable>(_ model: T.Type, for key: String) -> Bool {
        return get(model, for: key) != nil
    }
}
