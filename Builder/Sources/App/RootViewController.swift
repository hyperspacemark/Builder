import UIKit

final class RootViewController: UIViewController {
    var contentViewController: UIViewController {
        didSet {
            transition(from: oldValue, to: contentViewController)
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.contentViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.view.frame = view.bounds
        contentViewController.view.autoresizingMask = view.autoresizingMask
        contentViewController.didMove(toParentViewController: self)
    }

    func transition(from oldViewController: UIViewController, to newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        addChildViewController(newViewController)

        transition(from: oldViewController, to: newViewController, duration: 0.5, options: [.transitionCrossDissolve], animations: {}) { completed in
            oldViewController.removeFromParentViewController()
            newViewController.didMove(toParentViewController: self)
        }
    }
}
