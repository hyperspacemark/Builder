import Foundation

public protocol RequestAuthenticator {
    func authenticate(_ request: inout URLRequest) throws
}

final class AnyRequestAuthenticator: RequestAuthenticator {
    init(_ authenticate: @escaping (inout URLRequest) throws -> Void) {
        self._authenticate = authenticate
    }

    func authenticate(_ request: inout URLRequest) throws {
        try _authenticate(&request)
    }

    private let _authenticate: (inout URLRequest) throws -> Void
}

public final class Client {
    public enum Error: Swift.Error {
        case urlSession(Swift.Error)
        case jsonDecoding(Swift.Error)
        case buildkite(httpStatusCode: Int, BuildkiteError)
        case unknown
    }

    public enum Authentication {
        case token(String)
        case basic(username: String, password: String)
    }

    public final class RequestToken {
        init(task: URLSessionTask) {
            self.task = task
        }

        public func cancel() {
            task.cancel()
        }

        private let task: URLSessionTask
    }

    public init(authenticator: RequestAuthenticator, urlSession: URLSession = .shared) {
        self.authenticator = authenticator
        self.urlSession = urlSession
    }

    public convenience init(token: String, urlSession: URLSession = .shared) {
        let authenticator = AnyRequestAuthenticator { $0.authorize(usingBearerToken: token) }
        self.init(authenticator: authenticator, urlSession: urlSession)
    }

    @discardableResult
    public func request<Value>(_ request: Request<Value>, completion: @escaping (Result<Value, Client.Error>) -> Void) -> RequestToken
        where Value: Decodable {
        let urlRequest = try! self.urlRequest(for: request)

        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                switch (data, response, error) {
                case let (data?, response as HTTPURLResponse, nil):
                    completion(self.decode(data: data, response: response))

                case let (nil, _, error?):
                    completion(.failure(.urlSession(error)))

                default:
                    completion(.failure(.unknown))
                }
            }
        }

        task.resume()
            return RequestToken(task: task)
    }

    private let authenticator: RequestAuthenticator
    private let urlSession: URLSession
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = API.dateDecodingStrategy
        return decoder
    }()

    private func url<Value>(for request: Request<Value>) -> URL {
        var components = URLComponents(url: API.url, resolvingAgainstBaseURL: false)!
        components.path = request.path
        components.queryItems = request.queryItems.filter { $0.value != nil }
        return components.url!
    }
    
    private func urlRequest<Value>(for request: Request<Value>) throws -> URLRequest {
        var urlRequest = URLRequest(url: url(for: request))
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.acceptContentType(API.contentType)

        try authenticator.authenticate(&urlRequest)

        if let body = request.body {
            urlRequest.httpBody = try jsonEncoder.encode(body)
        }

        return urlRequest
    }

    private func decode<Value>(data: Data, response: HTTPURLResponse) -> Result<Value, Error> where Value: Decodable {
        do {
            guard (200..<300).contains(response.statusCode) else {
                let buildkiteError = try jsonDecoder.decode(BuildkiteError.self, from: data)
                return .failure(.buildkite(httpStatusCode: response.statusCode, buildkiteError))
            }

            return .success(try jsonDecoder.decode(Value.self, from: data))
        } catch let error as DecodingError {
            return .failure(.jsonDecoding(error))
        } catch {
            return .failure(.unknown)
        }
    }
}

private extension URLRequest {
    mutating func acceptContentType(_ contentType: String) {
        setValue(contentType, forHTTPHeaderField: "Accept")
    }

    mutating func authorize(usingBearerToken token: String) {
        setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
