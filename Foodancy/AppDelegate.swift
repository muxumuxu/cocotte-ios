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

let contactEmail = "foodancy@muxumuxu.com"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        CoreDataStack.initializeWithMomd("Foodancy", sql: "Foodancy.sqlite")

        let op = ImportOperation()
        op.completionBlock = {
            if let err = op.error {
                print("Error while importing data: \(err)")
            }
        }
        NSOperationQueue().addOperation(op)

        customizeAppearance()

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
}
