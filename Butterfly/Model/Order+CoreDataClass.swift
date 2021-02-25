//
//  Order+CoreDataClass.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//
//

import Foundation
import CoreData

@objc(Order)
public class Order: NSManagedObject, Updatable {
    
    // MARK: - fetch
    
    class func getOrder(_ id: Int32, in context: NSManagedObjectContext) -> Order? {
        var order: Order?
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.predicate = NSPredicate(format: "id == %i", id)
            request.fetchLimit = 1
            if let result = try? context.fetch(request) {
                order = result.first
            }
        }
        return order
    }
    
    class func orderExists(_ orderNumber: String, in context: NSManagedObjectContext) -> Bool {
        var exists = false
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.predicate = NSPredicate(format: "orderNumber == %@", orderNumber)
            if let result = try? context.count(for: request){
                exists = result > 0
            }
        }
        
        return exists
    }
    
    class func all(in context: NSManagedObjectContext) -> [Order] {
        var orders: [Order] = []
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "issueDate", ascending: false)]
            if let result = try? context.fetch(request) {
                orders = result
            }
        }
        return orders
    }
    
    class func newOrderID(in context: NSManagedObjectContext) -> Int32 {
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
    
    static func isOutdated(orderID: Int32, lastUpdated: String, context: NSManagedObjectContext) -> (outdated: Bool, order: Order?) {
        if let order = getOrder(orderID, in: context) {
            let outdated = order.isOutdated(lastUpdated: lastUpdated)
            return (outdated, order)
        }
        
        return (true, nil)
    }
    
    @discardableResult
    static func insertFromJson(_ jsonObject: Json, context: NSManagedObjectContext) -> Order? {
        if let order = context.insert(entityClass: Order.self) {
            updateOrder(order: order, jsonObject: jsonObject, in: context)
            return order
        }
        
        return nil
    }
    
    static func updateOrder(order: Order, jsonObject: Json, in context: NSManagedObjectContext) {
        var stringDate = ""
        context.performAndWait {
            order.id = jsonObject[K.WS.ID] as? Int32 ?? 0
            order.supplierId = jsonObject[K.WS.SUPPLIER_ID] as? Int32 ?? 0
            order.orderNumber = jsonObject[K.WS.PURCHASE_ORDER_NUMBER] as? String ?? ""
            order.stockPurchaseProcessIds = jsonObject[K.WS.STOCK_PURCHASE_PROCESS_IDS] as? [Int16]
            stringDate = jsonObject[K.WS.ISSUE_DATE] as? String ?? ""
            order.issueDate = Utilities.jsonDateFormatter.date(from: stringDate)
            order.status = jsonObject[K.WS.STATUS] as? Int16 ?? 0
            order.active = (jsonObject[K.WS.ACTIVE_FLAG] as? NSNumber ?? 0).boolValue
            stringDate = jsonObject[K.WS.LAST_UPDATED] as? String ?? ""
            order.lastUpdated = Utilities.jsonDateFormatter.date(from: stringDate)
            order.lastUpdatedUserId = jsonObject[K.WS.LAST_UPDATED_USER_ENTITY_ID] as? Int32 ?? 0
            stringDate = jsonObject[K.WS.SENT_DATE] as? String ?? ""
            order.sentDate = Utilities.jsonDateFormatter.date(from: stringDate)
            order.serverTimestamp = jsonObject[K.WS.SERVER_TIMESTAMP] as? Int64 ?? 0
            order.deviceKey = jsonObject[K.WS.DEVICE_KEY] as? String ?? ""
            order.approvalStatus = jsonObject[K.WS.APPROVAL_STATUS] as? Int16 ?? 0
            stringDate = jsonObject[K.WS.PREFERRED_DELIVERY_DATE] as? String ?? ""
            order.prefferedDeliveryDate = Utilities.jsonDateFormatter.date(from: stringDate)
            order.deliveryNote = jsonObject[K.WS.DELIVERY_NOTE] as? String ?? ""
            
            // items
            for jsonItem in jsonObject[K.WS.ITEMS] as? [Json] ?? [] {
                let id = (jsonItem[K.WS.ID] as? NSNumber ?? 0).int16Value
                let remoteLastUpdated = jsonItem[K.WS.LAST_UPDATED] as? String ?? ""
                let info = Item.isOutdated(itemID: id, lastUpdated: remoteLastUpdated, context: context)
                if info.item == nil, let item = Item.insertFromJson(jsonItem, context: context) {
                    order.addToItems(item)
                } else if info.outdated {
                    Item.update(item: info.item!, jsonObject: jsonItem, context: context)
                }
            }
            
            // invoices
            for jsonInvoice in jsonObject[K.WS.INVOICES] as? [Json] ?? [] {
                let id = (jsonInvoice[K.WS.ID] as? NSNumber ?? 0).int16Value
                let remoteLastUpdated = jsonInvoice[K.WS.LAST_UPDATED] as? String ?? ""
                let info = Invoice.isOutdated(invoiceID: id, lastUpdated: remoteLastUpdated, context: context)
                if info.invoice == nil, let invoice = Invoice.insertFromJson(jsonInvoice, context: context) {
                    order.addToInvoices(invoice)
                } else if info.outdated {
                    Invoice.update(invoice: info.invoice!, jsonObject: jsonInvoice, context: context)
                }
            }
            
            // cancellations
            order.cancellations = []
            for jsonCancellation in jsonObject[K.WS.CANCELLATIONS] as? [Json] ?? [] {
                if let cancellation = Cancellation.insertFromJson(jsonCancellation, context: context) {
                    order.addToCancellations(cancellation)
                }
            }
        }
    }
}
