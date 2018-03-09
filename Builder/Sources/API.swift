import Buildkite

protocol API {
    @discardableResult
    func request<Value>(_ request: Request<Value>, completion: @escaping (Result<Value, Client.Error>) -> Void) -> Client.RequestToken where Value: Decodable
}

extension Client: API {}
