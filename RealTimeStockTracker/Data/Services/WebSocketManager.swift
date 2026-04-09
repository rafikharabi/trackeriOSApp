//
//  WebSocketManager.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 04/04/2026.
//

import Foundation

// MARK:  -  WebSocket Delegate  -

protocol WebSocketDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidDisconnect(error: Error?)
    func webSocketDidReceiveMessage(_ message: String)
}

// MARK:  -  WebSocket Manager  -

class WebSocketManager: NSObject, WebSocketManagerProtocol {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL
    private var isConnected = false
    
    weak var delegate: WebSocketDelegate?
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    func connect() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
        delegate?.webSocketDidDisconnect(error: nil)
    }
    
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                print("WebSocket send error: \(error)")
                self?.delegate?.webSocketDidDisconnect(error: error)
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.delegate?.webSocketDidReceiveMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.delegate?.webSocketDidReceiveMessage(text)
                    }
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.delegate?.webSocketDidDisconnect(error: error)
            }
        }
    }
    
    var connectionStatus: WebSocketConnectionStatus {
        return isConnected ? .connected : .disconnected
    }
}

// MARK:  -  URLSessionWebSocketDelegate  -

extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        delegate?.webSocketDidConnect()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        delegate?.webSocketDidDisconnect(error: nil)
    }
}
