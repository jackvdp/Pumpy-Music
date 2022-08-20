//
//  NewQueueManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 06/08/2022.
//  Copyright © 2022 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer
import PumpyLibrary
import PumpyAnalytics
import MusicKit

class QueueManager: QueueProtocol {
    
    var username: String
    let controller: MPMusicPlayerApplicationController
    let debouncer = Debouncer()
    let authManager: AuthorisationManager
    @Published var queueTracks = [PumpyLibrary.Track]()
    @Published var queueIndex = 0
    @Published var analysingEnergy = false
    
    init(name: String,
         authManager: AuthorisationManager,
         controller: MPMusicPlayerApplicationController = MPMusicPlayerController.applicationQueuePlayer) {
        username = name
        self.authManager = authManager
        self.controller = controller
    }
    
    deinit {
        DeinitCounter.count += 1
    }
    
    func addPlaylistToQueue(queueDescriptor: MPMusicPlayerMediaItemQueueDescriptor) {
        conductQueuePerform { queue in
            let oldQueue = queue.items
            for item in oldQueue {
                if item != self.controller.nowPlayingItem {
                    queue.remove(item)
                }
            }
        } completion: { queue, _ in
            self.controller.prepend(queueDescriptor)
        }
    }
    
    func getUpNext() {
        conductQueuePerform { _ in
            return
        } completion: { queue, _ in
            self.queueTracks = queue.items
            self.getIndex()
        }
    }
    
    func removeFromQueue(id: String) {
        conductQueuePerform { queue in
            let items = queue.items.filter { $0.playbackStoreID == id }
            for item in items {
                queue.remove(item)
            }
        } completion: { queue, _ in
            self.queueTracks = queue.items
            self.getIndex()
        }
        
    }
    
    private func conductQueuePerform(queueTransaction: @escaping (MPMusicPlayerControllerMutableQueue)->(),
                                     completion: @escaping (MPMusicPlayerControllerQueue, Error?)->()) {
        debouncer.handler = {
            self.controller.perform(queueTransaction: queueTransaction, completionHandler: completion)
        }
        
    }
    
    func saveNewQueue(_ items: [MPMediaItem]) {
        PlaybackData.saveCurrentQueueOnline(items: items, for: self.username)
    }
    
    func getIndex() {
        let index = controller.indexOfNowPlayingItem
        if index <= queueTracks.count {
            queueIndex = index
        }
    }
    
}
