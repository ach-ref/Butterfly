//
//  Invoice+CoreDataProperties.swift
//  Butterfly
//
//  Created by Achref Marzouki on 25/02/2021.
//
//

import Foundation
import CoreData


extension Invoice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Invoice> {
        return NSFetchRequest<Invoice>(entityName: "Invoice")
    }

    @NSManaged public var active: Bool
    @NSManaged public var created: Date?
    @NSManaged public var id: Int32
    @NSManaged public var invoiceNumber: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var lastUpdatedUserId: Int32
    @NSManaged public var receiptSentDate: Date?
    @NSManaged public var receivedStatus: Int16
    @NSManaged public var transientId: String?
    @NSManaged public var order: Order?
    @NSManaged public var receipts: NSSet?

}

// MARK: Generated accessors for receipts
extension Invoice {

    @objc(addReceiptsObject:)
    @NSManaged public func addToReceipts(_ value: Receipt)

    @objc(removeReceiptsObject:)
    @NSManaged public func removeFromReceipts(_ value: Receipt)

    @objc(addReceipts:)
    @NSManaged public func addToReceipts(_ values: NSSet)

    @objc(removeReceipts:)
    @NSManaged public func removeFromReceipts(_ values: NSSet)

}
