//
//  MusicArrays.swift
//  PlaylistPicker
//
//  Created by Jack Vanderpump on 01/12/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation
import PumpyLibrary

class MusicCoreFunctions {
    
    static let musicPlayerController = MPMusicPlayerController.applicationQueuePlayer
    
    static func togglePlayPause(alarms: [Alarm], playlistManager: PlaylistManager) {
        if musicPlayerController.playbackState == .playing {
            musicPlayerController.pause()
        } else if musicPlayerController.playbackState == .paused {
            prepareToPlayAndPlay()
        } else {
            coldStart(alarms: alarms, playlistManager: playlistManager)
        }
    }
    
    static func skipToNextItem() {
        musicPlayerController.skipToNextItem()
    }
    
    static func skipBackToBeginningOrPreviousItem() {
        if musicPlayerController.currentPlaybackTime < 5 {
            musicPlayerController.skipToPreviousItem()
        } else {
            musicPlayerController.skipToBeginning()
        }
    }
    
    static func coldStart(alarms: [Alarm], playlistManager: PlaylistManager) {
        if let playlist = getMostRecentPlaylist(alarms: alarms) {
            playlistManager.playPlaylistNow(playlist: playlist.playlistLabel, secondaryPlaylists: playlist.secondaryPlaylists ?? [])
        } else {
            musicPlayerController.play()
        }
    }
    
    static func prepareToPlayAndPlay() {
        musicPlayerController.prepareToPlay { (error) in
            if let e = error {
                print(e)
            }
            self.musicPlayerController.play()
        }
    }
    
    static func playStoreItemsNow(_ items: [MusicStoreItem]) {
        let shuffledItems = items.shuffled()
        let shuffledIDs = shuffledItems.map { $0.id }
        musicPlayerController.setQueue(with: shuffledIDs)
        MusicCoreFunctions.prepareToPlayAndPlay()
    }
    
    static func playStoreItemsNext(_ items: [MusicStoreItem]) {
        if musicPlayerController.playbackState == .playing {
            let shuffledItems = items.shuffled()
            let shuffledIDs = shuffledItems.map { $0.id }
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: shuffledIDs)
            musicPlayerController.prepend(descriptor)
        } else {
            playStoreItemsNow(items)
        }
    }
    
    static func getNextPlaylist(alarms: [Alarm]) -> Alarm? {
        let currentDay = DetailInfo.getCurrentDayFormatted()
        let todaysAlarms = alarms.filter { $0.repeatStatus.isEmpty || $0.repeatStatus.contains(currentDay)}
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentMinute = Calendar.current.component(.minute, from: Date())
        
        var futureAlarms = todaysAlarms.filter { $0.time.hour >= currentHour }
        futureAlarms.removeAll(where: { $0.time.hour == currentHour && $0.time.min <= currentMinute})
        
        return futureAlarms.first
    }
    
    static func getMostRecentPlaylist(alarms: [Alarm]) -> Alarm? {
        let currentDay = DetailInfo.getCurrentDayFormatted()
        let todaysAlarms = alarms.filter { $0.repeatStatus.isEmpty || $0.repeatStatus.contains(currentDay)}
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentMinute = Calendar.current.component(.minute, from: Date())
        
        var pastAlarms = todaysAlarms.filter { $0.time.hour <= currentHour }
        pastAlarms.removeAll(where: { $0.time.hour == currentHour && $0.time.min > currentMinute })
        
        if currentHour >= 6 {
            pastAlarms.removeAll(where: { $0.time.hour < 6 })
        }
        
        return pastAlarms.last != nil ? pastAlarms.last : getNextPlaylist(alarms: alarms)
    }
    
}

