//
//  Food.swift
//
//
//  Created by David Miotti on 15/08/16.
//
//

import Foundation
import CoreData
import SwiftHelpers

final class Food: NSManagedObject, NamedEntity {
    static let entityName = "Food"

    enum FoodDangerType: Int {
        case Care, Avoid, Good
    }

    class func findById(id: Int, inContext context: NSManagedObjectContext) throws -> Food? {
        let req = entityFetchRequest()
        req.predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let res = try context.executeFetchRequest(req)
        return res.first as? Food
    }

    var dangerImage: UIImage? {
        if let danger = danger {
            switch danger {
            case "avoid":
                return UIImage(named: "forbidden_icon")
            case "care":
                return UIImage(named: "warning_icon")
            default:
                return UIImage(named: "good_icon")
            }
        }
        return UIImage(named: "good_icon")
    }

    var dangerType: FoodDangerType {
        if let danger = danger {
            switch danger {
            case "avoid":
                return .Avoid
            case "care":
                return .Care
            default:
                return .Good
            }
        }
        return .Good
    }
}
