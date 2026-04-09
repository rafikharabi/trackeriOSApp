//
//  Stock.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  Stock Entity  -

struct Stock: Equatable, Sendable {
    let symbol: String
    var currentPrice: Double
    var previousPrice: Double
    let description: String
    
    var priceChange: Double {
        return currentPrice - previousPrice
    }
    
    var priceChangePercentage: Double {
        guard previousPrice > 0 else { return 0 }
        return (priceChange / previousPrice) * 100
    }
    
    var isPriceIncreased: Bool {
        return currentPrice > previousPrice
    }
    
    init(symbol: String, currentPrice: Double, previousPrice: Double, description: String) {
        self.symbol = symbol
        self.currentPrice = currentPrice
        self.previousPrice = previousPrice
        self.description = description
    }
    
    // MARK:  -  Equatable  -
    
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        return lhs.symbol == rhs.symbol &&
               lhs.currentPrice == rhs.currentPrice &&
               lhs.previousPrice == rhs.previousPrice &&
               lhs.description == rhs.description
    }
}

// MARK:  -  Sample Data Extension  -

extension Stock {
    static let sampleStocks: [Stock] = [
        Stock(symbol: "AAPL", currentPrice: 175.50, previousPrice: 173.20, description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide."),
        Stock(symbol: "GOOGL", currentPrice: 138.75, previousPrice: 140.10, description: "Alphabet Inc. provides online advertising services in the United States, Europe, the Middle East, Africa, the Asia-Pacific, Canada, and Latin America."),
        Stock(symbol: "TSLA", currentPrice: 245.30, previousPrice: 240.50, description: "Tesla, Inc. designs, develops, manufactures, leases, and sells electric vehicles, and energy generation and storage systems."),
        Stock(symbol: "AMZN", currentPrice: 145.80, previousPrice: 147.90, description: "Amazon.com, Inc. engages in the retail sale of consumer products and subscriptions worldwide."),
        Stock(symbol: "MSFT", currentPrice: 380.25, previousPrice: 378.40, description: "Microsoft Corporation develops and supports software, services, devices, and solutions worldwide."),
        Stock(symbol: "NVDA", currentPrice: 485.50, previousPrice: 475.20, description: "NVIDIA Corporation provides graphics and compute and networking solutions worldwide."),
        Stock(symbol: "META", currentPrice: 315.60, previousPrice: 318.90, description: "Meta Platforms, Inc. develops products that enable people to connect and share with friends and family."),
        Stock(symbol: "NFLX", currentPrice: 455.20, previousPrice: 460.50, description: "Netflix, Inc. provides entertainment services."),
        Stock(symbol: "AMD", currentPrice: 125.40, previousPrice: 122.80, description: "Advanced Micro Devices, Inc. operates as a semiconductor company worldwide."),
        Stock(symbol: "INTC", currentPrice: 45.30, previousPrice: 46.20, description: "Intel Corporation designs, manufactures, and sells computer products and technologies."),
        Stock(symbol: "IBM", currentPrice: 155.70, previousPrice: 154.50, description: "International Business Machines Corporation provides integrated solutions and services worldwide."),
        Stock(symbol: "ORCL", currentPrice: 112.40, previousPrice: 111.20, description: "Oracle Corporation offers products and services that address enterprise information technology environments."),
        Stock(symbol: "CSCO", currentPrice: 52.30, previousPrice: 53.10, description: "Cisco Systems, Inc. designs and sells Internet Protocol based networking products."),
        Stock(symbol: "ADBE", currentPrice: 590.40, previousPrice: 585.30, description: "Adobe Inc. operates as a diversified software company worldwide."),
        Stock(symbol: "CRM", currentPrice: 220.50, previousPrice: 218.90, description: "Salesforce, Inc. provides customer relationship management technology."),
        Stock(symbol: "PYPL", currentPrice: 65.80, previousPrice: 67.20, description: "PayPal Holdings, Inc. operates a technology platform that enables digital payments."),
        Stock(symbol: "DIS", currentPrice: 92.30, previousPrice: 94.10, description: "The Walt Disney Company operates as an entertainment company worldwide."),
        Stock(symbol: "PEP", currentPrice: 168.50, previousPrice: 167.80, description: "PepsiCo, Inc. manufactures and sells beverages and convenient foods."),
        Stock(symbol: "KO", currentPrice: 58.90, previousPrice: 59.50, description: "The Coca-Cola Company manufactures and distributes nonalcoholic beverages."),
        Stock(symbol: "WMT", currentPrice: 158.40, previousPrice: 157.20, description: "Walmart Inc. engages in the operation of retail and wholesale stores."),
        Stock(symbol: "JPM", currentPrice: 155.60, previousPrice: 157.10, description: "JPMorgan Chase & Co. operates as a financial services company."),
        Stock(symbol: "V", currentPrice: 245.30, previousPrice: 244.20, description: "Visa Inc. operates a payments technology company."),
        Stock(symbol: "JNJ", currentPrice: 155.80, previousPrice: 156.90, description: "Johnson & Johnson researches and develops health care products."),
        Stock(symbol: "PG", currentPrice: 155.40, previousPrice: 154.80, description: "The Procter & Gamble Company manufactures consumer goods."),
        Stock(symbol: "HD", currentPrice: 330.20, previousPrice: 328.50, description: "The Home Depot, Inc. operates as a home improvement retailer.")
    ]
}
