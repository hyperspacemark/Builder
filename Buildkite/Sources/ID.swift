import Foundation

public struct ID<Tag>: RawRepresentable, Decodable {
    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension ID: ExpressibleByStringLiteral {
    public init(stringLiteral extendedGraphemeClusterLiteral: String) {
        self.rawValue = extendedGraphemeClusterLiteral
    }
}

extension ID: Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }

    public static func ==(lhs: ID, rhs: ID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
