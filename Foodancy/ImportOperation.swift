//
//  ImportOperation.swift
//  Foodancy
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers
import Alamofire
import SwiftyJSON
import CoreData

final class ImportOperation: SHOperation {

    var error: NSError?

    fileprivate var baseURL = "https://pregnant-foods.herokuapp.com/foods.json"

    fileprivate let importContext: NSManagedObjectContext
    fileprivate let networkManager: SessionManager

    override init() {
        importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.parent = CoreDataStack.shared.managedObjectContext

        let config = URLSession.shared.configuration
        config.timeoutIntervalForRequest = 5
        networkManager = SessionManager(configuration: config)
    }

    override func execute() {
        networkManager.request(baseURL).responseJSON { (res) in
            defer {
                self.finish()
            }

            guard let value = res.result.value else {
                self.error = res.result.error as? NSError
                return
            }

            self.importContext.performAndWait {
                let json = JSON(value)
                if let jsonFoods = json.array {

                    do {

                        var foods = [Food]()
                        for jsonFood in jsonFoods {
                            if let id = jsonFood["id"].int {
                                let food: Food
                                if let local = try Food.find(by: id, inContext: self.importContext) {
                                    food = local
                                } else {
                                    food = Food.insertEntity(inContext: self.importContext)
                                }
                                food.id = NSNumber(value: id)
                                food.name = jsonFood["name"].string
                                food.danger = jsonFood["danger"].string

                                let jsonCategory = jsonFood["category"]
                                if let categoryId = jsonCategory["id"].int {
                                    let cat = try self.findOrCreateCategory(categoryId)
                                    cat.id = NSNumber(value: categoryId)
                                    cat.name = jsonCategory["name"].string
                                    cat.order = jsonCategory["order"].int.flatMap { NSNumber(value: $0) }
                                    cat.image = jsonCategory["image"].string
                                    food.foodCategory = cat
                                }

                                let jsonRisk = jsonFood["risk"]
                                if let riskId = jsonRisk["id"].int {
                                    let risk = try self.findOrCreateRisk(riskId)
                                    risk.id = NSNumber(value: riskId)
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
    }

    fileprivate func findOrCreateCategory(_ categoryId: Int) throws -> FoodCategory {
        let cat: FoodCategory
        if let local = try FoodCategory.find(by: categoryId, inContext: self.importContext) {
            cat = local
        } else {
            cat = FoodCategory.insertEntity(inContext: self.importContext)
        }
        return cat
    }

    fileprivate func findOrCreateRisk(_ riskId: Int) throws -> Risk {
        let risk: Risk
        if let local = try Risk.find(by: riskId, inContext: self.importContext) {
            risk = local
        } else {
            risk = Risk.insertEntity(inContext: self.importContext)
        }
        return risk
    }

    fileprivate func saveContext() throws {
        var ctx: NSManagedObjectContext? = importContext
        while let toSave = ctx {
            if toSave.hasChanges {
                try toSave.save()
            }
            ctx = toSave.parent
        }
    }
}
