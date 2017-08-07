//
//  Analytics.swift
//  Foodancy
//
//  Created by David Miotti on 04/05/2017.
//  Copyright © 2017 David Miotti. All rights reserved.
//

import UIKit
import Amplitude_iOS
import Mixpanel

final class Analytics {
    
    static let instance = Analytics()
    
    func setup() {
        #if DEBUG
            Amplitude.instance().initializeApiKey("00d4356f153e0d7ccdac41869b9199bf")
            Mixpanel.sharedInstance(withToken: "273aa51ffb4fa55f8b8c55aa89f227b6")
        #else
            Amplitude.instance().initializeApiKey("460ce79c6ad144a4f4ffa5549bebd674")
            Mixpanel.sharedInstance(withToken: "724399ebeb9b04fbbce6e249b615fb33")
        #endif
        
        let defaults = UserDefaults.standard
        if let userId = defaults.object(forKey: "userId") as? String {
            Amplitude.instance().setUserId(userId)
            Mixpanel.sharedInstance()?.identify(userId)
        } else {
            let userId = UUID().uuidString
            defaults.set(userId, forKey: "userId")
            defaults.synchronize()
            Amplitude.instance().setUserId(userId)
            Mixpanel.sharedInstance()?.identify(userId)
        }
        
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().enableLocationListening()
    }
    
    func trackViewCategory(_ name: String) {
        track(eventName: "SelectCategory", props: ["name": name])
    }
    
    func trackViewFood(_ name: String, from: String, searchPattern: String? = nil) {
        var props: [AnyHashable: Any] = [
            "name": name,
            "from": from
        ]
        if let search = searchPattern {
            props["search"] = search
        }
        track(eventName: "SelectFood", props: props)
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
    
    func trackShare(_ foodName: String, category: String, media: String) {
        track(eventName: "Share", props: [
            "food": foodName,
            "category": category,
            "media": media
        ])
    }
    
    func track(eventName: String, props: [AnyHashable: Any]) {
        Amplitude.instance().logEvent(eventName, withEventProperties: props)
        Mixpanel.sharedInstance()?.track(eventName, properties: props)
    }
    
    func saveDeviceToken(deviceToken: Data) {
        Mixpanel.sharedInstance()?.people.addPushDeviceToken(deviceToken)
    }
    
    func trackPushNotification(userInfo: [AnyHashable: Any]) {
        Mixpanel.sharedInstance()?.trackPushNotification(userInfo)
    }
}
