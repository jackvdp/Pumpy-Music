//
//  CurrentItemManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 13/08/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import UIKit
import MusicKit
import PumpyLibrary

class NowPlayingManager: NowPlayingProtocol {
    
    @Published var currentTrack: PumpyLibrary.Track?
    @Published var currentArtwork: UIImage? = nil
    @Published var playButtonState: PlayButton = .notPlaying
    @Published var currentAudioFeatures: AudioFeatures?
    let musicPlayerController = ApplicationMusicPlayer.shared
    let spotifyTokenManager: SpotifyTokenManager
    
    init(spotifyTokenManager: SpotifyTokenManager) {
        self.spotifyTokenManager = spotifyTokenManager
    }
    
    deinit {
        print("deiniting")
        DeinitCounter.count += 1
    }
    
    func updateTrackData(tokenManager: TokenManager) {
        if let nowPlayingItem = musicPlayerController.queue.currentEntry?.item {
            switch nowPlayingItem {
            case .song(let song):
                currentTrack = NowPlayingItem(title: song.title,
                                              artist: song.artistName,
                                              artwork: song.artwork,
                                              playbackStoreID: song.id.rawValue,
                                              isExplicitItem: song.contentRating == . explicit,
                                              isrc: song.isrc)
            case .musicVideo(let song):
                currentTrack = NowPlayingItem(title: song.title,
                                              artist: song.artistName,
                                              artwork: song.artwork,
                                              playbackStoreID: song.id.rawValue,
                                              isExplicitItem: song.contentRating == . explicit,
                                              isrc: song.isrc)
            @unknown default:
                print("Unknown")
            }
        } else {
            currentArtwork = nil
            currentTrack = nil
            currentAudioFeatures = nil
        }
        playButtonState = musicPlayerController.state.playbackStatus == .playing ? .playing : .notPlaying
        
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

struct NowPlayingItem: PumpyLibrary.Track, Codable {
    var title: String?
    
    var artist: String?
    
    var artwork: MusicKit.Artwork?
    
    var playbackStoreID: String
    
    var isExplicitItem: Bool
    var isrc: String?
    func getBlockedTrack() -> BlockedTrack {
        BlockedTrack(title: title,
                     artist: artist,
                     isExplicit: isExplicitItem,
                     playbackID: playbackStoreID)
    }
    
    
}
