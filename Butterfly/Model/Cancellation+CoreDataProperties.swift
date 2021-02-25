//
//  Cancellation+CoreDataProperties.swift
//  Butterfly
//
//  Created by Achref Marzouki on 25/02/2021.
//
//

import Foundation
import CoreData


extension Cancellation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cancellation> {
        return NSFetchRequest<Cancellation>(entityName: "Cancellation")
    }

    @NSManaged public var created: Date?
    @NSManaged public var id: Int32
    @NSManaged public var lastUpatedUserId: Int32
    @NSManaged public var orderedQuantity: Int32
    @NSManaged public var productItemId: Int32
    @NSManaged public var transientId: String?
    @NSManaged public var order: Order?

}
