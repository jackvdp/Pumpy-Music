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

class MusicManager: ObservableObject {
    let musicPlayerController = MPMusicPlayerController.applicationQueuePlayer
    let tokenManager = TokenManager()
    let spotifyTokenManager = SpotifyTokenManager()
    let nowPlayingManager: NowPlayingManager
    let playlistManager: PlaylistManager
    let queueManager: QueueManager
    let crossfadeManager: CrossfadeManager
    let blockedTracksManager: BlockedTracksManager
    let settingsManager: SettingsManager
    let username: String
    
    init(username: String, settingsManager: SettingsManager) {
        self.username = username
        self.settingsManager = settingsManager
        nowPlayingManager = NowPlayingManager(spotifyTokenManager: spotifyTokenManager)
        crossfadeManager = CrossfadeManager(settingsManager: settingsManager)
        queueManager = QueueManager(name: username)
        blockedTracksManager = BlockedTracksManager(username: username, queueManager: queueManager)
        playlistManager = PlaylistManager(blockedTracksManager: blockedTracksManager, settingsManager: settingsManager, tokenManager: tokenManager)
        setUpNotifications()
    }
    
    deinit {
        endNotifications()
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
    }
    
    // MARK: - Respond to Notifications
    
    @objc func handleMusicPlayerManagerDidUpdateState(_ notification: Notification) {
        nowPlayingManager.updateTrackData(tokenManager: tokenManager)
        queueManager.getIndex()
        nowPlayingManager.updateTrackOnline(for: username, playlist: playlistManager.playlistLabel)
        crossfadeManager.checkTimer()
    }
    
    @objc func handleQueueDidUpdateState(_ notification: Notification) {
        queueManager.getUpNext()
    }
    
    @objc func handleLibraryDidChangeState(_ notification: Notification) {
        PlaybackData.savePlaylistsOnline(for: username)
    }
    
}


