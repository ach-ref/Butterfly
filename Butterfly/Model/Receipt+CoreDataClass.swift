//
//  Receipt+CoreDataClass.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//
//

import Foundation
import CoreData

@objc(Receipt)
public class Receipt: NSManagedObject, Updatable {

    // MARK: - fetch
    
    @discardableResult
    class func getReceipt(_ id: Int16, in context: NSManagedObjectContext) -> Receipt? {
        var receipt: Receipt?
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.predicate = NSPredicate(format: "id == %i", id)
            request.fetchLimit = 1
            if let result = try? context.fetch(request) {
                receipt = result.first
            }
        }
        return receipt
    }
    
    // MARK: - Json
    
    class func isOutdated(receiptID: Int16, lastUpdated: String, context: NSManagedObjectContext) -> (outdated: Bool, receipt: Receipt?) {
        if let receipt = getReceipt(receiptID, in: context) {
            let outdated = receipt.isOutdated(lastUpdated: lastUpdated)
            return (outdated, receipt)
        }
        
        return (true, nil)
    }
    
    class func insertFromJson(_ jsonObject: Json, context: NSManagedObjectContext) -> Receipt? {
        if let receipt = context.insert(entityClass: Receipt.self) {
            update(receipt: receipt, jsonObject: jsonObject, context: context)
            return receipt
        }
        
        return nil
    }
    
    class func update(receipt: Receipt, jsonObject: Json, context: NSManagedObjectContext) {
        var stringDate = ""
        context.performAndWait {
            receipt.id = jsonObject[K.WS.ID] as? Int32 ?? 0
            receipt.productItemId = jsonObject[K.WS.PRODUCT_ITEM_ID] as? Int32 ?? 0
            receipt.receivedQuantity = jsonObject[K.WS.RECEIVED_QUANTITY] as? Int16 ?? 0
            stringDate = jsonObject[K.WS.CREATED] as? String ?? ""
            receipt.created = Utilities.jsonDateFormatter.date(from: stringDate)
            receipt.lastUpdatedUserId = jsonObject[K.WS.LAST_UPDATED_USER_ENTITY_ID] as? Int32 ?? 0
            receipt.transientId = jsonObject[K.WS.TRANSIENT_IDENTIFIER] as? String ?? ""
            stringDate = jsonObject[K.WS.SENT_DATE] as? String ?? ""
            receipt.sentDate = Utilities.jsonDateFormatter.date(from: stringDate)
            receipt.active = (jsonObject[K.WS.ACTIVE_FLAG] as? NSNumber ?? 0).boolValue
            stringDate = jsonObject[K.WS.LAST_UPDATED] as? String ?? ""
            receipt.lastUpdated = Utilities.jsonDateFormatter.date(from: stringDate)
        }
    }
}
