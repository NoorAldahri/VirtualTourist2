//
//  DataContoller.swift
//  VirtualTourist
//
//  Created by Noor Aldahri on 07/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataContoller {
    
    static let shared = DataContoller()
    
    let persistenctContainer = NSPersistentContainer(name: "VirtualTourist")
    
    var viewContext: NSManagedObjectContext {
        return persistenctContainer.viewContext
    }
    
    func load() {
        persistenctContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
}
