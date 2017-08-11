import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension RangeReplaceableCollection where Iterator.Element == URLQueryItem {
    subscript(name: String) -> String? {
        get {
            return first { queryItem in queryItem.name == name }?.value
        }

        set {
            if let index = index(where: { queryItem in queryItem.name == name }) {
                remove(at: index)
            }

            append(URLQueryItem(name: name, value: newValue))
        }
    }
}

extension UInt {
    func clamped(within range: ClosedRange<UInt>) -> UInt {
        if self < range.lowerBound { return range.lowerBound }
        if self > range.upperBound { return range.upperBound }
        return self
    }

    func clamped(within range: Range<UInt>) -> UInt {
        if self < range.lowerBound { return range.lowerBound }
        if self > range.upperBound { return range.upperBound }
        return self
    }
}

public struct Request<Value> {
    let method: HTTPMethod
    let path: String
    private(set) var queryItems: [URLQueryItem]
    let body: [String: Any]?

    init(method: HTTPMethod, path: String, queryItems: [URLQueryItem] = [], body: [String: Any]? = nil) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.body = body
    }

    func limited(toPage page: UInt?, perPage: UInt?) -> Request {
        var copy = self
        copy.limit(toPage: page, perPage: perPage)
        return copy
    }
    
    mutating func limit(toPage: UInt?, perPage: UInt?) {
        queryItems["page"] = String((toPage ?? 1).clamped(within: 1...UInt.max))
        queryItems["per_page"] = String((perPage ?? 30).clamped(within: 1...100))
    }
}
