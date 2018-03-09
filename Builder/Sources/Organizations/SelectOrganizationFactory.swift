import struct Buildkite.Organization

final class OrganizationsFactory {
    init(api: API) {
        self.api = api
        self.cache = APICache()
    }

    func makeOrganizationListViewController() -> OrganizationListViewController {
        let organizations = Resource<[Organization]> { handleResult in
            self.api.request(Organization.all) { result in
                if case let .success(value) = result {
                    self.cache.save(value, for: .organizations)
                }

                handleResult(result)
            }
        }

        return OrganizationListViewController(organizations: organizations)
    }

    private let api: API
    private let cache: APICache
}
