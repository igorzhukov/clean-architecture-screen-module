import DomainLayer
import Foundation
import SwiftUI
import Utils

struct LocalCurrencyBuilder: ModuleBuilderWithContainer,
                                  ModuleInitialization {
    
    let moduleOutput: LocalCurrencyModuleOutput
    let selectedSymbol: String
    
    static func initialization(container: Container) throws {
        
        container.register(serviceType: .unique) { (resolver: ResolverServicesProtocol,
                                                    moduleOutput: LocalCurrencyModuleOutput,
                                                    selectedSymbol: String) -> LocalCurrencyView in
            let viewModel = LocalCurrencyViewModel(selectedSymbol: selectedSymbol)
            
            let interactor = LocalCurrencyInteractor(viewModel,
                                                          moduleOutput,
                                                          try container.resolve(),
                                                          try container.resolve(), selectedSymbol: selectedSymbol)
            
            let view = LocalCurrencyView(interactor: interactor,
                                              viewModel: viewModel)
            return view
        }
    }
    
    func build(container: Container) throws -> LocalCurrencyView {
        return try container.resolve(arg: moduleOutput, arg2: selectedSymbol)
    }
}
