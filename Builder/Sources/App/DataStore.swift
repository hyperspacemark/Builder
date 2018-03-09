import Buildkite

final class DataStore {
    init(api: API, selectedOrganization: Organization) {
        self.api = api
        self.selectedOrganization = selectedOrganization
        self.apiCache = APICache()
    }

    private(set) lazy var organizations = self.makeResource(request: Organization.all, cacheKey: .organizations)
    private(set) lazy var pipelines = self.makeResource(request: self.selectedOrganization.pipelines, cacheKey: .pipelines)
    private(set) lazy var agents = self.makeResource(request: self.selectedOrganization.agents, cacheKey: .agents)

    private let api: API
    private let selectedOrganization: Organization
    private let apiCache: APICache
    private var apiRequest: Client.RequestToken?

    private func makeResource<Value>(request: Request<Value>, cacheKey: APICache.Key) -> Resource<Value> {
        let resource = Resource<Value> { [weak self] callback in
            self?.api.request(request) { result in
                if case let .success(value) = result {
                    self?.apiCache.save(value, for: cacheKey)
                }

                callback(result)
            }
        }

        return resource
    }
}

struct APICache: DiskCache {
    static let cacheName = "com.Builder.APICache"

    enum Key: String, DiskCacheKey {
        case organizations
        case pipelines
        case agents
    }
}

enum ContentState<A> {
    case pending
    case loading
    case loaded(A)
    case refreshing
}

final class Resource<A: Codable> {

    typealias Subscriber = (ContentState<A>) -> Void
    
    init(load: @escaping (@escaping (Result<A, Client.Error>) -> Void) -> Void) {
        self.load = load
    }
    
    var state: ContentState<A> = .pending {
        didSet {
            for (_, subscriber) in subscribers {
                subscriber(state)
            }
        }
    }
    
    func refresh() {
        load { [weak self] result in
            if case let .success(value) = result {
                self?.state = .loaded(value)
            }
        }
    }
    
    func addSubscriber(_ subscriber: @escaping Subscriber) -> Disposable {
        let key = subscriberKeys.next()!
        subscribers[key] = subscriber
        subscriber(state)

        return Disposable { [weak self] in
            self?.subscribers[key] = nil
        }
    }
    
    private let load: (@escaping (Result<A, Client.Error>) -> Void) -> Void
    private var subscribers: [Int: Subscriber] = [:]
    private var subscriberKeys = (Int.min...).makeIterator()
}

final class Disposable {
    private let dispose: () -> Void

    init(_ dispose: @escaping () -> Void) {
        self.dispose = dispose
    }

    deinit {
        dispose()
    }
}
