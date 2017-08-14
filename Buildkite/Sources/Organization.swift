import Foundation

public struct Organization: Decodable {
    public let id: ID<Organization>
    public let name: String
    public let slug: String
    public let webURL: URL
    public let creationDate: Date

    public init(id: ID<Organization>, name: String, slug: String, webURL: URL, creationDate: Date) {
        self.id = id
        self.name = name
        self.slug = slug
        self.webURL = webURL
        self.creationDate = creationDate
    }

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
