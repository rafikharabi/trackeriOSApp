//
//  StockEntityTests.swift
//  RealTimeStockTrackerTests
//
//  Created by Usman Javed on 07/04/2026.
//

@preconcurrency import XCTest
@testable @preconcurrency import RealTimeStockTracker

// MARK:  -  Stock Entity Tests  -

final class StockEntityTests: XCTestCase {
    
    func testStockPriceChange_Increase() {
        // Given
        let stock = Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 140, description: "")
        
        // Then
        XCTAssertEqual(stock.priceChange, 10)
        XCTAssertTrue(stock.isPriceIncreased)
        XCTAssertEqual(stock.priceChangePercentage, (10.0/140.0) * 100, accuracy: 0.01)
    }
    
    func testStockPriceChange_Decrease() {
        // Given
        let stock = Stock(symbol: "AAPL", currentPrice: 130, previousPrice: 140, description: "")
        
        // Then
        XCTAssertEqual(stock.priceChange, -10)
        XCTAssertFalse(stock.isPriceIncreased)
        XCTAssertEqual(stock.priceChangePercentage, (-10.0/140.0) * 100, accuracy: 0.01)
    }
    
    func testStockPriceChange_Zero() {
        // Given
        let stock = Stock(symbol: "AAPL", currentPrice: 140, previousPrice: 140, description: "")
        
        // Then
        XCTAssertEqual(stock.priceChange, 0)
        XCTAssertFalse(stock.isPriceIncreased)
        XCTAssertEqual(stock.priceChangePercentage, 0)
    }
    
    func testStockEquality() {
        // Given
        let stock1 = Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 140, description: "Apple")
        let stock2 = Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 140, description: "Apple")
        let stock3 = Stock(symbol: "GOOG", currentPrice: 150, previousPrice: 140, description: "Google")
        
        // Then
        XCTAssertEqual(stock1, stock2)
        XCTAssertNotEqual(stock1, stock3)
    }
}
