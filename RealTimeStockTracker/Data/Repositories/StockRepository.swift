//
//  StockRepository.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  Stock Repository  -

class StockRepository: StockRepositoryProtocol {
    private let dataSource: StockDataSourceProtocol
    private let updateUseCase: UpdateStockPriceUseCaseProtocol
    private var stocks: [Stock] = []
    private var priceUpdateTask: Task<Void, Never>?
    
    var isConnected: Bool {
        return dataSource.isConnected
    }
    
    init(dataSource: StockDataSourceProtocol, updateUseCase: UpdateStockPriceUseCaseProtocol) {
        self.dataSource = dataSource
        self.updateUseCase = updateUseCase
    }
    
    func fetchStocks() async throws -> [Stock] {
        stocks = try await dataSource.getInitialStocks()
        return stocks
    }
    
    func updateStockPrice(symbol: String, newPrice: Double) async throws -> Stock? {
        guard let index = stocks.firstIndex(where: { $0.symbol == symbol }) else {
            return nil
        }
        
        let updatedStock = updateUseCase.execute(stock: stocks[index], newPrice: newPrice)
        stocks[index] = updatedStock
        return updatedStock
    }
    
    func subscribeToPriceUpdates(onUpdate: @escaping (String, Double) -> Void) async {
        // Create a task to handle the subscription
        priceUpdateTask = Task {
            await dataSource.subscribeToPriceUpdates { [weak self] symbol, newPrice in
                guard let self = self else { return }
                Task {
                    do {
                        let updatedStock = try await self.updateStockPrice(symbol: symbol, newPrice: newPrice)
                        if updatedStock != nil {
                            // Call the closure on main actor for UI updates
                            await MainActor.run {
                                onUpdate(symbol, newPrice)
                            }
                        }
                    } catch {
                        print("Error updating stock price: \(error)")
                    }
                }
            }
        }
    }
    
    func disconnectWebSocket() {
        priceUpdateTask?.cancel()
        dataSource.disconnectWebSocket()
    }
}
