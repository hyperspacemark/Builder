import UIKit
import struct Buildkite.Pipeline

protocol PipelinesFactory {
    func makePipelineListViewController() -> PipelineListViewController
    func makePipelineDetailViewController(for: Pipeline) -> PipelineDetailViewController
}

final class PipelinesViewController: UISplitViewController {
    init(factory: PipelinesFactory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
        delegate = self
        tabBarItem = masterNavigationController.topViewController?.tabBarItem
        viewControllers = [
            masterNavigationController,
            detailNavigationController
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let factory: PipelinesFactory
    private lazy var masterNavigationController: UINavigationController = {
        let viewController = self.factory.makePipelineListViewController()
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }()

    private lazy var detailNavigationController = UINavigationController()
}

extension PipelinesViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension PipelinesViewController: PipelineListViewControllerDelegate {
    func pipelineListViewController(_ viewController: PipelineListViewController, didSelect pipeline: Pipeline) {
        let detailViewController = factory.makePipelineDetailViewController(for: pipeline)
        showDetailViewController(detailViewController, sender: self)
    }
}
