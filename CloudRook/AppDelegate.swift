//
//  AppDelegate.swift
//  CloudRook
//
//  Created by Brad Caldwell on 12/13/16.
//  Copyright © 2016 Caldwell Contracting LLC. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notificationData : [String:String]?
    var notificationAvailable:Bool?
    var ref: FIRDatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "bd3a791f-1577-4449-86c4-096a0317f00b", handleNotificationReceived: { (notification) in
            print("^Received Notification - \(notification?.payload.notificationID)")
        },  handleNotificationAction: { (result) in
            let payload: OSNotificationPayload? = result?.notification.payload
            
            var fullMessage: String? = payload?.body
            if payload?.additionalData != nil {
                var additionalData: [AnyHashable: Any]? = payload?.additionalData
                if additionalData!["actionSelected"] != nil {
                    //fullMessage = fullMessage! + "\nPressed ButtonId:\(additionalData!["actionSelected"])"
                    
                }
            }
            (self.window?.rootViewController as! UITabBarController).selectedIndex = 0
            
            let gameId = result!.notification.payload.additionalData["gameId"]!
            let playerOne = result!.notification.payload.additionalData["playerOne"]!
            let playerTwo = result!.notification.payload.additionalData["playerTwo"]!
            let playerThree = result!.notification.payload.additionalData["playerThree"]!
            let playerFour = result!.notification.payload.additionalData["playerFour"]!
            let senderName = result!.notification.payload.additionalData["senderName"]!

            
            self.notificationData = [:]
            self.notificationData?["gameId"] = gameId as? String
            self.notificationData?["playerOne"] = playerOne as? String
            self.notificationData?["playerTwo"] = playerTwo as? String
            self.notificationData?["playerThree"] = playerThree as? String
            self.notificationData?["playerFour"] = playerFour as? String
            self.notificationData?["senderName"] = senderName as? String

            
            let gameInvitationReceived  =   Notification.Name("gameInvitationReceived")
            NotificationCenter.default.post(name: gameInvitationReceived, object: nil)
            self.notificationAvailable =  true


        }, settings: [kOSSettingsKeyAutoPrompt : true ,
                      kOSSettingsKeyInFocusDisplayOption:false])

        
        
        application.isStatusBarHidden = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//        let user = FIRAuth.auth()?.currentUser?.uid
//        if(user != nil){
//            DataService.ds.ref.child("users").child(user! + "/connected").setValue(false)
//        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        let user = FIRAuth.auth()?.currentUser?.uid
//        if(user != nil){
//            DataService.ds.ref.child("users").child(user! + "/connected").setValue(false)
//        }

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
//        let user = FIRAuth.auth()?.currentUser?.uid
//        if(user != nil){
//            DataService.ds.ref.child("users").child(user! + "/connected").setValue(true)
//        }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled || GIDSignIn.sharedInstance().handle(
            url,
            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
            annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }

    // MARK: - Core Data stack

//    lazy var persistentContainer: NSPersistentContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentContainer(name: "CloudRook")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                 
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
//
//    // MARK: - Core Data Saving support
//
//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
    
    
    

    

}

