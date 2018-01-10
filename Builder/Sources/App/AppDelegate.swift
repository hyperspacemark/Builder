import UIKit
import Buildkite

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        AppEnvironment.current.tokenStore.token = "c16c53a1289346f23870d30545ada3f19b1a1348"

        AppEnvironment.restore(from: AppEnvironment.current.environmentStore)

        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}
