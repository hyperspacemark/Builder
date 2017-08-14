import Foundation

public struct PipelineProvider {
    public struct BuildTriggers: OptionSet {
        public static var pullRequests = BuildTriggers(rawValue: 1 << 0)
        public static var pullRequestsFromForks = BuildTriggers(rawValue: 1 << 1)
        public static var tags = BuildTriggers(rawValue: 1 << 3)

        public var rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

    public struct PublishSettings: OptionSet {
        public static var commitStatus = PublishSettings(rawValue: 1 << 0)
        public static var commitStatusPerStep = PublishSettings(rawValue: 1 << 1)

        public var rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

    public let id: ID<PipelineProvider>
    public let webhookURL: URL
    public let repository: String
    public let triggerMode: String
    public let buildTriggers: BuildTriggers
    public let publishSettings: PublishSettings
}

extension PipelineProvider {
    public var hashValue: Int {
        return id.hashValue
    }

    public static func ==(lhs: PipelineProvider, rhs: PipelineProvider) -> Bool {
        return lhs.id == rhs.id
    }
}

extension PipelineProvider: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(ID<PipelineProvider>.self, forKey: .id)
        webhookURL = try container.decode(URL.self, forKey: .webhookURL)

        let settings = try container.decode(Settings.self, forKey: .settings)
        repository = settings.repository
        triggerMode = settings.triggerMode
        buildTriggers = BuildTriggers(from: settings)
        publishSettings = PublishSettings(from: settings)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case webhookURL = "webhook_url"
        case settings
    }
}

private extension PipelineProvider {
    struct Settings: Decodable {
        enum CodingKeys: String, CodingKey {
            case publishCommitStatus = "publish_commit_status"
            case publishCommitStatusPerStep = "publish_commit_status_per_step"
            case buildPullRequests = "build_pull_requests"
            case buildPullRequestForks = "build_pull_request_forks"
            case buildTags = "build_tags"
            case repository
            case triggerMode = "trigger_mode"
        }

        let publishCommitStatus: Bool
        let publishCommitStatusPerStep: Bool
        let buildPullRequests: Bool
        let buildPullRequestForks: Bool
        let buildTags: Bool
        let repository: String
        let triggerMode: String
    }
}

private extension PipelineProvider.BuildTriggers {
    init(from settings: PipelineProvider.Settings) {
        rawValue = 0
        if settings.buildPullRequests { insert(.pullRequests) }
        if settings.buildPullRequestForks { insert(.pullRequestsFromForks) }
        if settings.buildTags { insert(.tags) }
    }
}

private extension PipelineProvider.PublishSettings {
    init(from settings: PipelineProvider.Settings) {
        rawValue = 0
        if settings.publishCommitStatus { insert(.commitStatus) }
        if settings.publishCommitStatusPerStep { insert(.commitStatusPerStep) }
    }
}
