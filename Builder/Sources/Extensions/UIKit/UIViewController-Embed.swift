import UIKit

extension UIViewController {
    func embed(_ viewController: UIViewController) {
        addChildViewController(viewController)
        viewController.view.autoresizingMask = view.autoresizingMask
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
}
