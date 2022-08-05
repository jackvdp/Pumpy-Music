//
//  NotificationPush.swift
//  AlarmClone
//
//  Created by Jes Yang on 2019/10/26.
//  Copyright © 2019 Jes Yang. All rights reserved.
//

import Foundation
import UserNotifications
import PumpyLibrary

enum NotificationCategory: String {
    case AlarmNotification
}

class NotificationPush {
    
    let content = UNMutableNotificationContent()
    var identifier = ""
    var dateComponent = DateComponents()
    
    func scheduleNotification(alarm: Alarm) {
        
        content.title = "Playlist: \(alarm.playlistLabel)"
        content.body = "Playlist \(alarm.playlistLabel) to play now."
        content.categoryIdentifier = NotificationCategory.AlarmNotification.rawValue
        content.userInfo = setUserInfo(alarm: alarm)
        
        let hour = alarm.time.hour
        let min = alarm.time.min
        
        if alarm.repeatStatus.count == 0 {
            identifier = alarm.uuid
            dateComponent = DateComponents(calendar: Calendar.current, hour: hour, minute: min, second: 0)
            addScheduleNotification()
        } else {
            for day in alarm.repeatStatus {
                identifier = alarm.uuid + day.rawValue
                let weekday = day.index + 1
                dateComponent = DateComponents(calendar: Calendar.current,
                                                   hour: hour,
                                                   minute: min,
                                                   second: 0,
                                                   weekday: weekday)
                addScheduleNotification()
            }
        }
    }
    
    func addScheduleNotification() {
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Notificaion succeed.")
            }
        }
    }
    
    
    func deleteNotification(alarm: Alarm) {
        var identifiers = [String]()
        let content = UNUserNotificationCenter.current()
        if alarm.repeatStatus.count == 0 {
            identifiers.append(alarm.uuid)
        } else {
            
            for day in alarm.repeatStatus {
                identifiers.append(alarm.uuid + day.rawValue)
            }
        }
        content.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func setUserInfo(alarm: Alarm) -> [AnyHashable : Any] {
        var userInfo = [AnyHashable : Any]()
        
        userInfo.updateValue(alarm.playlistLabel, forKey: K.Alarm.playlistLabel)
        
        if let secondaryPlaylists = alarm.secondaryPlaylists {
            if let data = try? JSONEncoder().encode(secondaryPlaylists) {
                userInfo.updateValue(data, forKey: K.Alarm.secondaryAlarm)
            }
        }
        
        if let eso = alarm.externalSettingsOverride {
            userInfo.updateValue(eso, forKey: K.Alarm.externalSettingsOverride)
            if let sqrc = alarm.showQRCode {
                userInfo.updateValue(sqrc, forKey: K.Alarm.showQRCode)
            }
            if let content = alarm.contentType {
                userInfo.updateValue(content.rawValue, forKey: K.Alarm.contentType)
            }
            if let type = alarm.qrType {
                userInfo.updateValue(type.rawValue, forKey: K.Alarm.qrType)
                if type == .custom {
                    if let qrl = alarm.QRLink {
                        userInfo.updateValue(qrl, forKey: K.Alarm.qrLink)
                    }
                    if let qrm = alarm.QRMessage {
                        userInfo.updateValue(qrm, forKey: K.Alarm.qrMessage)
                    }
                    if let speed = alarm.messageSpeed {
                        userInfo.updateValue(speed, forKey: K.Alarm.messageSpeed)
                    }
                }
            }
        }
        
        return userInfo
    }
}
