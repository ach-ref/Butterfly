//
//  TestCoreDataManager.swift
//  ButterflyTests
//
//  Created by Achref Marzouki on 25/02/2021.
//

import CoreData

final class TestCoreDataManager: NSObject {
    
    // MARK: - Private
    
    private let modelName = "Butterfly"
    
    // MARK: - Shared instance
    
    static let shared = TestCoreDataManager()
    
    // MARK: - Stack
    
    var managedContext: NSManagedObjectContext {
        return self.storeContainer.viewContext
    }
    
    lazy var storeContainer: NSPersistentContainer = {
        // container
        let container = NSPersistentContainer(name: self.modelName)
        // container description - In memory type
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        // load stores
        container.loadPersistentStores { (storeDescrption, error) in
            if let error = error as NSError? {
                fatalError("Error while creating core data stack : \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
}
