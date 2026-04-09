//
//  UpdateStockPriceUseCase.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  Update Stock Price Use Case Protocol  -

protocol UpdateStockPriceUseCaseProtocol {
    func execute(stock: Stock, newPrice: Double) -> Stock
}

// MARK:  -  Update Stock Price Use Case  -

class UpdateStockPriceUseCase: UpdateStockPriceUseCaseProtocol {
    func execute(stock: Stock, newPrice: Double) -> Stock {
        return Stock(
            symbol: stock.symbol,
            currentPrice: newPrice,
            previousPrice: stock.currentPrice,
            description: stock.description
        )
    }
}
