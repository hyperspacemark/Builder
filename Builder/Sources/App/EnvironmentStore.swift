import struct Buildkite.Organization
import struct Buildkite.User
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder
import class Foundation.UserDefaults

protocol EnvironmentStore: class {
    var currentUser: User? { get set }
    var selectedOrganization: Organization? { get set }
}

final class EnvironmentCache: DiskCache {
    static let cacheName = "com.Builder.EnvironmentCache"

    enum Key: String, DiskCacheKey {
        case environment
    }
}

private struct CodableEnvironment: Codable {
    var currentUser: User?
    var selectedOrganization: Organization?
}

extension EnvironmentCache: EnvironmentStore {
    var currentUser: User? {
        get {
            return environment.currentUser
        }

        set {
            var env = environment
            env.currentUser = newValue
            save(env, for: .environment)
        }
    }

    var selectedOrganization: Organization? {
        get {
            return environment.selectedOrganization
        }

        set {
            var env = environment
            env.selectedOrganization = newValue
            save(env, for: .environment)
        }
    }

    private var environment: CodableEnvironment {
        return fetch(CodableEnvironment.self, for: .environment) ?? CodableEnvironment(currentUser: nil, selectedOrganization: nil)
    }
}
