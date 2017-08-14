import Foundation

public struct Emoji: Decodable {
    public let name: String
    public let url: URL
    public let aliases: [String]
}

extension Emoji: Hashable {
    public var hashValue: Int {
        return name.hashValue ^ url.hashValue
    }

    public static func ==(lhs: Emoji, rhs: Emoji) -> Bool {
        return lhs.name == rhs.name
            && lhs.url == rhs.url
    }
}
