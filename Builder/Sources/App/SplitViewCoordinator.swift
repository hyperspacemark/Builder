import Buildkite
import UIKit

final class SplitViewCoordinator: UISplitViewControllerDelegate {

    lazy var organizationsView: (OrganizationsViewDriver, OrganizationsViewController) = {
        let viewController = OrganizationsViewController()

        let driver = OrganizationsViewDriver(ui: viewController) { organization in
        }

        return (driver, viewController)
    }()

    lazy var splitViewController: UISplitViewController = {
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [
            masterNavigationController,
            detailNavigationController
        ]
        splitViewController.delegate = self
        return splitViewController
    }()

    func updateDisplayModeButtonItem() {
        detailNavigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
    }

    lazy var masterNavigationController: UINavigationController = UINavigationController(rootViewController: organizationsView.1)
    lazy var detailNavigationController: UINavigationController = UINavigationController(rootViewController: DetailViewController())

    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
