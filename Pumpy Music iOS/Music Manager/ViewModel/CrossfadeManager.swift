//
//  CrossfadeManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 13/08/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer
import SwiftUI

class CrossfadeManager {
    
    let musicPlayerController = MPMusicPlayerController.applicationQueuePlayer
    var crossfadeTimer: Timer?
    var crossfading: Crossfade?
    let settingsManager: SettingsManager
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        checkTimer()
        observeSettings()
    }
    
    deinit {
        print("deiniting")
        removeObserver()
    }
    
    func checkTimer() {
        if settingsManager.settings.crossfadeOn {
            setTimer()
        } else {
            turnTimerOff()
        }
    }
    
    func setTimer() {
        
        if let item = musicPlayerController.nowPlayingItem  {
            if musicPlayerController.playbackState == .playing {
                let trackTime = musicPlayerController.currentPlaybackTime
                let trackLength = item.playbackDuration
                let timeTillCrossfade = trackLength - trackTime - 15
                
                return crossfadeTimer = Timer.scheduledTimer(withTimeInterval: timeTillCrossfade, repeats: false) { timer in
                    self.crossfadeTracks()
                }
            }
        }
        
        turnTimerOff()
    }
    
    func turnTimerOff() {
        crossfadeTimer?.invalidate()
        crossfadeTimer = nil
    }
    
    func crossfadeTracks() {
        if musicPlayerController.playbackState == .playing {
            if let nowPlayingItem = musicPlayerController.nowPlayingItem {
                if (nowPlayingItem.playbackDuration - musicPlayerController.currentPlaybackTime) < 15 {
                    if crossfading == nil {
                        return crossfading = Crossfade() {
                            self.crossfading = nil
                        }
                    }
                }
            }
        }
        checkTimer()
    }
   
}


extension CrossfadeManager {
    func observeSettings() {
        NotificationCenter.default.addObserver(forName: Notification.Name.SettingsUpdate, object: nil, queue: OperationQueue.current) { notification in
            self.checkTimer()
        }
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SettingsUpdate, object: nil)
    }
}
