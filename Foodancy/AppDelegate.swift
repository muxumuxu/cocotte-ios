//
//  AppDelegate.swift
//  Foodancy
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import CoreData
import SnapKit
import SwiftHelpers
import Amplitude_iOS
import Fabric
import Crashlytics
import FBSDKCoreKit

let contactEmail = "foodancy@muxumuxu.com"
let iTunesLink = "https://itunes.apple.com/us/app/foodancy/id1148406816?ls=1&mt=8"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        CoreDataStack.initializeWithMomd("Foodancy", sql: "Foodancy.sqlite")

        configureCrashlytics()

        downloadContent()

        customizeAppearance()

        configureAmplitudeSDK()

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataStack.shared.saveContext()
    }

    func customizeAppearance() {
        let nav = UINavigationBar.appearance()
        nav.shadowImage = UIImage()
        nav.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)

        let app = UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])
        app.defaultTextAttributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(18, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: "8E8E93".UIColor
        ]
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    private let importOperationQueue = NSOperationQueue()

    private func downloadContent() {

        importOperationQueue.maxConcurrentOperationCount = 1

        if !hasImportedData() {
            let localImport = LocalImportOperation()
            localImport.completionBlock = {
                if let err = localImport.error {
                    print("Error while local importing data: \(err)")
                }
            }
            importOperationQueue.addOperation(localImport)
        }

        let op = ImportOperation()
        op.completionBlock = {
            if let err = op.error {
                print("Error while importing data: \(err)")
                if !self.hasImportedData() {
                    self.downloadContent()
                }
            }
        }
        importOperationQueue.addOperation(op)
    }

    private func configureCrashlytics() {
        Fabric.with([Crashlytics.self])
    }

    private func configureAmplitudeSDK() {
        #if DEBUG
            Amplitude.instance().initializeApiKey("00d4356f153e0d7ccdac41869b9199bf")
        #else
            Amplitude.instance().initializeApiKey("460ce79c6ad144a4f4ffa5549bebd674")
        #endif

        let defaults = NSUserDefaults.standardUserDefaults()
        if let userId = defaults.objectForKey("userId") as? String {
            Amplitude.instance().setUserId(userId)
        } else {
            let userId = NSUUID().UUIDString
            defaults.setObject(userId, forKey: "userId")
            defaults.synchronize()
            Amplitude.instance().setUserId(userId)
        }

        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().enableLocationListening()
    }

    private func hasImportedData() -> Bool {
        let req = Food.entityFetchRequest()
        req.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]
        let ctx = CoreDataStack.shared.managedObjectContext
        var err: NSError?
        let count = ctx.countForFetchRequest(req, error: &err)
        return count > 0
    }
}
