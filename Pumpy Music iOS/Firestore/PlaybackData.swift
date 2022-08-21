//
//  PlaybackData.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 16/01/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase
import MediaPlayer
import PumpyLibrary
import MusicKit

class PlaybackData {
    
    static func saveCurrentPlaybackInfo(_ playbackItem: PlaybackItem, for username: String) {
        FireMethods.save(object: playbackItem,
                         name: username,
                         documentName: K.FStore.currentPlayback,
                         dataFieldName: K.FStore.currentPlayback)
    }
    
    
    static func savePlaylistsOnline(for username: String) {
        let playlists = MusicContent.getPlaylists().map {
            PlaylistOnline(name: $0.name ?? "",
                           id: $0.cloudGlobalID ?? "")
        }
        FireMethods.save(object: playlists,
                         name: username,
                         documentName: K.FStore.playlistCollection,
                         dataFieldName: K.FStore.playlistCollection)
    }

    
    static func saveTracksOnline(playlist: String, for username: String) {
        let firebaseTracks = try! FirebaseEncoder().encode(MusicContent.getOnlineTracks(chosenPlaylist: playlist))

        FireMethods.save(dict: [
            K.FStore.trackCollection : firebaseTracks,
            K.FStore.playlistName : playlist
        ],
        name: username,
        documentName: K.FStore.trackCollection)
    }
    
    static func saveCurrentQueueOnline(items: [PumpyLibrary.Track], for username: String) {
        let tracks = items.map { TrackOnline(name: $0.name ?? "",
                                             artist: $0.artist ?? "",
                                             id: $0.playbackStoreID)}
        FireMethods.save(object: tracks,
                         name: username,
                         documentName: K.FStore.upNext,
                         dataFieldName: K.FStore.upNext)
    }
    
    static func updatePlaybackInfoOnline(for username: String, item: Song?, index: Int, playbackState: MusicKit.ApplicationMusicPlayer.PlaybackStatus, playlistLabel: String) {
        var currentTrack = "Not Playing"
        var currentArtist = "– – – –"
        var id = String()
        
        if let nowPlayingItem = item {
            currentArtist = nowPlayingItem.artist ?? ""
            currentTrack = nowPlayingItem.title
            id = nowPlayingItem.playbackStoreID
        }
        
        let playbackInfo = PlaybackItem(
            itemID: id,
            trackName: currentTrack,
            trackArtistName: currentArtist,
            playlistName: playlistLabel,
            playbackState: playbackState == .playing ? 0 : 1,
            versionNumber: K.versionNumber,
            queueIndex: index
        )
        
        saveCurrentPlaybackInfo(playbackInfo, for: username)
        
    }
    
}

