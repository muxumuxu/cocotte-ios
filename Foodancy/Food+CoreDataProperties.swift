//
//  Food+CoreDataProperties.swift
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

extension Food {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var risk: Risk?
    @NSManaged var url: String?
    @NSManaged var info: String?
    @NSManaged var danger: String?
    @NSManaged var foodCategory: FoodCategory?
    @NSManaged var favDate: Date?

}
