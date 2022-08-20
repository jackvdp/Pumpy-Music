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
import PumpyLibrary
import UIKit

class RemoteManager: ObservableObject {
    
    let db = Firestore.firestore()
    var remoteListener: ListenerRegistration?
    let username: String
    let musicManager: MusicManager
    let alarmManager: AlarmData
    let debouncer = Debouncer()
    
    init(username: String, musicManager: MusicManager, alarmManager: AlarmData) {
        self.username = username
        self.musicManager = musicManager
        self.alarmManager = alarmManager
        recieveRemoteCommands()
    }
    
    deinit {
        DeinitCounter.count += 1
    }
    
    func recieveRemoteCommands() {
        remoteListener = FireMethods.listen(db: db,
                                            name: username,
                                            documentName: K.FStore.remoteData,
                                            dataFieldName: K.FStore.remoteData,
                                            decodeObject: RemoteInfo.self) { remoteInfoDecoded in
            
            self.respondToRemoteInfo(remoteInfoDecoded)
        }
    }
    
    func removeListener() {
        remoteListener?.remove()
    }
    
    func respondToRemoteInfo(_ remoteInfo: RemoteInfo) {
        guard abs(remoteInfo.updateTime.timeIntervalSinceNow) < 5 else {
            resetRemoteInfo()
            return
        }
        
        debouncer.handler = {
            if let command = remoteInfo.remoteCommand {
                self.actOnRemoteCommand(command)
            }
            self.resetRemoteInfo()
        }
    }
    
    private func actOnRemoteCommand(_ remoteData: RemoteEnum) {
        
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
            musicManager.playlistManager.playPlaylistNext(playlist: playlist)
        case .scheduledPlaylistFromServer(let playlist):
            if UIApplication.shared.applicationState != .active {
                musicManager.playlistManager.playPlaylistNext(playlist: playlist)
            } else {
                print("Ignored")
            }
        case .getLibraryPlaylists:
            PlaybackData.savePlaylistsOnline(for: username)
        case .getTracksFromPlaylist(let playlist):
            PlaybackData.saveTracksOnline(playlist: playlist, for: username)
        case .removeTrackFromQueue(let id):
            musicManager.queueManager.removeFromQueue(id: id)
        case .addToQueue(let queueIDs):
            print(queueIDs)
        case .activeInfo:
            ActiveInfo.save(.loggedIn, for: username)
        case .increaseEnergy:
            print("Increase energy")
        case .decreaseEnergy:
            print("Decrease energy")
        }
    }
    
    private func resetRemoteInfo() {
        FireMethods.save(object: RemoteInfo(),
                         name: username,
                         documentName: K.FStore.remoteData,
                         dataFieldName: K.FStore.remoteData)
    }
    
}
