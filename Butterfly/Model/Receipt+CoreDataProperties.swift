//
//  Receipt+CoreDataProperties.swift
//  Butterfly
//
//  Created by Achref Marzouki on 25/02/2021.
//
//

import Foundation
import CoreData


extension Receipt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Receipt> {
        return NSFetchRequest<Receipt>(entityName: "Receipt")
    }

    @NSManaged public var active: Bool
    @NSManaged public var created: Date?
    @NSManaged public var id: Int32
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var lastUpdatedUserId: Int32
    @NSManaged public var productItemId: Int32
    @NSManaged public var receivedQuantity: Int16
    @NSManaged public var sentDate: Date?
    @NSManaged public var transientId: String?
    @NSManaged public var invoice: Invoice?

}
