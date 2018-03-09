import struct Foundation.Data
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder
import class Foundation.PropertyListDecoder
import class Foundation.PropertyListEncoder
import class Foundation.UserDefaults

protocol KeyValueStore {
    func array(forKey defaultName: String) -> [Any]?
    func dictionary(forKey defaultName: String) -> [String: Any]?
    func data(forKey defaultName: String) -> Data?

    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: KeyValueStore {}
