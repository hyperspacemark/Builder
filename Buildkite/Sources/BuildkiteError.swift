public struct BuildkiteError: Decodable, Error {
    public let message: String
}

extension BuildkiteError: Hashable {
    public var hashValue: Int {
        return message.hashValue
    }

    public static func ==(lhs: BuildkiteError, rhs: BuildkiteError) -> Bool {
        return lhs.message == rhs.message
    }
}
