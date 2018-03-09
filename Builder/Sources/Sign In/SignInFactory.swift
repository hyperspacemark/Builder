protocol SignInFactoryProtocol {
    func makeAuthenticator() -> TokenAuthenticator
}

final class SignInFactory: SignInFactoryProtocol {
    func makeAuthenticator() -> TokenAuthenticator {
        return TokenAuthenticator()
    }
}
