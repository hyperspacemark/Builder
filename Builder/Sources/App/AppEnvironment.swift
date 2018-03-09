import Foundation
import struct Buildkite.User
import struct Buildkite.Organization
import class Buildkite.Client

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
        environmentStore: EnvironmentStore = EnvironmentCache()
    ) {

        let environment =  Environment(userSession: userSession,
                                       tokenStore: tokenStore,
                                       environmentStore: environmentStore)
        replaceCurrent(with: environment)
    }

    static func signIn(user: User, token: String, organization: Organization) -> UserSession {
        let userSession = UserSession(user: user, client: Client(token: token), organization: organization)
        replaceCurrent(userSession: userSession)
        current.tokenStore.token = token
        return userSession
    }

    static func signOut() {
        replaceCurrent(userSession: nil)
        current.tokenStore.token = nil
    }

    static func selectOrganization(_ organization: Organization) {
        guard let userSession = current.userSession else {
            preconditionFailure("Expected user session to not be nil.")
        }

        let newSession = UserSession(user: userSession.user, client: userSession.client, organization: organization)
        replaceCurrent(userSession: newSession)
        save(current, to: current.environmentStore)
    }

    static func restore(from environmentStore: EnvironmentStore) {
        guard let token = current.tokenStore.token,
            let user = environmentStore.currentUser,
            let organization = environmentStore.selectedOrganization else {
            replaceCurrent(userSession: nil)
                return
        }

        let client = Client(token: token)
        let userSession = UserSession(user: user, client: client, organization: organization)
        replaceCurrent(userSession: userSession)
    }

    static func save(_ environment: Environment, to environmentStore: EnvironmentStore) {
        environmentStore.currentUser = environment.userSession?.user
        environmentStore.selectedOrganization = environment.userSession?.organization
    }
}
