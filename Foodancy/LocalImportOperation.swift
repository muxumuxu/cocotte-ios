//
//  LocalImportOperation.swift
//  Foodancy
//
//  Created by David Miotti on 28/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers
import CoreData
import SwiftyJSON

final class LocalImportOperation: SHOperation {

    var error: NSError?

    private var baseURL = "https://pregnant-foods.herokuapp.com/foods.json"

    private let importContext: NSManagedObjectContext

    override init() {
        importContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        importContext.parentContext = CoreDataStack.shared.managedObjectContext
    }

    override func execute() {
        guard let path = NSBundle.mainBundle().pathForResource("foods", ofType: "json"), data = NSData(contentsOfFile: path) else {
            error = NSError(domain: "LocalImport", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Unable to find foods.json"
            ])
            finish()
            return
        }

        defer {
            self.finish()
        }

        self.importContext.performBlockAndWait {
            let json = JSON(data: data)
            if let jsonFoods = json.array {

                do {

                    var foods = [Food]()
                    for jsonFood in jsonFoods {
                        if let id = jsonFood["id"].int {
                            let food: Food
                            if let local = try Food.findById(id, inContext: self.importContext) {
                                food = local
                            } else {
                                food = Food.insertEntity(inContext: self.importContext)
                            }
                            food.id = id
                            food.name = jsonFood["name"].string
                            food.danger = jsonFood["danger"].string

                            let jsonCategory = jsonFood["category"]
                            if let categoryId = jsonCategory["id"].int {
                                let cat = try self.findOrCreateCategory(categoryId)
                                cat.id = categoryId
                                cat.name = jsonCategory["name"].string
                                cat.order = jsonCategory["order"].int
                                cat.image = jsonCategory["image"].string
                                food.foodCategory = cat
                            }

                            let jsonRisk = jsonFood["risk"]
                            if let riskId = jsonRisk["id"].int {
                                let risk = try self.findOrCreateRisk(riskId)
                                risk.id = riskId
                                risk.name = jsonRisk["name"].string
                                risk.url = jsonRisk["url"].string
                                food.risk = risk
                            }

                            food.url = jsonFood["url"].string
                            food.info = jsonFood["info"].string
                            foods.append(food)
                        }
                    }

                    try self.saveContext()

                } catch let err as NSError {
                    self.error = err
                }
            }
        }
    }

    private func findOrCreateCategory(categoryId: Int) throws -> FoodCategory {
        let cat: FoodCategory
        if let local = try FoodCategory.findById(categoryId, inContext: self.importContext) {
            cat = local
        } else {
            cat = FoodCategory.insertEntity(inContext: self.importContext)
        }
        return cat
    }

    private func findOrCreateRisk(riskId: Int) throws -> Risk {
        let risk: Risk
        if let local = try Risk.findById(riskId, inContext: self.importContext) {
            risk = local
        } else {
            risk = Risk.insertEntity(inContext: self.importContext)
        }
        return risk
    }

    private func saveContext() throws {
        var ctx: NSManagedObjectContext? = importContext
        while let toSave = ctx {
            if toSave.hasChanges {
                try toSave.save()
            }
            ctx = toSave.parentContext
        }
    }

}
