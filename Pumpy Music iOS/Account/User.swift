//
//  User.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 28/06/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase
import PumpyLibrary

class User: ObservableObject, UserProtocol {
    
    typealias M = MusicManager
    typealias P = PlaylistManager
    
    let username: String
    let remoteDataManager: RemoteManager
    let alarmData: AlarmData
    let settingsManager: SettingsManager
    let externalDisplayManager: ExternalDisplayManager<PlaylistManager>
    let musicManager: MusicManager
    
    init(username: String) {
        self.username = username
        settingsManager = SettingsManager(username: username)
        musicManager = MusicManager(username: username, settingsManager: settingsManager)
        alarmData = AlarmData(username: username)
        remoteDataManager = RemoteManager(username: username, musicManager: musicManager, alarmManager: alarmData)
        externalDisplayManager = ExternalDisplayManager(username: username, playlistManager: musicManager.playlistManager)
        PlaybackData.savePlaylistsOnline(for: username)
        ActiveInfo.save(.loggedIn, for: username)
        subscribeToTopic()
    }
    
    deinit {
        DeinitCounter.count += 1
    }
    
    func signOut() {
        firebaseSignOut()
        unsubscribeToTopic()
        ActiveInfo.save(.loggedOut, for: username)
        alarmData.removeObservers()
        remoteDataManager.removeListener()
        musicManager.blockedTracksManager.removeListener()
        musicManager.spotifyTokenManager.cancelTimer()
        musicManager.playlistManager.removeObservers()
        musicManager.endNotifications()
        settingsManager.removeSettingsListener()
        externalDisplayManager.removeSettingsListener()
    }
    
    func firebaseSignOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func subscribeToTopic() {
        let topic = username.lowercased().replacingOccurrences(of: "@", with: ".")
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let e = error {
                print("Error \(e)")
            } else {
                print("Subscribed to \(topic) topic and it's notifications")
            }
        }
    }
    
    func unsubscribeToTopic() {
        let topic = username.lowercased().replacingOccurrences(of: "@", with: ".")
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let e = error {
                print("Error \(e)")
            }
        }
    }
}

struct DeinitCounter {
    static var count = 0 {
        didSet {
            print("*****  " + count.description)
        }
    }
}
