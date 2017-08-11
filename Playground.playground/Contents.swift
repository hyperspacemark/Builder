import Buildkite
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

let client = Client(token: "c16c53a1289346f23870d30545ada3f19b1a1348")
let request = Organization.having(slug: "builder")
client.execute(request) { result in
    switch result {
    case let .success(organization):
        print(organization)
        
    case let .failure(error):
        print(error)
    }
}
