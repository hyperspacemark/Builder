import UIKit
import Buildkite

protocol DashboardViewControllerDelegate: class {
    func dashboardViewControllerDidSignOut(_ viewController: DashboardViewController)
}

final class DashboardViewController: UIViewController {
    weak var delegate: DashboardViewControllerDelegate?

    init(factory: DashboardFactory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        embed(dashboardTabBarController)
    }

    private let factory: DashboardFactory

    private lazy var dashboardTabBarController: UITabBarController = {
        let viewController = UITabBarController()
        viewController.viewControllers = [
            self.pipelinesViewController,
            self.agentsViewController,
            self.userBuildsViewController,
            self.userViewController
        ]
        return viewController
    }()

    private lazy var pipelinesViewController = factory.makePipelinesViewController()
    private lazy var agentsViewController = factory.makeAgentsViewController()
    private lazy var userBuildsViewController = factory.makeBuildsViewController()
    private lazy var userViewController: UserViewController = {
        let viewController = factory.makeUserViewController()
        viewController.delegate = self
        return viewController
    }()
}

extension DashboardViewController: UserViewControllerDelegate {
    func userViewControllerDidSignOut(_ viewController: UserViewController) {
        delegate?.dashboardViewControllerDidSignOut(self)
    }
}
