//
//  UpNextManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 19/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import MusicKit
import SwiftUI
import PumpyLibrary
import PumpyAnalytics

class MusicManager: ObservableObject, MusicProtocol {
    let musicPlayerController = ApplicationMusicPlayer.shared
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
        nowPlayingManager = NowPlayingManager()
        queueManager = QueueManager(name: username, authManager: authManager)
        blockedTracksManager = BlockedTracksManager(username: username, queueManager: queueManager)
        playlistManager = PlaylistManager(blockedTracksManager: blockedTracksManager,
                                          settingsManager: settingsManager,
                                          tokenManager: tokenManager,
                                          queueManager: queueManager)
        setUpNotifications()
    }
    
    deinit {
        endNotifications()
        DeinitCounter.count += 1
    }
    
    // MARK: - Setup Notifications
    
    func setUpNotifications() {
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
    }
    
    // MARK: - Respond to Notifications
    
    @objc func handleMusicPlayerManagerDidUpdateState(_ notification: Notification) {
        nowPlayingManager.updateTrackData()
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
