//
//  MockFetchStocksUseCase.swift
//  RealTimeStockTrackerTests
//
//  Created by Usman Javed on 07/04/2026.
//

import Foundation
@testable import RealTimeStockTracker

// MARK:  -  Mock Fetch Stocks Use Case  -

class MockFetchStocksUseCase: FetchStocksUseCaseProtocol {
    let repository: StockRepositoryProtocol
    var didCallExecute = false
    var mockStocks: [Stock] = []
    var shouldThrowError = false
    
    init(repository: StockRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Stock] {
        didCallExecute = true
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        return try await repository.fetchStocks()
    }
}
