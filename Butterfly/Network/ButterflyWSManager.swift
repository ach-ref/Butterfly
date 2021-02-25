//
//  ButterflyWSManager.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import CoreData

class ButterflyWSManager: NSObject {
    
    // MARK: - Shared instance
    
    static let shared = ButterflyWSManager()
    
    // MARK: - Initialzers
    
    override private init() {
        super.init()
    }
    
    // MARK: - Orders
    
    func synchroniseOrders(in context: NSManagedObjectContext, completion: @escaping () -> Void) {
        // get remote orders and synchronise with the local data if needed
        ApiManager.shared.request(url: ButterflyRouter.orders) { response in
            if let response = response, let jsonResult = response.value as? [Json] {
                self.synchroniseOrders(from: jsonResult, in: context) {
                    // save
                    context.saveContext()
                }
            }
            // completion handler
            completion()
        }
    }
    
    // MARK: - Helpers
    
    func synchroniseOrders(from jsonResult: [Json], in context: NSManagedObjectContext, completion:  @escaping () -> Void) {
        for jsonOrder in jsonResult {
            let orderID = jsonOrder[K.WS.ID] as? Int32 ?? 0
            let remoteLastUpdated = jsonOrder[K.WS.LAST_UPDATED] as? String ?? ""
            let info = Order.isOutdated(orderID: orderID, lastUpdated: remoteLastUpdated, context: context)
            if info.order == nil {
                Order.insertFromJson(jsonOrder, context: context)
            } else if info.outdated {
                Order.updateOrder(order: info.order!, jsonObject: jsonOrder, in: context)
            }
        }
        // completion handler
        completion()
    }
}
