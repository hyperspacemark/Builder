import Foundation

public struct Job: Decodable {
    public let id: ID<Job>
    public let type: String
    public let name: String
    public let agentQueryRules: [String]
    public let state: String
    public let webURL: URL
    public let logURL: URL
    public let rawLogURL: URL
    public let command: String
    public let exitStatus: Int
    public let artifactPaths: String
    public let creationDate: Date
    public let scheduledDate: Date
    public let startDate: Date
    public let finishDate: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case agentQueryRules = "agent_query_rules"
        case state
        case webURL = "web_url"
        case logURL = "log_url"
        case rawLogURL = "raw_log_url"
        case command
        case exitStatus = "exit_status"
        case artifactPaths = "artifact_paths"
        case creationDate = "created_at"
        case scheduledDate = "scheduled_at"
        case startDate = "started_at"
        case finishDate = "finished_at"
    }
}

extension Job: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Job, rhs: Job) -> Bool {
        return lhs.id == rhs.id
    }
}
