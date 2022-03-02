//
//  Notifications.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 24/09/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import Firebase

extension AppDelegate  {

    // MARK: - Notification SetUp
    
    func notificationSetUp() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay], completionHandler: { (granted, error) in
            if granted {
                print("Allowed.")
            } else {
                print("Not allowed.")
            }
            guard granted else { return }
            self.getNotificationSettings()
        })
        UNUserNotificationCenter.current().delegate = self
    }
        
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("Firebase registration token: \(token)")
            let dataDict:[String: String] = ["token": token]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        }
    }
    
    
    // Remote Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for Remote Token. Error: \(error)")
    }
    
    // MARK: - Notification Manager
    
    // Local notificaitons
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Get notification at foreground...")
        
        let userInfo = notification.request.content.userInfo
        changePlaylist(userInfo)
        configureExtDisplay(userInfo)
        
        completionHandler([.sound, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Get notification at background...")
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier, UNNotificationDismissActionIdentifier:
            print("blah blah blah")
        default:
            break
            
        }
        
        let userInfo = response.notification.request.content.userInfo
        changePlaylist(userInfo)
        completionHandler()
    }
    
    // Remote notificaitons
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Tada")
        if let dataString = userInfo["action"] as? String {
            if let data = Data(base64Encoded: dataString) {
                let jsonDecoder = JSONDecoder()
                if let action = try? jsonDecoder.decode(RemoteInfo.self, from: data) {
                    if let command = action.remoteCommand {
                        accountManager.user?.remoteDataManager.respondToRemoteCommand(remoteData: command)
                    }
                }
            }
        }
        
        completionHandler(.newData)
    }
    
    
    // Respond to notificaitons
    
    func changePlaylist(_ userInfo: [AnyHashable : Any]) {
        if let musicManager = accountManager.user?.musicManager {
            if let playlist = userInfo[K.Alarm.playlistLabel] as? String {
                let secondaryPlaylistData = userInfo[K.Alarm.secondaryAlarm] as? Data
                let secondaryPlaylist = try? JSONDecoder().decode([SecondaryPlaylist].self, from: secondaryPlaylistData ?? Data())
                musicManager.playlistManager.playPlaylistNext(playlist: playlist, secondaryPlaylists: secondaryPlaylist ?? [])
            } else {
                print("Error decoding playlist alarm")
            }
        }
    }
    
    func configureExtDisplay(_ userInfo: [AnyHashable : Any]) {
        if let externalDisplayManager = accountManager.user?.externalDisplayManager {
            if let externalSettingsOverride = userInfo[K.Alarm.externalSettingsOverride] as? Bool, externalSettingsOverride {
                externalDisplayManager.extDisType = .override
                if let contentType = userInfo[K.Alarm.contentType] as? String {
                    if let type = ExtDisContentType.init(rawValue: contentType) {
                        externalDisplayManager.liveSettings.displayContent = type
                    }
                }
                if let showQRCode = userInfo[K.Alarm.showQRCode] as? Bool {
                    externalDisplayManager.liveSettings.showQRCode = showQRCode
                    if showQRCode {
                        if let qrType = userInfo[K.Alarm.qrType] as? String {
                            if let type = QRType.init(rawValue: qrType) {
                                externalDisplayManager.liveSettings.qrType = type
                                if type == .custom {
                                    if let qrLink = userInfo[K.Alarm.qrLink] as? String {
                                        externalDisplayManager.liveSettings.qrURL = qrLink
                                    }
                                    if let qrMessage = userInfo[K.Alarm.qrMessage] as? String {
                                        externalDisplayManager.liveSettings.marqueeTextLabel = qrMessage
                                    }
                                    if let speed = userInfo[K.Alarm.messageSpeed] as? Double {
                                        externalDisplayManager.liveSettings.marqueeLabelSpeed = speed
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                externalDisplayManager.extDisType = .defualts
                externalDisplayManager.updateLiveSettings()
            }
        }
    }
    
}
