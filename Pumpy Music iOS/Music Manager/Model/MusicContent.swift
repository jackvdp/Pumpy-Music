//
//  Playlist.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 18/05/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer

class MusicContent {
    
    static func getPlaylists() -> [Playlist] {
        if let playlistsAndFolders = MPMediaQuery.playlists().collections {
            let playlists = playlistsAndFolders.filter { !($0.value(forProperty: "isFolder") as? Bool ?? false) }
            if let plists = playlists as? [MPMediaPlaylist] {
                return plists.map { Playlist(item: $0) }
            }
        }
        return []
    }
    
    static func getTracks(for playlist: MPMediaPlaylist) -> [Track] {
        let songs = playlist.items
        let tracks = songs.map { Track(track: $0) }
        return tracks.sorted { $0.artist < $1.artist }
    }
    
    static func getListOfPlaylistNames() -> [String] {
        if let playlistsAndFolders = MPMediaQuery.playlists().collections {
            let playlists = playlistsAndFolders.filter { !($0.value(forProperty: "isFolder") as? Bool ?? false) }
            return playlists.map { $0.value(forProperty: MPMediaPlaylistPropertyName)! as! String }
        }
        return []
    }
    
    static func getOnlineTracks(chosenPlaylist: String) -> [TrackOnline] {
        let playlists = MPMediaQuery.playlists().collections
        var trackArray: [TrackOnline] = []
        for playlist in playlists! {
            if (playlist.value(forProperty: MPMediaPlaylistPropertyName)as! String) == chosenPlaylist {
                let songs = playlist.items
                for song in songs {
                    if song.artwork != nil {
                        trackArray.append(TrackOnline(name: song.title ?? "",
                                                      artist:song.artist ?? "",
                                                      id: song.playbackStoreID
                        ))
                    }
                }
            }
        }
        let sortedTracks = trackArray.sorted(by: { $0.artist < $1.artist})
        return sortedTracks
    }
}
