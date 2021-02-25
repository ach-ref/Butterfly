//
//  Item+CoreDataProperties.swift
//  Butterfly
//
//  Created by Achref Marzouki on 25/02/2021.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var active: Bool
    @NSManaged public var id: Int32
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var lastUpdatedUserId: Int32
    @NSManaged public var productItemId: Int32
    @NSManaged public var quantity: Int32
    @NSManaged public var transientId: String?
    @NSManaged public var order: Order?

}
