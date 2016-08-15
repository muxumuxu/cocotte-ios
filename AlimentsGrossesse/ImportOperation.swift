//
//  ImportOperation.swift
//  AlimentsGrossesse
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

    private var baseURL = "https://pregnant-foods.herokuapp.com/foods.json"

    private let importContext: NSManagedObjectContext

    override init() {
        importContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        importContext.parentContext = CoreDataStack.shared.managedObjectContext
    }

    override func execute() {
        Alamofire.request(.GET, baseURL).responseJSON { (res) in
            defer {
                self.finish()
            }

            guard let value = res.result.value else {
                self.error = res.result.error
                return
            }

            self.importContext.performBlockAndWait {
                let json = JSON(value)
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
                                food.danger = jsonFood["dange"].string

                                let jsonCategory = jsonFood["category"]
                                if let categoryId = jsonCategory["id"].int {
                                    let cat: FoodCategory
                                    if let local = try FoodCategory.findById(categoryId, inContext: self.importContext) {
                                        cat = local
                                    } else {
                                        cat = FoodCategory.insertEntity(inContext: self.importContext)
                                    }
                                    cat.id = categoryId
                                    cat.name = jsonCategory["name"].string
                                    cat.order = jsonCategory["order"].int
                                    cat.image = jsonCategory["image"].string

                                    food.foodCategory = cat
                                }
                                food.risk = jsonFood["risk"].string
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
