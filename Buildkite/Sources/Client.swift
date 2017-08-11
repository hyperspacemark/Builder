import Foundation

public final class Client {
    public enum Error: Swift.Error {
        case urlSession(Swift.Error)
        case jsonDecoding(Swift.Error)
        case buildkite(httpStatusCode: Int, BuildkiteError)
        case unknown
    }

    public init(token: String? = nil, urlSession: URLSession = .shared) {
        self.token = token
        self.urlSession = urlSession
    }

    public func execute<Value>(_ request: Request<Value>, completion: @escaping (Result<Value, Error>) -> Void) where Value: Decodable {
        let urlRequest = try! self.urlRequest(for: request)

        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            switch (data, response, error) {
            case let (data?, response as HTTPURLResponse, nil):
                completion(self.decode(data: data, response: response))

            case let (nil, _, error?):
                completion(.failure(.urlSession(error)))

            default:
                completion(.failure(.unknown))
            }
        }

        task.resume()
    }

    private let token: String?
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

        if let token = token {
            urlRequest.authorize(usingBearerToken: token)
        }

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
