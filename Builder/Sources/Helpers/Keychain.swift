import Security
import Foundation

final class Keychain {
    init(service: String) {
        self.service = service
        self.baseQuery = [kSecClass: kSecClassGenericPassword,
                          kSecAttrService: service,
                          kSecAttrAccessible: kSecAttrAccessibleAlways]
    }

    private let service: String
    private let baseQuery: [CFString: Any]

    subscript(account account: String) -> String? {
        get {
            var query = baseQuery
            query[kSecAttrAccount] = account
            query[kSecReturnData] = true

            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)

            if status == errSecSuccess, let data = result as? Data, let string = String(data: data, encoding: .utf8) {
                return string
            } else {
                return nil
            }
        }

        set {
            guard let string = newValue, let data = string.data(using: .utf8) else {
                var query = baseQuery
                query[kSecAttrAccount] = account
                SecItemDelete(query as CFDictionary)
                return
            }

            if containsValue(forAccount: account) {
                var query = baseQuery
                query[kSecAttrAccount] = account

                let newAttributes = [kSecValueData: data]

                SecItemUpdate(query as CFDictionary, newAttributes as CFDictionary)
            } else {
                var query = baseQuery
                query[kSecAttrAccount] = account
                query[kSecReturnData] = true
                query[kSecValueData] = data

                var result: AnyObject?
                let status = SecItemAdd(query as CFDictionary, &result)
            }
        }
    }

    private func containsValue(forAccount account: String) -> Bool {
        var query = baseQuery
        query[kSecAttrAccount] = account

        var result: CFTypeRef? = NSObject()

        return SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess
    }
}
