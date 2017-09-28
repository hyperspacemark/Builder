import Foundation
import Buildkite

final class OrganizationsCache {
    var organizations: [Organization] = [
        Organization(id: "a", name: "Venmo", slug: "venmo", webURL: URL(string: "https://www.venmo.com")!, creationDate: Date()),
        Organization(id: "b", name: "Apple", slug: "apple", webURL: URL(string: "https://www.apple.com")!, creationDate: Date()),
        Organization(id: "c", name: "Interstellar Apps", slug: "interstellar-apps", webURL: URL(string: "https://www.markada.ms")!, creationDate: Date()),
        ]
}
