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

struct Playlist {
    var item: MPMediaPlaylist
    var id = UUID()
}

struct Track: Hashable {
    var title: String
    var artist: String
    var artwork: MPMediaItemArtwork?
    var playbackID: String
    var isExplicit: Bool
    var features: AudioFeatures?
    var id = UUID()
}

extension Track {
    init(track: MPMediaItem) {
        title = track.title ?? "N/A"
        artist = track.artist ?? "N/A"
        playbackID = track.playbackStoreID
        isExplicit = track.isExplicitItem
        artwork = track.artwork
    }
}

extension MPMusicPlayerApplicationController {

    open override func prepend(_ descriptor: MPMusicPlayerQueueDescriptor) {
        super.prepend(descriptor)
        let nc = NotificationCenter.default
        nc.post(name: .MPMusicPlayerControllerQueueDidChange, object: MPMusicPlayerController.applicationQueuePlayer)
    }
}


private struct MusicStoreKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private struct MusicStoreFrontKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var musicStoreKey: String? {
        get { self[MusicStoreKey.self] }
        set { self[MusicStoreKey.self] = newValue }
    }
    var musicStoreFrontKey: String? {
        get { self[MusicStoreFrontKey.self] }
        set { self[MusicStoreFrontKey.self] = newValue }
    }
}


extension MusicManager {
    func addMusicObserver(for notificatioName: NSNotification.Name, action: Selector) {
        NotificationCenter.default.addObserver(self,
                                               selector: action,
                                               name: notificatioName,
                                               object: musicPlayerController)
    }
    func removeMusicObserver(for notificatioName: NSNotification.Name) {
        NotificationCenter.default.removeObserver(self,
                                                  name: notificatioName,
                                                  object: musicPlayerController)
    }
    
    func removeMusicObservers(for notificationsName: [NSNotification.Name]) {
        for notificatioName in notificationsName {
            removeMusicObserver(for: notificatioName)
        }
    }
}


enum PlayButton: String {
    case playing = "Pause"
    case notPlaying = "Play"
}
