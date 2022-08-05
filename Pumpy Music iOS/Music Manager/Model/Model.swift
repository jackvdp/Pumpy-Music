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
import Scheduler

protocol Track {
    var title: String? { get }
    var artist: String? { get }
    var artwork: MPMediaItemArtwork? { get }
    var playbackStoreID: String { get }
    var isExplicitItem: Bool { get }
    
    func getBlockedTrack() -> BlockedTrack
}

extension MPMediaItem: Track {
    func getBlockedTrack() -> BlockedTrack {
        return BlockedTrack(title: self.title,
                            artist: self.artist,
                            isExplicit: self.isExplicitItem,
                            playbackID: self.playbackStoreID)
    }
}

protocol Playlist {
    var name: String? { get }
    var items: [MPMediaItem] { get }
    var cloudGlobalID: String? { get }
    var representativeItem: MPMediaItem? { get }
}

extension MPMediaPlaylist: Playlist, ScheduledPlaylist {}

struct BlockedTrack: Codable, Hashable {
    var title: String?
    var artist: String?
    var isExplicit: Bool?
    var playbackID: String
}

struct PreviewTrack: Track {
    var title: String?
    var artist: String?
    var artwork: MPMediaItemArtwork?
    var playbackStoreID: String
    var isExplicitItem: Bool
    
    func getBlockedTrack() -> BlockedTrack {
        return BlockedTrack(title: self.title,
                            artist: self.artist,
                            isExplicit: self.isExplicitItem,
                            playbackID: self.playbackStoreID)
    }
}

struct MockData {
    static let playlist = PreviewPlaylist(name: "Test", items: [], cloudGlobalID: "", representativeItem: nil)
    static let track = PreviewTrack(title: "Test", artist: "Test", artwork: nil, playbackStoreID: "", isExplicitItem: true)
}

struct PreviewPlaylist: Playlist {
    var name: String?
    var items: [MPMediaItem]
    var cloudGlobalID: String?
    var representativeItem: MPMediaItem?
}

extension MPMusicPlayerApplicationController {
    
    open override func prepend(_ descriptor: MPMusicPlayerQueueDescriptor) {
        super.prepend(descriptor)
        let nc = NotificationCenter.default
        nc.post(name: .MPMusicPlayerControllerQueueDidChange, object: MPMusicPlayerController.applicationQueuePlayer)
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

class ParkBenchTimer {
    let startTime: CFAbsoluteTime
    var endTime: CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        let d = endTime! - startTime
        print(d)
        
        return d
    }
    
    var duration: CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}
