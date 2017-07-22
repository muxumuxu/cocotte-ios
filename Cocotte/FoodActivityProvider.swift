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
    
    static let oneToOneGoodMessage = "Tu sais que cet aliment est autorisé pendant la grossesse ? 🙂"
    static let oneToOneCareMessage = "Tu sais qu'il faut faire attention à cet aliment pendant la grossesse ? 🙃"
    static let oneToOneAvoidMessage = "Tu sais que cet aliment est dangereux pendant la grossesse ? 🙃"
    
    static let oneToManyGoodMessage = "Savez-vous que cet aliment est autorisé pendant la grossesse ? 🙂"
    static let oneToManyCareMessage = "Savez-vous qu'il faut faire attention à cet aliment pendant la grossesse ? 🙃"
    static let oneToManyAvoidMessage = "Savez-vous que cet aliment est dangereux pendant la grossesse ? 🙃"
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        guard let type = food?.dangerType else { return nil }
        
        let status: String
        let message: String
        
        switch activityType {
        case UIActivityType.postToFacebook, UIActivityType.postToTwitter:
            switch type {
            case .good: message = FoodActivityProvider.oneToManyGoodMessage
            case .avoid: message = FoodActivityProvider.oneToManyAvoidMessage
            case .care: message = FoodActivityProvider.oneToManyCareMessage
            }
        default:
            switch type {
            case .good: message = FoodActivityProvider.oneToOneGoodMessage
            case .avoid: message = FoodActivityProvider.oneToOneAvoidMessage
            case .care: message = FoodActivityProvider.oneToOneCareMessage
            }
        }
        
        switch type {
        case .good:     status = "✅ Autorisé"
        case .care:     status = "⚠️ Faire attention"
        case .avoid:    status = "⛔️ Dangereux"
        }
        
        let foodName = food.name!.firstLetterCapitalization
        switch activityType {
        case UIActivityType.postToFacebook, UIActivityType.postToTwitter:
            return "\(message)\n--\n\(foodName)\n\(status)\nPour voir plus d'aliments 🍉🍭🥑 :"
        default:
            return "\(message)\n--\n\(foodName)\n\(status)\nPour voir plus d'aliments 🍉🍭🥑 :"
        }
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "alimentation grossesse"
    }
}
