//
//  SymbolsListViewModel.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 04/04/2026.
//

import Foundation

// MARK:  -  Symbols List View Model  -

class SymbolsListViewModel {
    
    // MARK:  -  Properties  -
    
    private let fetchStocksUseCase: FetchStocksUseCaseProtocol
    private let sortStocksUseCase: SortStocksUseCaseProtocol
    private var repository: StockRepositoryProtocol?
    private var stocks: [Stock] = []
    private var displayedStocks: [Stock] = []
    private var currentSortType: SortType = .bySymbol
    private var isLoading = false
    
    // MARK:  -  Closures for UI Binding  -
    
    var onStocksUpdated: (() -> Void)?
    var onConnectionStatusChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK:  -  Computed Properties  -
    
    var numberOfStocks: Int {
        return displayedStocks.count
    }
    
    var isWebSocketConnected: Bool {
        return repository?.isConnected ?? false
    }
    
    var isRepositoryReady: Bool {
        return repository != nil
    }
    
    // MARK:  -  Initialization  -
    
    init(fetchStocksUseCase: FetchStocksUseCaseProtocol, sortStocksUseCase: SortStocksUseCaseProtocol) {
        self.fetchStocksUseCase = fetchStocksUseCase
        self.sortStocksUseCase = sortStocksUseCase
    }
    
    // MARK:  -  Public Methods  -
    
    func loadStocks() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let fetchedStocks = try await fetchStocksUseCase.execute()
            self.stocks = fetchedStocks
            self.displayedStocks = fetchedStocks
            self.repository = fetchStocksUseCase.repository
            
            await MainActor.run {
                self.onStocksUpdated?()
            }
        } catch {
            await MainActor.run {
                self.onError?("Failed to load stocks: \(error.localizedDescription)")
            }
        }
        
        isLoading = false
    }
    
    func stock(at index: Int) -> Stock {
        return displayedStocks[index]
    }
    
    func sortStocks(by sortType: SortType) {
        currentSortType = sortType
        displayedStocks = sortStocksUseCase.execute(stocks: stocks, sortType: sortType)
        onStocksUpdated?()
    }
    
    func connectWebSocket() {
        guard let repository = repository else {
            onError?("Repository not initialized. Please wait for stocks to load.")
            return
        }
        
        // Create update handler
        let updateHandler: (String, Double) -> Void = { [weak self] symbol, newPrice in
            DispatchQueue.main.async {
                self?.handlePriceUpdate(symbol: symbol, newPrice: newPrice)
            }
        }
        
        // Subscribe to updates in background
        Task {
            await repository.subscribeToPriceUpdates(onUpdate: updateHandler)
            
            await MainActor.run {
                self.onConnectionStatusChanged?(true)
            }
        }
    }
    
    func disconnectWebSocket() {
        repository?.disconnectWebSocket()
        onConnectionStatusChanged?(false)
    }
    
    // MARK:  -  Private Methods  -
    
    private func handlePriceUpdate(symbol: String, newPrice: Double) {
        if let index = stocks.firstIndex(where: { $0.symbol == symbol }) {
            let oldStock = stocks[index]
            let updatedStock = Stock(
                symbol: oldStock.symbol,
                currentPrice: newPrice,
                previousPrice: oldStock.currentPrice,
                description: oldStock.description
            )
            stocks[index] = updatedStock
            displayedStocks = sortStocksUseCase.execute(stocks: stocks, sortType: currentSortType)
            onStocksUpdated?()
        }
    }
}
