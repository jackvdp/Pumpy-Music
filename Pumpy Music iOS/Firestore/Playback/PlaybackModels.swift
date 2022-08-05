//
//  PlaybackModels.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 17/05/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import PumpyLibrary

struct PlaybackItem: Codable {
    var itemID: String
    var trackName: String
    var trackArtistName: String
    var playlistName: String
    var playbackState: Int
    var updateTime = Date.getCurrentTime()
    var versionNumber: String
    var queueIndex: Int
}

struct TrackOnline: Hashable, Codable {
    var name: String
    var artist: String
    var id: String
}

struct TrackToDownload: Codable {
    var trackToDownload: URL?
}


struct PlaylistOnline: Codable {    
    var name: String
    var id: String
}
