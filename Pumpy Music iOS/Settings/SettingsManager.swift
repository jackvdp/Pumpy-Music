//
//  SettingsVM.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 03/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class SettingsManager: ObservableObject {
    
    let username: String
    var settingsListener: ListenerRegistration?
    @Published var settings = SettingsModel() {
        didSet {
            saveSettings(settings: settings)
            postSettings()
        }
    }
    
    init(username: String) {
        self.username = username
        downloadSettings()
    }
    
    deinit {
        print("deiniting")
    }
    
    func downloadSettings() {
        let db = Firestore.firestore()
        settingsListener = FireMethods.listen(db: db, name: username, documentName: K.FStore.settings, dataFieldName: K.FStore.settings, decodeObject: SettingsModel.self) { settings in
            self.settings = settings
        }
    }
    
    func removeSettingsListener() {
        settingsListener?.remove()
    }
    
    func saveSettings(settings: SettingsModel) {
        FireMethods.save(object: settings, name: username, documentName: K.FStore.settings, dataFieldName: K.FStore.settings)
    }
    
    func postSettings() {
        NotificationCenter.default.post(name: Notification.Name.SettingsUpdate, object: nil)
    }
    
}
