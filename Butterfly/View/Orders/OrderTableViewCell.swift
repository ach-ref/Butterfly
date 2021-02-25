//
//  OrderTableViewCell.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var orderNumberLabel: UILabel!
    @IBOutlet private weak var itemsNumberLabel: UILabel!
    @IBOutlet private weak var lastUpdatedLabel: UILabel!
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        
    }

    // MARK: - UI
    
    private func configure() {
        orderNumberLabel.text = nil
        orderNumberLabel.textColor = UIColor(named: "Secondary")
        itemsNumberLabel.text = nil
        lastUpdatedLabel.text = nil
    }
    
    func setupContent(order: Order) {
        let itemsCountFormat = NSLocalizedString("orders.itemCount", comment: "")
        orderNumberLabel.text = "# \(order.orderNumber ?? "<N/A>")"
        itemsNumberLabel.text = String.localizedStringWithFormat(itemsCountFormat, order.items?.count ?? 0)
        lastUpdatedLabel.text = order.issueDate == nil ? "<N/A>" : Utilities.appDateFormatter.string(from: order.issueDate!)
    }
}
