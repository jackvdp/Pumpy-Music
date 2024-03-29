//
//  CurrentItemManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 13/08/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class NowPlayingManager: ObservableObject {
    
    @Published var currentTrack: Track?
    @Published var currentArtwork: UIImage? = nil
    @Published var playButtonState: PlayButton = .notPlaying
    @Published var currentAudioFeatures: AudioFeatures?
    let musicPlayerController = MPMusicPlayerController.applicationQueuePlayer
    let spotifyTokenManager: SpotifyTokenManager
    
    init(spotifyTokenManager: SpotifyTokenManager) {
        self.spotifyTokenManager = spotifyTokenManager
    }
    
    deinit {
        print("deiniting")
    }
    
    func updateTrackData(tokenManager: TokenManager) {
        if let nowPlayingItem = musicPlayerController.nowPlayingItem {
            Artwork(token: tokenManager.appleMusicToken, store: tokenManager.appleMusicStoreFront)
                .getArtwork(from: Track(track: nowPlayingItem), size: 500) { image in
                DispatchQueue.main.async {
                    self.currentArtwork = image
                }
            }
            currentTrack = Track(track: nowPlayingItem)

            if let token = spotifyTokenManager.spotifyToken {
                SpotifyAPI(spotifyToken: token).getAudioFeaturesofTrack(id: nowPlayingItem.playbackStoreID) { features in
                    DispatchQueue.main.async {
                        self.currentAudioFeatures = features
                    }
                }
            }
        } else {
            currentArtwork = nil
            currentTrack = nil
            currentAudioFeatures = nil
        }
        playButtonState = musicPlayerController.playbackState == .playing ? .playing : .notPlaying
        
    }
    
    func updateTrackOnline(for username: String, playlist: String) {
        PlaybackData.updatePlaybackInfoOnline(for: username,
                                              item: musicPlayerController.nowPlayingItem,
                                              index: musicPlayerController.indexOfNowPlayingItem,
                                              playbackState: musicPlayerController.playbackState.rawValue,
                                              playlistLabel: playlist)
    }
    
}
