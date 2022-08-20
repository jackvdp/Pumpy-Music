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

extension MPMediaItem: Track {
    public func getBlockedTrack() -> BlockedTrack {
        return BlockedTrack(title: self.title,
                            artist: self.artist,
                            isExplicit: self.isExplicitItem,
                            playbackID: self.playbackStoreID)
    }
}

extension MPMediaPlaylist: Playlist, ScheduledPlaylist {}

