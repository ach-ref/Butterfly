//
//  ButterflyTests.swift
//  ButterflyTests
//
//  Created by Achref Marzouki on 24/02/2021.
//

import XCTest
import SwiftyJSON
@testable import Butterfly

class ButterflyTests: XCTestCase {

    // MARK: - Properties
    
    private var coreDataManager: TestCoreDataManager!
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        coreDataManager = TestCoreDataManager.shared
    }

    override func tearDownWithError() throws {
        coreDataManager = nil
    }

    // MARK: - Utilities
    
    func testUtilities() {
        // json date formatter
        let aDate = Utilities.jsonDateFormatter.date(from: "2020-05-07T09:32:28.213Z")
        let anotherDate = Date(timeIntervalSince1970: 1588843948)
        XCTAssert(aDate!.timeIntervalSince1970.rounded() == anotherDate.timeIntervalSince1970.rounded())
        // app date formatter
        let stringDate = Utilities.appDateFormatter.string(from: aDate!)
        XCTAssert(!stringDate.isEmpty)
        // trimmed string
        XCTAssert(!"a     b".trimmed().isEmpty)
        XCTAssert("\n\t    \t\n".trimmed().isEmpty)
        
    }
    
    // MARK: - Network
    
    func testRoutable() throws {
        // check that we get an url for the route
        XCTAssertNoThrow(try ButterflyRouter.orders.asURLRequest())
    }
    
    // MARK: - Data
    
    func testInitialDataSync() {
        let initialDataUrl = Bundle(for: type(of: self)).url(forResource: "initial", withExtension: "json")!
        let stringJson = try? String(contentsOf: initialDataUrl)
        let jsonObject = JSON(parseJSON: stringJson ?? "").arrayObject as? [Json] ?? []
        let context = coreDataManager.storeContainer.newBackgroundContext()
        ButterflyWSManager.shared.synchroniseOrders(from: jsonObject, in: context) {
            // save context
            context.saveContext()
            // get orders
            let orders = Order.all(in: context)
            // check orders
            XCTAssert(orders.count == 1)
            // check items
            XCTAssert(orders.first!.items?.count ?? 0 == 4)
            // check invoices
            XCTAssert(orders.first!.invoices?.count ?? 0 == 1)
            // check receipts
            XCTAssert((orders.first!.invoices!.allObjects.first! as! Invoice).receipts?.count ?? 0 == 1)
            // check cancellations
            XCTAssert(orders.first!.cancellations?.count ?? 0 == 1)
        }
    }
    
    func testNoUpdate() {
        let updatedDataUrl = Bundle(for: type(of: self)).url(forResource: "noupdate", withExtension: "json")!
        let stringJson = try? String(contentsOf: updatedDataUrl)
        let jsonObject = JSON(parseJSON: stringJson ?? "").arrayObject as? [Json] ?? []
        let context = coreDataManager.storeContainer.newBackgroundContext()
        ButterflyWSManager.shared.synchroniseOrders(from: jsonObject, in: context) {
            // save context
            context.saveContext()
            // get orders
            let orders = Order.all(in: context)
            // check orders count
            XCTAssert(orders.count == 1)
            // order # 1
            XCTAssert(orders.first!.status == 1)
            XCTAssert(orders.first!.active == true)
            XCTAssert(orders.first!.deviceKey == "string")
        }
    }
    
    func testUpdatedRemoteData() {
        let updatedDataUrl = Bundle(for: type(of: self)).url(forResource: "update", withExtension: "json")!
        let stringJson = try? String(contentsOf: updatedDataUrl)
        let jsonObject = JSON(parseJSON: stringJson ?? "").arrayObject as? [Json] ?? []
        let context = coreDataManager.storeContainer.newBackgroundContext()
        ButterflyWSManager.shared.synchroniseOrders(from: jsonObject, in: context) {
            // save context
            context.saveContext()
            // get orders
            let orders = Order.all(in: context)
            // check orders count
            XCTAssert(orders.count == 1)
            // check order
            XCTAssert(orders.first!.active == false)
            // check item #1
            let item = Item.getItem(1, in: context)
            XCTAssert(item!.quantity == 100)
            // invoice # 11
            let invoice = Invoice.getInvoice(11, in: context)
            XCTAssert(invoice!.receivedStatus == 3)
            // receipt # 110
            let receipt = Receipt.getReceipt(110, in: context)
            XCTAssert(receipt!.receivedQuantity == 12345)
            XCTAssert(receipt!.transientId == "radom identifier")
        }
    }
    
    // MARK: - Perfs

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
