import Foundation

public struct Artifact: Decodable {
    public struct Download: Decodable {
        let url: URL
    }

    public enum State: String, Decodable {
        case new
        case error
        case finished
        case deleted
    }
    
    public let id: ID<Artifact>
    public let jobID: ID<Job>
    public let url: URL
    public let download: Download
    public let state: State
    public let path: String
    public let directoryName: String
    public let fileName: String
    public let mimeType: String
    public let fileSize: UInt
    public let globPath: String
    public let originalPath: String
    public let sha1Sum: String
}

extension Artifact: Hashable {
    public var hashValue: Int {
        return id.hashValue ^ jobID.hashValue
    }

    public static func ==(lhs: Artifact, rhs: Artifact) -> Bool {
        return lhs.id == rhs.id && lhs.jobID == rhs.jobID
    }
}

extension Artifact.Download {
    public var hashValue: Int {
        return url.hashValue
    }

    public static func ==(lhs: Artifact.Download, rhs: Artifact.Download) -> Bool {
        return lhs.url == rhs.url
    }
}
