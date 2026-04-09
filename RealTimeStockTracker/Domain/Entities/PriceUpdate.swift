//
//  PriceUpdate.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import Foundation

// MARK:  -  Price Update Entity  -

struct PriceUpdate: Codable {
    let symbol: String
    let price: Double
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case price
    }
}
