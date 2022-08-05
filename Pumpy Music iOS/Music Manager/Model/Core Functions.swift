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
import Scheduler

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
    
    static func getMostRecentPlaylist(alarms: [Alarm]) -> Alarm? {
        let tempCheckAlarms = alarms
        var tempCheckedAlarms: [Alarm] = []
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentMinute = Calendar.current.component(.minute, from: Date())
        
        //Check it's the right day and before the current hour.
        for tempCheckAlarm in tempCheckAlarms {
            if (tempCheckAlarm.repeatStatus == [] || tempCheckAlarm.repeatStatus.contains(DetailInfo.getCurrentDayFormatted())) && ((tempCheckAlarm.time.hour < currentHour && 6 <= tempCheckAlarm.time.hour) || (tempCheckAlarm.time.hour == currentHour && tempCheckAlarm.time.min < currentMinute)) {
                tempCheckedAlarms.append(tempCheckAlarm)
            }
        }
        //Check nearest alarm time and then play
        if !tempCheckedAlarms.isEmpty {
            tempCheckedAlarms.sort {
                if $0.time.date.hour < 6, $1.time.date.hour >= 6 { return false }
                if $1.time.date.hour < 6, $0.time.date.hour >= 6 { return true }
                return ($0.time.date.hour, $0.time.date.minute) < ($1.time.date.hour, $1.time.date.minute)
            }
            return tempCheckedAlarms.last
        } else {
            // return the first playlist
            if !tempCheckAlarms.isEmpty {
                return tempCheckAlarms[0]
            } else {
                return nil
            }
        }
    }
    
}

