//
//  FetchStocksUseCase.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  Fetch Stocks Use Case Protocol  -

protocol FetchStocksUseCaseProtocol {
    var repository: StockRepositoryProtocol { get }
    func execute() async throws -> [Stock]
}

// MARK:  -  Fetch Stocks Use Case  -

class FetchStocksUseCase: FetchStocksUseCaseProtocol {
    let repository: StockRepositoryProtocol
    
    init(repository: StockRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Stock] {
        return try await repository.fetchStocks()
    }
}
