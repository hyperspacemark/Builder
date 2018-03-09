import struct Buildkite.Organization

struct Environment {
    let userSession: UserSession?
    let tokenStore: TokenStore
    let environmentStore: EnvironmentStore

    init(
        userSession: UserSession? = nil,
        tokenStore: TokenStore = TokenStore(),
        environmentStore: EnvironmentStore = EnvironmentCache()
        ) {
        self.userSession = userSession
        self.tokenStore = tokenStore
        self.environmentStore = environmentStore
    }
}
