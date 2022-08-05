//
//  RemoteDataManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 27/01/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase
import MediaPlayer
import Scheduler
import PumpyLibrary

class RemoteManager: ObservableObject {
    
    let db = Firestore.firestore()
    var remoteListener: ListenerRegistration?
    let username: String
    let musicManager: MusicManager
    let alarmManager: AlarmData
    
    init(username: String, musicManager: MusicManager, alarmManager: AlarmData) {
        self.username = username
        self.musicManager = musicManager
        self.alarmManager = alarmManager
        recieveRemoteCommands()
    }
    
    deinit {
        print("deiniting")
    }
    
    func recieveRemoteCommands() {
        remoteListener = FireMethods.listen(db: db, name: username, documentName: K.FStore.remoteData, dataFieldName: K.FStore.remoteData, decodeObject: RemoteInfo.self) { remoteInfoDecoded in
            if let rc = remoteInfoDecoded.remoteCommand {
                self.respondToRemoteCommand(remoteData: rc)
            }
        }
    }
    
    func removeListener() {
        remoteListener?.remove()
    }
    
    func respondToRemoteCommand(remoteData: RemoteEnum) {
        
        switch remoteData {
        case .playPause:
            MusicCoreFunctions.togglePlayPause(alarms: alarmManager.alarmArray, playlistManager: musicManager.playlistManager)

        case .skipTrack:
            MusicCoreFunctions.skipToNextItem()
            
        case .previousTrack:
            MusicCoreFunctions.skipBackToBeginningOrPreviousItem()
            
        case .playPlaylistNow(let playlist):
            musicManager.playlistManager.playPlaylistNow(playlist: playlist)
            
        case .playPlaylistNext(let playlist):
//            musicManager.playlistManager.prependPlaylist(playlist: playlist)
            print("Prepend")
        case .scheduledPlaylistFromServer(let playlist):
            if UIApplication.shared.applicationState != .active {
//                musicManager.playlistManager.prependPlaylist(playlist: playlist)
            } else {
                print("Ignored")
            }
            
        case .getLibraryPlaylists:
            PlaybackData.savePlaylistsOnline(for: username)
            
        case .getTracksFromPlaylist(let playlist):
            PlaybackData.saveTracksOnline(playlist: playlist, for: username)
            
        case .removeTrackFromQueue(let id):
            print("\(id) to remove from queue")
            
        case .addToQueue(let queueIDs):
            print(queueIDs)
            
        case .activeInfo:
            ActiveInfo.save(.loggedIn, for: username)
        }
        
        resetRemoteInfo()
    }
    
    func resetRemoteInfo() {
        FireMethods.save(object: RemoteInfo(), name: username, documentName: K.FStore.remoteData, dataFieldName: K.FStore.remoteData)
    }
    
}
