//
//  OrdersTableViewController.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import UIKit
import NVActivityIndicatorView

class OrdersViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var loaderLabel: UILabel!
    @IBOutlet private weak var loaderIndicatorView: NVActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private
    
    private let orderCell = "OrderCell"
    
    private var orders: [Order] = []
    private var selectedIndex: Int?
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            // initial setup
            self.configureView()
            DispatchQueue.global(qos: .userInitiated).async {
                self.fetchData {
                    DispatchQueue.main.async {
                        self.setupContent()
                    }
                }
            }
        }
    }

    // MARK: - UI
    
    private func configureView() {
        // navigation bar
        title = NSLocalizedString("orders.title", comment: "")
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
        navigationItem.rightBarButtonItem = addButton
        // table view
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        let aNib = UINib(nibName: "OrderTableViewCell", bundle: Bundle(for: type(of: self)))
        tableView.register(aNib, forCellReuseIdentifier: orderCell)
        // pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        // show loader
        loaderLabel.text = NSLocalizedString("orders.loading", comment: "")
        loaderIndicatorView.type = .ballClipRotatePulse
        loaderIndicatorView.color = UIColor(named: "Secondary") ?? .black
        loaderIndicatorView.startAnimating()
    }
    
    private func setupContent() {
        // show navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
        // hide loader
        hideLoader()
        // reload data
        tableView.reloadData()
    }
    
    private func hideLoader() {
        loaderIndicatorView.stopAnimating()
        loaderView.isHidden = true
        tableView.isHidden = false
    }
    
    // MARK: - Data
    
    private func fetchData(completion: @escaping () -> Void) {
        let backgroundContext = CoreDataManager.shared.storeContainer.newBackgroundContext()
        ButterflyWSManager.shared.synchroniseOrders(in: backgroundContext) {
            self.orders = Order.all(in: CoreDataManager.shared.managedContext)
            completion()
        }
    }
    
    @objc
    private func refreshData(_ sender: AnyObject) {
        // synchronize data if needed
        fetchData {
            DispatchQueue.main.async {
                // reload data
                self.tableView.reloadData()
                // end refresh animation
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func refreshOrdersFromDatabase(completion: @escaping () -> Void) {
        // fetch in the background
        DispatchQueue.global(qos: .userInitiated).async {
            self.orders = Order.all(in: CoreDataManager.shared.managedContext)
            // call the handler in the main thread
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func refreshOrderFromDatabase(at index: Int, completion: @escaping () -> Void) {
        // fetch in the background
        DispatchQueue.global(qos: .userInitiated).async {
            CoreDataManager.shared.managedContext.refresh(self.orders[index], mergeChanges: true)
            // call the handler in the main thread
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "NewOrder", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewOrder" {
            let newOrderController = segue.destination as! NewOrderViewController
            newOrderController.delegate = self
        } else if segue.identifier == "OrderDetail", let index = selectedIndex {
            let orderDetailController = segue.destination as! OrderDetailTableViewController
            orderDetailController.index = index
            orderDetailController.order = orders[index]
            orderDetailController.delegate = self
            selectedIndex = nil
        }
    }
}

// MARK: - Table view data source

extension OrdersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order = orders[indexPath.row]
        let aCell = tableView.dequeueReusableCell(withIdentifier: orderCell, for: indexPath) as! OrderTableViewCell
        aCell.setupContent(order: order)
        
        return aCell
    }
}

// MARK: - Table view delegate

extension OrdersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "OrderDetail", sender: self)
    }
}

// MARK: - New order controller delegate

extension OrdersViewController: NewOrderControllerDelegate {
    
    func newOrderControllerDidFinish(canceled: Bool) {
        
        guard !canceled else {
            return
        }
        
        // refetch orders from core data
        refreshOrdersFromDatabase() {
            // reload tableview
            self.setupContent()
        }
    }
}

// MARK: - Order detail controller delegate

extension OrdersViewController: OrderDetailControllerDelegate {
    
    func orderDetailControllerDidiFinish(amended: Bool, at index: Int) {
        
        guard amended else {
            return
        }
        
        // refetch orders from core data
        refreshOrderFromDatabase(at: index) {
            // reload tableview
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
}
