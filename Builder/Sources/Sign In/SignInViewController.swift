import UIKit
import Buildkite

protocol SignInViewControllerDelegate: class {
    func signInViewController(_ viewController: SignInViewController, didSignInAs user: User, withToken token: String, defaultOrganization: Organization)
}

final class SignInViewController: UIViewController {

    weak var delegate: SignInViewControllerDelegate?

    init(factory: SignInFactoryProtocol = SignInFactory()) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        embed(_navigationController)

        let tokenAuthenticationViewController = TokenAuthenticationViewController(authenticator: factory.makeAuthenticator())
        tokenAuthenticationViewController.delegate = self
        _navigationController.pushViewController(tokenAuthenticationViewController, animated: false)
    }

    // MARK: Private

    private enum State {
        case authenticatingToken
        case selectingOrganization(user: User, token: String)
        case signedIn(user: User, token: String, organization: Organization)
    }

    private var state: State = .authenticatingToken
    private let factory: SignInFactoryProtocol
    private let _navigationController = UINavigationController()
}

extension SignInViewController: TokenAuthenticationViewControllerDelegate {
    func tokenAuthenticationViewController(_ viewController: TokenAuthenticationViewController, didAuthenticate user: User, usingToken token: String) {
        let api = Client(token: token)
        let factory = OrganizationsFactory(api: api)

        state = .selectingOrganization(user: user, token: token)

        let viewController = factory.makeOrganizationListViewController()
        viewController.delegate = self
        _navigationController.pushViewController(viewController, animated: true)
    }
}

extension SignInViewController: OrganizationListViewControllerDelegate {
    func organizationListViewController(_ viewController: OrganizationListViewController, didSelect organization: Organization) {
        guard case let .selectingOrganization(user, token) = state else {
            return
        }

        state = .signedIn(user: user, token: token, organization: organization)
        delegate?.signInViewController(self, didSignInAs: user, withToken: token, defaultOrganization: organization)
    }
}
