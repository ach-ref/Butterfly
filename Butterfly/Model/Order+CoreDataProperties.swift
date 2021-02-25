//
//  Order+CoreDataProperties.swift
//  Butterfly
//
//  Created by Achref Marzouki on 25/02/2021.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var active: Bool
    @NSManaged public var approvalStatus: Int16
    @NSManaged public var deliveryNote: String?
    @NSManaged public var deviceKey: String?
    @NSManaged public var id: Int32
    @NSManaged public var issueDate: Date?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var lastUpdatedUserId: Int32
    @NSManaged public var orderNumber: String?
    @NSManaged public var prefferedDeliveryDate: Date?
    @NSManaged public var sentDate: Date?
    @NSManaged public var serverTimestamp: Int64
    @NSManaged public var status: Int16
    @NSManaged public var stockPurchaseProcessIds: Array<Int16>?
    @NSManaged public var supplierId: Int32
    @NSManaged public var cancellations: NSSet?
    @NSManaged public var invoices: NSSet?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for cancellations
extension Order {

    @objc(addCancellationsObject:)
    @NSManaged public func addToCancellations(_ value: Cancellation)

    @objc(removeCancellationsObject:)
    @NSManaged public func removeFromCancellations(_ value: Cancellation)

    @objc(addCancellations:)
    @NSManaged public func addToCancellations(_ values: NSSet)

    @objc(removeCancellations:)
    @NSManaged public func removeFromCancellations(_ values: NSSet)

}

// MARK: Generated accessors for invoices
extension Order {

    @objc(addInvoicesObject:)
    @NSManaged public func addToInvoices(_ value: Invoice)

    @objc(removeInvoicesObject:)
    @NSManaged public func removeFromInvoices(_ value: Invoice)

    @objc(addInvoices:)
    @NSManaged public func addToInvoices(_ values: NSSet)

    @objc(removeInvoices:)
    @NSManaged public func removeFromInvoices(_ values: NSSet)

}

// MARK: Generated accessors for items
extension Order {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
