//
//  MockStockRepository.swift
//  RealTimeStockTrackerTests
//
//  Created by Usman Javed on 07/04/2026.
//

import Foundation
@testable import RealTimeStockTracker

// MARK:  -  Mock Stock Repository  -

class MockStockRepository: StockRepositoryProtocol {
    var mockStocks: [Stock] = []
    var shouldThrowError = false
    var subscribeToPriceUpdatesCalled = false
    var disconnectWebSocketCalled = false
    var isConnected = false
    var priceUpdateHandler: ((String, Double) -> Void)?
    var fetchStocksCalled = false
    
    func fetchStocks() async throws -> [Stock] {
        fetchStocksCalled = true
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        return mockStocks
    }
    
    func updateStockPrice(symbol: String, newPrice: Double) async throws -> Stock? {
        if let index = mockStocks.firstIndex(where: { $0.symbol == symbol }) {
            let updated = Stock(
                symbol: mockStocks[index].symbol,
                currentPrice: newPrice,
                previousPrice: mockStocks[index].currentPrice,
                description: mockStocks[index].description
            )
            mockStocks[index] = updated
            return updated
        }
        return nil
    }
    
    func subscribeToPriceUpdates(onUpdate: @escaping @Sendable (String, Double) -> Void) async {
        subscribeToPriceUpdatesCalled = true
        self.priceUpdateHandler = onUpdate
        self.isConnected = true
    }
    
    func disconnectWebSocket() {
        disconnectWebSocketCalled = true
        isConnected = false
        priceUpdateHandler = nil
    }
    
    // Helper method for testing
    func triggerPriceUpdate(symbol: String, price: Double) {
        priceUpdateHandler?(symbol, price)
    }
}
