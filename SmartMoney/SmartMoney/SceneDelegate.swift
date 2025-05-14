import UIKit
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let authViewController = AuthAssembly.assemble()
        
        let schema = Schema([
            TransactionModel.self,
            CategoryModel.self,
            Card.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let modelContext = ModelContext(modelContainer)
            let mainVC = TransactionsListAssembly.buildTransactionsListModule(modelContext: modelContext)
            let navigationController = UINavigationController(rootViewController: mainVC)
            window.rootViewController = navigationController
        } catch {
            let mainVC = UIViewController()
            mainVC.view.backgroundColor = .green
            let navigationController = UINavigationController(rootViewController: mainVC)
            window.rootViewController = navigationController
        }
        
        
//        let mainVC = TransactionsListAssembly.buildTransactionsListModule(modelContext: modelContext)
//        authViewController.navigationItem.hidesBackButton = true
//        let navigationController = UINavigationController(rootViewController: mainVC)
//        
//        // navigationController.pushViewController(authViewController, animated: false)
//                
//        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }

}

