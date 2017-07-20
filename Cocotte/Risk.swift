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

extension NamedEntity where Self: NSFetchRequestResult {
    static func find(by id: Int, inContext context: NSManagedObjectContext) throws -> Self? {
        let req = NSFetchRequest<Self>(entityName: entityName)
        req.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        let res = try context.fetch(req)
        return res.first
    }
}

final class Risk: NSManagedObject, NamedEntity {
    static let entityName = "Risk"
}
