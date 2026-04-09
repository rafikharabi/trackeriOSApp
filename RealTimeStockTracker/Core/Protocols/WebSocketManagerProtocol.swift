//
//  WebSocketManagerProtocol.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  WebSocket Connection Status  -

enum WebSocketConnectionStatus {
    case connected
    case disconnected
}

// MARK:  -  WebSocket Manager Protocol  -

protocol WebSocketManagerProtocol: AnyObject {
    var delegate: WebSocketDelegate? { get set }
    var connectionStatus: WebSocketConnectionStatus { get }
    func connect()
    func disconnect()
    func sendMessage(_ message: String)
}
