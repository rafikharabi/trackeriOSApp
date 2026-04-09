//
//  UpdateStockPriceUseCaseTests.swift
//  RealTimeStockTrackerTests
//
//  Created by Usman Javed on 07/04/2026.
//

import XCTest
@testable import RealTimeStockTracker

// MARK:  -  Update Stock Price UseCase Tests  -

final class UpdateStockPriceUseCaseTests: XCTestCase {
    
    var sut: UpdateStockPriceUseCase!
    var testStock: Stock!
    
    override func setUp() {
        super.setUp()
        sut = UpdateStockPriceUseCase()
        testStock = Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: "Apple Inc.")
    }
    
    override func tearDown() {
        sut = nil
        testStock = nil
        super.tearDown()
    }
    
    func testUpdateStockPrice_Increase() {
        // When
        let updatedStock = sut.execute(stock: testStock, newPrice: 175)
        
        // Then
        XCTAssertEqual(updatedStock.currentPrice, 175)
        XCTAssertEqual(updatedStock.previousPrice, 150)
        XCTAssertEqual(updatedStock.priceChange, 25)
        XCTAssertTrue(updatedStock.isPriceIncreased)
    }
    
    func testUpdateStockPrice_Decrease() {
        // When
        let updatedStock = sut.execute(stock: testStock, newPrice: 125)
        
        // Then
        XCTAssertEqual(updatedStock.currentPrice, 125)
        XCTAssertEqual(updatedStock.previousPrice, 150)
        XCTAssertEqual(updatedStock.priceChange, -25)
        XCTAssertFalse(updatedStock.isPriceIncreased)
    }
    
    func testUpdateStockPrice_NoChange() {
        // When
        let updatedStock = sut.execute(stock: testStock, newPrice: 150)
        
        // Then
        XCTAssertEqual(updatedStock.currentPrice, 150)
        XCTAssertEqual(updatedStock.previousPrice, 150)
        XCTAssertEqual(updatedStock.priceChange, 0)
        XCTAssertFalse(updatedStock.isPriceIncreased)
    }
    
    func testPriceChangePercentage() {
        // When
        let updatedStock = sut.execute(stock: testStock, newPrice: 165)
        
        // Then
        let expectedPercentage = (15.0 / 150.0) * 100
        XCTAssertEqual(updatedStock.priceChangePercentage, expectedPercentage, accuracy: 0.01)
    }
}

