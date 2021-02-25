//
//  CoreDataManager.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import CoreData

final class CoreDataManager: NSObject {

    // MARK: - Private
    
    private let modelName = "Butterfly"
    
    // MARK: - Shared instance
    
    static let shared = CoreDataManager()
    
    // MARK: - Stack
    
    var managedContext: NSManagedObjectContext {
        return self.storeContainer.viewContext
    }
    
    lazy var storeContainer: NSPersistentContainer = {
        // container
        let container = NSPersistentContainer(name: self.modelName)
        
        // documents url
        let storeName = "\(self.modelName).sqlite"
        let documentsDirectoryUrl = try? FileManager.default.url(for: .documentDirectory,
                                                                 in: .userDomainMask,
                                                                 appropriateFor: nil,
                                                                 create: true)
        guard let persistentStoreURL = documentsDirectoryUrl?.appendingPathComponent(storeName) else {
            fatalError("Unable to find persistent store in \"Documents\" directory")
        }
        
        // container description - Lightweight migration & custom url
        let description = NSPersistentStoreDescription(url: persistentStoreURL)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
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
