import Foundation
import XCTest
@testable import Builder

class StorageTests: XCTestCase {
    func testGet() {
        let storageName = "StorageTests"
        let urlString = "http://www.example.com"
        let storage = Storage(name: storageName, keyValueStore: UserDefaults())
        let key = "url"
        storage.set(URL(string: urlString)!, forKey: key)

        let url = storage.get(URL.self, forKey: key)

        XCTAssertEqual(url?.absoluteString, urlString)
    }
}
