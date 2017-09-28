import struct Buildkite.User
import enum Buildkite.Result
import class Buildkite.Client

enum SignInServiceError: Error {
    case requestFailed
    case invalidAccessToken
}

protocol SignInServiceProtocol {
    func signIn(usingToken token: String, _ completion: @escaping (Result<User, SignInServiceError>) -> Void)
}

final class SignInService: SignInServiceProtocol {
    func signIn(usingToken token: String, _ completion: @escaping (Result<User, SignInServiceError>) -> Void) {
        let client = Client(token: token)
        client.execute(User.current) { result in
            completion(result.mapError(SignInServiceError.init))
        }
        self.client = client
    }

    private var client: Client?
}

private extension SignInServiceError {
    init(_ clientError: Buildkite.Client.Error) {
        switch clientError {
        case let .buildkite(statusCode, _) where statusCode == 401:
            self = .invalidAccessToken

        default:
            self = .requestFailed
        }
    }
}
