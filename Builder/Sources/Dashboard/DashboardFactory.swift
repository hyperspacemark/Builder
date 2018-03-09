import struct Buildkite.Pipeline
import struct Buildkite.Organization

protocol DashboardFactoryProtocol {
    func makePipelinesViewController() -> PipelinesViewController
    func makeAgentsViewController() -> AgentsViewController
    func makeBuildsViewController() -> BuildsViewController
    func makeUserViewController() -> UserViewController
}

final class DashboardFactory: DashboardFactoryProtocol {
    init(userSession: UserSession) {
        self.dataStore = DataStore(api: userSession.client, selectedOrganization: userSession.organization)
    }

    func makePipelinesViewController() -> PipelinesViewController {
        return PipelinesViewController(factory: self)
    }

    func makeAgentsViewController() -> AgentsViewController {
        return AgentsViewController()
    }

    func makeBuildsViewController() -> BuildsViewController {
        return BuildsViewController()
    }

    func makeUserViewController() -> UserViewController {
        return UserViewController()
    }

    private let dataStore: DataStore
}

extension DashboardFactory: PipelinesFactory {
    func makePipelineListViewController() -> PipelineListViewController {
        return PipelineListViewController(pipelines: dataStore.pipelines)
    }

    func makePipelineDetailViewController(for pipeline: Pipeline) -> PipelineDetailViewController {
        return PipelineDetailViewController(pipeline: pipeline)
    }
}
