//
//  OrderDetailTableViewController.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import UIKit

protocol OrderDetailControllerDelegate: class {
    func orderDetailControllerDidiFinish(amended: Bool, at index: Int)
}

class OrderDetailTableViewController: UITableViewController {

    // MARK: - Properties
    
    var index: Int!
    var order: Order!
    
    weak var delegate: OrderDetailControllerDelegate?
    
    // MARK: - Private
    
    private let detailCell = "DetailCell"
    
    private var storeItems: [Item]?
    private var items: [Item] {
        guard storeItems == nil else { return storeItems! }
        let items = (order.items?.allObjects ?? []) as! [Item]
        return items.sorted { $0.id < $1.id }
    }
    
    private lazy var invoices: [Invoice] = {
        let invoices = (order.invoices?.allObjects ?? []) as! [Invoice]
        return invoices.sorted { $0.id < $1.id }
    }()
    
    private var noItems: Bool { items.count == 0 }
    private var noInvoices: Bool { invoices.count == 0 }
    
    private var itemsAmended = false
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial setup
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // popped
        if isMovingFromParent {
            delegate?.orderDetailControllerDidiFinish(amended: itemsAmended, at: index)
        }
    }

    // MARK: - UI
    
    private func configureView() {
        // navigation bar
        title = "# \(order.orderNumber ?? "<N/A>")"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
        navigationItem.rightBarButtonItem = addButton
        // table view
        let aNib = UINib(nibName: "OrderDetailTableViewCell", bundle: Bundle(for: type(of: self)))
        tableView.register(aNib, forCellReuseIdentifier: detailCell)
        
    }
    
    // MARK: - Data
    
    private func refreshOrder(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // refetch the order from the store
            let context = self.order.managedObjectContext ?? CoreDataManager.shared.managedContext
            self.order = Order.getOrder(self.order.id, in: context)
            self.storeItems = nil
            // update the UI from the main thread
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "NewItem", sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewItem" {
            let newItemController = segue.destination as! NewItemViewController
            newItemController.delegate = self
            newItemController.order = order
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return noItems ? 1 : items.count
        case 1: return noInvoices ? 1 : invoices.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: detailCell, for: indexPath) as! OrderDetailTableViewCell
        
        switch indexPath.section {
        // first section - items
        case 0:
            if noItems { aCell.setupContent(emptyCellType: .item) }
            else { aCell.setupContent(item: items[indexPath.row]) }
        // second section - invoices
        case 1:
            if noInvoices { aCell.setupContent(emptyCellType: .invoice) }
            else { aCell.setupContent(invoice: invoices[indexPath.row]) }
        // error
        default:
            fatalError("Undefined Section \(indexPath.section)")
        }
        
        return aCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("orderDetail.itemsSectionTitle", comment: "")
        case 1: return NSLocalizedString("orderDetail.invoicesSectionTitle", comment: "")
        default: return nil
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - New item controller delegate

extension OrderDetailTableViewController: NewItemControllerDelegate {
    
    func newItemControllerDidFinish(canceled: Bool) {
        
        guard !canceled else {
            return
        }
        
        // refetch the order from core data
        itemsAmended = true
        refreshOrder() {
            // reload items section
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
}
