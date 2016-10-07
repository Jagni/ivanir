//
//  AppDelegate.swift
//  Ivanir
//
//  Created by Jagni Dasa Horta Bezerra on 8/22/16.
//  Copyright © 2016 Jagni. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if !UIApplication.shared.isRegisteredForRemoteNotifications{
            registerForPushNotifications(application)
        }
        // Override point for customization after application launch.
        // Use Firebase library to configure APIs
        FIRApp.configure()
        
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().isOpaque = true
        UITabBar.appearance().barTintColor = UIColor ( red: 0.9531, green: 0.9531, blue: 0.9531, alpha: 1.0 )
        UITabBar.appearance().tintColor = UIColor(red: 0.2733, green: 0.4861, blue: 0.896, alpha: 1.0)
        
        id = UserDefaults.standard.integer(forKey: "id")
        
        let today = Date()
        let calendar = Calendar.current
        let monthDay = (calendar as NSCalendar).components(NSCalendar.Unit.day, from: today)
        
        if id != monthDay.day{
            UserDefaults.standard.set(nil, forKey: "croppedPhoto")
            UserDefaults.standard.set(nil, forKey: "photo")
            UserDefaults.standard.set(false, forKey: "hasRecordedAudio")
            UserDefaults.standard.set(false, forKey: "hasRevealed")
            UserDefaults.standard.synchronize()
        }
            
        else{
            if UserDefaults.standard.bool(forKey: "revealed"){
                self.window = UIWindow(frame: UIScreen.main.bounds)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "RevealedVC")
                
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
        return true
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            types: [UIUserNotificationType.badge, UIUserNotificationType.sound, UIUserNotificationType.alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
        print("Device Token:", tokenString)
    }
    
    
}

