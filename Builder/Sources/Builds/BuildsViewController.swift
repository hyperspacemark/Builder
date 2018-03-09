import UIKit

final class BuildsViewController: UISplitViewController {
    init() {
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

    lazy var masterNavigationController: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: BuildListViewController())
        return navigationController
    }()

    lazy var detailNavigationController: UINavigationController = UINavigationController(rootViewController: BuildDetailViewController())
}

extension BuildsViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
