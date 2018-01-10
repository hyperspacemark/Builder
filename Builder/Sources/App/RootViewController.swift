import UIKit

final class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(_splitViewController)
        view.addSubview(_splitViewController.view)
        _splitViewController.view.frame = view.bounds
        _splitViewController.view.autoresizingMask = view.autoresizingMask
        _splitViewController.didMove(toParentViewController: self)
    }

    private lazy var _splitViewController: UISplitViewController = {
        let viewController = UISplitViewController()
        viewController.delegate = self
        viewController.viewControllers = [
            masterNavigationController,
            detailNavigationController
        ]
        return viewController
    }()

    lazy var masterNavigationController: UINavigationController = UINavigationController(rootViewController: OrganizationsViewController())
    lazy var detailNavigationController: UINavigationController = UINavigationController(rootViewController: DetailViewController())
}

extension RootViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
