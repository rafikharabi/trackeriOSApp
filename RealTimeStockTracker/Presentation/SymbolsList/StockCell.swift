//
//  StockCell.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 04/04/2026.
//

import UIKit

// MARK:  -  Stock Cell  -

class StockCell: UITableViewCell {
    
    // MARK:  -  IBOutlets  -
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var changeIndicatorView: UIView!
    
    // MARK:  -  Lifecycle  -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK:  -  Setup  -
    
    private func setupUI() {
        changeIndicatorView.layer.cornerRadius = 4
        changeIndicatorView.layer.masksToBounds = true
    }
    
    // MARK:  -  Configuration  -
    
    func configure(with stock: Stock) {
        symbolLabel.text = stock.symbol
        priceLabel.text = String(format: "$%.2f", stock.currentPrice)
        
        let changeValue = stock.priceChange
        let changePercentage = stock.priceChangePercentage
        let isPositive = changeValue > 0
        let sign = isPositive ? "+" : ""
        
        changeLabel.text = String(format: "%@$%.2f (%.2f%%)", sign, abs(changeValue), changePercentage)
        changeLabel.textColor = isPositive ? .systemGreen : .systemRed
        changeIndicatorView.backgroundColor = isPositive ? .systemGreen : .systemRed
    }
}
