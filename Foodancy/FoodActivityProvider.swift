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
            case .avoid: status = "à éviter"
            case .care: status = "faire attention"
            case .good: status = "autorisé"
            }
        }
        
        let foodName = food.name!.firstLetterCapitalization
        switch activityType {
        case UIActivityType.postToFacebook, UIActivityType.postToTwitter:
            return "Vous saviez que \(foodName) est \(status) pendant la grossesse ? 🙃"
        default:
            return "Regarde, \(foodName) est \(status) pendant la grossesse 🤗"
        }
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "alimentation grossesse"
    }
}
