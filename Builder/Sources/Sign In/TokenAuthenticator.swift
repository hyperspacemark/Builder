import Buildkite

final class TokenAuthenticator {
    func authenticateUser(usingToken token: String, completion: @escaping (Result<User, Client.Error>) -> Void) {
        let client = Client(token: token)
        client.request(User.current, completion: completion)
    }
}

