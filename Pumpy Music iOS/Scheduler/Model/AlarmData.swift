//
//  AlarmData.swift
//  AlarmClone
//
//  Created by Jes Yang on 2019/10/24.
//  Copyright © 2019 Jes Yang. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class AlarmData: NSObject, ObservableObject {
    
    let username: String
    let db = Firestore.firestore()
    var alarmListener: ListenerRegistration?
    @Published var alarmArray = [Alarm]()
    
    init(username: String) {
        self.username = username
        super.init()
        addDefaultsObservers()
        loadOnlineData()
    }
    
    deinit {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func saveData(alarmArray: [Alarm]) {
        saveDataOnline(alarmArray: alarmArray)
        saveDataOffline(alarmArray: alarmArray)
    }
    
    func loadData() {
        self.alarmArray = AlarmData.loadAlarms()
    }
    
    static func loadAlarms() -> [Alarm] {
        guard let alarms = UserDefaults.standard.object(forKey: K.alarmsKey) as? Data else { return [] }

        guard let alarmArray = (try? PropertyListDecoder().decode([Alarm].self, from: alarms)) else {
            print("Load data error.")
            return []
        }
        
        return alarmArray
    }
    
    func loadOnlineData() {
        var alarmArray = [Alarm]()
        saveDataOffline(alarmArray: alarmArray)
        
        alarmListener = FireMethods.listen(db: db, name: username, documentName: K.FStore.alarmCollection, dataFieldName: K.FStore.alarmCollection, decodeObject: [Alarm].self) { alarms in
            alarmArray = alarms
            self.saveDataOffline(alarmArray: alarmArray)
        }
    }
    
    private func saveDataOnline(alarmArray: [Alarm]) {
        FireMethods.save(object: alarmArray,
                         name: username,
                         documentName: K.FStore.alarmCollection,
                         dataFieldName: K.FStore.alarmCollection)
    }
    
    private func saveDataOffline(alarmArray: [Alarm]) {
        do {
            let alarms = try PropertyListEncoder().encode(alarmArray)
            UserDefaults.standard.set(alarms, forKey: K.alarmsKey)
            print("Successfully Saved Alarms Offline")
        } catch {
            print("Save data error.")
        }
    }

    func addDefaultsObservers() {
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: K.alarmsKey,
                                          options: NSKeyValueObservingOptions.new,
                                          context: nil)
    }
    
    func removeObservers() {
        alarmListener?.remove()
        UserDefaults.standard.removeObserver(self, forKeyPath: K.alarmsKey)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == K.alarmsKey {
            loadData()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            for alarmToAdd in alarmArray {
                NotificationPush().scheduleNotification(alarm: alarmToAdd)
            }
        }
    }
}
