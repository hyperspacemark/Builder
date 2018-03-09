final class TokenStore {
    private let keychain = Keychain(service: KeychainIdentifier.service)

    private enum KeychainIdentifier {
        static let service = "com.markadams.Builder.buildkite-auth"
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
