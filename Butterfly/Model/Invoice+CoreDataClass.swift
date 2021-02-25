//
//  Invoice+CoreDataClass.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//
//

import Foundation
import CoreData

@objc(Invoice)
public class Invoice: NSManagedObject, Updatable {

    // MARK: - fetch
    
    @discardableResult
    class func getInvoice(_ id: Int16, in context: NSManagedObjectContext) -> Invoice? {
        var invoice: Invoice?
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.predicate = NSPredicate(format: "id == %i", id)
            request.fetchLimit = 1
            if let result = try? context.fetch(request) {
                invoice = result.first
            }
        }
        return invoice
    }
    
    // MARK: - Json
    
    class func isOutdated(invoiceID: Int16, lastUpdated: String, context: NSManagedObjectContext) -> (outdated: Bool, invoice: Invoice?) {
        if let invoice = getInvoice(invoiceID, in: context) {
            let outdated = invoice.isOutdated(lastUpdated: lastUpdated)
            return (outdated, invoice)
        }
        
        return (true, nil)
    }
    
    class func insertFromJson(_ jsonObject: Json, context: NSManagedObjectContext) -> Invoice? {
        if let invoice = context.insert(entityClass: Invoice.self) {
            update(invoice: invoice, jsonObject: jsonObject, context: context)
            return invoice
        }
        
        return nil
    }
    
    class func update(invoice: Invoice, jsonObject: Json, context: NSManagedObjectContext) {
        var stringDate = ""
        context.performAndWait {
            invoice.id = jsonObject[K.WS.ID] as? Int32 ?? 0
            invoice.invoiceNumber = jsonObject[K.WS.INVOICE_NUMBER] as? String ?? ""
            invoice.receivedStatus = (jsonObject[K.WS.RECEIVED_STATUS] as? NSNumber ?? 0).int16Value
            stringDate = jsonObject[K.WS.CREATED] as? String ?? ""
            invoice.created = Utilities.jsonDateFormatter.date(from: stringDate)
            invoice.lastUpdatedUserId = jsonObject[K.WS.LAST_UPDATED_USER_ENTITY_ID] as? Int32 ?? 0
            invoice.transientId = jsonObject[K.WS.TRANSIENT_IDENTIFIER] as? String ?? ""
            stringDate = jsonObject[K.WS.RECEIPT_SENT_DATE] as? String ?? ""
            invoice.receiptSentDate = Utilities.jsonDateFormatter.date(from: stringDate)
            invoice.active = (jsonObject[K.WS.ACTIVE_FLAG] as? NSNumber ?? 0).boolValue
            stringDate = jsonObject[K.WS.LAST_UPDATED] as? String ?? ""
            invoice.lastUpdated = Utilities.jsonDateFormatter.date(from: stringDate)
            
            // receipts
            for jsonReceipt in jsonObject[K.WS.RECEIPTS] as? [Json] ?? [] {
                let id = (jsonReceipt[K.WS.ID] as? NSNumber ?? 0).int16Value
                let remoteLastUpdated = jsonObject[K.WS.LAST_UPDATED] as? String ?? ""
                let info = Receipt.isOutdated(receiptID: id, lastUpdated: remoteLastUpdated, context: context)
                if info.receipt == nil, let receipt = Receipt.insertFromJson(jsonReceipt, context: context) {
                    invoice.addToReceipts(receipt)
                } else if info.outdated {
                    Receipt.update(receipt: info.receipt!, jsonObject: jsonReceipt, context: context)
                }
            }
        }
    }
}
