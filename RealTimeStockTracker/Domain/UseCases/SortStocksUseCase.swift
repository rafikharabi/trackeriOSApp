//
//  SortStocksUseCase.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  Sort Type  -

enum SortType: String, CaseIterable {
    case bySymbol = "Symbol"
    case byPrice = "Price"
    case byPriceChange = "Price Change"
}

// MARK:  -  Sort Stocks Use Case Protocol  -

protocol SortStocksUseCaseProtocol {
    func execute(stocks: [Stock], sortType: SortType) -> [Stock]
}

// MARK:  -  Sort Stocks Use Case  -

class SortStocksUseCase: SortStocksUseCaseProtocol {
    func execute(stocks: [Stock], sortType: SortType) -> [Stock] {
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
