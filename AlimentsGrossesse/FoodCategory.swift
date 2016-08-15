//
//  FoodCategory.swift
//
//
//  Created by David Miotti on 15/08/16.
//
//

import Foundation
import CoreData
import SwiftHelpers

class FoodCategory: NSManagedObject, NamedEntity {
    static let entityName = "FoodCategory"

    class func findById(id: Int, inContext context: NSManagedObjectContext) throws -> FoodCategory? {
        let req = entityFetchRequest()
        req.predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let res = try context.executeFetchRequest(req)
        return res.first as? FoodCategory
    }
}
