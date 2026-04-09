//
//  SortStocksUseCaseTests.swift
//  RealTimeStockTrackerTests
//
//  Created by Usman Javed on 07/04/2026.
//

import XCTest
@testable import RealTimeStockTracker

// MARK:  -  Sort Stocks UseCase Tests  -

final class SortStocksUseCaseTests: XCTestCase {
    
    var sut: SortStocksUseCase!
    var testStocks: [Stock]!
    
    override func setUp() {
        super.setUp()
        sut = SortStocksUseCase()
        testStocks = [
            Stock(symbol: "TSLA", currentPrice: 100, previousPrice: 95, description: ""),
            Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: ""),
            Stock(symbol: "GOOG", currentPrice: 200, previousPrice: 195, description: "")
        ]
    }
    
    override func tearDown() {
        sut = nil
        testStocks = nil
        super.tearDown()
    }
    
    func testSortBySymbol() {
        // When
        let sorted = sut.execute(stocks: testStocks, sortType: .bySymbol)
        
        // Then
        XCTAssertEqual(sorted[0].symbol, "AAPL")
        XCTAssertEqual(sorted[1].symbol, "GOOG")
        XCTAssertEqual(sorted[2].symbol, "TSLA")
    }
    
    func testSortByPrice() {
        // When
        let sorted = sut.execute(stocks: testStocks, sortType: .byPrice)
        
        // Then
        XCTAssertEqual(sorted[0].symbol, "GOOG") // Highest price
        XCTAssertEqual(sorted[1].symbol, "AAPL")
        XCTAssertEqual(sorted[2].symbol, "TSLA") // Lowest price
    }
    
    func testSortByPriceChange() {
        // Given
        var stocksWithChanges = [
            Stock(symbol: "AAPL", currentPrice: 160, previousPrice: 150, description: ""), // +10
            Stock(symbol: "GOOG", currentPrice: 210, previousPrice: 200, description: ""), // +10
            Stock(symbol: "TSLA", currentPrice: 110, previousPrice: 100, description: "")  // +10
        ]
        
        // When
        let sorted = sut.execute(stocks: stocksWithChanges, sortType: .byPriceChange)
        
        // Then
        XCTAssertEqual(sorted.count, 3)
    }
    
    func testSortWithEmptyArray() {
        // When
        let sorted = sut.execute(stocks: [], sortType: .bySymbol)
        
        // Then
        XCTAssertTrue(sorted.isEmpty)
    }
    
    func testSortWithSingleStock() {
        // Given
        let singleStock = [Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: "")]
        
        // When
        let sorted = sut.execute(stocks: singleStock, sortType: .byPrice)
        
        // Then
        XCTAssertEqual(sorted.count, 1)
        XCTAssertEqual(sorted[0].symbol, "AAPL")
    }
}

