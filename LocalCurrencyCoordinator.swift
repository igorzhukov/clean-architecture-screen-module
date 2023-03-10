import DomainLayer
import SwiftUI
import UIKit
import Utils

protocol LocalCurrencyModuleOutput: AnyObject {
    func goBack()
}

final class LocalCurrencyCoordinator: NavigationCoordinator,
                                           LocalCurrencyModuleOutput {
    
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    
    var parent: Coordinator?
    var container = Container()
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        do {
            let view = try LocalCurrencyBuilder(moduleOutput: self,
                                                     selectedSymbol: Defaults.defaultEquivalentCurrencySymbol)
                .build(container: container)
            
            let hostingController = UIHostingController(rootView: view)
            hostingController.navigationItem.isNavigationBarHidden = true
            hostingController.hidesBottomBarWhenPushed = true
            
            BackButtonNavigationStyle().setup(viewController: hostingController, navigationController: navigationController)
            
            
            navigationController.pushViewController(hostingController, animated: true)
        } catch {
            logError("DI Error \(error)")
        }
    }
    
    func goBack() {
        navigationController.popViewController(animated: true)
    }
}
