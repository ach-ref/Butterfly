//
//  Updatable+CoreDataClass.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//
//

import Foundation
import CoreData


protocol Updatable: class {

    var lastUpdated: Date? { get set }
    
    func isOutdated(lastUpdated: String) -> Bool
}

extension Updatable where Self: NSManagedObject {
    
    func isOutdated(lastUpdated: String) -> Bool {
        var outdated = false
        let now = Date()
        let remoteLastUpdated = Utilities.jsonDateFormatter.date(from: lastUpdated) ?? now
        
        managedObjectContext?.performAndWait {
            let localLastUpdated = self.lastUpdated ?? now
            outdated = remoteLastUpdated > localLastUpdated
        }
        
        return outdated
    }
}
