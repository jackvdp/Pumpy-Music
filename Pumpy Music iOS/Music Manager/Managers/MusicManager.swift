//
//  UpNextManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 19/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer
import SwiftUI
import PumpyLibrary
import PumpyAnalytics

class MusicManager: ObservableObject, MusicProtocol {
    let musicPlayerController = MPMusicPlayerController.applicationQueuePlayer
    let tokenManager = TokenManager()
    let authManager = AuthorisationManager()
    let spotifyTokenManager = SpotifyTokenManager()
    let nowPlayingManager: NowPlayingManager
    let playlistManager: PlaylistManager
    let queueManager: QueueManager
    let blockedTracksManager: BlockedTracksManager
    let settingsManager: SettingsManager
    let username: String
    
    init(username: String, settingsManager: SettingsManager) {
        self.username = username
        self.settingsManager = settingsManager
        nowPlayingManager = NowPlayingManager(spotifyTokenManager: spotifyTokenManager)
        queueManager = QueueManager(name: username, authManager: authManager, controller: musicPlayerController)
        blockedTracksManager = BlockedTracksManager(username: username, queueManager: queueManager)
        playlistManager = PlaylistManager(blockedTracksManager: blockedTracksManager,
                                          settingsManager: settingsManager,
                                          tokenManager: tokenManager,
                                          queueManager: queueManager,
                                          controller: musicPlayerController)
        setUpNotifications()
    }
    
    deinit {
        endNotifications()
        DeinitCounter.count += 1
    }
    
    // MARK: - Setup Notifications
    
    func setUpNotifications() {
        musicPlayerController.beginGeneratingPlaybackNotifications()
        addMusicObserver(for: .MPMusicPlayerControllerNowPlayingItemDidChange,
                         action: #selector(handleMusicPlayerManagerDidUpdateState))
        addMusicObserver(for: .MPMusicPlayerControllerPlaybackStateDidChange,
                         action: #selector(handleMusicPlayerManagerDidUpdateState))
        addMusicObserver(for: .MPMusicPlayerControllerQueueDidChange,
                         action: #selector(handleQueueDidUpdateState))
        addMusicObserver(for: .MPMediaLibraryDidChange,
                         action: #selector(handleLibraryDidChangeState))
    }
    
    func endNotifications() {
        removeMusicObservers(for: [
            .MPMusicPlayerControllerNowPlayingItemDidChange,
            .MPMusicPlayerControllerPlaybackStateDidChange,
            .MPMusicPlayerControllerQueueDidChange,
            .MPMediaLibraryDidChange
        ])
        musicPlayerController.endGeneratingPlaybackNotifications()
    }
    
    // MARK: - Respond to Notifications
    
    @objc func handleMusicPlayerManagerDidUpdateState(_ notification: Notification) {
        nowPlayingManager.updateTrackData(tokenManager: tokenManager)
        queueManager.getIndex()
        nowPlayingManager.updateTrackOnline(for: username, playlist: playlistManager.playlistLabel)
    }
    
    @objc func handleQueueDidUpdateState(_ notification: Notification) {
        self.queueManager.getUpNext()
    }
    
    @objc func handleLibraryDidChangeState(_ notification: Notification) {
        PlaybackData.savePlaylistsOnline(for: username)
    }
    
}
