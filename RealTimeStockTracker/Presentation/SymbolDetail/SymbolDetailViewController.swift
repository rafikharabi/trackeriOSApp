//
//  SymbolDetailViewController.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 06/04/2026.
//

import UIKit

// MARK:  -  Symbol Detail View Controller  -

class SymbolDetailViewController: UIViewController {
    
    // MARK:  -  IBOutlets  -
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceIndicatorView: UIView!
    
    // MARK:  -  Properties  -
    
    var viewModel: SymbolDetailViewModel?
    
    // MARK:  -  Lifecycle  -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        updateUI()
    }
    
    // MARK:  -  Setup Methods  -
    
    private func setupUI() {
        title = "Stock Details"
        view.backgroundColor = .systemBackground
        
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.opaqueSeparator.cgColor
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = true
        descriptionTextView.dataDetectorTypes = .link
        
        priceIndicatorView.layer.cornerRadius = 6
        priceIndicatorView.clipsToBounds = true
        
    }
    
    private func setupBindings() {
        viewModel?.onStockUpdated = { [weak self] in
            self?.updateUI()
        }
        
        viewModel?.onError = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
        }
    }
    
    private func updateUI() {
        let stock = viewModel?.stock
        
        symbolLabel.text = stock?.symbol
        priceLabel.text = String(format: "$%.2f", stock?.currentPrice ?? 0.0)
        
        let changeValue = stock?.priceChange ?? 0.0
        let changePercentage = stock?.priceChangePercentage ?? 0.0
        let isPositive = changeValue > 0
        let sign = isPositive ? "+" : ""
        
        changeLabel.text = String(format: "%@$%.2f (%.2f%%)", sign, abs(changeValue), changePercentage)
        changeLabel.textColor = isPositive ? .systemGreen : .systemRed
        priceIndicatorView.backgroundColor = isPositive ? .systemGreen : .systemRed
        
        descriptionTextView.text = stock?.description
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
