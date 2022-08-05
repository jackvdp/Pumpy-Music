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

//struct Playlist: ScheduledPlaylist {
//
//    init(item: MPMediaPlaylist) {
//        name = item.name
//        items = item.items.map { i in
//            let timer = ParkBenchTimer()
//
//            let values: Set = [MPMediaItemPropertyTitle,
//                               MPMediaItemPropertyArtist,
//                               MPMediaItemPropertyArtwork,
//                               MPMediaItemPropertyPlaybackStoreID,
//                               MPMediaItemPropertyIsExplicit]
//
//            var allProperties: [String: Any] = [:]
//            i.enumerateValues(forProperties: values, using: {key,value,_ in allProperties[key] = value})
//
//            let t = Track(title: allProperties[MPMediaItemPropertyTitle] as? String ?? "N/A",
//                  artist: allProperties[MPMediaItemPropertyArtist] as? String ?? "N/A",
//                  artwork: nil, //allProperties[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork,
//                  playbackID: allProperties[MPMediaItemPropertyPlaybackStoreID] as? String ?? "N/A",
//                  isExplicit: allProperties[MPMediaItemPropertyIsExplicit] as? Bool ?? false)
//
////            let t = Track(title: i.title ?? "N/A",
////                         artist: i.artist ?? "N/A",
////                          artwork: i.artwork,
////                         playbackID: i.playbackStoreID,
////                         isExplicit: i.isExplicitItem)
//
//            timer.stop()
//            return t
//        }
//        artwork = item.representativeItem?.artwork
//        cloudID = item.cloudGlobalID
//    }
//
//    var name: String?
//    var items: [Track]
//    var artwork: MPMediaItemArtwork?
//    var cloudID: String?
//    var id = UUID()
//
//}

//extension MPMediaPlaylist: ScheduledPlaylist {}
//
//struct Track: Hashable {
//    var title: String
//    var artist: String
//    var artwork: MPMediaItemArtwork?
//    var playbackID: String
//    var isExplicit: Bool
//    var features: AudioFeatures?
//    var id = UUID()
//}
//
//extension Track {
//    init(track: MPMediaItem) {
//        title = track.title ?? "N/A"
//        artist = track.artist ?? "N/A"
//        playbackID = track.playbackStoreID
//        isExplicit = track.isExplicitItem
//        artwork = track.artwork
//    }
//
//    func getBlockedTrack() -> BlockedTrack {
//        return BlockedTrack(title: self.title,
//                            artist: self.artist,
//                            isExplicit: self.isExplicit,
//                            playbackID: self.playbackID)
//    }
//}

struct BlockedTrack: Codable, Hashable {
    var title: String?
    var artist: String?
    var isExplicit: Bool?
    var playbackID: String
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
