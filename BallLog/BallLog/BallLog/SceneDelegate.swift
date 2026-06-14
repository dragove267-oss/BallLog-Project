import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let tabBarController = UITabBarController()

        // 오늘 경기 탭
        let gamesVC = ViewController()
        let gamesNav = UINavigationController(rootViewController: gamesVC)
        gamesNav.tabBarItem = UITabBarItem(title: "경기",
                                           image: UIImage(systemName: "baseball"),
                                           tag: 0)

        // 어제 결과 탭
        let yesterdayVC = YesterdayResultViewController()
        let yesterdayNav = UINavigationController(rootViewController: yesterdayVC)
        yesterdayNav.tabBarItem = UITabBarItem(title: "결과",
                                               image: UIImage(systemName: "checkmark.circle"),
                                               tag: 1)

        // 예측 기록 탭
        let historyVC = PredictionHistoryViewController()
        let historyNav = UINavigationController(rootViewController: historyVC)
        historyNav.tabBarItem = UITabBarItem(title: "예측",
                                             image: UIImage(systemName: "star"),
                                             tag: 2)

        // 검색 탭
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "검색",
                                            image: UIImage(systemName: "magnifyingglass"),
                                            tag: 3)

        tabBarController.viewControllers = [gamesNav, yesterdayNav, historyNav, searchNav]
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
