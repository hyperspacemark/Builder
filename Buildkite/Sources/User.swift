public struct User: Decodable {
    public let id: ID<User>
    public let name: String
    public let email: String
    public let avatar: URL
    public let creationDate: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatar = "avatar_url"
        case creationDate = "created_at"
    }
}

extension User: Hashable {
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    public var hashValue: Int {
        return id.hashValue
    }
}
