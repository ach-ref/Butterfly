//
//  Item+CoreDataClass.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject, Updatable {

    // MARK: - fetch
    
    class func getItem(_ id: Int16, in context: NSManagedObjectContext) -> Item? {
        var item: Item?
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.predicate = NSPredicate(format: "id == %i", id)
            request.fetchLimit = 1
            if let result = try? context.fetch(request) {
                item = result.first
            }
        }
        return item
    }
    
    class func newItemID(in context: NSManagedObjectContext) -> Int32 {
        var id = Int32.max
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            request.fetchLimit = 1
            if let result = try? context.fetch(request) {
                id = (result.first?.id ?? 0) + 1
            }
        }
        
        return id
    }
    
    // MARK: - Json
    
    class func isOutdated(itemID: Int16, lastUpdated: String, context: NSManagedObjectContext) -> (outdated: Bool, item: Item?) {
        if let item = getItem(itemID, in: context) {
            let outdated = item.isOutdated(lastUpdated: lastUpdated)
            return (outdated, item)
        }
        
        return (true, nil)
    }
    
    @discardableResult
    class func insertFromJson(_ jsonObject: Json, context: NSManagedObjectContext) -> Item? {
        if let item = context.insert(entityClass: Item.self) {
            update(item: item, jsonObject: jsonObject, context: context)
            return item
        }
        
        return nil
    }
    
    class func update(item: Item, jsonObject: Json, context: NSManagedObjectContext) {
        context.performAndWait {
            item.id = jsonObject[K.WS.ID] as? Int32 ?? 0
            item.productItemId = jsonObject[K.WS.PRODUCT_ITEM_ID] as? Int32 ?? 0
            item.quantity = jsonObject[K.WS.QUANTITY] as? Int32 ?? 0
            item.lastUpdatedUserId = jsonObject[K.WS.LAST_UPDATED_USER_ENTITY_ID] as? Int32 ?? 0
            item.transientId = jsonObject[K.WS.TRANSIENT_IDENTIFIER] as? String ?? ""
            item.active = (jsonObject[K.WS.ACTIVE_FLAG] as? NSNumber ?? 0).boolValue
            let stringData = jsonObject[K.WS.LAST_UPDATED] as? String ?? ""
            item.lastUpdated = Utilities.jsonDateFormatter.date(from: stringData)
        }
    }
}
