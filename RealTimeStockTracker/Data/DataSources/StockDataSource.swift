//
//  StockDataSource.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  Stock Data Source Protocol  -

protocol StockDataSourceProtocol {
    func getInitialStocks() async throws -> [Stock]
    func subscribeToPriceUpdates(onUpdate: @escaping (String, Double) -> Void) async
    func disconnectWebSocket()
    var isConnected: Bool { get }
}

// MARK:  -  Stock Data Source  -

class StockDataSource: StockDataSourceProtocol {
    private let webSocketManager: WebSocketManagerProtocol
    private var priceUpdateHandler: ((String, Double) -> Void)?
    private var updateTask: Task<Void, Never>?
    private(set) var isConnected = false
    
    init(webSocketManager: WebSocketManagerProtocol) {
        self.webSocketManager = webSocketManager
        setupWebSocketDelegate()
    }
    
    private func setupWebSocketDelegate() {
        webSocketManager.delegate = self
    }
    
    func getInitialStocks() async throws -> [Stock] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        return Stock.sampleStocks
    }
    
    func subscribeToPriceUpdates(onUpdate: @escaping (String, Double) -> Void) async {
        self.priceUpdateHandler = onUpdate
        webSocketManager.connect()
    }
    
    func disconnectWebSocket() {
        updateTask?.cancel()
        webSocketManager.disconnect()
        isConnected = false
    }
    
    private func generateRandomPriceUpdate() -> PriceUpdate {
        let symbols = Stock.sampleStocks.map { $0.symbol }
//        let randomSymbol = "AAPL"
        let randomSymbol = symbols.randomElement() ?? "AAPL"
        let randomPrice = Double.random(in: 50...500)
        
        return PriceUpdate(symbol: randomSymbol, price: randomPrice)
    }
    
    private func startSendingUpdates() {
        updateTask = Task {
            while !Task.isCancelled && isConnected {
                let update = generateRandomPriceUpdate()
                let jsonString = """
                {"symbol":"\(update.symbol)","price":\(update.price)}
                """
                webSocketManager.sendMessage(jsonString)
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }
}

// MARK:  -  WebSocket Delegate  -

extension StockDataSource: WebSocketDelegate {
    func webSocketDidConnect() {
        print("WebSocket connected")
        isConnected = true
        startSendingUpdates()
    }
    
    func webSocketDidDisconnect(error: Error?) {
        print("WebSocket disconnected: \(error?.localizedDescription ?? "no error")")
        isConnected = false
        updateTask?.cancel()
    }
    
    func webSocketDidReceiveMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let priceUpdate = try? JSONDecoder().decode(PriceUpdate.self, from: data) else {
            return
        }
        priceUpdateHandler?(priceUpdate.symbol, priceUpdate.price)
    }
}
