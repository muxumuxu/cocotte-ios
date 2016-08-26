//
//  Risk+CoreDataProperties.swift
//  
//
//  Created by David Miotti on 26/08/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Risk {

    @NSManaged var name: String?
    @NSManaged var id: NSNumber?
    @NSManaged var url: String?
    @NSManaged var foods: NSSet?

}
