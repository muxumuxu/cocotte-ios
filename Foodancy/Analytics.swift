//
//  Analytics.swift
//  Foodancy
//
//  Created by David Miotti on 04/05/2017.
//  Copyright © 2017 David Miotti. All rights reserved.
//

import UIKit
import Amplitude_iOS

final class Analytics {
    
    static let instance = Analytics()
    
    func setup() {
        #if DEBUG
            Amplitude.instance().initializeApiKey("00d4356f153e0d7ccdac41869b9199bf")
        #else
            Amplitude.instance().initializeApiKey("460ce79c6ad144a4f4ffa5549bebd674")
        #endif
        
        let defaults = UserDefaults.standard
        if let userId = defaults.object(forKey: "userId") as? String {
            Amplitude.instance().setUserId(userId)
        } else {
            let userId = UUID().uuidString
            defaults.set(userId, forKey: "userId")
            defaults.synchronize()
            Amplitude.instance().setUserId(userId)
        }
        
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().enableLocationListening()
    }
    
    func trackViewCategory(_ name: String) {
        track(eventName: "SelectCategory", props: ["name": name])
    }
    
    func trackViewFood(_ name: String, from: String) {
        track(eventName: "SelectFood", props: ["name": name, "from": from])
    }
    
    func trackFav(_ foodName: String, fav: Bool) {
        let eventName: String
        if (fav) {
            eventName = "AddFav"
        } else {
            eventName = "RemoveFav"
        }
        track(eventName: eventName, props: ["food": foodName])
    }
    
    func track(eventName: String, props: [AnyHashable: Any]) {
        Amplitude.instance().logEvent(eventName, withEventProperties: props)
    }
}
