//
//  OrderDetailTableViewCell.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import UIKit

enum OrderDetailEmptyCellType {
    case item, invoice
}

class OrderDetailTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    // MARK: - UI
    
    func setupContent(item: Item)  {
        // title
        titleLabel.text = String(format: "# %02d", item.id)
        titleLabel.textColor = UIColor(named: "Secondary")
        // detail
        detailLabel.text = String(format: NSLocalizedString("orderDetail.quantity", comment: ""), item.quantity)
    }
    
    func setupContent(invoice: Invoice)  {
        // title
        titleLabel.text = String(format: "# %02d", invoice.id)
        titleLabel.textColor = UIColor(named: "Secondary")
        // detail
        detailLabel.text = String(format: NSLocalizedString("orderDetail.receivedStatus", comment: ""), invoice.receivedStatus)
    }
    
    func setupContent(emptyCellType: OrderDetailEmptyCellType) {
        // title
        let key = emptyCellType == .item ? "orderDetail.noItems" : "orderDetail.noInvoices"
        titleLabel.text = NSLocalizedString(key, comment: "")
        titleLabel.textColor = .darkGray
        // detail
        detailLabel.text = nil
    }
}
