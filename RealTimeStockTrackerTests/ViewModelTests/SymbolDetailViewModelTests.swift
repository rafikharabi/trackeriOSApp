//
//  SymbolDetailViewModelTests.swift
//  RealTimeStockTrackerTests
//
//  Created by Usman Javed on 07/04/2026.
//

import XCTest
@testable import RealTimeStockTracker

// MARK:  -  Symbol Detail ViewModel Tests  -

final class SymbolDetailViewModelTests: XCTestCase {
    
    var sut: SymbolDetailViewModel!
    var mockRepository: MockStockRepository!
    var testStock: Stock!
    
    override func setUp() {
        super.setUp()
        print("\n🏗️ Setting up SymbolDetailViewModelTests")
        mockRepository = MockStockRepository()
        testStock = Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: "Apple Inc.")
        sut = SymbolDetailViewModel(stock: testStock, repository: mockRepository)
        
        // Give time for async subscription to complete
        let expectation = XCTestExpectation(description: "Subscription setup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        testStock = nil
        super.tearDown()
    }
    
    func testSetupPriceUpdateSubscription() {
        // Then
        XCTAssertTrue(mockRepository.subscribeToPriceUpdatesCalled, "subscribeToPriceUpdates should be called during ViewModel initialization")
    }
    
    func testInitialStockValue() {
        // Then
        XCTAssertEqual(sut.stock.symbol, "AAPL")
        XCTAssertEqual(sut.stock.currentPrice, 150)
        XCTAssertEqual(sut.stock.previousPrice, 145)
    }
    
    func testPriceUpdateForMatchingSymbol() {
        // Given
        let expectation = XCTestExpectation(description: "Price update received")
        sut.onStockUpdated = {
            expectation.fulfill()
        }
        
        // When
        mockRepository.triggerPriceUpdate(symbol: "AAPL", price: 175.50)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(sut.stock.currentPrice, 175.50)
        XCTAssertEqual(sut.stock.previousPrice, 150)
    }
    
    func testPriceUpdateForNonMatchingSymbol() {
        // Given
        let expectation = XCTestExpectation(description: "No price update")
        expectation.isInverted = true
        
        sut.onStockUpdated = {
            expectation.fulfill()
        }
        
        // When
        mockRepository.triggerPriceUpdate(symbol: "GOOG", price: 175.50)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.stock.currentPrice, 150)
    }
    
    func testMultiplePriceUpdates() {
        // Given
        let expectation = XCTestExpectation(description: "Multiple price updates")
        expectation.expectedFulfillmentCount = 2
        
        var prices: [Double] = []
        sut.onStockUpdated = {
            prices.append(self.sut.stock.currentPrice)
            expectation.fulfill()
        }
        
        // When
        mockRepository.triggerPriceUpdate(symbol: "AAPL", price: 160)
        mockRepository.triggerPriceUpdate(symbol: "AAPL", price: 175.50)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(prices, [160, 175.50])
        XCTAssertEqual(sut.stock.currentPrice, 175.50)
    }
    
    func testUpdateStockManually() {
        // Given
        let expectation = XCTestExpectation(description: "Manual stock update")
        let newStock = Stock(symbol: "AAPL", currentPrice: 200, previousPrice: 150, description: "Updated")
        
        sut.onStockUpdated = {
            expectation.fulfill()
        }
        
        // When
        sut.updateStock(newStock)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.stock.currentPrice, 200)
    }
    
    func testPriceChangeCalculation() {
        // Given
        let stock = sut.stock
        
        // Then
        let expectedChange = 5.0
        let expectedPercentage = (5.0 / 145.0) * 100
        
        XCTAssertEqual(stock.priceChange, expectedChange, accuracy: 0.001)
        XCTAssertEqual(stock.priceChangePercentage, expectedPercentage, accuracy: 0.01)
        XCTAssertTrue(stock.isPriceIncreased)
    }
}

