public struct Pipeline: Decodable {
    public let id: ID<Pipeline>
    public let url: URL
    public let webURL: URL
    public let name: String
    public let slug: String
    public let repository: URL
    public let provider: PipelineProvider
    public let buildsURL: URL
    public let badgeURL: URL
    public let creationDate: Date
    public let scheduledBuildsCount: UInt
    public let runningBuildsCount: UInt
    public let scheduledJobsCount: UInt
    public let runningJobsCount: UInt
    public let waitingJobsCount: UInt

    private enum CodingKeys: String, CodingKey {
        case id
        case url
        case webURL = "web_url"
        case name
        case slug
        case repository
        case provider
        case buildsURL = "builds_url"
        case badgeURL = "badge_url"
        case creationDate = "created_at"
        case scheduledBuildsCount = "scheduled_builds_count"
        case runningBuildsCount = "running_builds_count"
        case scheduledJobsCount = "scheduled_jobs_count"
        case runningJobsCount = "running_jobs_count"
        case waitingJobsCount = "waiting_jobs_count"
    }
}

extension Pipeline: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Pipeline, rhs: Pipeline) -> Bool {
        return lhs.id == rhs.id
    }
}
