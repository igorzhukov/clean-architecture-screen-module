import Foundation
import DomainLayer
import SwiftUI

protocol LocalCurrencyPresenter: AnyObject, SnackBarPresenter {
    func show(_ items: [PaymentCurreniesAndPairs.PaymentCurrency])
    
    func showHideLoading(_ isLoading: Bool)
    func showHideLoadingFailed(_ isFailed: Bool)
    
    func updateSelectedSymbol(_ symbol: String?)
    func updateLoadingSymbol(_ symbol: String?)
    
    func updateEmptyStateSubtitle(withQuery query: String)
}

final class LocalCurrencyViewModel: SnackBarViewModel, LocalCurrencyPresenter {
  
    init(selectedSymbol: String) {
        self.selectedSymbol = selectedSymbol
    }
   
    private var imageProvider = FiatCurrencyImageProvider()
    
    @Published var searchTextFieldModel = SearchTextFieldModel(placeholder: "Search"~,
                                                               keyBoard: .default,
                                                               hideButton: false)
    
    @Published private(set) var loading: Bool = false
    @Published private(set) var loadingFailed: Bool = false
    @Published private(set) var selectedSymbol: String?
    @Published private(set) var loadingSymbol: String? = nil
    @Published private(set) var currencies: [PaymentCurreniesAndPairs.PaymentCurrency] = []
    
    func imageName(for currency: PaymentCurreniesAndPairs.PaymentCurrency) -> String {
        imageProvider.name(forSymbol: currency.symbol)
    }
    
    let title = "Local Currency"~
    
    let emptyStateTitle = "alert.noSearchResultsTitle"~
    private(set) var emptyStateSubtitle = ""
    
    func updateEmptyStateSubtitle(withQuery query: String) {
        emptyStateSubtitle = String(
            format: "alert.noSearchResultsSubtitle"~,
            query
        )
    }
    
    let loadingTitle = "Loading..."~
    let loadingFailedTitle = "alert.problemTitle"~
    let loadingFailedSubtitle = "alert.problemSubtitle"~
    
    func show(_ items: [PaymentCurreniesAndPairs.PaymentCurrency]) {
        currencies = items
    }
    
    func showHideLoading(_ isLoading: Bool) {
        loading = isLoading
    }
    
    func showHideLoadingFailed(_ isFailed: Bool) {
        loadingFailed = isFailed
    }
    
    func updateSelectedSymbol(_ symbol: String?) {
        selectedSymbol = symbol
    }
    
    func updateLoadingSymbol(_ symbol: String?) {
        loadingSymbol = symbol
    }
}
