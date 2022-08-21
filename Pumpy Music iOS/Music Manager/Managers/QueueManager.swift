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
    let controller = ApplicationMusicPlayer.shared
    let debouncer = Debouncer()
    let authManager: AuthorisationManager
    @Published var queueTracks = [PumpyLibrary.Track]()
    @Published var queueIndex = 0
    @Published var analysingEnergy = false
    
    init(name: String,
         authManager: AuthorisationManager) {
        username = name
        self.authManager = authManager
    }
    
    deinit {
        DeinitCounter.count += 1
    }
    
    func addPlaylistToQueue(queueDescriptor: MPMusicPlayerMediaItemQueueDescriptor) {
        let items = queueDescriptor.itemCollection.items
        Task {
            try await controller.queue.insert(items, position: .afterCurrentEntry)
            getUpNext()
        }
    }
    
    func getUpNext() {
        queueTracks = controller.queue.entries.compactMap {
            let item = $0.item
            switch item {
            case .song(let s): return s
            default: return nil
            }
        }
        getIndex()
    }
    
    func getIndex() {
        guard let currentEntry = controller.queue.currentEntry else {
            queueIndex = 0
            return
        }
        queueIndex = controller.queue.entries.firstIndex(of: currentEntry) ?? 0
    }
    
    func removeFromQueue(id: String) {
        
    }
    

    func saveNewQueue(_ items: [MPMediaItem]) {
        PlaybackData.saveCurrentQueueOnline(items: queueTracks, for: self.username)
    }
    
}
