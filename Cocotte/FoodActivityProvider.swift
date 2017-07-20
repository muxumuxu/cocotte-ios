//
//  FoodActivityProvider.swift
//  Foodancy
//
//  Created by David Miotti on 05/06/2017.
//  Copyright © 2017 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

final class FoodActivityProvider: UIActivityItemProvider {
    var food: Food!
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        var status: String = "à éviter"
        if let type = food?.dangerType {
            switch type {
            case .avoid, .care: status = "à éviter"
            case .good: status = "autorisé"
            }
        }
        
        let foodName = food.name!.firstLetterCapitalization
        switch activityType {
        case UIActivityType.postToFacebook, UIActivityType.postToTwitter:
            return "Vous saviez que cet aliment est \(status) pendant la grossesse ? 🙃\n--\n\(foodName.firstLetterCapitalization)\n\(status.firstLetterCapitalization)\nPour voir plus d'aliments 🍉🍭🥑 :"
        default:
            return "Tu savais que cet aliment est \(status) pendant la grossesse ? 🙃\n--\n\(foodName.firstLetterCapitalization)\n\(status.firstLetterCapitalization)\nPour voir plus d'aliments 🍉🍭🥑 :"
        }
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "alimentation grossesse"
    }
}
