//
//  SymbolsListViewModelTests.swift
//  RealTimeStockTrackerTests
//
//  Created by Usman Javed on 07/04/2026.
//

import XCTest
@testable import RealTimeStockTracker

// MARK:  -  Symbols List ViewModel Tests  -

final class SymbolsListViewModelTests: XCTestCase {
    
    var sut: SymbolsListViewModel!
    var mockRepository: MockStockRepository!
    var mockFetchUseCase: MockFetchStocksUseCase!
    var mockSortUseCase: MockSortStocksUseCase!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockStockRepository()
        mockFetchUseCase = MockFetchStocksUseCase(repository: mockRepository)
        mockSortUseCase = MockSortStocksUseCase()
        sut = SymbolsListViewModel(fetchStocksUseCase: mockFetchUseCase, sortStocksUseCase: mockSortUseCase)
        
        let loadExpectation = XCTestExpectation(description: "Stocks loaded")
        sut.onStocksUpdated = {
            loadExpectation.fulfill()
        }
        
        await sut.loadStocks()
        await fulfillment(of: [loadExpectation], timeout: 5.0)
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockFetchUseCase = nil
        mockSortUseCase = nil
        super.tearDown()
    }
    
    // MARK:  -  WebSocket Connection Tests  -
    
    func testConnectWebSocket() async {
        // Verify repository is ready
        XCTAssertTrue(sut.isRepositoryReady, "Repository should be ready after loadStocks")
        
        // Given
        let expectation = XCTestExpectation(description: "WebSocket connected")
        
        sut.onConnectionStatusChanged = { isConnected in
            if isConnected {
                expectation.fulfill()
            }
        }
        
        // When
        sut.connectWebSocket()
        
        // Then
        await fulfillment(of: [expectation], timeout: 3.0)
        
        XCTAssertTrue(mockRepository.subscribeToPriceUpdatesCalled, "subscribeToPriceUpdates should be called")
        XCTAssertTrue(sut.isWebSocketConnected, "isWebSocketConnected should be true")
    }
    
    func testConnectWebSocket_WithManualDelay() async {
        // Verify repository is ready
        XCTAssertTrue(sut.isRepositoryReady, "Repository should be ready after loadStocks")
        
        // Given
        let expectation = XCTestExpectation(description: "WebSocket connected")
        
        sut.onConnectionStatusChanged = { isConnected in
            if isConnected {
                expectation.fulfill()
            }
        }
        
        // When
        sut.connectWebSocket()
        
        // Add a small delay to allow connection to establish
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        await fulfillment(of: [expectation], timeout: 3.0)
        XCTAssertTrue(mockRepository.subscribeToPriceUpdatesCalled)
        XCTAssertTrue(sut.isWebSocketConnected)
    }
    
    func testDisconnectWebSocket() async {
        // First connect
        let connectExpectation = XCTestExpectation(description: "WebSocket connected")
        sut.onConnectionStatusChanged = { isConnected in
            if isConnected {
                connectExpectation.fulfill()
            }
        }
        
        sut.connectWebSocket()
        await fulfillment(of: [connectExpectation], timeout: 3.0)
        
        // Then disconnect
        let disconnectExpectation = XCTestExpectation(description: "WebSocket disconnected")
        sut.onConnectionStatusChanged = { isConnected in
            if !isConnected {
                disconnectExpectation.fulfill()
            }
        }
        
        // When
        sut.disconnectWebSocket()
        
        // Then
        await fulfillment(of: [disconnectExpectation], timeout: 3.0)
        XCTAssertTrue(mockRepository.disconnectWebSocketCalled, "disconnectWebSocket should be called")
        XCTAssertFalse(sut.isWebSocketConnected, "isWebSocketConnected should be false")
    }
    
    func testIsWebSocketConnected() async {
        // Initially should be false
        XCTAssertFalse(sut.isWebSocketConnected)
        
        // Connect
        let connectExpectation = XCTestExpectation(description: "WebSocket connected")
        sut.onConnectionStatusChanged = { isConnected in
            if isConnected {
                connectExpectation.fulfill()
            }
        }
        
        sut.connectWebSocket()
        await fulfillment(of: [connectExpectation], timeout: 3.0)
        XCTAssertTrue(sut.isWebSocketConnected)
        
        // Disconnect
        let disconnectExpectation = XCTestExpectation(description: "WebSocket disconnected")
        sut.onConnectionStatusChanged = { isConnected in
            if !isConnected {
                disconnectExpectation.fulfill()
            }
        }
        
        sut.disconnectWebSocket()
        await fulfillment(of: [disconnectExpectation], timeout: 3.0)
        XCTAssertFalse(sut.isWebSocketConnected)
    }
    
    // MARK:  -  Price Update Tests  -
    
    func testPriceUpdateViaWebSocket() async {
        // Given - Setup with specific stock
        let initialStock = Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: "Apple Inc.")
        mockRepository.mockStocks = [initialStock]
        
        // Reload stocks with new data
        let loadExpectation = XCTestExpectation(description: "Stocks reloaded")
        sut.onStocksUpdated = {
            loadExpectation.fulfill()
        }
        await sut.loadStocks()
        await fulfillment(of: [loadExpectation], timeout: 2.0)
        
        // Connect WebSocket
        let connectExpectation = XCTestExpectation(description: "WebSocket connected")
        sut.onConnectionStatusChanged = { isConnected in
            if isConnected {
                connectExpectation.fulfill()
            }
        }
        
        sut.connectWebSocket()
        await fulfillment(of: [connectExpectation], timeout: 3.0)
        
        // Set up price update expectation
        let priceUpdateExpectation = XCTestExpectation(description: "Price updated")
        sut.onStocksUpdated = {
            priceUpdateExpectation.fulfill()
        }
        
        // When
        mockRepository.triggerPriceUpdate(symbol: "AAPL", price: 160)
        
        // Then
        await fulfillment(of: [priceUpdateExpectation], timeout: 3.0)
        
        let updatedStock = sut.stock(at: 0)
        XCTAssertEqual(updatedStock.currentPrice, 160, "Price should be updated to 160")
        XCTAssertEqual(updatedStock.previousPrice, 150, "Previous price should be 150")
    }
    
    func testMultiplePriceUpdates() async {
        // Given
        let initialStock = Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: "Apple Inc.")
        mockRepository.mockStocks = [initialStock]
        
        // Reload stocks
        let loadExpectation = XCTestExpectation(description: "Stocks reloaded")
        sut.onStocksUpdated = {
            loadExpectation.fulfill()
        }
        await sut.loadStocks()
        await fulfillment(of: [loadExpectation], timeout: 2.0)
        
        // Connect WebSocket
        let connectExpectation = XCTestExpectation(description: "WebSocket connected")
        sut.onConnectionStatusChanged = { isConnected in
            if isConnected {
                connectExpectation.fulfill()
            }
        }
        
        sut.connectWebSocket()
        await fulfillment(of: [connectExpectation], timeout: 3.0)
        
        // Set up expectation for multiple updates
        let expectation = XCTestExpectation(description: "Multiple price updates")
        expectation.expectedFulfillmentCount = 2
        
        var updateCount = 0
        sut.onStocksUpdated = {
            updateCount += 1
            expectation.fulfill()
        }
        
        // When
        mockRepository.triggerPriceUpdate(symbol: "AAPL", price: 160)
        mockRepository.triggerPriceUpdate(symbol: "AAPL", price: 170)
        
        // Then
        await fulfillment(of: [expectation], timeout: 3.0)
        
        let updatedStock = sut.stock(at: 0)
        XCTAssertEqual(updateCount, 2, "Should receive 2 updates")
        XCTAssertEqual(updatedStock.currentPrice, 170, "Final price should be 170")
        XCTAssertEqual(updatedStock.previousPrice, 160, "Previous price should be 160")
    }
    
    func testPriceUpdateForDifferentSymbol() async {
        // Given
        let stocks = [
            Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: "Apple Inc."),
            Stock(symbol: "GOOG", currentPrice: 200, previousPrice: 195, description: "Google Inc.")
        ]
        mockRepository.mockStocks = stocks
        
        // Reload stocks
        let loadExpectation = XCTestExpectation(description: "Stocks reloaded")
        sut.onStocksUpdated = {
            loadExpectation.fulfill()
        }
        await sut.loadStocks()
        await fulfillment(of: [loadExpectation], timeout: 2.0)
        
        // Connect WebSocket
        let connectExpectation = XCTestExpectation(description: "WebSocket connected")
        sut.onConnectionStatusChanged = { isConnected in
            if isConnected {
                connectExpectation.fulfill()
            }
        }
        
        sut.connectWebSocket()
        await fulfillment(of: [connectExpectation], timeout: 3.0)
        
        // Set up expectation
        let expectation = XCTestExpectation(description: "Price update received")
        sut.onStocksUpdated = {
            expectation.fulfill()
        }
        
        // When
        mockRepository.triggerPriceUpdate(symbol: "GOOG", price: 210)
        
        // Then
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // Find and verify GOOG stock
        var googStock: Stock?
        for i in 0..<sut.numberOfStocks {
            let stock = sut.stock(at: i)
            if stock.symbol == "GOOG" {
                googStock = stock
                break
            }
        }
        
        XCTAssertNotNil(googStock, "GOOG stock should exist")
        XCTAssertEqual(googStock?.currentPrice, 210, "GOOG price should be 210")
        XCTAssertEqual(googStock?.previousPrice, 200, "GOOG previous price should be 200")
    }
    
    func testSortPreservesAfterPriceUpdate() async {
        // Given
        let stocks = [
            Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: ""),
            Stock(symbol: "GOOG", currentPrice: 200, previousPrice: 195, description: ""),
            Stock(symbol: "TSLA", currentPrice: 100, previousPrice: 95, description: "")
        ]
        mockRepository.mockStocks = stocks
        
        // Reload stocks
        let loadExpectation = XCTestExpectation(description: "Stocks reloaded")
        sut.onStocksUpdated = {
            loadExpectation.fulfill()
        }
        await sut.loadStocks()
        await fulfillment(of: [loadExpectation], timeout: 2.0)
        
        // Sort by price (highest first)
        sut.sortStocks(by: .byPrice)
        
        // Verify initial sort order
        XCTAssertEqual(sut.stock(at: 0).symbol, "GOOG") // 200
        XCTAssertEqual(sut.stock(at: 1).symbol, "AAPL") // 150
        XCTAssertEqual(sut.stock(at: 2).symbol, "TSLA") // 100
        
        // Connect WebSocket
        let connectExpectation = XCTestExpectation(description: "WebSocket connected")
        sut.onConnectionStatusChanged = { isConnected in
            if isConnected {
                connectExpectation.fulfill()
            }
        }
        
        sut.connectWebSocket()
        await fulfillment(of: [connectExpectation], timeout: 3.0)
        
        let expectation = XCTestExpectation(description: "Price update received")
        sut.onStocksUpdated = {
            expectation.fulfill()
        }
        
        // When - Update TSLA price to become highest
        mockRepository.triggerPriceUpdate(symbol: "TSLA", price: 250)
        
        // Then
        await fulfillment(of: [expectation], timeout: 3.0)
        
        let firstStock = sut.stock(at: 0)
        XCTAssertEqual(firstStock.symbol, "TSLA", "TSLA should be first after price update")
        XCTAssertEqual(firstStock.currentPrice, 250, "TSLA price should be 250")
    }
    
    // MARK:  -  Load Stocks Tests  -
    
    func testLoadStocks_Success() async {
        // Given
        let freshMockRepository = MockStockRepository()
        let freshFetchUseCase = MockFetchStocksUseCase(repository: freshMockRepository)
        let freshSut = SymbolsListViewModel(fetchStocksUseCase: freshFetchUseCase, sortStocksUseCase: mockSortUseCase)
        
        let expectation = XCTestExpectation(description: "Stocks loaded")
        let expectedStocks = [
            Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: "Apple Inc.")
        ]
        freshMockRepository.mockStocks = expectedStocks
        
        freshSut.onStocksUpdated = {
            expectation.fulfill()
        }
        
        // When
        await freshSut.loadStocks()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(freshSut.numberOfStocks, 1)
        XCTAssertEqual(freshSut.stock(at: 0).symbol, "AAPL")
    }
    
    func testLoadStocks_Failure() async {
        // Given
        let freshMockRepository = MockStockRepository()
        let freshFetchUseCase = MockFetchStocksUseCase(repository: freshMockRepository)
        let freshSut = SymbolsListViewModel(fetchStocksUseCase: freshFetchUseCase, sortStocksUseCase: mockSortUseCase)
        
        let expectation = XCTestExpectation(description: "Error handled")
        freshMockRepository.shouldThrowError = true
        
        freshSut.onError = { errorMessage in
            XCTAssertFalse(errorMessage.isEmpty)
            expectation.fulfill()
        }
        
        // When
        await freshSut.loadStocks()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(freshSut.numberOfStocks, 0)
    }
    
    // MARK:  -  Sort Tests  -
    
    func testSortStocks_ByPrice() {
        // Given
        let stocks = [
            Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: ""),
            Stock(symbol: "GOOG", currentPrice: 200, previousPrice: 195, description: ""),
            Stock(symbol: "TSLA", currentPrice: 100, previousPrice: 95, description: "")
        ]
        mockRepository.mockStocks = stocks
        
        // When
        sut.sortStocks(by: .byPrice)
        
        // Then
        XCTAssertTrue(mockSortUseCase.didCallExecute)
        XCTAssertEqual(mockSortUseCase.lastSortType, .byPrice)
    }
    
    func testSortStocks_BySymbol() {
        // Given
        let stocks = [
            Stock(symbol: "TSLA", currentPrice: 100, previousPrice: 95, description: ""),
            Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: ""),
            Stock(symbol: "GOOG", currentPrice: 200, previousPrice: 195, description: "")
        ]
        mockRepository.mockStocks = stocks
        
        // When
        sut.sortStocks(by: .bySymbol)
        
        // Then
        XCTAssertTrue(mockSortUseCase.didCallExecute)
        XCTAssertEqual(mockSortUseCase.lastSortType, .bySymbol)
    }
    
    func testSortStocks_ByPriceChange() {
        // Given
        let stocks = [
            Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: ""),
            Stock(symbol: "GOOG", currentPrice: 200, previousPrice: 195, description: ""),
            Stock(symbol: "TSLA", currentPrice: 100, previousPrice: 95, description: "")
        ]
        mockRepository.mockStocks = stocks
        
        // When
        sut.sortStocks(by: .byPriceChange)
        
        // Then
        XCTAssertTrue(mockSortUseCase.didCallExecute)
        XCTAssertEqual(mockSortUseCase.lastSortType, .byPriceChange)
    }
    
    func testStockAtIndex() async {
        // Given
        let expectedStocks = [
            Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: "Apple Inc."),
            Stock(symbol: "GOOG", currentPrice: 200, previousPrice: 195, description: "Google Inc.")
        ]
        mockRepository.mockStocks = expectedStocks
        
        let loadExpectation = XCTestExpectation(description: "Stocks loaded")
        sut.onStocksUpdated = {
            loadExpectation.fulfill()
        }
        await sut.loadStocks()
        await fulfillment(of: [loadExpectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(sut.stock(at: 0).symbol, "AAPL")
        XCTAssertEqual(sut.stock(at: 1).symbol, "GOOG")
    }
    
    func testNumberOfStocks() async {
        // Given
        let expectedStocks = [
            Stock(symbol: "AAPL", currentPrice: 150, previousPrice: 145, description: ""),
            Stock(symbol: "GOOG", currentPrice: 200, previousPrice: 195, description: ""),
            Stock(symbol: "TSLA", currentPrice: 100, previousPrice: 95, description: "")
        ]
        mockRepository.mockStocks = expectedStocks
        
        let loadExpectation = XCTestExpectation(description: "Stocks loaded")
        sut.onStocksUpdated = {
            loadExpectation.fulfill()
        }
        await sut.loadStocks()
        await fulfillment(of: [loadExpectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(sut.numberOfStocks, 3)
    }
}
