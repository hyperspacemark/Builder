public struct Log: Decodable {
    public let url: URL
    public let content: String
    public let size: UInt

    public enum Format: String {
        case json
        case text
        case html
    }
}

extension Log: Hashable {
    public var hashValue: Int {
        return url.hashValue
    }

    public static func ==(lhs: Log, rhs: Log) -> Bool {
        return lhs.url == rhs.url
    }
}
