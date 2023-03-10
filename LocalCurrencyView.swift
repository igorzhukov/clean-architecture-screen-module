import SwiftUI
import DomainLayer

struct LocalCurrencyView: View {
    
    private let interactor: LocalCurrencyInteractor
    @ObservedObject private var viewModel: LocalCurrencyViewModel
    
    init(interactor: LocalCurrencyInteractor,
         viewModel: LocalCurrencyViewModel) {
        self.interactor = interactor
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .withWhiteNavigationBar(title: viewModel.title)
            .onAppear() {
                interactor.onAppear()
            }
            .compatibleFullScreenWithPublisher(
                isPresented: viewModel.$errorSnackBar.map { $0 != nil }.eraseToAnyPublisher(),
                transaction: .init(animation: .easeInOut(duration: UIGlobalConstants
                    .defaultAnimationDuration))) {
                        ErrorSnackbarView(
                            snackBarErrorMessage: viewModel.errorSnackBar ?? "",
                            isVisible: viewModel.errorSnackBar != nil,
                            isHiddenButton: viewModel.isHiddenRetryButtonBySnackBar) {
                                interactor.onRetry()
                            }
                    }
                    .layoutDirectioned()
    }
    
    @ViewBuilder private var content: some View {
        if viewModel.loading {
            loadingView()
        } else if viewModel.loadingFailed {
            loadingFailedView()
        } else {
            VStack {
                SearchTextField(features: $viewModel.searchTextFieldModel, onDidChange: interactor.onSearchQueryUpdate(_:))
                    .padding(.vertical, 10)
                if viewModel.currencies.isEmpty {
                    emptyView()
                } else {
                    itemsList(currencies: viewModel.currencies)
                }
            }
        }
    }
    
}

extension LocalCurrencyView {
    private func itemsList(currencies: [PaymentCurreniesAndPairs.PaymentCurrency]) -> some View {
        return ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                ForEach(currencies, id: \.id) { currency in
                    HStack(spacing: 16) {
                        RoundedIcon(viewModel.imageName(for: currency), 48)
                        
                        VStack(alignment: .leading) {
                            Text(currency.name)
                                .font(.system(size: 17))
                                .foregroundColor(Asset.Colors.textPrimary.colorSwiftUI)
                            Text(currency.symbol)
                                .font(.system(size: 17))
                                .foregroundColor(Asset.Colors.textSecondary.colorSwiftUI)
                        }
                        
                        Spacer()
                        
                        if currency.symbol == viewModel.selectedSymbol &&
                            currency.symbol != viewModel.loadingSymbol {
                            Image(Asset.Assets.checkmarkBlue.name)
                        }
                        
                        if currency.symbol == viewModel.loadingSymbol {
                            ProgressView()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        interactor.onTap(at: currency)
                    }
                }
            }
        }
    }
    
    private func loadingView() -> some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
            }
            
            ActivityIndicatorNative(isAnimating: viewModel.loading)
            
            Text(viewModel.loadingTitle)
                .font(.system(size: 15))
                .foregroundColor(Asset.Colors.textSecondary.colorSwiftUI)
            
            Spacer()
        }
    }
    
    private func loadingFailedView() -> some View {
        VStack(spacing: 12) {
            Spacer()
            
            HStack {
                Spacer()
            }
            
            Image(Asset.Assets.oops.name)
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.bottom, 12)
                .background(Color.blue)
            
            Text(viewModel.loadingFailedTitle)
                .font(.system(size: 27, weight: .bold))
                .foregroundColor(Asset.Colors.textPrimary.colorSwiftUI)
            
            Text(viewModel.loadingFailedSubtitle)
                .font(.system(size: 17))
                .foregroundColor(Asset.Colors.textSecondary.colorSwiftUI)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
    }
    
    private func emptyView() -> some View {
        VStack(spacing: 12) {
            Spacer()
            
            HStack {
                Spacer()
            }
            
            Image(Asset.Assets.noResults.name)
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.bottom, 12)
            
            Text(viewModel.emptyStateTitle)
                .font(.system(size: 27, weight: .bold))
                .foregroundColor(Asset.Colors.textPrimary.colorSwiftUI)
            
            Text(viewModel.emptyStateSubtitle)
                .font(.system(size: 17))
                .foregroundColor(Asset.Colors.textSecondary.colorSwiftUI)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
    }
}
