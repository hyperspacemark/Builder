public struct Organization: Decodable {
    public let id: ID<Organization>
    public let name: String
    public let slug: String
    public let webURL: URL
    public let creationDate: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
        case webURL = "web_url"
        case creationDate = "created_at"
    }
}

extension Organization: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Organization, rhs: Organization) -> Bool {
        return lhs.id == rhs.id
    }
}
