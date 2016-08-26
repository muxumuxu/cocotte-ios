//
//  Risk.swift
//
//
//  Created by David Miotti on 26/08/16.
//
//

import Foundation
import CoreData
import SwiftHelpers

final class Risk: NSManagedObject, NamedEntity {
    static let entityName = "Risk"

    class func findById(id: Int, inContext context: NSManagedObjectContext) throws -> Risk? {
        let req = entityFetchRequest()
        req.predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let res = try context.executeFetchRequest(req)
        return res.first as? Risk
    }
}
