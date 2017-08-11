import Foundation

internal enum API {
    static let url = URL(string: "https://api.buildkite.com/v2")!
    static let contentType = "application/json"

    static let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = {
        func decodeDate(from decoder: Decoder) throws -> Date {
            let string = try decoder.singleValueContainer().decode(String.self)

            guard let date = API.dateFormatter.date(from: string) else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot initialize \(Date.self) with invalid \(String.self) value \(string)")
                throw DecodingError.dataCorrupted(context)
            }

            return date
        }

        return .formatted(dateFormatter)
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}
