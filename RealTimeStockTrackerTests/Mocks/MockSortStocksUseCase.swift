//
//  MockSortStocksUseCase.swift
//  RealTimeStockTrackerTests
//
//  Created by Usman Javed on 07/04/2026.
//

import Foundation
@testable import RealTimeStockTracker

// MARK:  -  Mock Sort Stocks Use Case  -

class MockSortStocksUseCase: SortStocksUseCaseProtocol {
    var didCallExecute = false
    var lastSortType: SortType?
    var mockSortedStocks: [Stock]?
    
    func execute(stocks: [Stock], sortType: SortType) -> [Stock] {
        didCallExecute = true
        lastSortType = sortType
        
        // If mock sorted stocks are provided, return them
        if let mockSortedStocks = mockSortedStocks {
            return mockSortedStocks
        }
        
        // Otherwise perform actual sort for testing
        var sortedStocks = stocks
        switch sortType {
        case .bySymbol:
            sortedStocks.sort { $0.symbol < $1.symbol }
        case .byPrice:
            sortedStocks.sort { $0.currentPrice > $1.currentPrice }
        case .byPriceChange:
            sortedStocks.sort { abs($0.priceChangePercentage) > abs($1.priceChangePercentage) }
        }
        return sortedStocks
    }
}
