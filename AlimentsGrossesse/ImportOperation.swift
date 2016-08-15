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
            defer { self.finish() }

            guard let data = res.data else {
                self.error = res.result.error
                print("Error: \(self.error)")
                return
            }

            let json = JSON(data)
            if let foods = json.array {
                print(foods)
            }
        }
    }
}
