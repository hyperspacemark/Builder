public struct Build: Decodable {
    public let id: ID<Build>
    public let url: URL
    public let webURL: URL
    public let number: UInt
    public let state: String
    public let isBlocked: Bool
    public let message: String
    public let commit: String
    public let branch: String
    public let env: [String: String]
    public let source: String
    public let creator: User
    public let jobs: [Job]
    public let creationDate: Date
    public let scheduledDate: Date
    public let startDate: Date
    public let finishDate: Date
    public let metadata: [String: String]
    public let pipeline: Pipeline

    private enum CodingKeys: String, CodingKey {
        case id
        case url
        case webURL = "web_url"
        case number
        case state
        case isBlocked = "blocked"
        case message
        case commit
        case branch
        case env
        case source
        case creator
        case jobs
        case creationDate = "created_at"
        case scheduledDate = "scheduled_at"
        case startDate = "started_at"
        case finishDate = "finished_at"
        case metadata = "meta_data"
        case pipeline = "pipeline"
    }
}

extension Build: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Build, rhs: Build) -> Bool {
        return lhs.id == rhs.id
    }
}
