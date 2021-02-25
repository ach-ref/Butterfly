//
//  Cancellation+CoreDataClass.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//
//

import Foundation
import CoreData

@objc(Cancellation)
public class Cancellation: NSManagedObject {

    // MARK: - Json
    
    class func insertFromJson(_ jsonObject: Json, context: NSManagedObjectContext) -> Cancellation? {
        if let cancellation = context.insert(entityClass: Cancellation.self) {
            cancellation.id = jsonObject[K.WS.ID] as? Int32 ?? 0
            cancellation.productItemId = jsonObject[K.WS.PRODUCT_ITEM_ID] as? Int32 ?? 0
            cancellation.orderedQuantity = jsonObject[K.WS.ORDERED_QUANTITY] as? Int32 ?? 0
            cancellation.lastUpatedUserId = jsonObject[K.WS.LAST_UPDATED_USER_ENTITY_ID] as? Int32 ?? 0
            let stringDate = jsonObject[K.WS.CREATED] as? String ?? ""
            cancellation.created = Utilities.jsonDateFormatter.date(from: stringDate)
            cancellation.transientId =  jsonObject[K.WS.TRANSIENT_IDENTIFIER] as? String ?? ""
            return cancellation
        }
        
        return nil
    }
}
