//
//  Queue + Energy.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/08/2022.
//  Copyright © 2022 Jack Vanderpump. All rights reserved.
//

import Foundation
import PumpyAnalytics
import MusicKit
import MediaPlayer

extension QueueManager {
    
    func increaseEnergy() {
        analyseQueue() { [weak self] tracks in
            guard let self = self else { return }
            let (mostEnergy, _) = self.sortTracksByEnergy(tracks: tracks)
            let items = self.matchTracksToQueueItems(tracks: mostEnergy)
            self.setItemsToQueue(items)
        }
    }
    
    func decreaseEnergy() {
        analyseQueue() { [weak self] tracks in
            guard let self = self else { return }
            let (_, leastEnergy) = self.sortTracksByEnergy(tracks: tracks)
            let items = self.matchTracksToQueueItems(tracks: leastEnergy)
            self.setItemsToQueue(items)
        }
    }
    
    
    private func analyseQueue(completion: @escaping ([PumpyAnalytics.Track])->()) {
        let tracks = createTracksFromQueue()
        AnalyseController().analyseTracks(tracks: tracks,
                                          authManager: authManager,
                                          completion: completion)
    }
    
    private func matchTracksToQueueItems(tracks: [PumpyAnalytics.Track]) -> [MPMediaItem] {
        return (queueTracks as! [MPMediaItem]).filter { item in
            tracks.contains(where: { track in
                track.sourceID == item.playbackStoreID
            })
        }
    }
    
    private func setItemsToQueue(_ items: [MPMediaItem]) {
        let itemCollection = MPMediaItemCollection(items: items)
        let queueDescriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: itemCollection)
        addPlaylistToQueue(queueDescriptor: queueDescriptor)
        
    }
    
    private func createTracksFromQueue() -> [PumpyAnalytics.Track] {
        return []
    }
    
    private func sortTracksByEnergy(tracks: [PumpyAnalytics.Track]) -> (mostEnergyIDs: [PumpyAnalytics.Track], leastEnergyIDs: [PumpyAnalytics.Track]) {
        let analysedTracks = tracks.filter { $0.audioFeatures != nil }
        let sortedTracks = analysedTracks.sorted(by: {
            $0.audioFeatures?.energy ?? 0 > $1.audioFeatures?.energy ?? 0
        })
        let pair = sortedTracks.split(into: 2)
        return (mostEnergyIDs: pair.first ?? [], leastEnergyIDs: pair.last ?? [])
    }
}
