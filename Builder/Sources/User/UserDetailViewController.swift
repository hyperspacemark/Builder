import UIKit

protocol UserDetailViewControllerDelegate: class {
    func userDetailViewControllerDidSignOut(_ viewController: UserDetailViewController)
}

final class UserDetailViewController: UIViewController {
    weak var delegate: UserDetailViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "User"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
    }

    @objc private func signOut() {
        delegate?.userDetailViewControllerDidSignOut(self)
    }
}
