//
//  StockRepositoryProtocol.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  Stock Repository Protocol  -

protocol StockRepositoryProtocol {
    func fetchStocks() async throws -> [Stock]
    func updateStockPrice(symbol: String, newPrice: Double) async throws -> Stock?
    func subscribeToPriceUpdates(onUpdate: @escaping (String, Double) -> Void) async
    func disconnectWebSocket()
    var isConnected: Bool { get }
}
