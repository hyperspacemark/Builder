import Foundation
import struct Buildkite.User
import class Buildkite.Client

final class TokenStore {
    private let keychain = Keychain(service: KeychainIdentifier.service)

    private enum KeychainIdentifier {
        static let service = "com.markadams.Builder"
        static let account = "buildkite.api.token"
    }

    var token: String? {
        get {
            return keychain[account: KeychainIdentifier.account]
        }

        set {
            keychain[account: KeychainIdentifier.account] = newValue
        }
    }
}

struct UserSession {
    let user: User
    let client: Client
}

struct Environment {
    let userSession: UserSession?
    let tokenStore: TokenStore
    let environmentStore: EnvironmentStoreProtocol

    init(
        userSession: UserSession? = nil,
        tokenStore: TokenStore = TokenStore(),
        environmentStore: EnvironmentStoreProtocol = EnvironmentStore()
    ) {
        self.userSession = userSession
        self.tokenStore = tokenStore
        self.environmentStore = environmentStore
    }
}

struct AppEnvironment {
    static var stack: [Environment] = [Environment()]

    static var current: Environment {
        return stack.last!
    }

    static func push(_ environment: Environment) {
        save(environment, to: environment.environmentStore)
        stack.append(environment)
    }

    static func pop() -> Environment? {
        let last = stack.popLast()
        let next = stack.last ?? Environment()
        save(next, to: next.environmentStore)
        return last
    }

    static func replaceCurrent(with environment: Environment) {
        push(environment)
        stack.remove(at: stack.count - 2)
    }

    static func replaceCurrent(
        userSession: UserSession? = nil,
        tokenStore: TokenStore = TokenStore(),
        environmentStore: EnvironmentStoreProtocol = EnvironmentStore()) {

        let environment =  Environment(userSession: userSession,
                                       tokenStore: tokenStore,
                                       environmentStore: environmentStore)
        replaceCurrent(with: environment)
    }

    static func signIn(user: User, token: String) {
        replaceCurrent(userSession: UserSession(user: user, client: Client(token: token)))
        current.tokenStore.token = token
    }

    static func signOut() {
        replaceCurrent(userSession: nil)
        current.tokenStore.token = nil
    }

    static func restore(from environmentStore: EnvironmentStoreProtocol) {
        if let token = current.tokenStore.token, let user = environmentStore.currentUser {
            let client = Client(token: token)
            replaceCurrent(userSession: UserSession(user: user, client: client))
        } else {
            replaceCurrent(userSession: nil)
        }
    }

    static func save(_ environment: Environment, to environmentStore: EnvironmentStoreProtocol) {
        environmentStore.currentUser = environment.userSession?.user
    }
}

protocol KeyValueStore {
    func dictionary(forKey defaultName: String) -> [String: Any]?
    func data(forKey defaultName: String) -> Data?

    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: KeyValueStore {}

protocol EnvironmentStoreProtocol: class {
    var currentUser: User? { get set }
}

final class EnvironmentStore: EnvironmentStoreProtocol {
    init(keyValueStore: KeyValueStore = UserDefaults.standard) {
        self.keyValueStore = keyValueStore
    }

    var currentUser: User? {
        get {
            return keyValueStore.data(forKey: Keys.currentUser).flatMap { data in
                try? jsonDecoder.decode(User.self, from: data)
            }
        }

        set {
            let data = newValue.flatMap { try? jsonEncoder.encode($0) }
            keyValueStore.set(data, forKey: Keys.currentUser)
        }
    }

    private let keyValueStore: KeyValueStore
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    private enum Keys {
        static let root = "com.markadams.builder.environment"
        static let currentUser = "com.markadams.builder.environment.currentUser"
    }
}
