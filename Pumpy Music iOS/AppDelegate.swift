//
//  AppDelegate.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 17/09/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import UIKit
import MediaPlayer
import Foundation
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?
    let sharedMusicManager = MusicManager.sharedMusicManager
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        let db = Firestore.firestore()
        print(db)
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .dark
            window?.tintColor = UIColor.white
        } else {
            // Fallback on earlier versions
        }
        
        application.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay], completionHandler: { (granted, error) in
            if granted {
                print("Allowed.")
            } else {
                print("Not allowed.")
            }
        })
        
        // Add category
        let snoozeAction = UNNotificationAction(identifier: NotificationAction.Snooze.rawValue, title: NotificationAction.Snooze.rawValue, options: [])
        let dislikeAction = UNNotificationAction(identifier: NotificationAction.Stop.rawValue, title: NotificationAction.Stop.rawValue, options: [.destructive])
        
        let category = UNNotificationCategory(identifier: NotificationCategory.AlarmNotification.rawValue, actions: [snoozeAction, dislikeAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // Showing notification at foreground
        UNUserNotificationCenter.current().delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appSettingsDidChange),
                                       name: UserDefaults.didChangeNotification,
                                       object: nil)
        
        UIApplication.shared.registerForRemoteNotifications()
        
            return true
    }
    
    @objc func appSettingsDidChange() {
        let alarmArray = AlarmData.loadData()
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for alarmToAdd in alarmArray {
            NotificationPush().scheduleNotification(alarm: alarmToAdd)
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
           // Called when a new scene session is being created.
           // Use this method to select a configuration to create the new scene with.
           return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
       }

       func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
           // Called when the user discards a scene session.
           // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
           // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
       }
    
    
        // Get notification at foreground
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.sound, .alert])
            print("Get notification at foreground...")
            
            let playlistLabel = notification.request.content.userInfo["playlistLabel"]
            print(playlistLabel ?? "Nada")
            sharedMusicManager.playPlaylistNext(chosenPlaylist: playlistLabel as? String)
        
            
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

            center.getPendingNotificationRequests { (requests) in
                print(requests)
            }
            
            completionHandler()
        }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken
                    deviceToken: Data) {
    }

    func application(_ application: UIApplication,
                didFailToRegisterForRemoteNotificationsWithError
                    error: Error) {
       // Try again later.
    }
    
}



