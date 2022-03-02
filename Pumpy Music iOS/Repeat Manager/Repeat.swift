//
//  Repeat.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 17/08/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer

class RepeatTrack {
    
    let musicManager: MusicManager
    let audioPlayer = AudioPlayer()
    let volume: Float
    var volumeSetting: Float
    
    init(musicManager: MusicManager) {
        self.musicManager = musicManager
        self.volume = MPVolumeView.getVolume()
        self.volumeSetting = self.volume
        playRepeatTrack()
    }
    
    var changeRepeatTrackTimer: Timer?
    var startRepeatTrackTimer: Timer?
    var endRepeatTrackTimer: Timer?
    
    // MARK: - Repeat Track
    
    func playRepeatTrack() {
        if musicManager.musicPlayerController.playbackState == .playing {
            print("REPEATING")
            if !(changeRepeatTrackTimer?.isValid ?? false) {
                changeRepeatTrackTimer = Timer.scheduledTimer(timeInterval: 1,
                                                              target: self,
                                                              selector: #selector(self.waitToPlayRepeatTrack),
                                                              userInfo: nil,
                                                              repeats: true)
            }
        }
    }
    
    @objc func waitToPlayRepeatTrack() {
        if let item = musicManager.user?.repeatManager.repeatItem {
            if item.enabled {
                if musicManager.musicPlayerController.playbackState == .playing {
                    let playbackTime = musicManager.musicPlayerController.currentPlaybackTime
                    let playbackDuration = musicManager.musicPlayerController.nowPlayingItem?.playbackDuration ?? 0
                    
                    if (playbackDuration - playbackTime) < 20 {
                        let savedURLS = RepeatManager.getAudioFiles()
                        if let unwrappedURL = item.audio {
                            if let file = savedURLS.first(where: { $0.lastPathComponent == unwrappedURL }) {
                                if !(startRepeatTrackTimer?.isValid ?? false) {
                                    startRepeatTrackTimer = Timer.scheduledTimer(timeInterval: 0.25,
                                                                                 target: self,
                                                                                 selector: #selector(self.startRepeat),
                                                                                 userInfo: file,
                                                                                 repeats: true)
                                }
                            } else {
                                print(savedURLS)
                                print(unwrappedURL)
                            }
                        }
                        changeRepeatTrackTimer?.invalidate()
                    } else {
                        print("Waiting to start repeat")
                    }
                } else {
                    // Not playing. Cancel repeat
                    changeRepeatTrackTimer?.invalidate()
                }
            } else {
                // Repeat Not Enabled. Cancel repeat
                changeRepeatTrackTimer?.invalidate()
            }
        } else {
            // Repeat item not available. Cancel repeat
            changeRepeatTrackTimer?.invalidate()
        }
    }
    
    @objc func startRepeat() {
        if volumeSetting > 0.3 {
            volumeSetting -= 0.05
            MPVolumeView.setVolume(volumeSetting)
        } else {
            if let file = startRepeatTrackTimer?.userInfo as? URL {
                audioPlayer.playSoundsFromURL(url: file)
                endRepeatTrackTimer = Timer.scheduledTimer(timeInterval: 0.25,
                                                           target: self,
                                                           selector: #selector(endRepeat),
                                                           userInfo: nil,
                                                           repeats: true)
            }
            startRepeatTrackTimer?.invalidate()
            volumeSetting = volume
            MPVolumeView.setVolume(volumeSetting)
        }
        
    }
    
    @objc func endRepeat() {
        let duration = audioPlayer.audioPlayer?.duration ?? 0
        let currentTime = audioPlayer.audioPlayer?.currentTime ?? 0
        if duration - currentTime < 5 {
            if volumeSetting > 0.3 {
                volumeSetting -= 0.05
                MPVolumeView.setVolume(volumeSetting)
            } else {
                audioPlayer.audioPlayer?.stop()
                endRepeatTrackTimer?.invalidate()
                musicManager.musicPlayerController.skipToNextItem()
                MusicCoreFunctions.prepareToPlayAndPlay()
                volumeSetting = volume
                MPVolumeView.setVolume(volumeSetting)
            }
        } else {
            print("waiting to end")
        }
    }
    
}
