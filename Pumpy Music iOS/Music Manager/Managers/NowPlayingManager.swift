//
//  CurrentItemManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 13/08/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import MusicKit
import PumpyLibrary
import MediaPlayer
import Combine
import SwiftUI

class NowPlayingManager: NowPlayingProtocol {
    
    @Published var currentTrack: PumpyLibrary.Track?
    @Published var playButtonState: PlayButton = .notPlaying
    @Published var currentAudioFeatures: AudioFeatures?
    let musicPlayerController = ApplicationMusicPlayer.shared
    
    
    @ObservedObject private var queue = ApplicationMusicPlayer.shared.queue
    @ObservedObject private var state = ApplicationMusicPlayer.shared.state
    private var queueCancellable: AnyCancellable? = nil
    private var stateCancellable: AnyCancellable? = nil
    
    init() {
        queueCancellable = queue.objectWillChange.sink { [weak self] (_) in
            self?.updateTrackData()
            self?.objectWillChange.send()
        }
        stateCancellable = state.objectWillChange.sink { [weak self] () in
            self?.playButtonState = self?.musicPlayerController.state.playbackStatus == .playing ? .playing : .notPlaying
            self?.objectWillChange.send()
        }
    }
    
    deinit {
        print("deiniting")
        DeinitCounter.count += 1
    }
    
    func updateTrackData() {
        playButtonState = musicPlayerController.state.playbackStatus == .playing ? .playing : .notPlaying
        if let nowPlayingItem = musicPlayerController.queue.currentEntry?.item {
            switch nowPlayingItem {
            case .song(let song):
                currentTrack = song
                print(song.name)
                print(song.isrc)
                
                return
            default:
                print("Unknown")
            }
        }
        currentTrack = nil
        currentAudioFeatures = nil
    }
    
    func updateTrackOnline(for username: String, playlist: String) {
        var song: Song?
        if let item = musicPlayerController.queue.currentEntry?.item {
            switch item {
            case .song(let s):
                song = s
            default:
                song = nil
            }
        }
        
        var index = 0
        if let entry =  musicPlayerController.queue.currentEntry {
            index = musicPlayerController.queue.entries.firstIndex(of: entry) ?? 0
        }
        
        PlaybackData.updatePlaybackInfoOnline(for: username,
                                              item: song,
                                              index: index,
                                              playbackState: musicPlayerController.state.playbackStatus,
                                              playlistLabel: playlist)
    }
    
}
