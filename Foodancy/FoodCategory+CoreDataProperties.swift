//
//  FoodCategory+CoreDataProperties.swift
//
//
//  Created by David Miotti on 15/08/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FoodCategory {

    @NSManaged var id: NSNumber?
    @NSManaged var order: NSNumber?
    @NSManaged var name: String?
    @NSManaged var image: String?
    @NSManaged var foods: NSSet?

}
