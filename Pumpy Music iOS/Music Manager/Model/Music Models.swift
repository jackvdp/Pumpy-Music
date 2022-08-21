//
//  Model.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 22/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer
import SwiftUI
import PumpyLibrary
import MusicKit

extension MPMediaPlaylist: PumpyLibrary.Playlist, ScheduledPlaylist {}

extension MPMediaItem: PlayableMusicItem {
    public var playParameters: PlayParameters? {
        let data = "{\"id\": \"\(id)\",\"kind\": \"song\"}"
            .data(using: .utf8)!
        return try! JSONDecoder().decode(PlayParameters.self, from: data)
    }

    public var id: MusicItemID {
        MusicItemID(rawValue: playbackStoreID)
    }
}

extension MPMediaItem: PumpyLibrary.Track {
    public var name: String? {
        return title
    }
    
    public var musicKitArtwork: MusicKit.Artwork? {
        return nil
    }
    
    public var mpArtwork: MPMediaItemArtwork? {
        return artwork
    }
    
    public func getBlockedTrack() -> BlockedTrack {
        BlockedTrack(title: title,
                     artist: artist,
                     isExplicit: isExplicitItem,
                     playbackID: playbackStoreID)
    }
    
}
