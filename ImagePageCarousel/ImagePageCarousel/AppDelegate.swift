//
//  AppDelegate.swift

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - App Coordinator

    var window: UIWindow?
    var coordinator: Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController: UINavigationController = .init()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        coordinator = Coordinator(navigationController)
        coordinator?.start()

        return true
    }
}
