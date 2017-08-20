import Foundation

public extension Organization {
    public static var all: Request<[Organization]> {
        return Request(method: .get, path: "/v2/organizations")
    }

    public static func page(_ page: UInt?, perPage: UInt?) -> Request<[Organization]> {
        return Organization.all.limited(toPage: page, perPage: perPage)
    }
    
    public static func having(slug: String) -> Request<Organization> {
        return Request(method: .get, path: "/v2/organizations/\(slug)")
    }

    public var pipelines: Request<[Pipeline]> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/pipelines")
    }

    public var builds: Request<[Build]> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/builds")
    }

    public func builds(in pipeline: Pipeline) -> Request<[Build]> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/pipelines/\(pipeline.slug)/builds")
    }

    public func cancel(_ build: Build) -> Request<Build> {
        return Request(method: .put, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/cancel")
    }
    
    public func rebuild(_ build: Build) -> Request<Build> {
        return Request(method: .put, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/rebuild")
    }

    public func cancel(_ job: Job, in build: Build) -> Request<Job> {
        return Request(method: .put, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/jobs/\(job.id)/retry")
    }

    public func unblock(_ job: Job, in build: Build) -> Request<Job> {
        return Request(method: .put, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/jobs/\(job.id)/unblock")
    }

    
    public func log(for job: Job, in build: Build, format: Log.Format) -> Request<Log> {
        let fileExtension: String = {
            switch format {
            case .json: return ""
            case .text: return ".txt"
            case .html: return ".html"
            }
        }()

        return Request(method: .get, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/jobs/\(job.id)/log\(fileExtension)")
    }

    public func environmentVariables(for job: Job, in build: Build) -> Request<[String: String]> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/jobs/\(job.id)/env")
    }

    public var agents: Request<[Agent]> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/agents")
    }

    enum AgentFilter: Hashable {
        case name(String)
        case hostname(String)
        case version(String)

        public static func ==(lhs: AgentFilter, rhs: AgentFilter) -> Bool {
            switch (lhs, rhs) {
            case let (.name(left), .name(right)): return left == right
            case let (.hostname(left), .hostname(right)): return left == right
            case let (.version(left), .version(right)): return left == right
            default: return false
            }
        }

        public var hashValue: Int {
            switch self {
            case let .name(name): return 0 ^ name.hashValue
            case let .hostname(hostname): return 1 ^ hostname.hashValue
            case let .version(version): return 2 ^ version.hashValue
            }
        }

        var queryItem: URLQueryItem {
            switch self {
            case let .name(name): return URLQueryItem(name: "name", value: name)
            case let .hostname(hostname): return URLQueryItem(name: "hostname", value: hostname)
            case let .version(version): return URLQueryItem(name: "version", value: version)
            }
        }
    }

    public func agents(filteredBy agentFilters: Set<AgentFilter>) -> Request<[Agent]> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/agents", queryItems: agentFilters.map { $0.queryItem }, body: nil)
    }

    public func agent(havingID id: String) -> Request<Agent> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/agents/\(id)")
    }

    public func stop(_ agent: Agent, cancelCurrentJob: Bool = true) -> Request<()> {
        let body = ["force": cancelCurrentJob]
        return Request(method: .put, path: "/v2/organizations/\(slug)/agents/\(agent.id)/stop", body: body)
    }

    public func artifacts(from build: Build) -> Request<[Artifact]> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/artifacts")
    }

    public func artifacts(from job: Job, in build: Build) -> Request<[Artifact]> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/jobs/\(job.id)/artifacts")
    }

    public func artifact(havingID id: String, in build: Build) -> Request<Artifact> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/artifacts/\(id)")
    }

    public func download(_ artifact: Artifact, in build: Build) -> Request<Artifact.Download> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/pipelines/\(build.pipeline.slug)/builds/\(build.number)/artifacts/\(artifact.id)/download")
    }

    public var emojis: Request<[Emoji]> {
        return Request(method: .get, path: "/v2/organizations/\(slug)/emojis")
    }
}

public extension Pipeline {
    public static func having(slug: String, in organization: Organization) -> Request<Pipeline> {
        return Request(method: .get, path: "/v2/organizations/\(organization.slug)/pipelines/\(slug)")
    }
}

public extension User {
    public static var current: Request<User> {
        return Request(method: .get, path: "/v2/user")
    }
    
    public var builds: Request<[Build]> {
        return Request(method: .get, path: "/v2/builds")
    }
    
    public var organizations: Request<[Organization]> {
        return Request(method: .get, path: "/v2/organizations")
    }
}
