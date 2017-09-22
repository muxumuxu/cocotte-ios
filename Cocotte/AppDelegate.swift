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
import SafariServices

let contactEmail = "bonjour@cocotte-app.com"
let iTunesLink = "https://itunes.apple.com/us/app/cocotte/id1148406816?ls=1&mt=8"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        CoreDataStack.initializeWithMomd("Foodancy", sql: "Foodancy.sqlite")

        configureCrashlytics()

        downloadContent()

        customizeAppearance()

        Analytics.instance.setup()

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        askForPushNotifications()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataStack.shared.saveContext()
    }

    func customizeAppearance() {
        let nav = UINavigationBar.appearance()
        nav.shadowImage = UIImage()
        nav.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)

        let app = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        app.defaultTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: "8E8E93".UIColor
        ]
    
        let appearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        appearance.defaultTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: "2B2B2C".UIColor
        ]

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Analytics.instance.saveDeviceToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Analytics.instance.trackPushNotification(userInfo: userInfo)
        if let urlString = userInfo["url"] as? String, let url = URL(string: urlString) {
            let safari = SFSafariViewController(url: url)
            window?.rootViewController?.present(safari, animated: true)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Did failed to register for push notification: \(error)")
    }

    fileprivate let importOperationQueue = OperationQueue()

    fileprivate func downloadContent() {

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

    fileprivate func configureCrashlytics() {
        Fabric.with([Crashlytics.self])
    }

    fileprivate func hasImportedData() -> Bool {
        let req = NSFetchRequest<Food>(entityName: Food.entityName)
        req.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]
        let ctx = CoreDataStack.shared.managedObjectContext
        let count = (try? ctx.count(for: req)) ?? 0
        return count > 0
    }
    
    fileprivate func askForPushNotifications() {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
}
