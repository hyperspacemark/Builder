import UIKit
import Buildkite

final class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        embed(state.viewController)
    }

    private enum State {
        case signedOut(SignInViewController)
        case signedIn(DashboardViewController)

        var isSignedIn: Bool {
            switch self {
            case .signedOut:
                return false

            case .signedIn:
                return true
            }
        }

        var viewController: UIViewController {
            switch self {
            case let .signedOut(viewController):
                return viewController

            case let .signedIn(viewController):
                return viewController
            }
        }
    }

    private lazy var state: State = self.makeInitialState()

    private func makeInitialState() -> State {
        if let userSession = AppEnvironment.current.userSession {
            return .signedIn(makeDashboardViewController(userSession: userSession))
        } else {
            return .signedOut(makeSignInViewController())
        }
    }

    private func makeDashboardViewController(userSession: UserSession) -> DashboardViewController {
        let factory = DashboardFactory(userSession: userSession)
        let viewController = DashboardViewController(factory: factory)
        viewController.delegate = self
        return viewController
    }

    private func makeSignInViewController() -> SignInViewController {
        let viewController = SignInViewController()
        viewController.delegate = self
        return viewController
    }

    private func transition(to newState: State) {
        let oldState = state
        state = newState
        addChildViewController(state.viewController)
        oldState.viewController.willMove(toParentViewController: nil)

        state.viewController.view.frame = view.bounds.offsetBy(dx: 0, dy: view.bounds.height)
        state.viewController.view.autoresizingMask = view.autoresizingMask

        transition(from: oldState.viewController, to: state.viewController, duration: 0.3, options: [UIViewAnimationOptions(rawValue: 7 << 16)], animations: {
            self.state.viewController.view.frame = self.view.bounds
        }) { transitionWasAnimated in
            oldState.viewController.removeFromParentViewController()
            self.state.viewController.didMove(toParentViewController: self)
        }
    }
}

extension RootViewController: SignInViewControllerDelegate {
    func signInViewController(_ viewController: SignInViewController, didSignInAs user: User, withToken token: String, defaultOrganization: Organization) {
        precondition(!state.isSignedIn)
        let userSession = AppEnvironment.signIn(user: user, token: token, organization: defaultOrganization)
        transition(to: .signedIn(makeDashboardViewController(userSession: userSession)))
    }
}

extension RootViewController: DashboardViewControllerDelegate {
    func dashboardViewControllerDidSignOut(_ viewController: DashboardViewController) {
        AppEnvironment.signOut()
        transition(to: .signedOut(makeSignInViewController()))
    }
}
