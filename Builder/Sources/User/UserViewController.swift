import UIKit

protocol UserViewControllerDelegate: class {
    func userViewControllerDidSignOut(_ viewController: UserViewController)
}

final class UserViewController: UIViewController {
    weak var delegate: UserViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = userDetailViewController.tabBarItem
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var _navigationController: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: userDetailViewController)
        return navigationController
    }()

    private lazy var userDetailViewController: UserDetailViewController = {
        let viewController = UserDetailViewController()
        viewController.delegate = self
        return viewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(_navigationController)
        _navigationController.view.frame = view.bounds
        _navigationController.view.autoresizingMask = view.autoresizingMask
        view.addSubview(_navigationController.view)
        _navigationController.didMove(toParentViewController: self)
    }
}

extension UserViewController: UserDetailViewControllerDelegate {
    func userDetailViewControllerDidSignOut(_ viewController: UserDetailViewController) {
        delegate?.userViewControllerDidSignOut(self)
    }
}
