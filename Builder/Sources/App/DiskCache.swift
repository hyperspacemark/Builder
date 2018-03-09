import Foundation

protocol DiskCacheKey {
    var stringValue: String { get }
}

extension DiskCacheKey where Self: RawRepresentable, Self.RawValue == String {
    var stringValue: String {
        return rawValue
    }
}

protocol DiskCache {
    associatedtype Key: DiskCacheKey

    static var cacheName: String { get }

    func fetch<V: Decodable>(_ type: V.Type, for key: Key) -> V?
    func save<V: Encodable>(_ value: V, for key: Key)
}

extension DiskCache {
    func fetch<V: Decodable>(_ type: V.Type, for key: Key) -> V? {
        do {
            let data = try Data(contentsOf: file(for: key))
            return try JSONDecoder().decode(V.self, from: data)
        } catch let error as DecodingError {
            assertionFailure(error.localizedDescription)
            return nil
        } catch {
            print(error)
            return nil
        }
    }

    func save<V: Encodable>(_ value: V, for key: Key) {
        do {
            let encoded = try JSONEncoder().encode(value)
            try encoded.write(to: file(for: key), options: [.atomic])
        } catch let error as EncodingError {
            assertionFailure(error.localizedDescription)
        } catch {
            print(error)
        }
    }

    private func file(for key: Key) -> URL {
        return directory.appendingPathComponent(key.stringValue)
    }

    private var directory: URL {
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url = documents.appendingPathComponent(Self.cacheName, isDirectory: true)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
}
