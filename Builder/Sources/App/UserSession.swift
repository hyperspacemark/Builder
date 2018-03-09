import struct Buildkite.User
import struct Buildkite.Organization
import class Buildkite.Client

struct UserSession {
    let user: User
    let client: Client
    let organization: Organization
}
