//
//  SymbolsListViewController.swift
//  RealTimeStockTracker
//
//  Created by Usman Javed on 04/04/2026.
//

import UIKit

// MARK:  -  Symbols List View Controller  -

class SymbolsListViewController: UIViewController {
    
    // MARK:  -  IBOutlets  -
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    // MARK:  -  Properties  -
    
    private let repository = StockRepository(
        dataSource: StockDataSource(
            webSocketManager: WebSocketManager(url: URL(string: "wss://ws.postman-echo.com/raw")!)
        ),
        updateUseCase: UpdateStockPriceUseCase()
    )
    
    private lazy var viewModel: SymbolsListViewModel = {
        let fetchUseCase = FetchStocksUseCase(repository: repository)
        let sortUseCase = SortStocksUseCase()
        return SymbolsListViewModel(fetchStocksUseCase: fetchUseCase, sortStocksUseCase: sortUseCase)
    }()
    
    // MARK:  -  Lifecycle  -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupTableView()
        loadStocks()
    }
    
    // MARK:  -  Setup Methods  -
    
    private func setupUI() {
        title = "Stock Tracker"
        connectionStatusLabel.text = "Status: Disconnected"
        connectionStatusLabel.textColor = .systemRed
        connectionButton.setTitle("Start", for: .normal)
        connectionButton.backgroundColor = .systemGreen
        connectionButton.layer.cornerRadius = 8
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "StockCell", bundle: nil), forCellReuseIdentifier: "StockCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupBindings() {
        viewModel.onStocksUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onConnectionStatusChanged = { [weak self] isConnected in
            self?.updateConnectionUI(isConnected: isConnected)
        }
        
        viewModel.onError = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
        }
    }
    
    private func loadStocks() {
        Task {
            await viewModel.loadStocks()
        }
    }
    
    private func updateConnectionUI(isConnected: Bool) {
        connectionStatusLabel.text = "Status: \(isConnected ? "Connected" : "Disconnected")"
        connectionStatusLabel.textColor = isConnected ? .systemGreen : .systemRed
        connectionButton.setTitle(isConnected ? "Stop" : "Start", for: .normal)
        connectionButton.backgroundColor = isConnected ? .systemRed : .systemGreen
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK:  -  IBActions  -
    
    @IBAction func connectionButtonTapped(_ sender: UIButton) {
        if viewModel.isWebSocketConnected {
            viewModel.disconnectWebSocket()
        } else {
            viewModel.connectWebSocket()
        }
    }
    
    @IBAction func sortChanged(_ sender: UISegmentedControl) {
        let sortType: SortType
        switch sender.selectedSegmentIndex {
        case 0:
            sortType = .bySymbol
        case 1:
            sortType = .byPrice
        case 2:
            sortType = .byPriceChange
        default:
            sortType = .bySymbol
        }
        viewModel.sortStocks(by: sortType)
    }
}

// MARK:  -  UITableViewDataSource  -

extension SymbolsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfStocks
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockCell
        let stock = viewModel.stock(at: indexPath.row)
        cell.configure(with: stock)
        return cell
    }
}

// MARK:  -  UITableViewDelegate  -

extension SymbolsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let stock = viewModel.stock(at: indexPath.row)
        
        let symbolDetailStoryboard = UIStoryboard(name: "SymbolDetail", bundle: nil)
        let symbolDetailViewController = symbolDetailStoryboard.instantiateViewController(identifier: "SymbolDetailViewController") as! SymbolDetailViewController
        let detailVM = SymbolDetailViewModel(stock: stock, repository: repository)
        symbolDetailViewController.viewModel = detailVM
        navigationController?.pushViewController(symbolDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
