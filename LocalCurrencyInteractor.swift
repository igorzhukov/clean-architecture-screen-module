import DomainLayer
import Foundation
import Combine

final class LocalCurrencyInteractor {
    private let presenter: LocalCurrencyPresenter
    private weak var moduleOutput: LocalCurrencyModuleOutput?
    
    private var notFilteredCurrencies: [PaymentCurreniesAndPairs.PaymentCurrency] = []
    
    private var selectedSymbol: String
    private var symbolToSelect: String? = nil
    private var loadingSymbol: String? = nil
    
    private let getCurrenciesUseCase: GetPaymentCurreniesAndPairsUseCase
    private let setLocalCurrencyUseCase: SetLocalCurrencyUseCase
    
    private var subscriptions: Set<AnyCancellable> = .init()
    
    // MARK: Initialization
    
    init(_ presenter: LocalCurrencyPresenter,
         _ moduleOutput: LocalCurrencyModuleOutput,
         _ getCurrenciesUseCase: GetPaymentCurreniesAndPairsUseCase,
         _ setLocalCurrencyUseCase: SetLocalCurrencyUseCase,
         selectedSymbol: String) {
        self.presenter = presenter
        self.moduleOutput = moduleOutput
        self.getCurrenciesUseCase = getCurrenciesUseCase
        self.setLocalCurrencyUseCase = setLocalCurrencyUseCase
        self.selectedSymbol = selectedSymbol
    }
    
    // MARK: UI events
    
    func onTap(at currency: PaymentCurreniesAndPairs.PaymentCurrency) {
        guard selectedSymbol != currency.symbol else { return }
        setLocalCurrency(currency.symbol)
    }
    
    private func loadData() {
        presenter.showHideLoading(true)
        
        getCurrenciesUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self.presenter.showHideLoading(false)
                    self.presenter.showHideLoadingFailed(true)
                    self.presenter.showSnackBarError(error: error, isHiddenRetryButtonBySnackBar: false)
                }
            } receiveValue: { [weak self] currency in
                guard let self = self else { return }
                self.presenter.hideSnackBarError()
                self.presenter.showHideLoading(false)
                self.presenter.showHideLoadingFailed(false)
                self.notFilteredCurrencies = currency.currencies.filter { $0.isCrypto == false }
                self.presenter.show(self.notFilteredCurrencies)
            }
            .store(in: &subscriptions)
    }
    
    private func setLocalCurrency(_ symbol: String) {
        symbolToSelect = symbol
        
        presenter.updateSelectedSymbol(nil)
        presenter.updateLoadingSymbol(symbol)
        
        setLocalCurrencyUseCase.execute(symbol: symbol)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.presenter.updateSelectedSymbol(self.selectedSymbol)
                    self.presenter.updateLoadingSymbol(nil)
                    self.presenter.showSnackBarError(error: error, isHiddenRetryButtonBySnackBar: true)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.presenter.hideSnackBarError()
                self.selectedSymbol = symbol
                self.symbolToSelect = nil
                Defaults.defaultEquivalentCurrencySymbol = symbol
                self.moduleOutput?.goBack()
            }
            .store(in: &subscriptions)
    }
    
    func onRetry() {
        loadData()
    }
    
    func onAppear() {
        loadData()
        onSearchQueryUpdate("")
    }
    
    func onSearchQueryUpdate(_ query: String) {
        presenter.updateEmptyStateSubtitle(withQuery: query)
        
        let query = query.lowercased()
        let filteredCurrencies: [PaymentCurreniesAndPairs.PaymentCurrency]
        
        if query.isEmpty {
            filteredCurrencies = notFilteredCurrencies
        } else {
            filteredCurrencies = notFilteredCurrencies.filter {
                $0.symbol.lowercased().contains(query) ||
                $0.name.lowercased().contains(query)
            }
        }
        
        presenter.show(filteredCurrencies)
    }
}
