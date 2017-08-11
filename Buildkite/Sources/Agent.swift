import Foundation

public struct Agent: Decodable {
    let id: ID<Agent>
    let url: URL
    let webURL: URL
    let name: String
    let connectionState: String
    let hostName: String
    let ipAddress: String
    let userAgent: String
    let version: String
    let creator: User
    let creationDate: Date
    let job: Job?
    let lastJobFinishedDate: Date
    let priority: String
    let metadata: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case url
        case webURL = "web_url"
        case name
        case connectionState = "connection_state"
        case hostName = "hostname"
        case ipAddress = "ip_address"
        case userAgent = "user_agent"
        case version
        case creator
        case creationDate = "created_at"
        case job
        case lastJobFinishedDate = "last_job_finished_at"
        case priority
        case metadata = "meta_data"
    }
}

extension Agent: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: Agent, rhs: Agent) -> Bool {
        return lhs.id == rhs.id
    }
}
