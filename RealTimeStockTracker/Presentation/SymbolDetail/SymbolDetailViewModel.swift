//
//  SymbolDetailViewModel.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  Symbol Detail View Model  -

class SymbolDetailViewModel {
    
    // MARK:  -  Properties  -
    
    private(set) var stock: Stock
    private var repository: StockRepositoryProtocol?
    private var priceUpdateTask: Task<Void, Never>?
    
    // MARK:  -  Closures for UI Binding  -
    
    var onStockUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK:  -  Initialization  -
    
    init(stock: Stock, repository: StockRepositoryProtocol? = nil) {
        self.stock = stock
        self.repository = repository
        setupPriceUpdateSubscription()
    }
    
    // MARK:  -  Public Methods  -
    
    func updateStock(_ newStock: Stock) {
        self.stock = newStock
        onStockUpdated?()
    }
    
    // MARK:  -  Private Methods  -
    
    private func setupPriceUpdateSubscription() {
        guard let repository = repository else { return }
        
        priceUpdateTask = Task { [weak self] in
            let updateHandler: (String, Double) -> Void = { symbol, newPrice in
                Task { [weak self] in
                    await self?.handlePriceUpdate(symbol: symbol, newPrice: newPrice)
                }
            }
            
            await repository.subscribeToPriceUpdates(onUpdate: updateHandler)
        }
    }
    
    private func handlePriceUpdate(symbol: String, newPrice: Double) async {
        guard symbol == stock.symbol else { return }
        
        let updatedStock = Stock(
            symbol: stock.symbol,
            currentPrice: newPrice,
            previousPrice: stock.currentPrice,
            description: stock.description
        )
        
        await MainActor.run {
            self.stock = updatedStock
            self.onStockUpdated?()
        }
    }
    
    deinit {
        priceUpdateTask?.cancel()
    }
}
