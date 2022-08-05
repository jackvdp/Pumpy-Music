//
//  MusicStoreSong.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 24/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation

struct MusicStoreItem: Hashable {
    var id: String
    var name: String
    var artistName: String
    var artworkURL: String
    var isExplicit: Bool
    var type: MusicStoreType
    
    var collectiveString: String {
        switch type {
        case .playlist:
            return "playlists"
        case .album:
            return "albums"
        case .station:
            return "stations"
        case .track:
            return "tracks"
        }
    }
}

struct MSCollection: Hashable {
    var title: String
    var objects: [MusicStoreItem]
}

struct MusicStoreResult {
    var songs: [MusicStoreItem]
    var playlists: [MusicStoreItem]
}

enum MusicStoreType: String, Codable {
    case playlist = "playlist"
    case track = "song"
    case album = "album"
    case station = "radioStation"
}

enum PlayType {
    case now
    case next
}


