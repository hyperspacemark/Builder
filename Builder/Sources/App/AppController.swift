import UIKit
import struct Buildkite.User
import class Buildkite.Client
import enum Buildkite.Result

final class AppController: SignOutServiceProtocol {

    func launch(withOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> UIWindow {
        window.rootViewController = rootViewController

        DispatchQueue.main.async {
            if AppEnvironment.current.userSession != nil {
                self.showSignedInUI()
            } else {
                self.showSignedOutUI()
            }
        }

        return window
    }

    // SignOutServiceProtocol

    func signOut() {
        AppEnvironment.signOut()
        showSignedOutUI()
    }

    private enum State {
        case launching
        case signedIn(SplitViewCoordinator)
        case signedOut(SignInPresenter)
    }

    private var state: State = .launching
    private lazy var window: UIWindow = UIWindow()
    private let rootViewController = RootViewController()

    private func signIn(user: User, token: String) {
        AppEnvironment.signIn(user: user, token: token)
        showSignedInUI()
    }

    private func showSignedInUI() {
        let coordinator = SplitViewCoordinator()
        rootViewController.contentViewController = coordinator.splitViewController
        state = .signedIn(coordinator)
    }

    private func showSignedOutUI() {
        let viewController = SignInViewController()
        let presenter = SignInPresenter(ui: viewController, service: SignInService(), didFinish: signIn)
        rootViewController.contentViewController = viewController
        state = .signedOut(presenter)
    }
}
