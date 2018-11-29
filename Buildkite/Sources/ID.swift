import Foundation

public struct ID<Tag>: RawRepresentable, Codable, Hashable {
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
