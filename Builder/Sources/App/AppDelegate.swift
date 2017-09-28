import UIKit
import Buildkite

protocol ServiceLocator {
    var signOutService: SignOutServiceProtocol { get }
}

protocol SignOutServiceProtocol {
    func signOut()
}

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, ServiceLocator {
    var window: UIWindow?

    var signOutService: SignOutServiceProtocol {
        return appController
    }

    private lazy var appController: AppController = AppController()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        AppEnvironment.current.tokenStore.token = "c16c53a1289346f23870d30545ada3f19b1a1348"

        AppEnvironment.restore(from: AppEnvironment.current.environmentStore)

        window = appController.launch(withOptions: launchOptions)
        window?.makeKeyAndVisible()
        
        return true
    }
}
